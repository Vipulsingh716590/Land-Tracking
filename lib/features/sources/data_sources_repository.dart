import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../map/data/zones_repository.dart';
import '../map/domain/geojson_parser.dart';
import '../map/domain/overlay.dart';
import 'data_source.dart';

const _key = 'data_sources_v1';

/// Kept on this device only. It is not part of the backup file or the Supabase sync,
/// because it can hold an access token.
class DataSourcesNotifier extends Notifier<List<DataSource>> {
  @override
  List<DataSource> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null) {
        state = [for (final e in jsonDecode(raw) as List) DataSource.fromJson(e as Map<String, dynamic>)];
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      (await SharedPreferences.getInstance())
          .setString(_key, jsonEncode([for (final s in state) s.toJson()]));
    } catch (_) {}
  }

  void upsert(DataSource s) {
    state = state.any((x) => x.id == s.id)
        ? [for (final x in state) x.id == s.id ? s : x]
        : [...state, s];
    _save();
  }

  void remove(String id) {
    state = [for (final s in state) if (s.id != id) s];
    _save();
  }

  void setEnabled(String id, bool on) {
    state = [for (final s in state) s.id == id ? s.copyWith(enabled: on) : s];
    _save();
  }

  /// Downloads a GeoJSON source and makes it the map's zones or overlays.
  /// The file is parsed first, so a bad response changes nothing. Returns an error text or null.
  Future<String?> fetch(String id) async {
    final s = state.where((x) => x.id == id).firstOrNull;
    if (s == null || !s.isGeojson) return 'not a GeoJSON source';
    try {
      final r = await http.get(Uri.parse(s.url), headers: {
        if (!kIsWeb) 'User-Agent': 'AyodhyaZameen/1.0 (personal land tracking app)',
        ...s.headers,
      }).timeout(const Duration(seconds: 60));
      if (r.statusCode != 200) return 'HTTP ${r.statusCode}';
      final body = utf8.decode(r.bodyBytes);
      final zones = s.kind == SourceKind.zonesGeojson;
      final count = zones ? parseZones(body).length : parseOverlays(body).length;
      final p = await SharedPreferences.getInstance();
      await p.setString(zones ? zonesImportKey : overlaysImportKey, body);
      ref.invalidate(zones ? zonesProvider : overlaysProvider);
      state = [
        for (final x in state)
          x.id == id ? x.copyWith(lastFetched: DateTime.now().toIso8601String(), lastCount: count) : x
      ];
      _save();
      return null;
    } catch (e) {
      return '$e';
    }
  }
}

final dataSourcesProvider =
    NotifierProvider<DataSourcesNotifier, List<DataSource>>(DataSourcesNotifier.new);
