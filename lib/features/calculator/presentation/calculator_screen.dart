import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/demo_badge.dart';
import '../../../core/widgets/disclaimer_footer.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/unit_rules_repository.dart';
import '../domain/area_converter.dart';
import '../domain/unit_rule.dart';

String unitLabel(AppLocalizations t, AreaUnit u) => switch (u) {
      AreaUnit.bigha => t.unit_bigha,
      AreaUnit.biswa => t.unit_biswa,
      AreaUnit.biswansi => t.unit_biswansi,
      AreaUnit.sqft => t.unit_sqft,
      AreaUnit.sqyd => t.unit_sqyd,
      AreaUnit.sqm => t.unit_sqm,
      AreaUnit.acre => t.unit_acre,
    };

String fmt(double v) {
  final s = v.abs() >= 100 ? v.toStringAsFixed(2) : v.toStringAsFixed(4);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _State();
}

class _State extends ConsumerState<CalculatorScreen> {
  String? ruleId;
  AreaUnit from = AreaUnit.bigha;
  AreaUnit rateUnit = AreaUnit.biswa;
  final valueC = TextEditingController(text: '1');
  final rateC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final rules = ref.watch(unitRulesProvider);
    if (rules.isEmpty) {
      return Center(
          child: TextButton(
              onPressed: () => context.push('/rules'), child: Text(t.addRule)));
    }
    final UnitRule rule =
        rules.firstWhere((r) => r.id == ruleId, orElse: () => rules.first);
    final conv = AreaConverter(rule);
    final value = double.tryParse(valueC.text);
    final rate = double.tryParse(rateC.text);

    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: rule.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: t.district),
            items: [
              for (final r in rules)
                DropdownMenuItem(
                    value: r.id, child: Text('${r.district} (${r.unitName})')),
            ],
            onChanged: (v) => setState(() => ruleId = v),
          ),
        ),
        IconButton(
            tooltip: t.unitRules,
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/rules')),
      ]),
      if (rule.isDemo)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            const DemoBadge(),
            const SizedBox(width: 8),
            Expanded(
                child: Text(t.unverified,
                    style: const TextStyle(color: Colors.red))),
          ]),
        ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: TextField(
            controller: valueC,
            decoration: InputDecoration(
              labelText: t.value,
              errorText: value == null ? t.invalidNumber : null,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _unitDropdown(t, t.fromUnit, from, (u) => from = u)),
      ]),
      const SizedBox(height: 16),
      Text(t.results, style: Theme.of(context).textTheme.titleMedium),
      if (value != null)
        for (final e in conv.convertAll(value, from).entries)
          ListTile(
            dense: true,
            title: Text(unitLabel(t, e.key)),
            trailing: Text(fmt(e.value),
                style: Theme.of(context).textTheme.titleMedium),
          ),
      const Divider(),
      Row(children: [
        Expanded(
          child: TextField(
            controller: rateC,
            decoration: InputDecoration(labelText: t.ratePerUnit),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _unitDropdown(t, t.rateUnit, rateUnit, (u) => rateUnit = u)),
      ]),
      if (value != null && rate != null)
        ListTile(
          title: Text(t.totalPrice),
          trailing: Text(
              '₹ ${fmt(conv.totalPrice(area: value, areaUnit: from, rate: rate, rateUnit: rateUnit))}',
              style: Theme.of(context).textTheme.titleLarge),
        ),
      const Divider(),
      Text(t.formula, style: Theme.of(context).textTheme.titleMedium),
      Text(t.formulaBigha(fmt(rule.biswaPerBigha), fmt(rule.sqftPerBiswa),
          fmt(rule.biswansiPerBiswa))),
      Text(t.formulaFixed),
      Text(t.formulaTotal),
      const SizedBox(height: 8),
      Text('${t.source}: ${rule.sourceNote}'),
      Text('${t.lastUpdated}: ${rule.updatedOn}'),
      const DisclaimerFooter(),
    ]);
  }

  Widget _unitDropdown(AppLocalizations t, String label, AreaUnit cur,
          void Function(AreaUnit) set) =>
      DropdownButtonFormField<AreaUnit>(
        initialValue: cur,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final u in AreaUnit.values)
            DropdownMenuItem(value: u, child: Text(unitLabel(t, u))),
        ],
        onChanged: (u) => setState(() => set(u!)),
      );
}
