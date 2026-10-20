import 'dart:io';

import 'package:ayodhya_zameen/features/map/domain/geojson_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final zones =
      parseZones(File('assets/geojson/zones_sample.geojson').readAsStringSync());

  test('sample has all three plan years, all marked demo', () {
    expect({for (final z in zones) z.planYear}, {2026, 2031, 2036});
    expect(zones.every((z) => z.isDemo), isTrue);
  });

  test('zones differ by year at the same point', () {
    // Just outside the 2026 residential block, inside the 2036 one.
    const lat = 26.803, lng = 82.201;
    List<String> at(int y) => [
          for (final z in zones)
            if (z.planYear == y && z.contains(lat, lng)) z.id
        ];
    expect(at(2026), isEmpty);
    expect(at(2036), isNotEmpty);
  });

  test('point outside every zone', () {
    expect(zones.any((z) => z.contains(0, 0)), isFalse);
  });

  test('colour comes from data', () {
    expect({for (final z in zones) z.colour}, {'red', 'yellow', 'green'});
  });
}
