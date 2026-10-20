import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/diary_entry.dart';

class DiaryNotifier extends Notifier<List<DiaryEntry>> {
  @override
  List<DiaryEntry> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString('diary_v1');
      if (raw != null) {
        state = [for (final e in jsonDecode(raw) as List) DiaryEntry.fromJson(e as Map<String, dynamic>)];
      }
    } catch (_) {}
  }

  void _save() async {
    try {
      (await SharedPreferences.getInstance())
          .setString('diary_v1', jsonEncode([for (final e in state) e.toJson()]));
    } catch (_) {}
  }

  void upsert(DiaryEntry e) {
    state = state.any((x) => x.id == e.id)
        ? [for (final x in state) x.id == e.id ? e : x]
        : [...state, e];
    _save();
  }

  void remove(String id) {
    state = [for (final e in state) if (e.id != id) e];
    _save();
  }
}

final diaryProvider = NotifierProvider<DiaryNotifier, List<DiaryEntry>>(DiaryNotifier.new);

class DiaryQueryNotifier extends Notifier<DiaryQuery> {
  @override
  DiaryQuery build() => const DiaryQuery();
  void set(DiaryQuery q) => state = q;
}

final diaryQueryProvider = NotifierProvider<DiaryQueryNotifier, DiaryQuery>(DiaryQueryNotifier.new);
