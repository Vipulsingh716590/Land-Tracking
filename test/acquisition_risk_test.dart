import 'dart:io';

import 'package:ayodhya_zameen/features/map/domain/acquisition_risk.dart';
import 'package:ayodhya_zameen/features/calculator/domain/area_converter.dart';
import 'package:ayodhya_zameen/features/map/domain/overlay.dart';
import 'package:ayodhya_zameen/features/plots/domain/models.dart';
import 'package:ayodhya_zameen/features/plots/presentation/plots_screen.dart';
import 'package:ayodhya_zameen/features/map/domain/zone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final overlays = parseOverlays(File('assets/geojson/overlays_sample.geojson').readAsStringSync());
  // Sample area: lat 26.797–26.801, lng 82.204–82.209.

  test('inside the area', () {
    final r = acquisitionRisk(26.799, 82.2065, overlays);
    expect(r.risk, RiskLevel.inside);
    expect(r.overlay!.isDemo, isTrue);
  });

  test('about 55 m west of the edge is near', () {
    // 0.0005 deg lng at this latitude ≈ 49.7 m.
    final r = acquisitionRisk(26.799, 82.2035, overlays);
    expect(r.risk, RiskLevel.near);
    expect(r.distanceM, closeTo(50, 3));
  });

  test('beyond the radius is none, and radius is adjustable', () {
    expect(acquisitionRisk(26.799, 82.200, overlays).risk, RiskLevel.none);
    expect(acquisitionRisk(26.799, 82.200, overlays, nearMeters: 500).risk, RiskLevel.near);
  });

  test('roads and metro lines never count as acquisition areas', () {
    final lines = overlays.where((o) => !o.isArea);
    expect(acquisitionRisk(26.792, 82.200, lines).risk, RiskLevel.none);
  });

  test('no overlays loaded means none, not a crash', () {
    expect(acquisitionRisk(26.8, 82.2, const []).risk, RiskLevel.none);
  });

  test('segment distance', () {
    const a = LatLngPoint(26.0, 82.0), b = LatLngPoint(26.0, 82.01);
    // 0.001 deg north of the middle is about 110.5 m
    expect(distanceToSegmentM(26.001, 82.005, a, b), closeTo(110.5, 1));
    // beyond the end the distance is to the endpoint (0.01 deg east ≈ 1000 m)
    expect(distanceToSegmentM(26.0, 82.02, a, b), closeTo(1000, 15));
  });

  group('road widening corridor', () {
    // Sample line takes 25 m on its right (east) side only; it passes through (26.790, 82.198).
    test('on the line is inside', () {
      expect(corridorRisk(26.7900, 82.1980, overlays).risk, RiskLevel.inside);
    });

    test('within half the width is inside, just outside is near', () {
      // 0.00008 deg lng ≈ 8 m east of the line, perpendicular distance slightly less.
      expect(corridorRisk(26.7900, 82.19808, overlays).risk, RiskLevel.inside);
      // 0.0004 deg ≈ 38 m east; the sample takes 25 m on the east (right) side => ~13 m past the edge.
      final r = corridorRisk(26.7900, 82.1984, overlays);
      expect(r.risk, RiskLevel.near);
      expect(r.distanceM, inInclusiveRange(8, 20));
    });

    test('far away is none', () {
      expect(corridorRisk(26.7860, 82.1900, overlays).risk, RiskLevel.none);
    });

    test('a line with no width is never guessed', () {
      final noWidth = [
        for (final o in overlays)
          if (o.kind == OverlayKind.roadWidening)
            MapOverlay(
                id: o.id, kind: o.kind, nameHi: o.nameHi, nameEn: o.nameEn, source: o.source,
                updatedOn: o.updatedOn, isDemo: true, points: o.points)
      ];
      final r = corridorRisk(26.7900, 82.1980, noWidth);
      expect(r.risk, RiskLevel.near);
      expect(r.widthUnknown, isTrue);
      expect(corridorRisk(26.7860, 82.1900, noWidth).risk, RiskLevel.none);
    });

    test('metro and ring road are not widening corridors', () {
      final others = overlays.where((o) => o.kind != OverlayKind.roadWidening);
      expect(corridorRisk(26.792, 82.200, others).risk, RiskLevel.none);
    });
  });

  group('metro and ring road corridors', () {
    test('metro: on the line is inside, 20 m width => 10 m each side', () {
      expect(corridorRisk(26.7850, 82.1850, overlays, kind: OverlayKind.metro).risk, RiskLevel.inside);
      // ~35 m perpendicular, 10 m half-width => ~25 m past the edge => near.
      final r = corridorRisk(26.7846, 82.1850, overlays, kind: OverlayKind.metro);
      expect(r.risk, RiskLevel.near);
      expect(r.distanceM, inInclusiveRange(15, 35));
    });

    test('ring road: wider corridor (60 m) covers more', () {
      // ~25 m from the line: outside a 20 m corridor, inside a 60 m one.
      const lat = 26.7650, lng = 82.1885;
      final ring = corridorRisk(lat + 0.00022, lng, overlays, kind: OverlayKind.ringRoad);
      expect(ring.risk, RiskLevel.inside);
    });

    test('each kind only sees its own lines', () {
      // The metro point is nowhere near the ring road.
      expect(corridorRisk(26.7850, 82.1850, overlays, kind: OverlayKind.ringRoad).risk, RiskLevel.none);
      expect(corridorRisk(26.7650, 82.1885, overlays, kind: OverlayKind.metro).risk, RiskLevel.none);
    });

    test('missing width is reported for any kind, never guessed', () {
      final metroNoWidth = [
        for (final o in overlays)
          if (o.kind == OverlayKind.metro)
            MapOverlay(id: o.id, kind: o.kind, nameHi: o.nameHi, nameEn: o.nameEn,
                source: o.source, updatedOn: o.updatedOn, isDemo: true, points: o.points)
      ];
      final r = corridorRisk(26.7850, 82.1850, metroNoWidth, kind: OverlayKind.metro);
      expect(r.widthUnknown, isTrue);
    });

    test('plot level is the worst across all checks', () {
      final plot = Plot(
          id: 'x', location: 'l', lat: 26.7850, lng: 82.1850, area: 1, areaUnit: AreaUnit.sqft,
          ratePerUnit: 1, rateUnit: AreaUnit.sqft, ruleId: 'r', source: 's', updatedOn: 'd');
      expect(plotRiskLevel(plot, overlays), RiskLevel.inside);
    });
  });

  group('one-sided corridors', () {
    // Straight line running due north, so left = west and right = east.
    // 0.0001 deg lng ≈ 10 m, 0.0001 deg lat ≈ 11 m.
    MapOverlay line({double? width, double? left, double? right}) => MapOverlay(
          id: 't', kind: OverlayKind.roadWidening, nameHi: 'h', nameEn: 'e', source: 's',
          updatedOn: 'd', isDemo: true, corridorWidthM: width, corridorLeftM: left,
          corridorRightM: right,
          points: const [LatLngPoint(26.790, 82.2000), LatLngPoint(26.800, 82.2000)]);

    RiskResult at(MapOverlay o, double lngOffsetDeg, {double lat = 26.795}) =>
        corridorRisk(lat, 82.2000 + lngOffsetDeg, [o]);

    test('right-only: east side taken, west side not', () {
      final o = line(left: 0, right: 25);
      expect(at(o, 0.0001).risk, RiskLevel.inside); // ~10 m east
      expect(at(o, 0.0004).risk, RiskLevel.near); // ~40 m east, ~15 m past the edge
      expect(at(o, 0.0004).distanceM, closeTo(15, 2));
      final west = at(o, -0.0001); // ~10 m west: outside, 10 m from a zero-width side
      expect(west.risk, RiskLevel.near);
      expect(west.distanceM, closeTo(10, 1));
      expect(at(o, -0.0030).risk, RiskLevel.none);
    });

    test('left-only mirrors it', () {
      final o = line(left: 15, right: 0);
      expect(at(o, -0.0001).risk, RiskLevel.inside);
      expect(at(o, 0.0001).risk, RiskLevel.near);
    });

    test('different extents each side', () {
      final o = line(left: 10, right: 40);
      expect(at(o, 0.0003).risk, RiskLevel.inside); // 30 m east < 40
      expect(at(o, -0.0003).risk, RiskLevel.near); // 30 m west > 10
      expect(at(o, -0.00005).risk, RiskLevel.inside); // 5 m west < 10
    });

    test('the centre line itself is inside whenever either side is taken', () {
      expect(at(line(left: 0, right: 25), 0).risk, RiskLevel.inside);
      expect(at(line(left: 0, right: 0), 0).risk, isNot(RiskLevel.inside));
    });

    test('width alone stays symmetric; left/right override it', () {
      final w = line(width: 30);
      expect(at(w, 0.0001).risk, RiskLevel.inside);
      expect(at(w, -0.0001).risk, RiskLevel.inside);
      final both = line(width: 200, left: 0, right: 25);
      expect(at(both, -0.0001).risk, RiskLevel.near);
    });

    test('reports which side of the road the plot is on', () {
      final o = line(left: 0, right: 25);
      expect(at(o, 0.0001).side, Compass.east);
      expect(at(o, -0.0001).side, Compass.west);
      expect(at(line(width: 30), 0.0001).side, isNull); // symmetric: no side note
    });

    test('past the end of the line the corridor stops', () {
      final o = line(left: 0, right: 25);
      // ~330 m north of the end and 5 m east: far outside.
      expect(corridorRisk(26.8030, 82.20005, [o]).risk, RiskLevel.none);
    });

    test('negative extents are rejected when parsing', () {
      expect(
          () => parseOverlays('{"features":[{"geometry":{"type":"LineString","coordinates":[[0,0],[1,1]]},'
              '"properties":{"id":"x","kind":"road_widening","name_hi":"h","name_en":"e",'
              '"source":"s","updated_on":"d","corridor_left_m":-5}}]}'),
          throwsFormatException);
    });
  });

  test('demo plots either side of the sample widening line', () {
    // The sample takes land on the east side only.
    expect(corridorRisk(26.7950, 82.20015, overlays).risk, RiskLevel.inside);
    final west = corridorRisk(26.7950, 82.19985, overlays);
    expect(west.risk, RiskLevel.near);
    expect(west.side, Compass.west);
  });

  group('square corridor ends', () {
    // Due-north line from lat 26.790 to 26.800 at lng 82.2. 0.0001 deg lat ≈ 11 m, lng ≈ 10 m.
    MapOverlay line({required bool square, double? left, double? right, double? width}) => MapOverlay(
          id: 't', kind: OverlayKind.roadWidening, nameHi: 'h', nameEn: 'e', source: 's',
          updatedOn: 'd', isDemo: true, startAngleDeg: square ? 0 : null, endAngleDeg: square ? 0 : null, corridorLeftM: left,
          corridorRightM: right, corridorWidthM: width,
          points: const [LatLngPoint(26.790, 82.2000), LatLngPoint(26.800, 82.2000)]);

    RiskResult check(MapOverlay o, double lat, double lngOffset) =>
        corridorRisk(lat, 82.2000 + lngOffset, [o]);

    test('round ends (default) cover a point just past the last point', () {
      final o = line(square: false, width: 50);
      // ~11 m north of the end, ~10 m east: ~15 m from the end point, inside 25 m.
      expect(check(o, 26.8001, 0.0001).risk, RiskLevel.inside);
    });

    test('square ends cut the same point off', () {
      final o = line(square: true, width: 50);
      final r = check(o, 26.8001, 0.0001);
      expect(r.risk, RiskLevel.near);
      expect(r.distanceM, closeTo(11, 1)); // straight back to the flat end
    });

    test('distance beyond a square end grows, then drops out of range', () {
      final o = line(square: true, width: 50);
      expect(check(o, 26.8004, 0).distanceM, closeTo(44, 2));
      expect(check(o, 26.8020, 0).risk, RiskLevel.none); // ~220 m
    });

    test('square end: both ends are cut, start as well as finish', () {
      final o = line(square: true, width: 50);
      expect(check(o, 26.7997, 0).risk, RiskLevel.inside); // still on the line
      expect(check(o, 26.7899, 0.0001).risk, RiskLevel.near); // ~11 m before the start
    });

    test('along the line itself nothing changes', () {
      final round = line(square: false, width: 50), square = line(square: true, width: 50);
      for (final lng in [0.0, 0.0001, -0.0001, 0.0004]) {
        expect(check(square, 26.795, lng).risk, check(round, 26.795, lng).risk);
      }
    });

    test('the corner of a flat end uses the sideways overshoot too', () {
      final o = line(square: true, left: 0, right: 25);
      // West of the end: reach 0 on that side. ~11 m past, ~10 m across => ~15 m.
      expect(check(o, 26.8001, -0.0001).distanceM, closeTo(15, 1.5));
      // East of the end, 40 m across (15 m past the 25 m reach), ~11 m past => ~19 m.
      expect(check(o, 26.8001, 0.0004).distanceM, closeTo(19, 2));
    });

    test('bends in the middle of a line keep their rounded joins', () {
      final bent = MapOverlay(
          id: 'b', kind: OverlayKind.roadWidening, nameHi: 'h', nameEn: 'e', source: 's',
          updatedOn: 'd', isDemo: true, startAngleDeg: 0, endAngleDeg: 0, corridorWidthM: 50,
          points: const [LatLngPoint(26.790, 82.2000), LatLngPoint(26.795, 82.2000), LatLngPoint(26.795, 82.2050)]);
      // Just beyond the middle vertex on its outer side: the join must stay covered.
      expect(corridorRisk(26.79515, 82.19995, [bent]).risk, RiskLevel.inside);
    });

    test('parsing: square and round accepted, anything else rejected', () {
      String feature(String end) =>
          '{"features":[{"geometry":{"type":"LineString","coordinates":[[0,0],[1,1]]},"properties":'
          '{"id":"x","kind":"road_widening","name_hi":"h","name_en":"e","source":"s","updated_on":"d",'
          '"corridor_width_m":30$end}}]}';
      expect(parseOverlays(feature(',"corridor_end":"square"')).single.squareEnds, isTrue);
      expect(parseOverlays(feature(',"corridor_end":"round"')).single.squareEnds, isFalse);
      expect(parseOverlays(feature('')).single.squareEnds, isFalse);
      expect(() => parseOverlays(feature(',"corridor_end":"flat"')), throwsFormatException);
    });

    test('the sample widening line has an angled end', () {
      final o = overlays.firstWhere((o) => o.kind == OverlayKind.roadWidening);
      expect(o.startAngleDeg, 0);
      expect(o.endAngleDeg, 30);
    });
  });

  group('angled corridor ends', () {
    // Due-north line, lat 26.790 -> 26.800 at lng 82.2, so left = west, right = east.
    // 0.0001 deg lat ≈ 11.05 m, 0.0001 deg lng ≈ 9.99 m. Reach 25 m each side unless stated.
    MapOverlay line({double? start, double? end, double? left, double? right}) => MapOverlay(
          id: 't', kind: OverlayKind.roadWidening, nameHi: 'h', nameEn: 'e', source: 's',
          updatedOn: 'd', isDemo: true, startAngleDeg: start, endAngleDeg: end,
          corridorWidthM: left == null && right == null ? 50 : null,
          corridorLeftM: left, corridorRightM: right,
          points: const [LatLngPoint(26.790, 82.2000), LatLngPoint(26.800, 82.2000)]);

    // Offsets in metres: beyond = metres past the END point (negative = before it),
    // east = metres east of the line.
    RiskResult atEnd(MapOverlay o, {required double beyond, required double east}) =>
        corridorRisk(26.800 + beyond / 110540, 82.2000 + east / 99900, [o]);

    // Metres after the START point (negative = before it).
    RiskResult atStart(MapOverlay o, {required double after, required double east}) =>
        corridorRisk(26.790 + after / 110540, 82.2000 + east / 99900, [o]);

    test('0 degrees is the same as a square end', () {
      final angled = line(start: 0, end: 0);
      expect(atEnd(angled, beyond: 10, east: 5).risk, RiskLevel.near);
      expect(atEnd(angled, beyond: -10, east: 5).risk, RiskLevel.inside);
    });

    test('end +45: the east (right) side runs further, the west side stops short', () {
      final o = line(end: 45);
      // 20 m east, 15 m past the end point: the cut is 20 m past it on that side => inside.
      expect(atEnd(o, beyond: 15, east: 20).risk, RiskLevel.inside);
      // 20 m east, 25 m past: beyond the cut by 5/sqrt2 ≈ 3.5 m.
      final far = atEnd(o, beyond: 25, east: 20);
      expect(far.risk, RiskLevel.near);
      expect(far.distanceM, closeTo(3.5, 0.5));
      // 20 m west, 5 m BEFORE the end point: the cut is already 20 m before it on that side.
      final west = atEnd(o, beyond: -5, east: -20);
      expect(west.risk, RiskLevel.near);
      expect(west.distanceM, closeTo(10.6, 0.7));
      // 20 m west, 30 m before the end point is inside.
      expect(atEnd(o, beyond: -30, east: -20).risk, RiskLevel.inside);
    });

    test('end -45 mirrors it', () {
      final o = line(end: -45);
      expect(atEnd(o, beyond: 15, east: -20).risk, RiskLevel.inside); // west now runs further
      expect(atEnd(o, beyond: 5, east: 20).risk, RiskLevel.near); // east now stops short
    });

    test('the cut passes through the centre line end point', () {
      final o = line(end: 45);
      // On the centre line the cut is exactly at the end point.
      expect(atEnd(o, beyond: -2, east: 0).risk, RiskLevel.inside);
      expect(atEnd(o, beyond: 5, east: 0).distanceM, closeTo(3.5, 0.5)); // 5 m / sqrt2
    });

    test('start +45: the west (left) side runs back past the start, the east side starts late', () {
      final o = line(start: 45);
      expect(atStart(o, after: -10, east: -20).risk, RiskLevel.inside); // 20 m west, 10 m before
      final east = atStart(o, after: 10, east: 20); // 20 m east: corridor starts 20 m in
      expect(east.risk, RiskLevel.near);
      expect(east.distanceM, closeTo(7.1, 0.6));
    });

    test('each end has its own angle', () {
      final o = line(start: 0, end: 60);
      expect(atStart(o, after: -5, east: 0).risk, RiskLevel.near); // start is square
      expect(atEnd(o, beyond: 30, east: 20).risk, RiskLevel.inside); // 20*tan60 ≈ 34.6 m
    });

    test('one-sided corridors use their own reach with the angled cut', () {
      final o = line(end: 45, left: 0, right: 25);
      expect(atEnd(o, beyond: 8, east: 10).risk, RiskLevel.inside);
      expect(atEnd(o, beyond: 8, east: -10).risk, RiskLevel.near); // west side takes nothing
    });

    test('nothing changes along the middle of the line', () {
      final angled = line(start: 40, end: -40), square = line(start: 0, end: 0);
      for (final east in [0.0, 10.0, -10.0, 30.0]) {
        expect(corridorRisk(26.795, 82.2 + east / 99900, [angled]).risk,
            corridorRisk(26.795, 82.2 + east / 99900, [square]).risk);
      }
    });

    test('a bend in the middle keeps its join; only the ends are angled', () {
      final bent = MapOverlay(
          id: 'b', kind: OverlayKind.roadWidening, nameHi: 'h', nameEn: 'e', source: 's',
          updatedOn: 'd', isDemo: true, startAngleDeg: 30, endAngleDeg: 30, corridorWidthM: 50,
          points: const [LatLngPoint(26.790, 82.2000), LatLngPoint(26.795, 82.2000), LatLngPoint(26.795, 82.2050)]);
      expect(corridorRisk(26.79515, 82.19995, [bent]).risk, RiskLevel.inside);
    });

    test('parsing: angled with defaults, explicit angles, and rejects', () {
      String feature(String extra) =>
          '{"features":[{"geometry":{"type":"LineString","coordinates":[[0,0],[1,1]]},"properties":'
          '{"id":"x","kind":"road_widening","name_hi":"h","name_en":"e","source":"s","updated_on":"d",'
          '"corridor_width_m":30$extra}}]}';
      final a = parseOverlays(feature(',"corridor_end":"angled","corridor_end_angle_deg":-25.5')).single;
      expect(a.startAngleDeg, 0);
      expect(a.endAngleDeg, -25.5);
      expect(a.squareEnds, isFalse);
      expect(parseOverlays(feature(',"corridor_end":"angled"')).single.squareEnds, isTrue);
      expect(() => parseOverlays(feature(',"corridor_end":"angled","corridor_end_angle_deg":85')), throwsFormatException);
      expect(() => parseOverlays(feature(',"corridor_end":"square","corridor_end_angle_deg":10')), throwsFormatException);
      expect(() => parseOverlays(feature(',"corridor_end_angle_deg":10')), throwsFormatException);
    });
  });
}
