import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/geojson_parser.dart';
import '../domain/overlay.dart';
import '../domain/zone.dart';

const planYears = [2026, 2031, 2036];

class ZonesRepository {
  Future<List<Zone>> load() async =>
      parseZones(await rootBundle.loadString('assets/geojson/zones_sample.geojson'));
}

final zonesProvider =
    FutureProvider<List<Zone>>((ref) => ZonesRepository().load());

class PlanYear extends Notifier<int> {
  @override
  int build() => planYears.first;
  void set(int y) => state = y;
}

final planYearProvider = NotifierProvider<PlanYear, int>(PlanYear.new);

final overlaysProvider = FutureProvider<List<MapOverlay>>((ref) async =>
    parseOverlays(await rootBundle.loadString('assets/geojson/overlays_sample.geojson')));

class VisibleOverlays extends Notifier<Set<OverlayKind>> {
  @override
  Set<OverlayKind> build() => {};
  void toggle(OverlayKind k) =>
      state = state.contains(k) ? ({...state}..remove(k)) : {...state, k};
}

final visibleOverlaysProvider =
    NotifierProvider<VisibleOverlays, Set<OverlayKind>>(VisibleOverlays.new);
