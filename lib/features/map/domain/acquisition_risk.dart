import 'dart:math';

import 'overlay.dart';
import 'zone.dart';

enum RiskLevel { none, near, inside }

enum Compass { north, south, east, west }

/// The more serious of two levels.
RiskLevel worst(RiskLevel a, RiskLevel b) => a.index >= b.index ? a : b;

class RiskResult {
  const RiskResult(this.risk, [this.overlay, this.distanceM, this.widthUnknown = false, this.side]);
  final RiskLevel risk;
  final MapOverlay? overlay;

  /// Metres to the nearest edge (0 when inside); null when there is no area to compare.
  final double? distanceM;

  /// True when a widening line is close but the data gives no corridor width.
  final bool widthUnknown;

  /// Which side of the road the point is on (compass), set only for one-sided corridors.
  final Compass? side;

  static const none = RiskResult(RiskLevel.none);
}

/// Where a point lies relative to one segment, in metres on a local flat-earth projection
/// (accurate to well under 1% over the few-kilometre scale of a city).
class SegmentOffset {
  const SegmentOffset(this.distanceM, this.isLeft, this.eastM, this.northM,
      {this.rawT = 0.5, this.alongBeyondM = 0, this.perpM = 0, this.lenM = 0});
  final double distanceM;

  /// True when the point is to the left of the segment, looking from its start to its end.
  /// Points exactly on the line count as left; callers treat distance 0 separately.
  final bool isLeft;

  /// Vector from the nearest point on the segment to the point.
  final double eastM, northM;

  /// Position of the point's projection along the segment: 0 at the start, 1 at the end,
  /// outside 0..1 when the point lies beyond an end.
  final double rawT;

  /// Metres beyond the nearest end along the line (0 when the projection falls on the segment).
  final double alongBeyondM;

  /// Perpendicular distance to the infinite line through the segment.
  final double perpM;

  /// Segment length in metres.
  final double lenM;
}

SegmentOffset segmentOffset(double lat, double lng, LatLngPoint a, LatLngPoint b) {
  const mPerDegLat = 110540.0;
  final mPerDegLng = 111320.0 * cos(lat * pi / 180);
  double x(double v) => (v - lng) * mPerDegLng;
  double y(double v) => (v - lat) * mPerDegLat;
  final ax = x(a.lng), ay = y(a.lat), bx = x(b.lng), by = y(b.lat);
  final dx = bx - ax, dy = by - ay;
  final len2 = dx * dx + dy * dy;
  final rawT = len2 == 0 ? 0.0 : (-ax * dx - ay * dy) / len2;
  final t = rawT.clamp(0.0, 1.0);
  final px = ax + t * dx, py = ay + t * dy;
  final len = sqrt(len2);
  final beyond = rawT < 0 ? -rawT * len : (rawT > 1 ? (rawT - 1) * len : 0.0);
  // The point sits at the origin, so the vector from the line to it is (-px, -py).
  // Left of a->b means cross(b-a, point-a) > 0.
  final cross = dx * (0 - ay) - dy * (0 - ax);
  return SegmentOffset(sqrt(px * px + py * py), cross >= 0, -px, -py,
      rawT: rawT, alongBeyondM: beyond, lenM: len, perpM: len == 0 ? sqrt(px * px + py * py) : cross.abs() / len);
}

/// Metres from a point to a segment.
double distanceToSegmentM(double lat, double lng, LatLngPoint a, LatLngPoint b) =>
    segmentOffset(lat, lng, a, b).distanceM;

/// Checks a point against every possible-acquisition area.
/// Inside beats near; among several hits the closest one is reported.
RiskResult acquisitionRisk(double lat, double lng, Iterable<MapOverlay> overlays,
    {double nearMeters = 100}) {
  RiskResult best = RiskResult.none;
  double? bestDist;
  for (final o in overlays.where((o) => o.isArea)) {
    if (o.contains(lat, lng)) return RiskResult(RiskLevel.inside, o, 0);
    var d = double.infinity;
    for (var i = 0; i < o.points.length - 1; i++) {
      d = min(d, distanceToSegmentM(lat, lng, o.points[i], o.points[i + 1]));
    }
    if (d <= nearMeters && (bestDist == null || d < bestDist)) {
      bestDist = d;
      best = RiskResult(RiskLevel.near, o, d);
    }
  }
  return best;
}

/// Line layers that can have a land-taking corridor.
const corridorKinds = [OverlayKind.roadWidening, OverlayKind.ringRoad, OverlayKind.metro];

/// Checks a point against the corridors of one line layer (road widening by default).
///
/// A corridor reaches `corridor_left_m` / `corridor_right_m` from the centre line, or half of
/// `corridor_width_m` each side when those are absent. Each side is measured separately, so a
/// one-sided widening only flags land on the side that is taken. Lines with no stated extent are
/// never guessed; if one is close, [RiskResult.widthUnknown] is set.
RiskResult corridorRisk(double lat, double lng, Iterable<MapOverlay> overlays,
    {double nearMeters = 100, OverlayKind kind = OverlayKind.roadWidening}) {
  RiskResult best = RiskResult.none;
  for (final o in overlays.where((o) => o.kind == kind)) {
    final ext = o.corridor;
    var nearest = double.infinity;
    var bestEdge = double.infinity;
    var bestReach = 0.0;
    SegmentOffset? at;
    for (var i = 0; i < o.points.length - 1; i++) {
      final off = segmentOffset(lat, lng, o.points[i], o.points[i + 1]);
      nearest = min(nearest, off.distanceM);
      if (ext == null) continue;
      // On the centre line either side's extent applies, so use the larger.
      final reach = off.distanceM == 0
          ? max(ext.left, ext.right)
          : (off.isLeft ? ext.left : ext.right);
      final edge = _segmentEdge(
          off, ext, reach, i == 0 ? o.startAngleDeg : null,
          i == o.points.length - 2 ? o.endAngleDeg : null);
      if (edge < bestEdge) {
        bestEdge = edge;
        bestReach = reach;
        at = off;
      }
    }
    if (ext == null) {
      if (nearest <= nearMeters && best.risk == RiskLevel.none) {
        best = RiskResult(RiskLevel.near, o, nearest, true);
      }
      continue;
    }
    final side = ext.left == ext.right || at == null || at.distanceM == 0 ? null : _compass(at);
    // A corridor that takes nothing (0 m both sides) is never "inside".
    if (bestEdge <= 0 && bestReach > 0) return RiskResult(RiskLevel.inside, o, 0, false, side);
    if (bestEdge.clamp(0, double.infinity) <= nearMeters &&
        (best.risk == RiskLevel.none || best.widthUnknown || max(0.0, bestEdge) < best.distanceM!)) {
      best = RiskResult(RiskLevel.near, o, max(0.0, bestEdge), false, side);
    }
  }
  return best;
}

Compass _compass(SegmentOffset o) => o.eastM.abs() >= o.northM.abs()
    ? (o.eastM >= 0 ? Compass.east : Compass.west)
    : (o.northM >= 0 ? Compass.north : Compass.south);

/// Distance in metres from the point to the corridor of one segment (0 or less = inside).
///
/// The corridor is a strip along the segment, [ext.left] / [ext.right] wide on each side.
/// A round end adds a cap around the end point. A cut end (angle given) stops the strip
/// along a straight line, turned [angle] degrees anticlockwise from square (seen from
/// above, north up), with no cap beyond it.
double _segmentEdge(SegmentOffset off, ({double left, double right}) ext, double reach,
    double? startAngle, double? endAngle) {
  var best = double.infinity;
  if (startAngle == null && off.rawT < 0) best = min(best, off.distanceM - reach);
  if (endAngle == null && off.rawT > 1) best = min(best, off.distanceM - reach);

  // Strip in (a, l) metres: a runs along the segment from its start, l is sideways, left positive.
  final len = off.lenM;
  final pa = off.rawT * len, pl = off.isLeft ? off.perpM : -off.perpM;
  double cutStart(double l) => startAngle == null ? 0 : -l * tan(startAngle * pi / 180);
  double cutEnd(double l) => endAngle == null ? len : len - l * tan(endAngle * pi / 180);
  final quad = [
    (a: cutStart(-ext.right), l: -ext.right),
    (a: cutEnd(-ext.right), l: -ext.right),
    (a: cutEnd(ext.left), l: ext.left),
    (a: cutStart(ext.left), l: ext.left),
  ];
  return min(best, _distanceToQuad(pa, pl, quad));
}

/// 0 when inside the (convex) quadrilateral, otherwise the distance to its outline.
double _distanceToQuad(double pa, double pl, List<({double a, double l})> q) {
  var allLeft = true, allRight = true;
  var d = double.infinity;
  for (var i = 0; i < 4; i++) {
    final u = q[i], v = q[(i + 1) % 4];
    final ea = v.a - u.a, el = v.l - u.l;
    final cross = ea * (pl - u.l) - el * (pa - u.a);
    if (cross < 0) allLeft = false;
    if (cross > 0) allRight = false;
    final len2 = ea * ea + el * el;
    final t = len2 == 0 ? 0.0 : (((pa - u.a) * ea + (pl - u.l) * el) / len2).clamp(0.0, 1.0);
    d = min(d, sqrt(pow(pa - (u.a + t * ea), 2) + pow(pl - (u.l + t * el), 2)));
  }
  return allLeft || allRight ? 0 : d;
}
