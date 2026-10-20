import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../calculator/data/unit_rules_repository.dart';
import '../diary/data/diary_repository.dart';
import '../plots/data/plots_repository.dart';
import 'merge.dart';
import 'supabase_config.dart';

/// (collection name on the server, SharedPreferences key on the device)
const syncedCollections = {
  'unit_rules': 'unit_rules_v1',
  'plots': 'plots_v1',
  'people': 'people_v1',
  'disputes': 'disputes_v1',
  'diary': 'diary_v1',
};

class SyncState {
  const SyncState({
    this.signedIn = false,
    this.syncing = false,
    this.lastSync,
    this.error,
    this.skipped = false,
    this.workspaceLoaded = false,
    this.workspaceId,
    this.workspaceName,
    this.isOwner = false,
  });
  final bool signedIn, syncing, skipped, workspaceLoaded, isOwner;
  final String? lastSync, error, workspaceId, workspaceName;

  SyncState copyWith({
    bool? signedIn,
    bool? syncing,
    bool? skipped,
    String? lastSync,
    String? error,
    bool clearError = false,
    bool? workspaceLoaded,
    String? workspaceId,
    String? workspaceName,
    bool? isOwner,
    bool clearWorkspace = false,
  }) =>
      SyncState(
        signedIn: signedIn ?? this.signedIn,
        syncing: syncing ?? this.syncing,
        skipped: skipped ?? this.skipped,
        lastSync: lastSync ?? this.lastSync,
        error: clearError ? null : (error ?? this.error),
        workspaceLoaded: workspaceLoaded ?? this.workspaceLoaded,
        workspaceId: clearWorkspace ? null : (workspaceId ?? this.workspaceId),
        workspaceName: clearWorkspace ? null : (workspaceName ?? this.workspaceName),
        isOwner: clearWorkspace ? false : (isOwner ?? this.isOwner),
      );
}

class SyncController extends Notifier<SyncState> {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  SyncState build() {
    if (!supabaseConfigured) return const SyncState();
    final sub = _db.auth.onAuthStateChange.listen((e) {
      final signedIn = e.session != null;
      if (!signedIn) {
        state = state.copyWith(signedIn: false, workspaceLoaded: false, clearWorkspace: true);
      } else {
        state = state.copyWith(signedIn: true);
        if (e.event == AuthChangeEvent.signedIn) loadWorkspace();
      }
    });
    ref.onDispose(sub.cancel);
    final signedIn = _db.auth.currentSession != null;
    if (signedIn) Future.microtask(loadWorkspace);
    return SyncState(signedIn: signedIn);
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _db.auth.signInWithPassword(email: email.trim(), password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final r = await _db.auth.signUp(email: email.trim(), password: password);
      return r.session == null ? 'confirm-email' : null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Finds the workspace this account belongs to (one workspace per account for now).
  Future<void> loadWorkspace() async {
    try {
      final rows = await _db
          .from('workspace_members')
          .select('workspace_id, role, workspaces(name)')
          .eq('user_id', _db.auth.currentUser!.id)
          .order('joined_at')
          .limit(1);
      if (rows.isEmpty) {
        state = state.copyWith(workspaceLoaded: true, clearWorkspace: true);
        return;
      }
      final r = rows.first;
      state = state.copyWith(
        workspaceLoaded: true,
        workspaceId: r['workspace_id'] as String,
        workspaceName: (r['workspaces'] as Map?)?['name'] as String?,
        isOwner: r['role'] == 'owner',
      );
      await sync();
    } catch (e) {
      state = state.copyWith(workspaceLoaded: true, error: e.toString());
    }
  }

  /// Returns an error message, or null on success.
  Future<String?> createWorkspace(String name) async {
    try {
      await _db.rpc('create_workspace', params: {'p_name': name});
      await loadWorkspace();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  Future<String?> joinWorkspace(String code) async {
    try {
      await _db.rpc('join_workspace', params: {'p_code': code});
      await loadWorkspace();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  /// Owner only. Returns the code, or throws a readable message.
  Future<String> createInvite() async {
    try {
      return await _db.rpc('create_invite', params: {'ws': state.workspaceId}) as String;
    } catch (e) {
      throw _msg(e);
    }
  }

  Future<List<Map<String, dynamic>>> members() async {
    final rows = await _db
        .from('workspace_members')
        .select('user_id, email, role, joined_at')
        .eq('workspace_id', state.workspaceId!)
        .order('joined_at');
    return [for (final r in rows) Map<String, dynamic>.from(r)];
  }

  Future<String?> removeMember(String userId) async {
    try {
      await _db.rpc('remove_member', params: {'ws': state.workspaceId, 'member': userId});
      if (userId == _db.auth.currentUser?.id) {
        state = state.copyWith(clearWorkspace: true);
      }
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  String _msg(Object e) => e is PostgrestException ? e.message : e.toString();

  Future<void> signOut() async {
    await _db.auth.signOut();
    state = state.copyWith(signedIn: false, workspaceLoaded: false, clearWorkspace: true);
  }

  void showSignIn() => state = state.copyWith(skipped: false);

  void skip() => state = state.copyWith(skipped: true);

  Future<void> sync() async {
    if (!supabaseConfigured || state.syncing || _db.auth.currentUser == null || state.workspaceId == null) return;
    state = state.copyWith(syncing: true, clearError: true);
    try {
      await _run(state.workspaceId!);
      state = state.copyWith(syncing: false, lastSync: DateTime.now().toIso8601String());
      ref
        ..invalidate(unitRulesProvider)
        ..invalidate(plotsProvider)
        ..invalidate(peopleProvider)
        ..invalidate(disputesProvider)
        ..invalidate(diaryProvider);
    } catch (e) {
      state = state.copyWith(syncing: false, error: e.toString());
    }
  }

  Future<void> _run(String ws) async {
    final prefs = await SharedPreferences.getInstance();
    // Sync bookkeeping belongs to one workspace; start fresh if the workspace changed.
    if (prefs.getString('sync_ws') != ws) {
      await prefs.remove('sync_base_v1');
      await prefs.setString('sync_ws', ws);
    }
    final remoteAll = <String, Map<String, RemoteRow>>{};
    for (var from = 0;; from += 1000) {
      final page = await _db.from('records').select().eq('workspace_id', ws).range(from, from + 999);
      for (final row in page) {
        remoteAll.putIfAbsent(row['collection'] as String, () => {})[row['id'] as String] =
            RemoteRow(Map<String, dynamic>.from(row['data'] as Map), row['updated_at'] as String, row['deleted'] as bool);
      }
      if (page.length < 1000) break;
    }

    final baseRaw = prefs.getString('sync_base_v1');
    final baseAll = baseRaw == null
        ? <String, dynamic>{}
        : jsonDecode(baseRaw) as Map<String, dynamic>;
    final newBase = <String, dynamic>{};

    for (final entry in syncedCollections.entries) {
      final name = entry.key, key = entry.value;
      final rawLocal = prefs.getString(key);
      final localList = rawLocal == null ? <dynamic>[] : jsonDecode(rawLocal) as List;
      // DEMO rows never leave the device.
      final local = {
        for (final e in localList)
          if ((e as Map)['is_demo'] != true) e['id'] as String: Map<String, dynamic>.from(e)
      };
      final demo = [for (final e in localList) if ((e as Map)['is_demo'] == true) e];
      final base = {
        for (final e in ((baseAll[name] as Map?) ?? {}).entries)
          e.key as String: BaseEntry.fromJson(Map<String, dynamic>.from(e.value as Map))
      };

      final plan = mergeCollection(local: local, remote: remoteAll[name] ?? {}, base: base);

      final stamps = Map<String, String>.from(plan.remoteStamp);
      if (plan.push.isNotEmpty) {
        final rows = await _db.from('records').upsert([
          for (final p in plan.push.entries)
            {'workspace_id': ws, 'collection': name, 'id': p.key, 'data': p.value, 'deleted': false}
        ], onConflict: 'workspace_id,collection,id').select('id,updated_at');
        for (final r in rows) {
          stamps[r['id'] as String] = r['updated_at'] as String;
        }
      }
      for (final id in plan.tombstones) {
        await _db.from('records').update({'deleted': true}).eq('workspace_id', ws).eq('collection', name).eq('id', id);
      }

      newBase[name] = {
        for (final e in plan.result.entries)
          if (stamps[e.key] != null) e.key: BaseEntry(hashOf(e.value), stamps[e.key]!).toJson()
      };

      final out = [...demo, ...plan.result.values];
      // Keep untouched seeds visible: only write when there is real data or a stored list.
      if (rawLocal != null || plan.result.isNotEmpty) {
        await prefs.setString(key, jsonEncode(out));
      }
    }
    await prefs.setString('sync_base_v1', jsonEncode(newBase));
  }
}

final syncProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);
