import 'package:ayodhya_zameen/features/osm/nominatim.dart';
import 'package:ayodhya_zameen/features/osm/osm_way.dart';
import 'package:flutter_test/flutter_test.dart';

// Shape of a real Overpass `out geom` response (values here are made up for the test).
const overpass = '''
{"version":0.6,"elements":[
 {"type":"way","id":11,"tags":{"highway":"trunk","name":"Test Road","name:en":"Test Road EN"},
  "geometry":[{"lat":26.79,"lon":82.19},{"lat":26.80,"lon":82.20}]},
 {"type":"way","id":12,"tags":{"highway":"construction"},"geometry":[{"lat":26.7,"lon":82.1},{"lat":26.71,"lon":82.11}]},
 {"type":"way","id":13,"tags":{"railway":"rail","ref":"R1"},"geometry":[{"lat":26.7,"lon":82.1},{"lat":26.71,"lon":82.11}]},
 {"type":"way","id":14,"tags":{"railway":"proposed"},"geometry":[{"lat":26.7,"lon":82.1},{"lat":26.71,"lon":82.11}]},
 {"type":"way","id":15,"tags":{"waterway":"river","name":"Saryu"},"geometry":[{"lat":26.8,"lon":82.2},{"lat":26.81,"lon":82.21}]},
 {"type":"way","id":16,"tags":{"highway":"footway"},"geometry":[{"lat":26.8,"lon":82.2},{"lat":26.81,"lon":82.21}]},
 {"type":"way","id":17,"tags":{"highway":"primary"}},
 {"type":"way","id":18,"tags":{"highway":"primary"},"geometry":[{"lat":26.8,"lon":82.2}]},
 {"type":"node","id":19,"lat":26.8,"lon":82.2}
]}''';

void main() {
  test('overpass: kinds, names, and skips what it cannot draw', () {
    final ways = parseOverpass(overpass);
    expect(ways.map((w) => w.id), [11, 12, 13, 14, 15]);
    expect(ways.map((w) => w.kind), [
      OsmKind.majorRoad, OsmKind.roadWorks, OsmKind.rail, OsmKind.railWorks, OsmKind.river,
    ]);
    expect(ways.first.name, 'Test Road EN');
    expect(ways[2].name, 'R1'); // falls back to ref
    expect(ways[1].name, '');
    expect(ways.first.points.length, 2);
    expect(ways.first.url, 'https://www.openstreetmap.org/way/11');
  });

  test('overpass: rejects a non-overpass body', () {
    expect(() => parseOverpass('{"error":"x"}'), throwsFormatException);
    expect(parseOverpass('{"elements":[]}'), isEmpty);
  });

  test('overpass query covers Ayodhya and asks for geometry', () {
    final q = overpassQuery();
    expect(q, contains('out geom'));
    expect(q, contains('26.7,82.05,26.9,82.35'));
  });

  test('nominatim: parses hits, skips rows without coordinates', () {
    final hits = parseNominatim('[{"display_name":"Guptar Ghat, Ayodhya","lat":"26.7931","lon":"82.2076"},'
        '{"display_name":"bad"},{"display_name":"x","lat":"abc","lon":"1"}]');
    expect(hits.length, 1);
    expect(hits.single.lat, closeTo(26.7931, 1e-9));
    expect(hits.single.name, contains('Ghat'));
    expect(() => parseNominatim('{"a":1}'), throwsFormatException);
  });
}
