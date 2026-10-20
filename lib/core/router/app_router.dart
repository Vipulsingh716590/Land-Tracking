import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/calculator/presentation/unit_rules_screen.dart';
import '../../features/diary/presentation/diary_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/plots/presentation/plots_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class _Shell extends StatelessWidget {
  const _Shell(this.shell);
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.appTitle)),
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.calculate), label: t.calculator),
          NavigationDestination(icon: const Icon(Icons.map), label: t.map),
          NavigationDestination(icon: const Icon(Icons.place), label: t.plots),
          NavigationDestination(icon: const Icon(Icons.mic), label: t.diary),
          NavigationDestination(icon: const Icon(Icons.settings), label: t.settings),
        ],
      ),
    );
  }
}

StatefulShellBranch _branch(String path, Widget w) => StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (_, _) => w)]);

final appRouter = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, _) => const WelcomeScreen()),
  GoRoute(path: '/rules', builder: (_, _) => const UnitRulesScreen()),
  StatefulShellRoute.indexedStack(
    builder: (_, _, shell) => _Shell(shell),
    branches: [
      _branch('/home', const CalculatorScreen()),
      _branch('/map', const MapScreen()),
      _branch('/plots', const PlotsScreen()),
      _branch('/diary', const DiaryScreen()),
      _branch('/settings', const SettingsScreen()),
    ],
  ),
]);
