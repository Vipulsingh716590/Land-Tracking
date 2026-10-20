import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class DisclaimerFooter extends StatelessWidget {
  const DisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(AppLocalizations.of(context).disclaimer,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
      );
}
