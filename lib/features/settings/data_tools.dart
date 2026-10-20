import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/generated/app_localizations.dart';
import '../calculator/data/unit_rules_repository.dart';
import '../map/data/zones_repository.dart';
import '../map/domain/geojson_parser.dart';
import '../map/domain/overlay.dart';
import '../plots/data/plots_repository.dart';

/// Replaces the DEMO zones or overlays with a GeoJSON file the user supplies.
/// The file is parsed first; a bad file changes nothing.
Future<void> importGeojson(BuildContext context, WidgetRef ref, {required bool zones}) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final file = await FilePicker.pickFile(type: FileType.any);
  if (file == null) return;
  try {
    final text = utf8.decode(await file.readAsBytes());
    final count = zones ? parseZones(text).length : parseOverlays(text).length;
    final p = await SharedPreferences.getInstance();
    await p.setString(zones ? zonesImportKey : overlaysImportKey, text);
    ref.invalidate(zones ? zonesProvider : overlaysProvider);
    messenger.showSnackBar(SnackBar(content: Text('${t.imported}: $count')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('${t.importBad}: $e')));
  }
}

/// Goes back to the DEMO sample zones and overlays.
Future<void> resetGeojson(WidgetRef ref) async {
  final p = await SharedPreferences.getInstance();
  await p.remove(zonesImportKey);
  await p.remove(overlaysImportKey);
  ref
    ..invalidate(zonesProvider)
    ..invalidate(overlaysProvider);
}

/// Deletes every record marked DEMO (plots, disputes, unit rules). Records the user
/// entered or imported are untouched.
Future<int> removeDemoRecords(WidgetRef ref) async {
  var n = 0;
  final plots = ref.read(plotsProvider);
  final demoPlotIds = {for (final p in plots) if (p.isDemo) p.id};
  for (final id in demoPlotIds) {
    ref.read(plotsProvider.notifier).remove(id);
    n++;
  }
  for (final d in ref.read(disputesProvider).where((d) => d.isDemo)) {
    ref.read(disputesProvider.notifier).removeForPlot(d.plotId);
    n++;
  }
  for (final r in ref.read(unitRulesProvider).where((r) => r.isDemo)) {
    ref.read(unitRulesProvider.notifier).remove(r.id);
    n++;
  }
  return n;
}
