import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/widgets/demo_badge.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../calculator/presentation/calculator_screen.dart' show fmt, unitLabel;
import '../../plots/data/plots_repository.dart';
import '../../plots/domain/models.dart';
import '../../plots/presentation/plot_card.dart';
import '../../plots/presentation/plot_form.dart';
import '../../plots/presentation/plots_screen.dart' show filterPlots, plotRiskLevel;
import '../../calculator/data/unit_rules_repository.dart';
import '../../settings/settings_controller.dart';
import '../data/zones_repository.dart';
import '../../osm/osm_repository.dart';
import '../../sources/data_source.dart';
import '../../sources/data_sources_repository.dart';
import '../../osm/osm_way.dart';
import '../domain/acquisition_risk.dart';
import '../domain/overlay.dart';
import '../domain/zone.dart';

const _ayodhya = LatLng(26.7922, 82.1998);
const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Metres on the ground covered by one screen pixel at this zoom and latitude.
double metersPerPixel(double zoom, double lat) =>
    156543.03392 * math.cos(lat * math.pi / 180) / math.pow(2, zoom);

Color zoneColour(String c) => switch (c) {
      'red' => Colors.red,
      'yellow' => Colors.amber,
      'green' => Colors.green,
      _ => Colors.grey,
    };

Color overlayColour(OverlayKind k) => switch (k) {
      OverlayKind.metro => Colors.indigo,
      OverlayKind.ringRoad => Colors.deepPurple,
      OverlayKind.roadWidening => Colors.brown,
      OverlayKind.acquisition => Colors.pink,
    };

String overlayLabel(AppLocalizations t, OverlayKind k) => switch (k) {
      OverlayKind.metro => t.layerMetro,
      OverlayKind.ringRoad => t.layerRingRoad,
      OverlayKind.roadWidening => t.layerWidening,
      OverlayKind.acquisition => t.layerAcquisition,
    };

Color osmColour(OsmKind k) => switch (k) {
      OsmKind.majorRoad => Colors.blueGrey,
      OsmKind.roadWorks => Colors.orange,
      OsmKind.rail => Colors.black87,
      OsmKind.railWorks => Colors.grey,
      OsmKind.river => Colors.blue,
    };

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _controller = MapController();
  ({double lat, double lng, Zone? zone, bool inAcquisition})? tapped;
  MapOverlay? tappedOverlay;
  OsmWay? tappedOsm;

  double _distanceToLine(double lat, double lng, List<LatLngPoint> pts) {
    var d = double.infinity;
    for (var i = 0; i < pts.length - 1; i++) {
      d = math.min(d, distanceToSegmentM(lat, lng, pts[i], pts[i + 1]));
    }
    return d;
  }

  void _onTap(LatLng p, List<Zone> zones, List<MapOverlay> shown, List<OsmWay> osm) {
    // Lines are thin, so a tap counts when it lands within ~14 screen pixels of one.
    final tol = 14 * metersPerPixel(_controller.camera.zoom, p.latitude);
    MapOverlay? bestOverlay;
    OsmWay? bestOsm;
    var best = tol;
    for (final o in shown.where((o) => !o.isArea)) {
      final d = _distanceToLine(p.latitude, p.longitude, o.points);
      if (d <= best) {
        best = d;
        bestOverlay = o;
        bestOsm = null;
      }
    }
    for (final w in osm) {
      final d = _distanceToLine(p.latitude, p.longitude, w.points);
      if (d < best) {
        best = d;
        bestOsm = w;
        bestOverlay = null;
      }
    }
    if (bestOverlay != null || bestOsm != null) {
      setState(() {
        tapped = null;
        tappedOverlay = bestOverlay;
        tappedOsm = bestOsm;
      });
      return;
    }
    final hit = zones.where((z) => z.contains(p.latitude, p.longitude));
    final acq = shown.any((o) => o.contains(p.latitude, p.longitude));
    setState(() {
      tappedOverlay = null;
      tappedOsm = null;
      tapped = (lat: p.latitude, lng: p.longitude, zone: hit.firstOrNull, inAcquisition: acq);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = ref.watch(settingsProvider).locale.languageCode;
    final year = ref.watch(planYearProvider);
    final zonesAsync = ref.watch(zonesProvider);

    return zonesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${t.mapLoadError}: $e')),
      data: (all) {
        final zones = all.where((z) => z.planYear == year).toList();
        LatLng ll(LatLngPoint p) => LatLng(p.lat, p.lng);
        final zonePolygons = [
          for (final z in zones)
            for (final ring in z.rings)
              Polygon(
                points: [for (final p in ring) ll(p)],
                color: zoneColour(z.colour).withValues(alpha: 0.4),
                borderColor: zoneColour(z.colour),
                borderStrokeWidth: 2,
              ),
        ];
        final plots = filterPlots(ref.watch(plotsProvider),
            ref.watch(unitRulesProvider), ref.watch(plotFiltersProvider));
        final disputes = ref.watch(disputesProvider);
        final allOverlays = ref.watch(overlaysProvider).value ?? const <MapOverlay>[];
        final markers = [
          for (final p in plots)
            Marker(
              point: LatLng(p.lat, p.lng),
              width: 44,
              height: 44,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => showPlotCard(context, p.id),
                child: Tooltip(
                  message: '${p.location}  ₹ ${fmt(p.ratePerUnit)} / ${unitLabel(t, p.rateUnit)}',
                  child: Icon(Icons.location_on, size: 44, color: switch (plotRiskLevel(p, allOverlays)) {
                    RiskLevel.inside => Colors.deepOrange,
                    RiskLevel.near => Colors.amber.shade700,
                    RiskLevel.none => Theme.of(context).colorScheme.primary,
                  }),
                ),
              ),
            ),
        ];
        final circles = [
          for (final d in disputes.where((d) => d.status == DisputeStatus.pending))
            if (plots.where((p) => p.id == d.plotId).firstOrNull case final p?)
              CircleMarker(
                point: LatLng(p.lat, p.lng),
                radius: 120,
                useRadiusInMeter: true,
                color: Colors.red.withValues(alpha: 0.25),
                borderColor: Colors.red,
                borderStrokeWidth: 3,
              ),
        ];
        final visible = ref.watch(visibleOverlaysProvider);
        final shown = [for (final o in allOverlays) if (visible.contains(o.kind)) o];
        final overlayLines = [
          for (final o in shown.where((o) => !o.isArea))
            Polyline(
              points: [for (final p in o.points) ll(p)],
              color: overlayColour(o.kind),
              strokeWidth: o.kind == OverlayKind.roadWidening ? 4 : 6,
              pattern: o.kind == OverlayKind.roadWidening
                  ? StrokePattern.dashed(segments: const [20, 10])
                  : const StrokePattern.solid(),
            ),
        ];
        final osmOn = ref.watch(osmVisibleProvider);
        final osm = ref.watch(osmProvider);
        final osmWays = osmOn ? (osm.value?.ways ?? const <OsmWay>[]) : const <OsmWay>[];
        final osmLines = [
          for (final w in osmWays)
            Polyline(
              points: [for (final p in w.points) ll(p)],
              color: osmColour(w.kind),
              strokeWidth: 3,
              pattern: (w.kind == OsmKind.roadWorks || w.kind == OsmKind.railWorks)
                  ? StrokePattern.dashed(segments: const [12, 8])
                  : const StrokePattern.solid(),
            ),
        ];
        final acqPolygons = [
          for (final o in shown.where((o) => o.isArea))
            Polygon(
              points: [for (final p in o.points) ll(p)],
              color: overlayColour(o.kind).withValues(alpha: 0.2),
              borderColor: overlayColour(o.kind),
              borderStrokeWidth: 3,
            ),
        ];
        final rasterSources = [for (final x in ref.watch(dataSourcesProvider)) if (x.isRaster && x.enabled) x];
        final legend = {for (final z in zones) z.type(lang): z.colour};

        return Stack(children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _ayodhya,
              initialZoom: 13,
              minZoom: 5,
              maxZoom: 19,
              onTap: (_, p) => _onTap(p, zones, shown, osmWays),
              onLongPress: (_, p) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PlotForm(lat: p.latitude, lng: p.longitude))),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'com.example.ayodhya_zameen',
                maxNativeZoom: 19,
              ),
              for (final src in rasterSources)
                Opacity(
                  opacity: 0.75,
                  child: src.kind == SourceKind.wms
                      ? TileLayer(
                          wmsOptions: WMSTileLayerOptions(
                            baseUrl: src.url.contains('?') ? src.url : '${src.url}?',
                            layers: splitLayers(src.layers),
                          ),
                          tileProvider: NetworkTileProvider(headers: src.headers),
                          userAgentPackageName: 'com.example.ayodhya_zameen',
                        )
                      : TileLayer(
                          urlTemplate: src.url,
                          tileProvider: NetworkTileProvider(headers: src.headers),
                          userAgentPackageName: 'com.example.ayodhya_zameen',
                        ),
                ),
              PolygonLayer(polygons: [...zonePolygons, ...acqPolygons]),
              PolylineLayer(polylines: [...osmLines, ...overlayLines]),
              CircleLayer(circles: circles),
              MarkerLayer(markers: markers),
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
                alignment: Alignment.bottomRight,
              ),
            ],
          ),
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Text('${t.planYear}: $year',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    const DemoBadge(),
                  ]),
                  Slider(
                    min: 0,
                    max: (planYears.length - 1).toDouble(),
                    divisions: planYears.length - 1,
                    value: planYears.indexOf(year).toDouble(),
                    label: '$year',
                    onChanged: (v) => ref
                        .read(planYearProvider.notifier)
                        .set(planYears[v.round()]),
                  ),
                  Wrap(spacing: 6, children: [
                    FilterChip(
                      visualDensity: VisualDensity.compact,
                      avatar: osm.isLoading
                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.public, size: 14),
                      label: Text(t.layerOsm),
                      selected: osmOn,
                      onSelected: (_) => ref.read(osmVisibleProvider.notifier).toggle(),
                    ),
                    for (final src in ref.watch(dataSourcesProvider).where((x) => x.isRaster))
                      FilterChip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(Icons.layers, size: 14),
                        label: Text(src.name),
                        selected: src.enabled,
                        onSelected: (v) => ref.read(dataSourcesProvider.notifier).setEnabled(src.id, v),
                      ),
                    for (final k in OverlayKind.values)
                      FilterChip(
                        visualDensity: VisualDensity.compact,
                        avatar: Icon(Icons.circle, size: 12, color: overlayColour(k)),
                        label: Text(overlayLabel(t, k)),
                        selected: visible.contains(k),
                        onSelected: (_) =>
                            ref.read(visibleOverlaysProvider.notifier).toggle(k),
                      ),
                  ]),
                  Wrap(spacing: 12, children: [
                    for (final e in legend.entries)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.square, size: 14, color: zoneColour(e.value)),
                        const SizedBox(width: 4),
                        Text(e.key, style: Theme.of(context).textTheme.bodySmall),
                      ]),
                  ]),
                ]),
              ),
            ),
          ),
          if (osmOn)
            Positioned(
              left: 8,
              bottom: tapped != null || tappedOverlay != null || tappedOsm != null ? 150 : 8,
              child: _OsmCredit(data: osm.value, loading: osm.isLoading,
                  onRefresh: () => ref.read(osmProvider.notifier).refresh()),
            ),
          if (tappedOsm != null)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: _OsmCard(way: tappedOsm!, lang: lang, onClose: () => setState(() => tappedOsm = null)),
            ),
          if (tappedOverlay != null)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: _OverlayCard(
                lang: lang,
                overlay: tappedOverlay!,
                onClose: () => setState(() => tappedOverlay = null),
              ),
            ),
          if (tapped != null)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: _ZoneCard(
                lang: lang,
                zone: tapped!.zone,
                inAcquisition: tapped!.inAcquisition,
                year: year,
                onClose: () => setState(() => tapped = null),
              ),
            ),
        ]);
      },
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard(
      {required this.lang,
      required this.zone,
      required this.inAcquisition,
      required this.year,
      required this.onClose});
  final String lang;
  final Zone? zone;
  final bool inAcquisition;
  final int year;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final z = zone;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(z == null ? t.noZoneHere : z.name(lang),
                        style: Theme.of(context).textTheme.titleMedium)),
                if (z?.isDemo ?? false) const DemoBadge(),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ]),
              if (z != null) ...[
                Text('${t.zoneType}: ${z.type(lang)}'),
                Text('${t.heightLimit}: '
                    '${z.heightLimitM == null ? t.notSet : '${z.heightLimitM!.toStringAsFixed(0)} m'}'),
                Text('${t.planYear}: ${z.planYear}'),
                Text('${t.source}: ${z.source}'),
                Text('${t.lastUpdated}: ${z.updatedOn}'),
              ] else
                Text('${t.planYear}: $year'),
              if (inAcquisition)
                Text(t.acquisitionWarning,
                    style: TextStyle(color: overlayColour(OverlayKind.acquisition))),
            ]),
      ),
    );
  }
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({required this.lang, required this.overlay, required this.onClose});
  final String lang;
  final MapOverlay overlay;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(overlay.name(lang),
                        style: Theme.of(context).textTheme.titleMedium)),
                if (overlay.isDemo) const DemoBadge(),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ]),
              if (overlay.corridor case final c?)
                Text(overlay.corridorLeftM != null || overlay.corridorRightM != null
                    ? t.corridorSides(c.left.toStringAsFixed(0), c.right.toStringAsFixed(0))
                    : '${t.corridorWidth}: ${(c.left + c.right).toStringAsFixed(0)} m'),
              if (overlay.corridor != null && overlay.hasCutEnds)
                Text(overlay.squareEnds
                    ? t.corridorSquareEnds
                    : t.corridorAngledEnds(overlay.startAngleDeg!.toStringAsFixed(0),
                        overlay.endAngleDeg!.toStringAsFixed(0))),
              Text('${t.source}: ${overlay.source}'),
              Text('${t.lastUpdated}: ${overlay.updatedOn}'),
            ]),
      ),
    );
  }
}

class _OsmCredit extends StatelessWidget {
  const _OsmCredit({required this.data, required this.loading, required this.onRefresh});
  final OsmData? data;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final d = data;
    final status = loading
        ? t.osmLoading
        : d == null || d.fetchedAt == null
            ? '${t.osmFailed}${d?.error == null ? '' : ': ${d!.error}'}'
            : '${t.osmUpdated}: ${d.fetchedAt!.substring(0, 10)}${d.fromCache ? ' (${t.osmSaved})' : ''}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('© OpenStreetMap contributors · $status', style: Theme.of(context).textTheme.labelSmall),
          IconButton(
            tooltip: t.refresh, visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.refresh, size: 18), onPressed: loading ? null : onRefresh),
        ]),
      ),
    );
  }
}

class _OsmCard extends StatelessWidget {
  const _OsmCard({required this.way, required this.lang, required this.onClose});
  final OsmWay way;
  final String lang;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(way.name.isEmpty ? osmKindName(way.kind, lang) : way.name,
                        style: Theme.of(context).textTheme.titleMedium)),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ]),
              Text(osmKindName(way.kind, lang)),
              Text('${t.source}: OpenStreetMap (${way.url}), ODbL'),
              Text(t.osmNotOfficial, style: const TextStyle(color: Colors.red)),
            ]),
      ),
    );
  }
}
