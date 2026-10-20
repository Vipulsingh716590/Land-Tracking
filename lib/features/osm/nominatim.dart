import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class PlaceHit {
  const PlaceHit(this.name, this.lat, this.lng);
  final String name;
  final double lat, lng;
}

List<PlaceHit> parseNominatim(String body) {
  final list = jsonDecode(body);
  if (list is! List) throw const FormatException('not a Nominatim response');
  return [
    for (final e in list)
      if (e is Map && double.tryParse('${e['lat']}') != null && double.tryParse('${e['lon']}') != null)
        PlaceHit('${e['display_name'] ?? ''}', double.parse('${e['lat']}'), double.parse('${e['lon']}'))
  ];
}

/// Place search on the public OpenStreetMap Nominatim service. Call it only from a
/// button press (the service allows at most one request per second and no bulk use).
Future<List<PlaceHit>> searchPlace(String query) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'q': query,
    'format': 'jsonv2',
    'limit': '6',
    'countrycodes': 'in',
    // Prefer results around Ayodhya without excluding the rest of India.
    'viewbox': '82.05,26.90,82.35,26.70',
  });
  final r = await http.get(uri, headers: {
    if (!kIsWeb) 'User-Agent': 'AyodhyaZameen/1.0 (personal land tracking app)',
    'Accept-Language': 'hi,en',
  }).timeout(const Duration(seconds: 20));
  if (r.statusCode != 200) throw Exception('Nominatim HTTP ${r.statusCode}');
  return parseNominatim(utf8.decode(r.bodyBytes));
}
