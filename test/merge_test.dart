import 'package:ayodhya_zameen/features/sync/merge.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> d(String id, String v) => {'id': id, 'v': v};
RemoteRow r(String id, String v, String at, {bool deleted = false}) => RemoteRow(d(id, v), at, deleted);
BaseEntry b(String id, String v, String at) => BaseEntry(hashOf(d(id, v)), at);

MergePlan run(Map<String, Map<String, dynamic>> l, Map<String, RemoteRow> rem, Map<String, BaseEntry> base) =>
    mergeCollection(local: l, remote: rem, base: base);

void main() {
  test('first sync: local-only pushed, remote-only pulled', () {
    final p = run({'a': d('a', '1')}, {'b': r('b', '2', 't1')}, {});
    expect(p.push.keys, ['a']);
    expect(p.result.keys.toSet(), {'a', 'b'});
  });

  test('unchanged both sides: nothing pushed', () {
    final p = run({'a': d('a', '1')}, {'a': r('a', '1', 't1')}, {'a': b('a', '1', 't1')});
    expect(p.push, isEmpty);
    expect(p.tombstones, isEmpty);
    expect(p.remoteStamp['a'], 't1');
  });

  test('only remote changed: take remote', () {
    final p = run({'a': d('a', '1')}, {'a': r('a', '2', 't2')}, {'a': b('a', '1', 't1')});
    expect(p.result['a']!['v'], '2');
    expect(p.push, isEmpty);
  });

  test('only local changed: push', () {
    final p = run({'a': d('a', '9')}, {'a': r('a', '1', 't1')}, {'a': b('a', '1', 't1')});
    expect(p.push['a']!['v'], '9');
  });

  test('both changed: this device wins', () {
    final p = run({'a': d('a', '9')}, {'a': r('a', '2', 't2')}, {'a': b('a', '1', 't1')});
    expect(p.result['a']!['v'], '9');
    expect(p.push.containsKey('a'), isTrue);
  });

  test('deleted locally, unchanged remotely: tombstone', () {
    final p = run({}, {'a': r('a', '1', 't1')}, {'a': b('a', '1', 't1')});
    expect(p.tombstones, {'a'});
    expect(p.result, isEmpty);
  });

  test('deleted locally but edited remotely: edit survives', () {
    final p = run({}, {'a': r('a', '2', 't2')}, {'a': b('a', '1', 't1')});
    expect(p.result['a']!['v'], '2');
    expect(p.tombstones, isEmpty);
  });

  test('deleted remotely, unchanged here: removed here', () {
    final p = run({'a': d('a', '1')}, {'a': r('a', '1', 't2', deleted: true)}, {'a': b('a', '1', 't1')});
    expect(p.result, isEmpty);
    expect(p.push, isEmpty);
  });

  test('deleted remotely but edited here: edit survives and is pushed', () {
    final p = run({'a': d('a', '9')}, {'a': r('a', '1', 't2', deleted: true)}, {'a': b('a', '1', 't1')});
    expect(p.push['a']!['v'], '9');
  });

  test('hash ignores key order', () {
    expect(hashOf({'a': 1, 'b': [1, 2]}), hashOf({'b': [1, 2], 'a': 1}));
  });
}
