import '../../calculator/domain/area_converter.dart';
import '../../calculator/domain/unit_rule.dart';

enum PlotStatus { forSale, hold, sold }

AreaUnit _unit(String n) => AreaUnit.values.byName(n);

class Plot {
  const Plot({
    required this.id,
    required this.location,
    required this.lat,
    required this.lng,
    this.khasraNo = '',
    required this.area,
    required this.areaUnit,
    required this.ratePerUnit,
    required this.rateUnit,
    required this.ruleId,
    this.status = PlotStatus.forSale,
    this.riskNote = '',
    required this.source,
    required this.updatedOn,
    this.isDemo = false,
    this.favourite = false,
    this.watch = false,
  });

  final String id, location, khasraNo, riskNote, source, updatedOn, ruleId;
  final double lat, lng, area, ratePerUnit;
  final AreaUnit areaUnit, rateUnit;
  final PlotStatus status;
  final bool isDemo, favourite, watch;

  double totalPrice(UnitRule rule) => AreaConverter(rule).totalPrice(
      area: area, areaUnit: areaUnit, rate: ratePerUnit, rateUnit: rateUnit);

  double sqft(UnitRule rule) =>
      AreaConverter(rule).convert(area, areaUnit, AreaUnit.sqft);

  Plot copyWith({bool? favourite, bool? watch}) => Plot(
        id: id, location: location, lat: lat, lng: lng, khasraNo: khasraNo,
        area: area, areaUnit: areaUnit, ratePerUnit: ratePerUnit,
        rateUnit: rateUnit, ruleId: ruleId, status: status, riskNote: riskNote,
        source: source, updatedOn: updatedOn, isDemo: isDemo,
        favourite: favourite ?? this.favourite, watch: watch ?? this.watch,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'location': location, 'lat': lat, 'lng': lng,
        'khasra_no': khasraNo, 'area': area, 'area_unit': areaUnit.name,
        'rate_per_unit': ratePerUnit, 'rate_unit': rateUnit.name,
        'rule_id': ruleId, 'status': status.name, 'risk_note': riskNote,
        'source': source, 'updated_on': updatedOn, 'is_demo': isDemo,
        'favourite': favourite, 'watch': watch,
      };

  factory Plot.fromJson(Map<String, dynamic> j) => Plot(
        id: j['id'], location: j['location'],
        lat: (j['lat'] as num).toDouble(), lng: (j['lng'] as num).toDouble(),
        khasraNo: j['khasra_no'] ?? '', area: (j['area'] as num).toDouble(),
        areaUnit: _unit(j['area_unit']),
        ratePerUnit: (j['rate_per_unit'] as num).toDouble(),
        rateUnit: _unit(j['rate_unit']), ruleId: j['rule_id'],
        status: PlotStatus.values.byName(j['status']),
        riskNote: j['risk_note'] ?? '', source: j['source'],
        updatedOn: j['updated_on'], isDemo: j['is_demo'] ?? false,
        favourite: j['favourite'] ?? false, watch: j['watch'] ?? false,
      );
}

enum PersonRole { owner, previousOwner, dealer }

class Person {
  const Person(
      {required this.id,
      required this.role,
      required this.name,
      this.phone = '',
      required this.plotId});
  final String id, name, phone, plotId;
  final PersonRole role;

  Map<String, dynamic> toJson() => {
        'id': id, 'role': role.name, 'name': name, 'phone': phone,
        'plot_id': plotId,
      };
  factory Person.fromJson(Map<String, dynamic> j) => Person(
      id: j['id'], role: PersonRole.values.byName(j['role']),
      name: j['name'], phone: j['phone'] ?? '', plotId: j['plot_id']);
}

enum DisputeStatus { pending, resolved }

class Dispute {
  const Dispute({
    required this.id,
    required this.plotId,
    this.caseType = '',
    this.court = '',
    this.nextDate = '',
    this.status = DisputeStatus.pending,
    this.note = '',
    this.isDemo = false,
  });
  final String id, plotId, caseType, court, nextDate, note;
  final DisputeStatus status;
  final bool isDemo;

  Map<String, dynamic> toJson() => {
        'id': id, 'plot_id': plotId, 'case_type': caseType, 'court': court,
        'next_date': nextDate, 'status': status.name, 'note': note,
        'is_demo': isDemo,
      };
  factory Dispute.fromJson(Map<String, dynamic> j) => Dispute(
      id: j['id'], plotId: j['plot_id'], caseType: j['case_type'] ?? '',
      court: j['court'] ?? '', nextDate: j['next_date'] ?? '',
      status: DisputeStatus.values.byName(j['status']), note: j['note'] ?? '',
      isDemo: j['is_demo'] ?? false);
}
