import 'package:csv/csv.dart';

import '../../calculator/domain/area_converter.dart';
import '../../calculator/domain/unit_rule.dart';
import '../domain/models.dart';

class CsvRowError {
  const CsvRowError(this.row, this.reason);
  final int row; // 1-based, header is row 1
  final String reason;
}

class CsvImportResult {
  const CsvImportResult(this.plots, this.errors);
  final List<Plot> plots;
  final List<CsvRowError> errors;
}

const csvColumns = [
  'location', 'lat', 'lng', 'khasra_no', 'village', 'tehsil', 'area', 'area_unit', 'rate_per_unit',
  'rate_unit', 'district', 'status', 'risk_note', 'source', 'updated_on',
];

const _required = [
  'location', 'lat', 'lng', 'area', 'area_unit', 'rate_per_unit', 'rate_unit',
  'district', 'source',
];

/// Rows without a `source` are rejected: the app never stores a rate that
/// has no stated origin. Units are the AreaUnit names (bigha, biswa, sqft...).
CsvImportResult parsePlotsCsv(String text, List<UnitRule> rules, String today) {
  final rows = csv.decode(text);
  if (rows.isEmpty) return const CsvImportResult([], [CsvRowError(1, 'empty file')]);
  final header = [for (final h in rows.first) h.toString().trim().toLowerCase()];
  final missing = [for (final c in _required) if (!header.contains(c)) c];
  if (missing.isNotEmpty) {
    return CsvImportResult([], [CsvRowError(1, 'missing columns: ${missing.join(', ')}')]);
  }
  final plots = <Plot>[], errors = <CsvRowError>[];
  final stamp = DateTime.now().microsecondsSinceEpoch;
  for (var i = 1; i < rows.length; i++) {
    final r = rows[i];
    if (r.every((c) => c.toString().trim().isEmpty)) continue;
    String g(String c) {
      final k = header.indexOf(c);
      return k < 0 || k >= r.length ? '' : r[k].toString().trim();
    }

    void bad(String why) => errors.add(CsvRowError(i + 1, why));
    final lat = double.tryParse(g('lat')), lng = double.tryParse(g('lng'));
    final area = double.tryParse(g('area')), rate = double.tryParse(g('rate_per_unit'));
    final au = AreaUnit.values.asNameMap()[g('area_unit')];
    final ru = AreaUnit.values.asNameMap()[g('rate_unit')];
    final rule = rules.where((x) => x.district.toLowerCase() == g('district').toLowerCase()).firstOrNull;
    if (g('location').isEmpty) { bad('location empty'); continue; }
    if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) { bad('bad lat/lng'); continue; }
    if (area == null || area <= 0 || rate == null || rate < 0) { bad('bad area or rate'); continue; }
    if (au == null || ru == null) { bad('unknown unit (use bigha, biswa, biswansi, sqft, sqyd, sqm, acre)'); continue; }
    if (rule == null) { bad('district "${g('district')}" has no unit rule'); continue; }
    if (g('source').isEmpty) { bad('source is required'); continue; }
    final status = switch (g('status').toLowerCase()) {
      'sold' => PlotStatus.sold,
      'hold' => PlotStatus.hold,
      _ => PlotStatus.forSale,
    };
    plots.add(Plot(
      id: 'csv-$stamp-$i', location: g('location'), lat: lat, lng: lng,
      khasraNo: g('khasra_no'), village: g('village'), tehsil: g('tehsil'), area: area, areaUnit: au, ratePerUnit: rate,
      rateUnit: ru, ruleId: rule.id, status: status, riskNote: g('risk_note'),
      source: g('source'),
      updatedOn: g('updated_on').isEmpty ? today : g('updated_on'),
    ));
  }
  return CsvImportResult(plots, errors);
}
