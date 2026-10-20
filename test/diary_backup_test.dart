import 'dart:convert';

import 'package:ayodhya_zameen/features/backup/backup_service.dart';
import 'package:ayodhya_zameen/features/diary/domain/diary_entry.dart';
import 'package:flutter_test/flutter_test.dart';

const e1 = DiaryEntry(id: '1', date: '2026-10-01', text: 'सरयू किनारे का प्लॉट देखा', language: 'hi', plotId: 'p1');
const e2 = DiaryEntry(id: '2', date: '2026-10-05', text: 'Called dealer', language: 'en');
const e3 = DiaryEntry(id: '3', date: '2026-10-05', text: 'गुप्ता घाट', language: 'hi', plotId: 'p2');

void main() {
  const all = [e1, e2, e3];
  List<String> ids(DiaryQuery q) => [for (final e in searchDiary(all, q)) e.id];

  test('search by text, date, pin', () {
    expect(ids(const DiaryQuery(text: 'सरयू')), ['1']);
    expect(ids(const DiaryQuery(text: 'DEALER')), ['2']);
    expect(ids(const DiaryQuery(date: '2026-10-05')).toSet(), {'2', '3'});
    expect(ids(const DiaryQuery(plotId: 'p1')), ['1']);
    expect(ids(const DiaryQuery(text: 'घाट', plotId: 'p1')), isEmpty);
  });

  test('newest first', () => expect(ids(const DiaryQuery()).last, '1'));

  test('export text has dates, pin names and Hindi', () {
    final out = exportDiaryText(all, (id) => 'Plot $id');
    expect(out, contains('2026-10-01  [Plot p1]'));
    expect(out, contains('सरयू किनारे का प्लॉट देखा'));
  });

  test('backup round trip', () {
    final stored = {
      'diary_v1': jsonEncode([e1.toJson(), e2.toJson()]),
      'plots_v1': null,
    };
    final parsed = parseBackup(buildBackup(stored, '2026-10-20T00:00:00'));
    expect(parsed.keys, ['diary_v1']);
    expect((jsonDecode(parsed['diary_v1']!) as List).length, 2);
  });

  test('restore rejects bad files without producing data', () {
    expect(() => parseBackup('{"app":"other"}'), throwsFormatException);
    expect(() => parseBackup('not json'), throwsFormatException);
    final broken = jsonEncode({'app': 'ayodhya_zameen', 'version': 1, 'data': {'diary_v1': [{'id': 'x'}]}});
    expect(() => parseBackup(broken), throwsA(anything));
  });
}
