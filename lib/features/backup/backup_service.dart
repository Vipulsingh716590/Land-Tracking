import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/generated/app_localizations.dart';
import '../calculator/data/unit_rules_repository.dart';
import '../calculator/domain/unit_rule.dart';
import '../diary/data/diary_repository.dart';
import '../diary/domain/diary_entry.dart';
import '../plots/data/plots_repository.dart';
import '../plots/domain/models.dart';

const backupVersion = 1;
const _keys = ['unit_rules_v1', 'plots_v1', 'people_v1', 'disputes_v1', 'diary_v1'];

/// Validators: each list is parsed with the real fromJson before anything is written.
final Map<String, void Function(Map<String, dynamic>)> _validators = {
  'unit_rules_v1': UnitRule.fromJson,
  'plots_v1': Plot.fromJson,
  'people_v1': Person.fromJson,
  'disputes_v1': Dispute.fromJson,
  'diary_v1': DiaryEntry.fromJson,
};

/// Builds the backup JSON from the stored values (a missing key means "empty/default").
String buildBackup(Map<String, String?> stored, String now) => jsonEncode({
      'app': 'ayodhya_zameen',
      'version': backupVersion,
      'created': now,
      'data': {for (final k in _keys) if (stored[k] != null) k: jsonDecode(stored[k]!)},
    });

/// Returns the key→json-string map to write, or throws [FormatException].
Map<String, String> parseBackup(String text) {
  final root = jsonDecode(text);
  if (root is! Map || root['app'] != 'ayodhya_zameen' || root['version'] != backupVersion) {
    throw const FormatException('not an Ayodhya Zameen backup');
  }
  final data = root['data'] as Map<String, dynamic>;
  final out = <String, String>{};
  for (final e in data.entries) {
    final validate = _validators[e.key];
    if (validate == null) continue; // ignore unknown keys
    for (final item in e.value as List) {
      validate(item as Map<String, dynamic>);
    }
    out[e.key] = jsonEncode(e.value);
  }
  return out;
}

Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  final p = await SharedPreferences.getInstance();
  final now = DateTime.now().toIso8601String();
  final json = buildBackup({for (final k in _keys) k: p.getString(k)}, now);
  final uri = await FilePicker.saveFile(
    fileName: 'ayodhya_zameen_backup_${now.substring(0, 10)}.json',
    bytes: Uint8List.fromList(utf8.encode(json)),
    mimeType: 'application/json',
  );
  if (context.mounted && uri != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.backupSaved)));
  }
}

Future<void> restoreBackup(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final file = await FilePicker.pickFile(type: FileType.any);
  if (file == null) return;
  try {
    final data = parseBackup(utf8.decode(await file.readAsBytes()));
    final p = await SharedPreferences.getInstance();
    for (final k in _keys) {
      if (data.containsKey(k)) await p.setString(k, data[k]!);
    }
    ref
      ..invalidate(unitRulesProvider)
      ..invalidate(plotsProvider)
      ..invalidate(peopleProvider)
      ..invalidate(disputesProvider)
      ..invalidate(diaryProvider);
    messenger.showSnackBar(SnackBar(content: Text(t.restoreDone)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(t.restoreFailed)));
  }
}

Future<void> exportDiary(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  final plots = ref.read(plotsProvider);
  final text = exportDiaryText(ref.read(diaryProvider),
      (id) => plots.where((p) => p.id == id).firstOrNull?.location ?? '—');
  final uri = await FilePicker.saveFile(
    fileName: 'ayodhya_diary_${DateTime.now().toIso8601String().substring(0, 10)}.txt',
    bytes: Uint8List.fromList(utf8.encode(text)),
    mimeType: 'text/plain',
  );
  if (context.mounted && uri != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.backupSaved)));
  }
}
