import 'dart:convert';

import 'zone.dart';

/// Parses a GeoJSON FeatureCollection of Polygon / MultiPolygon features.
/// Throws [FormatException] on a feature that lacks required properties.
List<Zone> parseZones(String geojson) {
  final root = jsonDecode(geojson) as Map<String, dynamic>;
  final zones = <Zone>[];
  for (final f in root['features'] as List) {
    final p = (f as Map<String, dynamic>)['properties'] as Map<String, dynamic>;
    final g = f['geometry'] as Map<String, dynamic>;
    final polys = switch (g['type']) {
      'Polygon' => [g['coordinates'] as List],
      'MultiPolygon' => (g['coordinates'] as List).cast<List>(),
      final t => throw FormatException('Unsupported geometry: $t'),
    };
    List<LatLngPoint> ring(List coords) => [
          for (final c in coords)
            LatLngPoint((c[1] as num).toDouble(), (c[0] as num).toDouble())
        ];
    zones.add(Zone(
      id: p['id'] as String,
      nameHi: p['name_hi'] as String,
      nameEn: p['name_en'] as String,
      typeHi: p['type_hi'] as String,
      typeEn: p['type_en'] as String,
      colour: p['colour'] as String,
      planYear: p['plan_year'] as int,
      heightLimitM: (p['height_limit_m'] as num?)?.toDouble(),
      source: p['source'] as String,
      updatedOn: p['updated_on'] as String,
      isDemo: p['is_demo'] as bool? ?? false,
      rings: [for (final poly in polys) ring(poly.first as List)],
    ));
  }
  return zones;
}
