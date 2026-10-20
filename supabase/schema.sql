-- Ayodhya Zameen: run in the Supabase SQL editor. Safe to re-run.
-- Works for a fresh project and for one that already ran the older single-user schema.
--
-- Model: a "workspace" (the family) owns the records. Several accounts can be members.
-- Nobody outside the workspace can read or write its records.

create table if not exists public.workspaces (
  id         uuid primary key default gen_random_uuid(),
  name       text not null default 'Family',
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now()
);

create table if not exists public.workspace_members (
  workspace_id uuid not null references public.workspaces (id) on delete cascade,
  user_id      uuid not null references auth.users (id) on delete cascade,
  role         text not null check (role in ('owner', 'member')),
  email        text,
  joined_at    timestamptz not null default now(),
  primary key (workspace_id, user_id)
);

create table if not exists public.workspace_invites (
  code         text primary key,
  workspace_id uuid not null references public.workspaces (id) on delete cascade,
  created_by   uuid not null default auth.uid(),
  expires_at   timestamptz not null,
  used_by      uuid,
  used_at      timestamptz
);

create table if not exists public.records (
  workspace_id uuid        not null references public.workspaces (id) on delete cascade,
  collection   text        not null check (collection in
                 ('unit_rules','plots','people','disputes','diary')),
  id           text        not null,
  data         jsonb       not null,
  deleted      boolean     not null default false,
  updated_at   timestamptz not null default now(),
  updated_by   uuid        default auth.uid(),
  primary key (workspace_id, collection, id)
);

-- Upgrade from the single-user schema: each existing user becomes owner of a workspace
-- that holds their records.
do $$
declare u uuid; w uuid;
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'records' and column_name = 'user_id') then
    drop policy if exists "own rows: select" on public.records;
    drop policy if exists "own rows: insert" on public.records;
    drop policy if exists "own rows: update" on public.records;
    drop policy if exists "own rows: delete" on public.records;
    alter table public.records add column if not exists workspace_id uuid references public.workspaces (id) on delete cascade;
    alter table public.records add column if not exists updated_by uuid default auth.uid();
    for u in select distinct user_id from public.records loop
      insert into public.workspaces (name, created_by) values ('Family', u) returning id into w;
      insert into public.workspace_members (workspace_id, user_id, role) values (w, u, 'owner');
      update public.records set workspace_id = w, updated_by = u where user_id = u;
    end loop;
    alter table public.records drop constraint if exists records_pkey;
    alter table public.records drop column user_id;
    alter table public.records alter column workspace_id set not null;
    alter table public.records add primary key (workspace_id, collection, id);
  end if;
end $$;

create index if not exists records_ws_updated_idx on public.records (workspace_id, updated_at);

create or replace function public.set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  return new;
end $$;

drop trigger if exists records_set_updated_at on public.records;
create trigger records_set_updated_at
  before insert or update on public.records
  for each row execute function public.set_updated_at();

-- Membership test used by the policies. SECURITY DEFINER avoids recursive RLS on the members table.
create or replace function public.is_member(ws uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from workspace_members where workspace_id = ws and user_id = auth.uid())
$$;

create or replace function public.is_owner(ws uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from workspace_members
                 where workspace_id = ws and user_id = auth.uid() and role = 'owner')
$$;

-- Create a workspace and become its owner.
create or replace function public.create_workspace(p_name text) returns uuid
language plpgsql security definer set search_path = public as $$
declare w uuid;
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  insert into workspaces (name, created_by) values (coalesce(nullif(trim(p_name), ''), 'Family'), auth.uid())
    returning id into w;
  insert into workspace_members (workspace_id, user_id, role, email)
    values (w, auth.uid(), 'owner', auth.jwt() ->> 'email');
  return w;
end $$;

-- Owner makes a single-use code valid for 3 days.
create or replace function public.create_invite(ws uuid) returns text
language plpgsql security definer set search_path = public as $$
declare c text;
begin
  if not is_owner(ws) then raise exception 'only the owner can invite'; end if;
  c := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10));
  insert into workspace_invites (code, workspace_id, created_by, expires_at)
    values (c, ws, auth.uid(), now() + interval '3 days');
  return c;
end $$;

-- Redeem a code. Same error for every failure so codes cannot be probed.
create or replace function public.join_workspace(p_code text) returns uuid
language plpgsql security definer set search_path = public as $$
declare i workspace_invites%rowtype;
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  select * into i from workspace_invites
    where code = upper(trim(p_code)) and used_at is null and expires_at > now() for update;
  if not found then raise exception 'invalid or expired code'; end if;
  insert into workspace_members (workspace_id, user_id, role, email)
    values (i.workspace_id, auth.uid(), 'member', auth.jwt() ->> 'email')
    on conflict do nothing;
  update workspace_invites set used_by = auth.uid(), used_at = now() where code = i.code;
  return i.workspace_id;
end $$;

-- Owner removes someone, or anyone leaves (user = themselves). The last owner cannot leave.
create or replace function public.remove_member(ws uuid, member uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if member <> auth.uid() and not is_owner(ws) then raise exception 'only the owner can remove members'; end if;
  if exists (select 1 from workspace_members where workspace_id = ws and user_id = member and role = 'owner')
     and (select count(*) from workspace_members where workspace_id = ws and role = 'owner') = 1 then
    raise exception 'the last owner cannot be removed';
  end if;
  delete from workspace_members where workspace_id = ws and user_id = member;
end $$;

alter table public.workspaces        enable row level security;
alter table public.workspace_members enable row level security;
alter table public.workspace_invites enable row level security;
alter table public.records           enable row level security;
alter table public.workspaces        force row level security;
alter table public.workspace_members force row level security;
alter table public.workspace_invites force row level security;
alter table public.records           force row level security;

drop policy if exists "ws: select" on public.workspaces;
create policy "ws: select" on public.workspaces for select to authenticated using (is_member(id));

drop policy if exists "members: select" on public.workspace_members;
create policy "members: select" on public.workspace_members for select to authenticated using (is_member(workspace_id));

drop policy if exists "invites: select" on public.workspace_invites;
create policy "invites: select" on public.workspace_invites for select to authenticated using (is_owner(workspace_id));

drop policy if exists "records: select" on public.records;
drop policy if exists "records: insert" on public.records;
drop policy if exists "records: update" on public.records;
drop policy if exists "records: delete" on public.records;
create policy "records: select" on public.records for select to authenticated using (is_member(workspace_id));
create policy "records: insert" on public.records for insert to authenticated with check (is_member(workspace_id));
create policy "records: update" on public.records for update to authenticated
  using (is_member(workspace_id)) with check (is_member(workspace_id));
create policy "records: delete" on public.records for delete to authenticated using (is_member(workspace_id));

-- Table privileges: members/invites/workspaces are written only through the functions above.
revoke all on public.workspaces, public.workspace_members, public.workspace_invites, public.records from anon, authenticated;
grant select on public.workspaces, public.workspace_members, public.workspace_invites to authenticated;
grant select, insert, update, delete on public.records to authenticated;

revoke all on function public.create_workspace(text), public.create_invite(uuid),
  public.join_workspace(text), public.remove_member(uuid, uuid),
  public.is_member(uuid), public.is_owner(uuid) from public, anon;
grant execute on function public.create_workspace(text), public.create_invite(uuid),
  public.join_workspace(text), public.remove_member(uuid, uuid),
  public.is_member(uuid), public.is_owner(uuid) to authenticated;
