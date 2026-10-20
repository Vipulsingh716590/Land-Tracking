enum SourceKind { wms, xyz, zonesGeojson, overlaysGeojson }

/// An official data endpoint the user has added (for example a Bhuvan WMS layer or a
/// GeoJSON file published by a department). The app never ships endpoints it has not
/// verified; the user adds the ones they are entitled to use.
class DataSource {
  const DataSource({
    required this.id,
    required this.name,
    required this.kind,
    required this.url,
    this.layers = '',
    this.headerName = '',
    this.headerValue = '',
    required this.note,
    this.enabled = true,
    this.lastFetched,
    this.lastCount,
  });

  final String id, name, url, layers, headerName, headerValue, note;
  final SourceKind kind;
  final bool enabled;
  final String? lastFetched;
  final int? lastCount;

  bool get isRaster => kind == SourceKind.wms || kind == SourceKind.xyz;
  bool get isGeojson => !isRaster;

  Map<String, String> get headers => {if (headerName.isNotEmpty) headerName: headerValue};

  DataSource copyWith({bool? enabled, String? lastFetched, int? lastCount}) => DataSource(
        id: id, name: name, kind: kind, url: url, layers: layers, headerName: headerName,
        headerValue: headerValue, note: note, enabled: enabled ?? this.enabled,
        lastFetched: lastFetched ?? this.lastFetched, lastCount: lastCount ?? this.lastCount,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'kind': kind.name, 'url': url, 'layers': layers,
        'header_name': headerName, 'header_value': headerValue, 'note': note,
        'enabled': enabled, 'last_fetched': lastFetched, 'last_count': lastCount,
      };

  factory DataSource.fromJson(Map<String, dynamic> j) => DataSource(
        id: j['id'], name: j['name'], kind: SourceKind.values.byName(j['kind']), url: j['url'],
        layers: j['layers'] ?? '', headerName: j['header_name'] ?? '',
        headerValue: j['header_value'] ?? '', note: j['note'], enabled: j['enabled'] ?? true,
        lastFetched: j['last_fetched'], lastCount: j['last_count'],
      );
}

/// Returns an error key for the first problem found, or null when the source is usable.
/// Keys: name, note, url, https, layers, template.
String? validateSource({
  required String name,
  required String note,
  required String url,
  required SourceKind kind,
  required String layers,
}) {
  if (name.trim().isEmpty) return 'name';
  if (note.trim().isEmpty) return 'note'; // every layer must say where its data comes from
  final u = Uri.tryParse(url.trim());
  if (u == null || u.host.isEmpty) return 'url';
  if (u.scheme != 'https') return 'https';
  if (kind == SourceKind.wms && splitLayers(layers).isEmpty) return 'layers';
  if (kind == SourceKind.xyz && !(url.contains('{z}') && url.contains('{x}') && url.contains('{y}'))) {
    return 'template';
  }
  return null;
}

/// WMS layer names, comma separated in the form.
List<String> splitLayers(String s) =>
    [for (final l in s.split(',')) if (l.trim().isNotEmpty) l.trim()];
