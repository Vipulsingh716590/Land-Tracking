import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'osm_way.dart';

class OsmData {
  const OsmData(this.ways, this.fetchedAt, {this.fromCache = false, this.error});
  final List<OsmWay> ways;

  /// ISO time the data was downloaded.
  final String? fetchedAt;
  final bool fromCache;

  /// Set when a fresh download failed.
  final String? error;
}

const _cacheKey = 'osm_cache_v1';
const _endpoint = 'https://overpass-api.de/api/interpreter';

/// Downloads roads, railways and rivers around Ayodhya from the public Overpass API
/// (OpenStreetMap data, © OpenStreetMap contributors, ODbL). The last good download is
/// kept on the device, so the layer still works offline.
class OsmRepository {
  Future<OsmData> load({bool refresh = false}) async {
    final cached = await _readCache();
    if (cached != null && !refresh) return cached;
    try {
      final r = await http
          .post(Uri.parse(_endpoint),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                if (!kIsWeb) 'User-Agent': 'AyodhyaZameen/1.0 (personal land tracking app)',
              },
              body: {'data': overpassQuery()})
          .timeout(const Duration(seconds: 60));
      if (r.statusCode != 200) throw Exception('Overpass HTTP ${r.statusCode}');
      final body = utf8.decode(r.bodyBytes);
      final ways = parseOverpass(body);
      final now = DateTime.now().toIso8601String();
      try {
        (await SharedPreferences.getInstance())
            .setString(_cacheKey, jsonEncode({'fetched': now, 'body': body}));
      } catch (_) {}
      return OsmData(ways, now);
    } catch (e) {
      if (cached != null) return OsmData(cached.ways, cached.fetchedAt, fromCache: true, error: '$e');
      return OsmData(const [], null, error: '$e');
    }
  }

  Future<OsmData?> _readCache() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_cacheKey);
      if (raw == null) return null;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return OsmData(parseOverpass(m['body'] as String), m['fetched'] as String, fromCache: true);
    } catch (_) {
      return null;
    }
  }
}

class OsmNotifier extends AsyncNotifier<OsmData> {
  bool _force = false;

  @override
  Future<OsmData> build() => OsmRepository().load(refresh: _force);

  /// Downloads again; the previous data stays visible while it loads.
  Future<void> refresh() async {
    _force = true;
    ref.invalidateSelf();
    try {
      await future;
    } finally {
      _force = false;
    }
  }
}

final osmProvider = AsyncNotifierProvider<OsmNotifier, OsmData>(OsmNotifier.new);

class OsmVisible extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final osmVisibleProvider = NotifierProvider<OsmVisible, bool>(OsmVisible.new);
