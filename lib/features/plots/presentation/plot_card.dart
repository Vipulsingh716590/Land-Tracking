import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/demo_badge.dart';
import '../../../core/widgets/disclaimer_footer.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../calculator/data/unit_rules_repository.dart';
import '../../calculator/presentation/calculator_screen.dart' show unitLabel, fmt;
import '../../map/data/zones_repository.dart';
import '../../map/domain/acquisition_risk.dart';
import '../../map/domain/overlay.dart';
import '../../map/presentation/map_screen.dart' show overlayLabel;
import '../../settings/settings_controller.dart';
import '../data/plots_repository.dart';
import '../../calculator/domain/area_converter.dart';
import '../domain/models.dart';
import '../../diary/data/diary_repository.dart';
import '../../diary/presentation/diary_editor.dart';
import 'plot_form.dart';

// Official sites; the app links to them and never scrapes them.
const bhulekhUrl = 'https://upbhulekh.gov.in';
const bhunakshaUrl = 'https://upbhunaksha.gov.in';

void showPlotCard(BuildContext context, String plotId) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.7, maxChildSize: 0.95,
        builder: (_, sc) => PlotCard(plotId: plotId, controller: sc),
      ),
    );

class PlotCard extends ConsumerWidget {
  const PlotCard({super.key, required this.plotId, required this.controller});
  final String plotId;
  final ScrollController controller;

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final plot = ref.watch(plotsProvider).where((p) => p.id == plotId).firstOrNull;
    if (plot == null) return const SizedBox();
    final rules = ref.watch(unitRulesProvider);
    final rule = rules.firstWhere((r) => r.id == plot.ruleId, orElse: () => rules.first);
    final people = ref.watch(peopleProvider).where((p) => p.plotId == plotId).toList();
    final dispute = ref.watch(disputesProvider).where((d) => d.plotId == plotId).firstOrNull;
    String names(PersonRole r) => people.where((p) => p.role == r).map((p) => p.name).join(', ');
    final dealer = people.where((p) => p.role == PersonRole.dealer).firstOrNull;
    final notifier = ref.read(plotsProvider.notifier);
    final overlays = ref.watch(overlaysProvider).value ?? const <MapOverlay>[];
    final risk = acquisitionRisk(plot.lat, plot.lng, overlays);

    Widget row(String k, String v) => v.isEmpty
        ? const SizedBox()
        : Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('$k: $v'));

    return ListView(controller: controller, padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(child: Text(plot.location, style: Theme.of(context).textTheme.titleLarge)),
        if (plot.isDemo) const DemoBadge(),
      ]),
      Wrap(children: [
        IconButton(
          tooltip: t.favourite,
          icon: Icon(plot.favourite ? Icons.star : Icons.star_border),
          onPressed: () => notifier.toggleFavourite(plot.id)),
        IconButton(
          tooltip: t.watchlist,
          icon: Icon(plot.watch ? Icons.visibility : Icons.visibility_outlined),
          onPressed: () => notifier.toggleWatch(plot.id)),
        IconButton(
          tooltip: t.editPlot,
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => PlotForm(plot: plot)))),
        IconButton(
          tooltip: t.deletePlot,
          icon: const Icon(Icons.delete_outline),
          onPressed: () { notifier.remove(plot.id); Navigator.pop(context); }),
      ]),
      row(t.status, statusLabel(t, plot.status)),
      row(t.khasraNo, plot.khasraNo),
      row(t.village, plot.village),
      row(t.tehsil, plot.tehsil),
      row(t.area, '${fmt(plot.area)} ${unitLabel(t, plot.areaUnit)}${plot.areaUnit == AreaUnit.sqft ? '' : '  (${fmt(plot.sqft(rule))} ${t.unit_sqft})'}'),
      row(t.ratePerUnit, '₹ ${fmt(plot.ratePerUnit)} / ${unitLabel(t, plot.rateUnit)}'),
      row(t.totalPrice, '₹ ${fmt(plot.totalPrice(rule))}'),
      row(t.district, '${rule.district} (${rule.unitName})'),
      row(t.riskNote, plot.riskNote),
      _RiskRow(
        title: t.acquisitionCheck,
        none: t.riskNone,
        inside: t.riskInside,
        near: t.riskNear,
        risk: risk,
        lang: ref.watch(settingsProvider).locale.languageCode),
      for (final k in corridorKinds)
        _RiskRow(
          title: t.corridorCheckOf(overlayLabel(t, k)),
          none: t.corridorNoneOf(overlayLabel(t, k)),
          inside: t.corridorInsideOf(overlayLabel(t, k)),
          near: (m) => t.corridorNearOf(overlayLabel(t, k), m),
          unknownWidth: t.corridorWidthUnknownOf(overlayLabel(t, k)),
          risk: corridorRisk(plot.lat, plot.lng, overlays, kind: k),
          lang: ref.watch(settingsProvider).locale.languageCode),
      const Divider(),
      row(t.currentOwner, names(PersonRole.owner)),
      row(t.previousOwners, names(PersonRole.previousOwner)),
      row(t.dealer, dealer == null ? '' : '${dealer.name} ${dealer.phone}'),
      if (dispute != null) ...[
        const Divider(),
        Text('⚠ ${t.disputed}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        row(t.caseType, dispute.caseType),
        row(t.court, dispute.court),
        row(t.nextDate, dispute.nextDate),
        row(t.status, dispute.status == DisputeStatus.pending ? t.casePending : t.caseResolved),
        row(t.note, dispute.note),
      ],
      const Divider(),
      Text(t.diary, style: Theme.of(context).textTheme.titleSmall),
      for (final e in ref.watch(diaryProvider).where((e) => e.plotId == plotId).toList()..sort((a, b) => b.date.compareTo(a.date)))
        Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('${e.date}: ${e.text}', maxLines: 3, overflow: TextOverflow.ellipsis)),
      TextButton.icon(
        icon: const Icon(Icons.mic),
        label: Text(t.addNoteForPin),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryEditor(plotId: plotId)))),
      const Divider(),
      row(t.source, plot.source),
      row(t.lastUpdated, plot.updatedOn),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.copy), label: Text(t.copyForBhulekh),
          onPressed: () async {
            final rule0 = rule.district;
            await Clipboard.setData(ClipboardData(
                text: '${t.district}: $rule0\n${t.tehsil}: ${plot.tehsil}\n${t.village}: ${plot.village}\n${t.khasraNo}: ${plot.khasraNo}'));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.copied)));
            }
          }),
        OutlinedButton.icon(
          icon: const Icon(Icons.open_in_new), label: Text(t.openBhulekh),
          onPressed: () => _open(bhulekhUrl)),
        OutlinedButton.icon(
          icon: const Icon(Icons.open_in_new), label: Text(t.openBhunaksha),
          onPressed: () => _open(bhunakshaUrl)),
      ]),
      const DisclaimerFooter(),
    ]);
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({
    required this.title,
    required this.none,
    required this.inside,
    required this.near,
    required this.risk,
    required this.lang,
    this.unknownWidth,
  });
  final String title, none, inside;
  final String Function(int) near;
  final String? unknownWidth;
  final RiskResult risk;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final o = risk.overlay;
    if (risk.risk == RiskLevel.none || o == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text('$title: $none'),
      );
    }
    final isInside = risk.risk == RiskLevel.inside;
    final colour = isInside ? Colors.red : Colors.orange.shade800;
    final label = risk.widthUnknown
        ? '${unknownWidth ?? ''} (${risk.distanceM!.round()} m)'
        : (isInside ? inside : near(risk.distanceM!.round())) +
            (risk.side == null ? '' : ' (${sideLabel(AppLocalizations.of(context), risk.side!)})');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(Icons.warning_amber, color: colour),
        const SizedBox(width: 6),
        Expanded(
          child: Text('$title: $label — ${o.name(lang)}',
              style: TextStyle(color: colour, fontWeight: FontWeight.bold)),
        ),
        if (o.isDemo) const DemoBadge(),
      ]),
    );
  }
}

String sideLabel(AppLocalizations t, Compass c) => switch (c) {
      Compass.north => t.sideNorth,
      Compass.south => t.sideSouth,
      Compass.east => t.sideEast,
      Compass.west => t.sideWest,
    };
