import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/demo_badge.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/unit_rules_repository.dart';
import '../domain/unit_rule.dart';

class UnitRulesScreen extends ConsumerWidget {
  const UnitRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final rules = ref.watch(unitRulesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.unitRules)),
      floatingActionButton: FloatingActionButton(
        tooltip: t.addRule,
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: ListView(children: [
        for (final r in rules)
          ListTile(
            title: Row(children: [
              Flexible(child: Text('${r.district} — ${r.unitName}')),
              if (r.isDemo) ...[const SizedBox(width: 8), const DemoBadge()],
            ]),
            subtitle: Text('${r.biswaPerBigha} ${t.unit_biswa}/${t.unit_bigha} · '
                '${r.sqftPerBiswa} ${t.unit_sqft}/${t.unit_biswa}\n${r.sourceNote}'),
            isThreeLine: true,
            onTap: () => _edit(context, ref, r),
            trailing: IconButton(
              tooltip: t.deleteRule,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.read(unitRulesProvider.notifier).remove(r.id),
            ),
          ),
      ]),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, UnitRule? r) async {
    final t = AppLocalizations.of(context);
    final district = TextEditingController(text: r?.district);
    final name = TextEditingController(text: r?.unitName);
    final bpb = TextEditingController(text: r?.biswaPerBigha.toString());
    final spb = TextEditingController(text: r?.sqftPerBiswa.toString());
    final bsi = TextEditingController(text: (r?.biswansiPerBiswa ?? 20).toString());
    final src = TextEditingController(text: r?.sourceNote);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(r == null ? t.addRule : t.editRule),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _f(district, t.district),
            _f(name, t.unitName),
            _f(bpb, t.biswaPerBigha, num: true),
            _f(spb, t.sqftPerBiswa, num: true),
            _f(bsi, t.biswansiPerBiswa, num: true),
            _f(src, t.sourceNote),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.save)),
        ],
      ),
    );
    final a = double.tryParse(bpb.text), b = double.tryParse(spb.text),
        c = double.tryParse(bsi.text);
    if (ok != true || a == null || b == null || c == null ||
        a <= 0 || b <= 0 || c <= 0 || district.text.trim().isEmpty) {
      return;
    }
    // Editing a DEMO row confirms nothing by itself; the flag is cleared only
    // when the user has written a source note.
    final confirmed = src.text.trim().isNotEmpty;
    ref.read(unitRulesProvider.notifier).upsert(UnitRule(
          id: r?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
          district: district.text.trim(),
          unitName: name.text.trim(),
          biswaPerBigha: a,
          sqftPerBiswa: b,
          biswansiPerBiswa: c,
          sourceNote: src.text.trim(),
          updatedOn: DateTime.now().toIso8601String().substring(0, 10),
          isDemo: !confirmed || (r?.isDemo == true && src.text == r?.sourceNote),
        ));
  }

  Widget _f(TextEditingController c, String label, {bool num = false}) =>
      TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        keyboardType: num ? const TextInputType.numberWithOptions(decimal: true) : null,
      );
}
