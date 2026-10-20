import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/language_toggle.dart';
import '../../l10n/generated/app_localizations.dart';
import 'supabase_config.dart';
import 'sync_service.dart';

/// Shows a sign-in screen when Supabase is configured and nobody is signed in.
/// Without Supabase keys the app runs local-only, as before.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!supabaseConfigured) return child;
    final s = ref.watch(syncProvider);
    if (s.signedIn) {
      if (!s.workspaceLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      return s.workspaceId == null ? const _WorkspaceSetup() : child;
    }
    return s.skipped ? child : const _SignIn();
  }
}

class _SignIn extends ConsumerStatefulWidget {
  const _SignIn();
  @override
  ConsumerState<_SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<_SignIn> {
  final email = TextEditingController(), pass = TextEditingController();
  String? msg;
  bool busy = false;

  Future<void> _go(bool signUp) async {
    final t = AppLocalizations.of(context);
    if (email.text.trim().isEmpty || pass.text.length < 6) {
      setState(() => msg = t.credentialsHint);
      return;
    }
    setState(() { busy = true; msg = null; });
    final c = ref.read(syncProvider.notifier);
    final err = signUp ? await c.signUp(email.text, pass.text) : await c.signIn(email.text, pass.text);
    if (!mounted) return;
    setState(() {
      busy = false;
      msg = err == null ? null : (err == 'confirm-email' ? t.confirmEmail : err);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          const SizedBox(height: 32),
          const Icon(Icons.cloud_sync, size: 64),
          const SizedBox(height: 8),
          Text(t.signIn, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const Center(child: LanguageToggle()),
          const SizedBox(height: 16),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: t.email)),
          TextField(controller: pass, obscureText: true, decoration: InputDecoration(labelText: t.password)),
          if (msg != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(msg!, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 16),
          FilledButton(onPressed: busy ? null : () => _go(false), child: Text(t.signIn)),
          OutlinedButton(onPressed: busy ? null : () => _go(true), child: Text(t.createAccount)),
          TextButton(onPressed: ref.read(syncProvider.notifier).skip, child: Text(t.useOffline)),
        ]),
      ),
    );
  }
}

/// Shown once after sign-in: start a new family space or join one with an invite code.
class _WorkspaceSetup extends ConsumerStatefulWidget {
  const _WorkspaceSetup();
  @override
  ConsumerState<_WorkspaceSetup> createState() => _WorkspaceSetupState();
}

class _WorkspaceSetupState extends ConsumerState<_WorkspaceSetup> {
  final name = TextEditingController(text: 'Family'), code = TextEditingController();
  String? msg;
  bool busy = false;

  Future<void> _run(Future<String?> Function() f) async {
    setState(() { busy = true; msg = null; });
    final err = await f();
    if (mounted) setState(() { busy = false; msg = err; });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = ref.read(syncProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.familySpace),
        actions: [IconButton(tooltip: t.signOut, icon: const Icon(Icons.logout), onPressed: c.signOut)],
      ),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        Text(t.joinWithCode, style: Theme.of(context).textTheme.titleMedium),
        TextField(controller: code, textCapitalization: TextCapitalization.characters, decoration: InputDecoration(labelText: t.inviteCode)),
        const SizedBox(height: 8),
        FilledButton(onPressed: busy ? null : () => _run(() => c.joinWorkspace(code.text)), child: Text(t.join)),
        const SizedBox(height: 32),
        Text(t.orStartNew, style: Theme.of(context).textTheme.titleMedium),
        TextField(controller: name, decoration: InputDecoration(labelText: t.familyName)),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: busy ? null : () => _run(() => c.createWorkspace(name.text)), child: Text(t.createFamily)),
        if (msg != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(msg!, style: const TextStyle(color: Colors.red))),
      ]),
    );
  }
}
