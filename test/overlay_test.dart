import 'dart:io';

import 'package:ayodhya_zameen/features/map/domain/overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final all = parseOverlays(File('assets/geojson/overlays_sample.geojson').readAsStringSync());

  test('sample has every kind, all marked demo', () {
    expect({for (final o in all) o.kind}, OverlayKind.values.toSet());
    expect(all.every((o) => o.isDemo), isTrue);
  });

  test('only acquisition areas contain points', () {
    final acq = all.firstWhere((o) => o.isArea);
    expect(acq.contains(26.799, 82.2065), isTrue);
    expect(acq.contains(0, 0), isFalse);
    expect(all.where((o) => !o.isArea).any((o) => o.contains(26.799, 82.2065)), isFalse);
  });

  test('unknown kind is rejected', () {
    expect(
        () => parseOverlays('{"features":[{"geometry":{"type":"LineString","coordinates":[]},'
            '"properties":{"kind":"tram"}}]}'),
        throwsFormatException);
  });
}
