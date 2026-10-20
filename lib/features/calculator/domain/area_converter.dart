import 'unit_rule.dart';

enum AreaUnit { bigha, biswa, biswansi, sqft, sqyd, sqm, acre }

/// Physical standards (not district dependent).
const double sqftPerSqYd = 9;
const double sqftPerSqM = 10.7639104;
const double sqftPerAcre = 43560;

class AreaConverter {
  const AreaConverter(this.rule);

  /// District rule supplying the bigha / biswa / biswansi sizes.
  final UnitRule rule;

  double sqftPer(AreaUnit u) {
    switch (u) {
      case AreaUnit.bigha:
        return rule.biswaPerBigha * rule.sqftPerBiswa;
      case AreaUnit.biswa:
        return rule.sqftPerBiswa;
      case AreaUnit.biswansi:
        return rule.sqftPerBiswa / rule.biswansiPerBiswa;
      case AreaUnit.sqft:
        return 1;
      case AreaUnit.sqyd:
        return sqftPerSqYd;
      case AreaUnit.sqm:
        return sqftPerSqM;
      case AreaUnit.acre:
        return sqftPerAcre;
    }
  }

  double convert(double value, AreaUnit from, AreaUnit to) =>
      value * sqftPer(from) / sqftPer(to);

  Map<AreaUnit, double> convertAll(double value, AreaUnit from) =>
      {for (final u in AreaUnit.values) u: convert(value, from, u)};

  /// Total price for [area] given in [areaUnit], at [rate] per [rateUnit].
  double totalPrice({
    required double area,
    required AreaUnit areaUnit,
    required double rate,
    required AreaUnit rateUnit,
  }) =>
      convert(area, areaUnit, rateUnit) * rate;
}
