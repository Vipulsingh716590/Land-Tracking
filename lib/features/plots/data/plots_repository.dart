import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../calculator/domain/area_converter.dart';
import '../domain/models.dart';

/// Local, on-device storage. The notifiers below are the only code that
/// touches it, so a Supabase-backed version can replace [_Store] later.
class _Store {
  Future<List<T>> read<T>(
      String key, T Function(Map<String, dynamic>) from, List<T> seed) async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(key);
      if (raw != null) {
        return [for (final e in jsonDecode(raw) as List) from(e as Map<String, dynamic>)];
      }
    } catch (_) {}
    return seed;
  }

  Future<void> write(String key, List<Map<String, dynamic>> v) async {
    try {
      (await SharedPreferences.getInstance()).setString(key, jsonEncode(v));
    } catch (_) {}
  }
}

final _store = _Store();

// DEMO seed rows. Coordinates are approximate and rates are invented.
const _seedPlots = [
  Plot(
    id: 'demo-p1', location: 'Saryu riverfront (DEMO)', lat: 26.7985, lng: 82.2060,
    khasraNo: 'DEMO-101', area: 5, areaUnit: AreaUnit.biswa,
    ratePerUnit: 100000, rateUnit: AreaUnit.biswa, ruleId: 'demo-ayodhya',
    riskNote: 'DEMO: check ring-road acquisition',
    source: 'DEMO sample, not a real listing', updatedOn: '2026-10-20', isDemo: true,
  ),
  Plot(
    id: 'demo-p2', location: 'City border (DEMO)', lat: 26.7860, lng: 82.1900,
    khasraNo: 'DEMO-202', area: 2000, areaUnit: AreaUnit.sqft,
    ratePerUnit: 900, rateUnit: AreaUnit.sqft, ruleId: 'demo-ayodhya',
    source: 'DEMO sample, not a real listing', updatedOn: '2026-10-20', isDemo: true,
  ),
  Plot(
    id: 'demo-p3', location: 'Road side (DEMO)', lat: 26.7900, lng: 82.1980,
    khasraNo: 'DEMO-303', area: 1500, areaUnit: AreaUnit.sqft,
    ratePerUnit: 1200, rateUnit: AreaUnit.sqft, ruleId: 'demo-ayodhya',
    source: 'DEMO sample, not a real listing', updatedOn: '2026-10-20', isDemo: true,
  ),
  Plot(
    id: 'demo-p4', location: 'Metro side (DEMO)', lat: 26.7850, lng: 82.1850,
    khasraNo: 'DEMO-404', area: 1000, areaUnit: AreaUnit.sqft,
    ratePerUnit: 1100, rateUnit: AreaUnit.sqft, ruleId: 'demo-ayodhya',
    source: 'DEMO sample, not a real listing', updatedOn: '2026-10-20', isDemo: true,
  ),
  Plot(
    id: 'demo-p5', location: 'Ring road side (DEMO)', lat: 26.7650, lng: 82.1885,
    khasraNo: 'DEMO-505', area: 3000, areaUnit: AreaUnit.sqft,
    ratePerUnit: 700, rateUnit: AreaUnit.sqft, ruleId: 'demo-ayodhya',
    source: 'DEMO sample, not a real listing', updatedOn: '2026-10-20', isDemo: true,
  ),
  Plot(
    id: 'demo-p6', location: 'Road east side (DEMO)', lat: 26.7950, lng: 82.20015,
    khasraNo: 'DEMO-606', area: 1200, areaUnit: AreaUnit.sqft,
    ratePerUnit: 1300, rateUnit: AreaUnit.sqft, ruleId: 'demo-ayodhya',
    source: 'DEMO sample, not a real listing', updatedOn: '2026-10-20', isDemo: true,
  ),
  Plot(
    id: 'demo-p7', location: 'Road west side (DEMO)', lat: 26.7950, lng: 82.19985,
    khasraNo: 'DEMO-707', area: 1200, areaUnit: AreaUnit.sqft,
    ratePerUnit: 1300, rateUnit: AreaUnit.sqft, ruleId: 'demo-ayodhya',
    source: 'DEMO sample, not a real listing', updatedOn: '2026-10-20', isDemo: true,
  ),
];
const _seedDisputes = [
  Dispute(
    id: 'demo-d1', plotId: 'demo-p2', caseType: 'DEMO civil suit',
    court: 'DEMO court', nextDate: '2026-12-01', note: 'DEMO dispute note',
    isDemo: true,
  ),
];

class PlotsNotifier extends Notifier<List<Plot>> {
  @override
  List<Plot> build() {
    _store.read('plots_v1', Plot.fromJson, _seedPlots).then((v) => state = v);
    return _seedPlots;
  }

  void _save() =>
      _store.write('plots_v1', [for (final p in state) p.toJson()]);

  void upsert(Plot p) {
    state = state.any((x) => x.id == p.id)
        ? [for (final x in state) x.id == p.id ? p : x]
        : [...state, p];
    _save();
  }

  void addAll(List<Plot> ps) {
    state = [...state, ...ps];
    _save();
  }

  void remove(String id) {
    state = [for (final p in state) if (p.id != id) p];
    _save();
    ref.read(peopleProvider.notifier).removeForPlot(id);
    ref.read(disputesProvider.notifier).removeForPlot(id);
  }

  void toggleFavourite(String id) {
    state = [
      for (final p in state) p.id == id ? p.copyWith(favourite: !p.favourite) : p
    ];
    _save();
  }

  void toggleWatch(String id) {
    state = [
      for (final p in state) p.id == id ? p.copyWith(watch: !p.watch) : p
    ];
    _save();
  }
}

final plotsProvider =
    NotifierProvider<PlotsNotifier, List<Plot>>(PlotsNotifier.new);

class PeopleNotifier extends Notifier<List<Person>> {
  @override
  List<Person> build() {
    _store.read('people_v1', Person.fromJson, <Person>[]).then((v) => state = v);
    return const [];
  }

  void _save() => _store.write('people_v1', [for (final p in state) p.toJson()]);

  void setForPlot(String plotId, List<Person> people) {
    state = [...state.where((p) => p.plotId != plotId), ...people];
    _save();
  }

  void removeForPlot(String plotId) {
    state = [for (final p in state) if (p.plotId != plotId) p];
    _save();
  }
}

final peopleProvider =
    NotifierProvider<PeopleNotifier, List<Person>>(PeopleNotifier.new);

class DisputesNotifier extends Notifier<List<Dispute>> {
  @override
  List<Dispute> build() {
    _store.read('disputes_v1', Dispute.fromJson, _seedDisputes).then((v) => state = v);
    return _seedDisputes;
  }

  void _save() => _store.write('disputes_v1', [for (final d in state) d.toJson()]);

  /// One dispute per plot; passing null clears the tag.
  void setForPlot(String plotId, Dispute? d) {
    state = [...state.where((x) => x.plotId != plotId), ?d];
    _save();
  }

  void removeForPlot(String plotId) => setForPlot(plotId, null);
}

final disputesProvider =
    NotifierProvider<DisputesNotifier, List<Dispute>>(DisputesNotifier.new);

class PlotFilters {
  const PlotFilters(
      {this.area = '', this.maxBudget, this.minSqft, this.maxSqft, this.favouritesOnly = false});
  final String area;
  final double? maxBudget, minSqft, maxSqft;
  final bool favouritesOnly;
}

class FiltersNotifier extends Notifier<PlotFilters> {
  @override
  PlotFilters build() => const PlotFilters();
  void set(PlotFilters f) => state = f;
}

final plotFiltersProvider =
    NotifierProvider<FiltersNotifier, PlotFilters>(FiltersNotifier.new);
