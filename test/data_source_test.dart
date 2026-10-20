import 'package:ayodhya_zameen/features/calculator/data/unit_rules_seed.dart';
import 'package:ayodhya_zameen/features/plots/data/csv_import.dart';
import 'package:ayodhya_zameen/features/sources/data_source.dart';
import 'package:flutter_test/flutter_test.dart';

String? check({String name = 'n', String note = 'Bhuvan, NRSC', String url = 'https://example.org/wms', SourceKind kind = SourceKind.wms, String layers = 'a'}) =>
    validateSource(name: name, note: note, url: url, kind: kind, layers: layers);

void main() {
  test('a source needs a name and a source note', () {
    expect(check(name: ' '), 'name');
    expect(check(note: ''), 'note');
    expect(check(), isNull);
  });

  test('only https endpoints, with a real host', () {
    expect(check(url: 'http://example.org/wms'), 'https');
    expect(check(url: 'not a url'), 'url');
    expect(check(url: 'https://'), 'url');
  });

  test('wms needs layer names, xyz needs z/x/y placeholders', () {
    expect(check(layers: ' , '), 'layers');
    expect(check(kind: SourceKind.xyz, url: 'https://t.example.org/tiles.png'), 'template');
    expect(check(kind: SourceKind.xyz, url: 'https://t.example.org/{z}/{x}/{y}.png'), isNull);
    expect(check(kind: SourceKind.zonesGeojson, layers: ''), isNull);
  });

  test('layer names split on commas', () {
    expect(splitLayers('lulc:A, lulc:B ,,'), ['lulc:A', 'lulc:B']);
  });

  test('json round trip keeps the token and flags', () {
    const s = DataSource(
        id: '1', name: 'Bhuvan', kind: SourceKind.wms, url: 'https://x.org/wms', layers: 'a,b',
        headerName: 'Authorization', headerValue: 'Bearer t', note: 'NRSC', enabled: false);
    final r = DataSource.fromJson(s.toJson());
    expect(r.headers, {'Authorization': 'Bearer t'});
    expect(r.enabled, isFalse);
    expect(r.isRaster, isTrue);
    expect(const DataSource(id: '2', name: 'z', kind: SourceKind.zonesGeojson, url: 'https://x.org/z.json', note: 'n').isGeojson, isTrue);
  });

  test('csv import reads optional village and tehsil columns', () {
    final res = parsePlotsCsv(
        'location,lat,lng,area,area_unit,rate_per_unit,rate_unit,district,source,village,tehsil\n'
        'Plot,26.79,82.2,1,biswa,1,biswa,Gonda,src,Rampur,Sadar\n',
        unitRulesSeed, 'd');
    expect(res.plots.single.village, 'Rampur');
    expect(res.plots.single.tehsil, 'Sadar');
  });
}
