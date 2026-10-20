import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/geojson_parser.dart';
import '../domain/overlay.dart';
import '../domain/zone.dart';

const planYears = [2026, 2031, 2036];

const zonesImportKey = 'zones_geojson_v1';
const overlaysImportKey = 'overlays_geojson_v1';

/// The GeoJSON the user imported, or null when they have not (the DEMO sample is used then).
Future<String?> importedGeojson(String key) async {
  try {
    return (await SharedPreferences.getInstance()).getString(key);
  } catch (_) {
    return null;
  }
}

class ZonesRepository {
  Future<List<Zone>> load() async {
    final imported = await importedGeojson(zonesImportKey);
    if (imported != null) {
      try {
        return parseZones(imported);
      } catch (_) {}
    }
    return parseZones(await rootBundle.loadString('assets/geojson/zones_sample.geojson'));
  }
}

final zonesProvider =
    FutureProvider<List<Zone>>((ref) => ZonesRepository().load());

class PlanYear extends Notifier<int> {
  @override
  int build() => planYears.first;
  void set(int y) => state = y;
}

final planYearProvider = NotifierProvider<PlanYear, int>(PlanYear.new);

final overlaysProvider = FutureProvider<List<MapOverlay>>((ref) async {
  final imported = await importedGeojson(overlaysImportKey);
  if (imported != null) {
    try {
      return parseOverlays(imported);
    } catch (_) {}
  }
  return parseOverlays(await rootBundle.loadString('assets/geojson/overlays_sample.geojson'));
});

class VisibleOverlays extends Notifier<Set<OverlayKind>> {
  @override
  Set<OverlayKind> build() => {};
  void toggle(OverlayKind k) =>
      state = state.contains(k) ? ({...state}..remove(k)) : {...state, k};
}

final visibleOverlaysProvider =
    NotifierProvider<VisibleOverlays, Set<OverlayKind>>(VisibleOverlays.new);
