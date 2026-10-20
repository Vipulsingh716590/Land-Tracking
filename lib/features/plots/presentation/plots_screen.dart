import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/demo_badge.dart';
import '../../../core/widgets/disclaimer_footer.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../calculator/data/unit_rules_repository.dart';
import '../../calculator/domain/unit_rule.dart';
import '../../calculator/presentation/calculator_screen.dart' show unitLabel, fmt;
import '../../map/data/zones_repository.dart';
import '../../map/domain/acquisition_risk.dart';
import '../../map/domain/overlay.dart';
import '../data/csv_import.dart';
import '../data/plots_repository.dart';
import '../domain/models.dart';
import 'plot_card.dart';
import 'plot_form.dart';

/// Applies the filter to [plots]; pure so it can be unit tested.
List<Plot> filterPlots(List<Plot> plots, List<UnitRule> rules, PlotFilters f) {
  UnitRule ruleOf(Plot p) => rules.firstWhere((r) => r.id == p.ruleId, orElse: () => rules.first);
  return [
    for (final p in plots)
      if ((!f.favouritesOnly || p.favourite) &&
          (f.area.isEmpty || p.location.toLowerCase().contains(f.area.toLowerCase())) &&
          (f.maxBudget == null || p.totalPrice(ruleOf(p)) <= f.maxBudget!) &&
          (f.minSqft == null || p.sqft(ruleOf(p)) >= f.minSqft!) &&
          (f.maxSqft == null || p.sqft(ruleOf(p)) <= f.maxSqft!))
        p
  ];
}

/// Worst of the acquisition-area and all corridor results for a plot.
RiskLevel plotRiskLevel(Plot p, Iterable<MapOverlay> overlays) => [
      acquisitionRisk(p.lat, p.lng, overlays).risk,
      for (final k in corridorKinds) corridorRisk(p.lat, p.lng, overlays, kind: k).risk,
    ].reduce(worst);

RiskLevel _level(Plot p, Iterable<MapOverlay> o) => plotRiskLevel(p, o);

class PlotsScreen extends ConsumerWidget {
  const PlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final rules = ref.watch(unitRulesProvider);
    final f = ref.watch(plotFiltersProvider);
    final plots = filterPlots(ref.watch(plotsProvider), rules, f);
    final overlays = ref.watch(overlaysProvider).value ?? const <MapOverlay>[];
    final disputed = ref.watch(disputesProvider).map((d) => d.plotId).toSet();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: t.addPlot,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlotForm())),
        child: const Icon(Icons.add),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(children: [
            Expanded(child: Text(t.plots, style: Theme.of(context).textTheme.titleLarge)),
            IconButton(
              tooltip: t.filters, icon: const Icon(Icons.filter_list),
              onPressed: () => _filters(context, ref)),
            IconButton(
              tooltip: t.importCsv, icon: const Icon(Icons.upload_file),
              onPressed: () => importCsvFlow(context, ref)),
          ]),
        ),
        SwitchListTile(
          dense: true, title: Text(t.favouritesOnly), value: f.favouritesOnly,
          onChanged: (v) => ref.read(plotFiltersProvider.notifier).set(PlotFilters(
              area: f.area, maxBudget: f.maxBudget, minSqft: f.minSqft,
              maxSqft: f.maxSqft, favouritesOnly: v)),
        ),
        for (final p in plots)
          ListTile(
            leading: Icon(disputed.contains(p.id) ? Icons.warning : Icons.place,
                color: disputed.contains(p.id) ? Colors.red : null),
            title: Row(children: [
              Flexible(child: Text(p.location)),
              if (p.isDemo) ...[const SizedBox(width: 6), const DemoBadge()],
            ]),
            subtitle: Text('${fmt(p.area)} ${unitLabel(t, p.areaUnit)} · '
                '₹ ${fmt(p.ratePerUnit)}/${unitLabel(t, p.rateUnit)}'),
            trailing: Wrap(children: [
              if (_level(p, overlays) != RiskLevel.none)
                Icon(Icons.warning_amber, size: 18,
                    color: _level(p, overlays) == RiskLevel.inside ? Colors.red : Colors.orange.shade800),
              if (p.favourite) const Icon(Icons.star, size: 18),
              if (p.watch) const Icon(Icons.visibility, size: 18),
            ]),
            onTap: () => showPlotCard(context, p.id),
          ),
        const DisclaimerFooter(),
      ]),
    );
  }

  void _filters(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final f = ref.read(plotFiltersProvider);
    String s(double? v) => v == null ? '' : v.toString();
    final area = TextEditingController(text: f.area);
    final budget = TextEditingController(text: s(f.maxBudget));
    final minS = TextEditingController(text: s(f.minSqft));
    final maxS = TextEditingController(text: s(f.maxSqft));
    Widget fld(TextEditingController c, String l, {bool num = true}) => TextField(
        controller: c, decoration: InputDecoration(labelText: l),
        keyboardType: num ? const TextInputType.numberWithOptions(decimal: true) : null);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.filters),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            fld(area, t.areaFilter, num: false),
            fld(budget, t.maxBudget),
            fld(minS, t.minSqft),
            fld(maxS, t.maxSqft),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(plotFiltersProvider.notifier).set(PlotFilters(favouritesOnly: f.favouritesOnly));
              Navigator.pop(context);
            },
            child: Text(t.clear)),
          FilledButton(
            onPressed: () {
              ref.read(plotFiltersProvider.notifier).set(PlotFilters(
                  area: area.text.trim(), maxBudget: double.tryParse(budget.text),
                  minSqft: double.tryParse(minS.text), maxSqft: double.tryParse(maxS.text),
                  favouritesOnly: f.favouritesOnly));
              Navigator.pop(context);
            },
            child: Text(t.apply)),
        ],
      ),
    );
  }
}

Future<void> importCsvFlow(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final file = await FilePicker.pickFile(type: FileType.any);
  if (file == null) return;
  final text = utf8.decode(await file.readAsBytes(), allowMalformed: true);
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final res = parsePlotsCsv(text, ref.read(unitRulesProvider), today);
  ref.read(plotsProvider.notifier).addAll(res.plots);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.importResult),
      content: SingleChildScrollView(
        child: Text('${t.imported}: ${res.plots.length}\n${t.skipped}: ${res.errors.length}\n'
            '${res.errors.map((e) => '${t.row} ${e.row}: ${e.reason}').join('\n')}\n\n'
            '${t.csvColumnsHint}: ${csvColumns.join(', ')}'),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.ok))],
    ),
  );
  messenger.hideCurrentSnackBar();
}
