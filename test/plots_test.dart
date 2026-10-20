import 'package:ayodhya_zameen/features/calculator/data/unit_rules_seed.dart';
import 'package:ayodhya_zameen/features/calculator/domain/area_converter.dart';
import 'package:ayodhya_zameen/features/lock/lock_controller.dart';
import 'package:ayodhya_zameen/features/plots/data/csv_import.dart';
import 'package:ayodhya_zameen/features/plots/data/plots_repository.dart';
import 'package:ayodhya_zameen/features/plots/domain/models.dart';
import 'package:ayodhya_zameen/features/plots/presentation/plots_screen.dart';
import 'package:flutter_test/flutter_test.dart';

const header = 'location,lat,lng,area,area_unit,rate_per_unit,rate_unit,district,source,status\n';

void main() {
  test('csv: good row imported, bad rows rejected with reasons', () {
    final res = parsePlotsCsv(
      '${header}Vidya Kund,26.79,82.2,3,biswa,50000,biswa,Gonda,dealer call 2026-10-01,sold\n'
      'No source,26.79,82.2,3,biswa,50000,biswa,Gonda,,\n'
      'Bad district,26.79,82.2,3,biswa,50000,biswa,Nowhere,src,\n'
      'Bad lat,99,82.2,3,biswa,50000,biswa,Gonda,src,\n'
      'Bad unit,26.79,82.2,3,katha,50000,biswa,Gonda,src,\n',
      unitRulesSeed, '2026-10-20');
    expect(res.plots.length, 1);
    expect(res.plots.single.status, PlotStatus.sold);
    expect(res.plots.single.ruleId, 'demo-gonda');
    expect(res.errors.map((e) => e.row), [3, 4, 5, 6]);
  });

  test('csv: missing columns reported', () {
    final res = parsePlotsCsv('location,lat\nx,1\n', unitRulesSeed, 'd');
    expect(res.plots, isEmpty);
    expect(res.errors.single.reason, contains('missing columns'));
  });

  test('csv: Hindi text survives', () {
    final res = parsePlotsCsv('$headerसरयू तट,26.79,82.2,1,bigha,1,biswa,Gonda,स्रोत,\n',
        unitRulesSeed, 'd');
    expect(res.plots.single.location, 'सरयू तट');
  });

  group('filters', () {
    final rule = unitRulesSeed.first;
    Plot p(String id, String loc, double area, AreaUnit u, double rate, {bool fav = false}) => Plot(
        id: id, location: loc, lat: 0, lng: 0, area: area, areaUnit: u,
        ratePerUnit: rate, rateUnit: u, ruleId: rule.id, source: 's',
        updatedOn: 'd', favourite: fav);
    final all = [
      p('a', 'Saryu ghat', 1000, AreaUnit.sqft, 1000),
      p('b', 'Gupta Ghat', 3000, AreaUnit.sqft, 1000, fav: true),
    ];
    List<String> ids(PlotFilters f) => [for (final x in filterPlots(all, unitRulesSeed, f)) x.id];
    test('area text', () => expect(ids(const PlotFilters(area: 'gupta')), ['b']));
    test('budget', () => expect(ids(const PlotFilters(maxBudget: 2e6)), ['a']));
    test('size', () => expect(ids(const PlotFilters(minSqft: 2000)), ['b']));
    test('favourites', () => expect(ids(const PlotFilters(favouritesOnly: true)), ['b']));
  });

  test('total price uses district rule', () {
    final plot = Plot(
        id: 'x', location: 'l', lat: 0, lng: 0, area: 2, areaUnit: AreaUnit.bigha,
        ratePerUnit: 100, rateUnit: AreaUnit.biswa, ruleId: 'demo-gonda',
        source: 's', updatedOn: 'd');
    expect(plot.totalPrice(unitRulesSeed.last), 2 * 20 * 100); // Gonda: 20 biswa/bigha
  });

  test('json round trip', () {
    final p = Plot.fromJson(Plot(
        id: 'x', location: 'l', lat: 1, lng: 2, area: 3, areaUnit: AreaUnit.acre,
        ratePerUnit: 4, rateUnit: AreaUnit.sqm, ruleId: 'r', source: 's',
        updatedOn: 'd', watch: true).toJson());
    expect(p.areaUnit, AreaUnit.acre);
    expect(p.watch, isTrue);
  });

  test('pin hash is salted and deterministic', () {
    expect(hashPin('1234', 'a'), hashPin('1234', 'a'));
    expect(hashPin('1234', 'a'), isNot(hashPin('1234', 'b')));
    expect(hashPin('1234', 'a'), isNot(contains('1234')));
  });

  test('unused provider import check', () => expect(plotsProvider, isNotNull));
}
