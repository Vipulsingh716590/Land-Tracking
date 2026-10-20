import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/settings_controller.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(settingsProvider).locale.languageCode;
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'hi', label: Text('हिन्दी')),
        ButtonSegment(value: 'en', label: Text('English')),
      ],
      selected: {code},
      onSelectionChanged: (s) =>
          ref.read(settingsProvider.notifier).setLocale(Locale(s.first)),
    );
  }
}
