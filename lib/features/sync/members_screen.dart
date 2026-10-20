import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/generated/app_localizations.dart';
import 'sync_service.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});
  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  late Future<List<Map<String, dynamic>>> future = ref.read(syncProvider.notifier).members();

  void _reload() => setState(() => future = ref.read(syncProvider.notifier).members());

  Future<void> _invite() async {
    final t = AppLocalizations.of(context);
    String code;
    try {
      code = await ref.read(syncProvider.notifier).createInvite();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.inviteCode),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          SelectableText(code, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(t.inviteHelp),
        ]),
        actions: [
          TextButton(onPressed: () => Clipboard.setData(ClipboardData(text: code)), child: Text(t.copy)),
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(t.ok)),
        ],
      ),
    );
  }

  Future<void> _remove(String userId, bool isSelf) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(isSelf ? t.confirmLeave : t.confirmRemove),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.ok)),
        ],
      ),
    );
    if (ok != true) return;
    final err = await ref.read(syncProvider.notifier).removeMember(userId);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else if (isSelf) {
      Navigator.pop(context);
    } else {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final s = ref.watch(syncProvider);
    final me = Supabase.instance.client.auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(title: Text(t.manageMembers)),
      floatingActionButton: s.isOwner
          ? FloatingActionButton.extended(onPressed: _invite, icon: const Icon(Icons.person_add), label: Text(t.inviteMember))
          : null,
      body: FutureBuilder(
        future: future,
        builder: (_, snap) {
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(children: [
            for (final m in snap.data!)
              ListTile(
                leading: Icon(m['role'] == 'owner' ? Icons.verified_user : Icons.person),
                title: Text('${m['email'] ?? m['user_id']}${m['user_id'] == me ? ' (${t.you})' : ''}'),
                subtitle: Text(m['role'] == 'owner' ? t.roleOwner : t.roleMember),
                trailing: (s.isOwner && m['user_id'] != me) || m['user_id'] == me
                    ? IconButton(
                        tooltip: m['user_id'] == me ? t.leaveFamily : t.removeMember,
                        icon: Icon(m['user_id'] == me ? Icons.exit_to_app : Icons.person_remove),
                        onPressed: () => _remove(m['user_id'] as String, m['user_id'] == me),
                      )
                    : null,
              ),
            Padding(padding: const EdgeInsets.all(16), child: Text(t.removedKeepsCopy)),
          ]);
        },
      ),
    );
  }
}
