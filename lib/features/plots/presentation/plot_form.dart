import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../calculator/data/unit_rules_repository.dart';
import '../../calculator/domain/area_converter.dart';
import '../../calculator/presentation/calculator_screen.dart' show unitLabel;
import '../../osm/nominatim.dart';
import '../data/plots_repository.dart';
import '../domain/models.dart';

class PlotForm extends ConsumerStatefulWidget {
  const PlotForm({super.key, this.plot, this.lat, this.lng});
  final Plot? plot;
  final double? lat, lng;

  @override
  ConsumerState<PlotForm> createState() => _PlotFormState();
}

class _PlotFormState extends ConsumerState<PlotForm> {
  final _key = GlobalKey<FormState>();
  late final c = <String, TextEditingController>{};
  late AreaUnit areaUnit, rateUnit;
  late String ruleId;
  late PlotStatus status;
  bool disputed = false;
  bool searching = false;
  DisputeStatus dStatus = DisputeStatus.pending;

  TextEditingController _c(String k, [String? v]) =>
      c[k] = TextEditingController(text: v ?? '');

  @override
  void initState() {
    super.initState();
    final p = widget.plot;
    final rules = ref.read(unitRulesProvider);
    final people = ref.read(peopleProvider).where((x) => x.plotId == p?.id).toList();
    final d = ref.read(disputesProvider).where((x) => x.plotId == p?.id).firstOrNull;
    String pn(PersonRole r) => people.where((x) => x.role == r).map((x) => x.name).join(', ');
    _c('location', p?.location);
    _c('lat', (p?.lat ?? widget.lat)?.toString());
    _c('lng', (p?.lng ?? widget.lng)?.toString());
    _c('khasra', p?.khasraNo);
    _c('village', p?.village);
    _c('tehsil', p?.tehsil);
    _c('area', p?.area.toString());
    _c('rate', p?.ratePerUnit.toString());
    _c('risk', p?.riskNote);
    _c('source', p?.source);
    _c('owner', pn(PersonRole.owner));
    _c('prev', pn(PersonRole.previousOwner));
    _c('dealer', pn(PersonRole.dealer));
    _c('phone', people.where((x) => x.role == PersonRole.dealer).map((x) => x.phone).join());
    _c('caseType', d?.caseType);
    _c('court', d?.court);
    _c('nextDate', d?.nextDate);
    _c('dnote', d?.note);
    areaUnit = p?.areaUnit ?? AreaUnit.biswa;
    rateUnit = p?.rateUnit ?? AreaUnit.biswa;
    ruleId = p?.ruleId ?? rules.first.id;
    status = p?.status ?? PlotStatus.forSale;
    disputed = d != null;
    dStatus = d?.status ?? DisputeStatus.pending;
  }

  String? _req(String? v) => (v ?? '').trim().isEmpty ? AppLocalizations.of(context).required : null;
  String? _num(String? v) => double.tryParse(v ?? '') == null ? AppLocalizations.of(context).invalidNumber : null;
  String? _lat(String? v) { final d = double.tryParse(v ?? ''); return d == null || d.abs() > 90 ? AppLocalizations.of(context).invalidNumber : null; }
  String? _lng(String? v) { final d = double.tryParse(v ?? ''); return d == null || d.abs() > 180 ? AppLocalizations.of(context).invalidNumber : null; }

  Widget _f(String k, String label, {String? Function(String?)? v, bool num = false, int lines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: c[k], validator: v, maxLines: lines,
          decoration: InputDecoration(labelText: label),
          keyboardType: num ? const TextInputType.numberWithOptions(decimal: true, signed: true) : null,
        ),
      );

  Widget _unit(String label, AreaUnit cur, void Function(AreaUnit) set) {
    final t = AppLocalizations.of(context);
    return DropdownButtonFormField<AreaUnit>(
      initialValue: cur,
      decoration: InputDecoration(labelText: label),
      items: [for (final u in AreaUnit.values) DropdownMenuItem(value: u, child: Text(unitLabel(t, u)))],
      onChanged: (u) => setState(() => set(u!)),
    );
  }

  /// Looks the place name up on OpenStreetMap Nominatim and fills latitude / longitude.
  Future<void> _search() async {
    final t = AppLocalizations.of(context);
    final q = c['location']!.text.trim();
    if (q.isEmpty) return;
    setState(() => searching = true);
    try {
      final hits = await searchPlace(q);
      if (!mounted) return;
      if (hits.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.noPlaceFound)));
      } else {
        final pick = await showDialog<PlaceHit>(
          context: context,
          builder: (_) => SimpleDialog(title: Text(t.pickPlace), children: [
            for (final h in hits)
              SimpleDialogOption(onPressed: () => Navigator.pop(context, h), child: Text(h.name)),
          ]),
        );
        if (pick != null) {
          c['lat']!.text = pick.lat.toStringAsFixed(6);
          c['lng']!.text = pick.lng.toStringAsFixed(6);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t.searchFailed}: $e')));
      }
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final id = widget.plot?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    String v(String k) => c[k]!.text.trim();
    ref.read(plotsProvider.notifier).upsert(Plot(
          id: id, location: v('location'), lat: double.parse(v('lat')),
          lng: double.parse(v('lng')), khasraNo: v('khasra'), village: v('village'), tehsil: v('tehsil'),
          area: double.parse(v('area')), areaUnit: areaUnit,
          ratePerUnit: double.parse(v('rate')), rateUnit: rateUnit,
          ruleId: ruleId, status: status, riskNote: v('risk'),
          source: v('source'), updatedOn: today,
          favourite: widget.plot?.favourite ?? false, watch: widget.plot?.watch ?? false,
        ));
    var n = 0;
    Person person(PersonRole r, String name, [String phone = '']) =>
        Person(id: '$id-${n++}', role: r, name: name, phone: phone, plotId: id);
    ref.read(peopleProvider.notifier).setForPlot(id, [
      if (v('owner').isNotEmpty) person(PersonRole.owner, v('owner')),
      for (final s in v('prev').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty))
        person(PersonRole.previousOwner, s),
      if (v('dealer').isNotEmpty) person(PersonRole.dealer, v('dealer'), v('phone')),
    ]);
    ref.read(disputesProvider.notifier).setForPlot(
        id,
        disputed
            ? Dispute(id: 'd-$id', plotId: id, caseType: v('caseType'), court: v('court'),
                nextDate: v('nextDate'), status: dStatus, note: v('dnote'))
            : null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final rules = ref.watch(unitRulesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plot == null ? t.addPlot : t.editPlot),
        actions: [TextButton(onPressed: _save, child: Text(t.save))],
      ),
      body: Form(
        key: _key,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _f('location', t.location, v: _req),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: searching
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.search),
              label: Text(t.findOnMap),
              onPressed: searching ? null : _search,
            ),
          ),
          Row(children: [
            Expanded(child: _f('lat', t.latitude, v: _lat, num: true)),
            const SizedBox(width: 8),
            Expanded(child: _f('lng', t.longitude, v: _lng, num: true)),
          ]),
          _f('khasra', t.khasraNo),
          Row(children: [
            Expanded(child: _f('village', t.village)),
            const SizedBox(width: 8),
            Expanded(child: _f('tehsil', t.tehsil)),
          ]),
          DropdownButtonFormField<String>(
            initialValue: ruleId, isExpanded: true,
            decoration: InputDecoration(labelText: t.district),
            items: [for (final r in rules) DropdownMenuItem(value: r.id, child: Text('${r.district} (${r.unitName})'))],
            onChanged: (x) => setState(() => ruleId = x!),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _f('area', t.area, v: _num, num: true)),
            const SizedBox(width: 8),
            Expanded(child: _unit(t.areaUnit, areaUnit, (u) => areaUnit = u)),
          ]),
          Row(children: [
            Expanded(child: _f('rate', t.ratePerUnit, v: _num, num: true)),
            const SizedBox(width: 8),
            Expanded(child: _unit(t.rateUnit, rateUnit, (u) => rateUnit = u)),
          ]),
          DropdownButtonFormField<PlotStatus>(
            initialValue: status,
            decoration: InputDecoration(labelText: t.status),
            items: [for (final s in PlotStatus.values) DropdownMenuItem(value: s, child: Text(statusLabel(t, s)))],
            onChanged: (s) => setState(() => status = s!),
          ),
          const SizedBox(height: 8),
          _f('risk', t.riskNote, lines: 2),
          _f('source', t.sourceRequired, v: _req),
          const Divider(),
          _f('owner', t.currentOwner),
          _f('prev', t.previousOwners),
          _f('dealer', t.dealer),
          _f('phone', t.dealerPhone, num: true),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.disputed),
            value: disputed,
            onChanged: (x) => setState(() => disputed = x),
          ),
          if (disputed) ...[
            _f('caseType', t.caseType),
            _f('court', t.court),
            _f('nextDate', t.nextDate),
            DropdownButtonFormField<DisputeStatus>(
              initialValue: dStatus,
              decoration: InputDecoration(labelText: t.status),
              items: [for (final s in DisputeStatus.values) DropdownMenuItem(value: s, child: Text(s == DisputeStatus.pending ? t.casePending : t.caseResolved))],
              onChanged: (s) => setState(() => dStatus = s!),
            ),
            const SizedBox(height: 8),
            _f('dnote', t.note, lines: 2),
          ],
        ]),
      ),
    );
  }
}

String statusLabel(AppLocalizations t, PlotStatus s) => switch (s) {
      PlotStatus.forSale => t.statusForSale,
      PlotStatus.hold => t.statusHold,
      PlotStatus.sold => t.statusSold,
    };
