import 'dart:convert';

import '../map/domain/zone.dart';

enum OsmKind { majorRoad, roadWorks, rail, railWorks, river }

String osmKindName(OsmKind k, String lang) => switch (k) {
      OsmKind.majorRoad => lang == 'en' ? 'Main road' : 'मुख्य सड़क',
      OsmKind.roadWorks => lang == 'en' ? 'Road under construction / proposed' : 'निर्माणाधीन / प्रस्तावित सड़क',
      OsmKind.rail => lang == 'en' ? 'Railway' : 'रेल लाइन',
      OsmKind.railWorks => lang == 'en' ? 'Railway under construction / proposed' : 'निर्माणाधीन / प्रस्तावित रेल',
      OsmKind.river => lang == 'en' ? 'River' : 'नदी',
    };

/// One mapped line from OpenStreetMap. Mapped by volunteers, so it is a reference
/// and never an official alignment.
class OsmWay {
  const OsmWay(this.id, this.kind, this.name, this.points);
  final int id;
  final OsmKind kind;
  final String name;
  final List<LatLngPoint> points;

  String get url => 'https://www.openstreetmap.org/way/$id';
}

OsmKind? _kindOf(Map<String, dynamic> tags) {
  final hw = tags['highway'], rw = tags['railway'];
  if (hw is String) {
    if (const {'motorway', 'trunk', 'primary', 'secondary'}.contains(hw)) return OsmKind.majorRoad;
    if (hw == 'construction' || hw == 'proposed') return OsmKind.roadWorks;
  }
  if (rw is String) {
    if (const {'rail', 'light_rail', 'subway', 'metro'}.contains(rw)) return OsmKind.rail;
    if (rw == 'construction' || rw == 'proposed') return OsmKind.railWorks;
  }
  if (tags['waterway'] == 'river') return OsmKind.river;
  return null;
}

/// Parses an Overpass API `out geom` response. Ways without geometry are skipped.
List<OsmWay> parseOverpass(String body) {
  final root = jsonDecode(body);
  if (root is! Map || root['elements'] is! List) {
    throw const FormatException('not an Overpass response');
  }
  final out = <OsmWay>[];
  for (final e in root['elements'] as List) {
    if (e is! Map || e['type'] != 'way' || e['geometry'] is! List) continue;
    final tags = Map<String, dynamic>.from((e['tags'] as Map?) ?? {});
    final kind = _kindOf(tags);
    if (kind == null) continue;
    final pts = [
      for (final g in e['geometry'] as List)
        if (g is Map && g['lat'] is num && g['lon'] is num)
          LatLngPoint((g['lat'] as num).toDouble(), (g['lon'] as num).toDouble())
    ];
    if (pts.length < 2) continue;
    final name = (tags['name:en'] ?? tags['name'] ?? tags['ref'] ?? '') as String;
    out.add(OsmWay(e['id'] as int, kind, name, pts));
  }
  return out;
}

/// Search box around Ayodhya: south, west, north, east.
const ayodhyaBbox = (s: 26.70, w: 82.05, n: 26.90, e: 82.35);

String overpassQuery() {
  const b = ayodhyaBbox;
  final box = '(${b.s},${b.w},${b.n},${b.e})';
  return '[out:json][timeout:40];('
      'way["highway"~"^(motorway|trunk|primary|secondary|construction|proposed)\$"]$box;'
      'way["railway"~"^(rail|light_rail|subway|construction|proposed)\$"]$box;'
      'way["waterway"="river"]$box;'
      ');out geom;';
}
