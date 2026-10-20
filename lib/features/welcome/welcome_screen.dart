import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/language_toggle.dart';
import '../../l10n/generated/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.landscape, size: 72),
              const SizedBox(height: 16),
              Text(t.appTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(t.welcomeSubtitle, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Text(t.chooseLanguage, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Center(child: LanguageToggle()),
              const SizedBox(height: 32),
              FilledButton(
                  onPressed: () => context.go('/home'), child: Text(t.continueBtn)),
            ],
          ),
        ),
      ),
    );
  }
}
