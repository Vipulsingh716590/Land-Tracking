import 'dart:convert';

import 'zone.dart';

enum OverlayKind { metro, ringRoad, roadWidening, acquisition }

const _kindByName = {
  'metro': OverlayKind.metro,
  'ring_road': OverlayKind.ringRoad,
  'road_widening': OverlayKind.roadWidening,
  'acquisition': OverlayKind.acquisition,
};

class MapOverlay {
  const MapOverlay({
    required this.id,
    required this.kind,
    required this.nameHi,
    required this.nameEn,
    required this.source,
    required this.updatedOn,
    required this.isDemo,
    required this.points,
    this.corridorWidthM,
    this.corridorLeftM,
    this.corridorRightM,
    this.startAngleDeg,
    this.endAngleDeg,
  });

  final String id, nameHi, nameEn, source, updatedOn;
  final OverlayKind kind;
  final bool isDemo;

  /// Total width of land affected, centred on the line. Null when the data does not say.
  final double? corridorWidthM;

  /// One-sided corridors: metres taken from the centre line on each side, measured
  /// looking along the line in the order its points are listed. They override
  /// [corridorWidthM]; a missing side counts as 0.
  final double? corridorLeftM, corridorRightM;

  /// How the corridor stops at the first and last point of the line.
  /// null = rounded cap (default). A number = flat cut, turned that many degrees
  /// anticlockwise (seen from above, north up) from square to the line; 0 is a square cut.
  final double? startAngleDeg, endAngleDeg;

  bool get hasCutEnds => startAngleDeg != null || endAngleDeg != null;
  bool get squareEnds => startAngleDeg == 0 && endAngleDeg == 0;

  /// How far the corridor reaches on each side, or null when the data gives no extent.
  ({double left, double right})? get corridor {
    if (corridorLeftM != null || corridorRightM != null) {
      return (left: corridorLeftM ?? 0, right: corridorRightM ?? 0);
    }
    final w = corridorWidthM;
    return w == null ? null : (left: w / 2, right: w / 2);
  }

  /// Line vertices for road/metro kinds, outer ring for acquisition polygons.
  final List<LatLngPoint> points;

  String name(String lang) => lang == 'en' ? nameEn : nameHi;
  bool get isArea => kind == OverlayKind.acquisition;
  bool contains(double lat, double lng) => isArea && pointInRing(lat, lng, points);
}

List<MapOverlay> parseOverlays(String geojson) {
  final out = <MapOverlay>[];
  for (final f in (jsonDecode(geojson) as Map<String, dynamic>)['features'] as List) {
    final p = f['properties'] as Map<String, dynamic>;
    final g = f['geometry'] as Map<String, dynamic>;
    final kind = _kindByName[p['kind']];
    if (kind == null) throw FormatException('Unknown overlay kind: ${p['kind']}');
    final raw = switch (g['type']) {
      'LineString' => g['coordinates'] as List,
      'Polygon' => (g['coordinates'] as List).first as List,
      final t => throw FormatException('Unsupported geometry: $t'),
    };
    out.add(MapOverlay(
      id: p['id'], kind: kind, nameHi: p['name_hi'], nameEn: p['name_en'],
      source: p['source'], updatedOn: p['updated_on'], isDemo: p['is_demo'] ?? false,
      startAngleDeg: _ends(p).start,
      endAngleDeg: _ends(p).end,
      corridorWidthM: _nonNegative(p, 'corridor_width_m'),
      corridorLeftM: _nonNegative(p, 'corridor_left_m'),
      corridorRightM: _nonNegative(p, 'corridor_right_m'),
      points: [for (final c in raw) LatLngPoint((c[1] as num).toDouble(), (c[0] as num).toDouble())],
    ));
  }
  return out;
}

double? _nonNegative(Map<String, dynamic> p, String key) {
  final v = (p[key] as num?)?.toDouble();
  if (v != null && (v < 0 || v.isNaN)) {
    throw FormatException('$key must be zero or more (feature ${p['id']})');
  }
  return v;
}

const maxCutAngleDeg = 80.0;

({double? start, double? end}) _ends(Map<String, dynamic> p) {
  final style = p['corridor_end'];
  final hasAngles = p.containsKey('corridor_start_angle_deg') || p.containsKey('corridor_end_angle_deg');
  switch (style) {
    case null || 'round':
      if (hasAngles) {
        throw FormatException('corridor angles need "corridor_end": "angled" (feature ${p['id']})');
      }
      return (start: null, end: null);
    case 'square':
      if (hasAngles) {
        throw FormatException('corridor angles need "corridor_end": "angled" (feature ${p['id']})');
      }
      return (start: 0, end: 0);
    case 'angled':
      double angle(String key) {
        final v = (p[key] as num?)?.toDouble() ?? 0;
        if (v.isNaN || v.abs() > maxCutAngleDeg) {
          throw FormatException('$key must be between -$maxCutAngleDeg and $maxCutAngleDeg (feature ${p['id']})');
        }
        return v;
      }
      return (start: angle('corridor_start_angle_deg'), end: angle('corridor_end_angle_deg'));
    default:
      throw FormatException('corridor_end must be "round", "square" or "angled", got "$style" (feature ${p['id']})');
  }
}
