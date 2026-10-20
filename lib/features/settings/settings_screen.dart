import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/language_toggle.dart';
import '../../l10n/generated/app_localizations.dart';
import '../sources/data_sources_screen.dart';
import 'data_tools.dart';
import '../backup/backup_service.dart';
import '../sync/members_screen.dart';
import '../sync/supabase_config.dart';
import '../sync/sync_service.dart';
import '../lock/lock_controller.dart';
import '../plots/presentation/plots_screen.dart' show importCsvFlow;
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final lock = ref.watch(lockProvider);
    final sync = ref.watch(syncProvider);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(t.language, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      const Align(alignment: Alignment.centerLeft, child: LanguageToggle()),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(t.darkMode),
        value: s.dark,
        onChanged: ref.read(settingsProvider.notifier).setDark,
      ),
      const Divider(),
      Text(t.privateMode, style: Theme.of(context).textTheme.titleMedium),
      if (!lock.hasPin)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_outline),
          title: Text(t.setPin),
          onTap: () => _setPin(context, ref),
        )
      else ...[
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_reset),
          title: Text(t.changePin),
          onTap: () => _setPin(context, ref),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.useBiometric),
          value: lock.biometric,
          onChanged: ref.read(lockProvider.notifier).setBiometric,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_open),
          title: Text(t.removePin),
          onTap: () => ref.read(lockProvider.notifier).removePin(),
        ),
      ],
      if (supabaseConfigured) ...[
        const Divider(),
        Text(t.account, style: Theme.of(context).textTheme.titleMedium),
        if (sync.signedIn) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: sync.syncing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
            title: Text(t.syncNow),
            subtitle: Text(sync.error != null
                ? '${t.syncFailed}: ${sync.error}'
                : (sync.lastSync == null ? t.neverSynced : '${t.lastSynced}: ${sync.lastSync!.substring(0, 16).replaceFirst('T', ' ')}')),
            onTap: ref.read(syncProvider.notifier).sync,
          ),
          if (sync.workspaceId != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.group),
              title: Text('${t.familySpace}: ${sync.workspaceName ?? ''}'),
              subtitle: Text(t.manageMembers),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersScreen())),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: Text(t.signOut),
            onTap: ref.read(syncProvider.notifier).signOut,
          ),
        ] else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.login),
            title: Text(t.signIn),
            subtitle: Text(t.offlineMode),
            onTap: ref.read(syncProvider.notifier).showSignIn,
          ),
      ],
      const Divider(),
      Text(t.realData, style: Theme.of(context).textTheme.titleMedium),
      Text(t.realDataHelp, style: Theme.of(context).textTheme.bodySmall),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.hub),
        title: Text(t.dataSources),
        subtitle: Text(t.dataSourcesShort),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataSourcesScreen())),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.layers),
        title: Text(t.importZones),
        onTap: () => importGeojson(context, ref, zones: true),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.route),
        title: Text(t.importOverlays),
        onTap: () => importGeojson(context, ref, zones: false),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.restore_page),
        title: Text(t.resetToDemo),
        onTap: () => resetGeojson(ref),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.cleaning_services),
        title: Text(t.removeDemo),
        onTap: () async {
          final n = await removeDemoRecords(ref);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t.removed}: $n')));
          }
        },
      ),
      const Divider(),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.upload_file),
        title: Text(t.importCsv),
        onTap: () => importCsvFlow(context, ref),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.backup),
        title: Text(t.backupData),
        onTap: () => exportBackup(context, ref),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.restore),
        title: Text(t.restoreData),
        onTap: () => restoreBackup(context, ref),
      ),
    ]);
  }

  Future<void> _setPin(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.setPin),
        content: TextField(
          controller: c, obscureText: true, maxLength: 8,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(helperText: t.pinHint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.save)),
        ],
      ),
    );
    if (ok == true && RegExp(r'^\d{4,8}$').hasMatch(c.text)) {
      await ref.read(lockProvider.notifier).setPin(c.text);
    }
  }
}
