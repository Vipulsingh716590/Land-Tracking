import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../sync/sync_service.dart';
import 'lock_controller.dart';

/// Covers the whole app with a PIN screen while private mode is locked,
/// and re-locks when the app goes to the background.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate> with WidgetsBindingObserver {
  final pin = TextEditingController();
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused) {
      ref.read(lockProvider.notifier).lock();
      ref.read(syncProvider.notifier).sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(lockProvider);
    if (!lock.loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!lock.locked) return widget.child;
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            Text(t.enterPin, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: pin,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 8,
              decoration: InputDecoration(errorText: error),
              onSubmitted: (_) => _submit(t),
            ),
            FilledButton(onPressed: () => _submit(t), child: Text(t.unlock)),
            if (lock.biometric)
              TextButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: Text(t.useBiometric),
                onPressed: () =>
                    ref.read(lockProvider.notifier).unlockWithBiometric(t.enterPin),
              ),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit(AppLocalizations t) async {
    final ok = await ref.read(lockProvider.notifier).unlockWithPin(pin.text);
    pin.clear();
    if (!ok && mounted) setState(() => error = t.wrongPin);
  }
}
