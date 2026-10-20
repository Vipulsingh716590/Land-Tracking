class LatLngPoint {
  const LatLngPoint(this.lat, this.lng);
  final double lat;
  final double lng;
}

class Zone {
  const Zone({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.typeHi,
    required this.typeEn,
    required this.colour,
    required this.planYear,
    required this.heightLimitM,
    required this.source,
    required this.updatedOn,
    required this.isDemo,
    required this.rings,
  });

  final String id;
  final String nameHi, nameEn, typeHi, typeEn;

  /// 'red' | 'yellow' | 'green' — set by the data, not by the app.
  final String colour;
  final int planYear;
  final double? heightLimitM;
  final String source;
  final String updatedOn;
  final bool isDemo;

  /// Outer rings of each polygon (holes are ignored in this phase).
  final List<List<LatLngPoint>> rings;

  String name(String lang) => lang == 'en' ? nameEn : nameHi;
  String type(String lang) => lang == 'en' ? typeEn : typeHi;

  bool contains(double lat, double lng) =>
      rings.any((r) => pointInRing(lat, lng, r));
}

/// Ray-casting point-in-polygon test.
bool pointInRing(double lat, double lng, List<LatLngPoint> ring) {
  var inside = false;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final a = ring[i], b = ring[j];
    if ((a.lat > lat) != (b.lat > lat) &&
        lng < (b.lng - a.lng) * (lat - a.lat) / (b.lat - a.lat) + a.lng) {
      inside = !inside;
    }
  }
  return inside;
}
