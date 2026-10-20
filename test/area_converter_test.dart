import 'package:ayodhya_zameen/features/calculator/domain/area_converter.dart';
import 'package:ayodhya_zameen/features/calculator/domain/unit_rule.dart';
import 'package:flutter_test/flutter_test.dart';

// Test-only rules with round numbers; not real district data.
const ayodhya = UnitRule(
    id: 'a', district: 'A', unitName: 'pakka', biswaPerBigha: 8,
    sqftPerBiswa: 3000, sourceNote: 't', updatedOn: '2026-01-01');
const gonda = UnitRule(
    id: 'g', district: 'G', unitName: 'kachcha', biswaPerBigha: 20,
    sqftPerBiswa: 100, sourceNote: 't', updatedOn: '2026-01-01');

void main() {
  test('bigha size comes from the district rule', () {
    expect(const AreaConverter(ayodhya).convert(1, AreaUnit.bigha, AreaUnit.sqft), 24000);
    expect(const AreaConverter(gonda).convert(1, AreaUnit.bigha, AreaUnit.sqft), 2000);
  });

  test('bigha to biswa follows biswa_per_bigha', () {
    expect(const AreaConverter(ayodhya).convert(1, AreaUnit.bigha, AreaUnit.biswa), 8);
    expect(const AreaConverter(gonda).convert(1, AreaUnit.bigha, AreaUnit.biswa), 20);
  });

  test('biswa to biswansi uses the rule', () {
    expect(const AreaConverter(gonda).convert(1, AreaUnit.biswa, AreaUnit.biswansi), 20);
  });

  test('fixed units', () {
    const c = AreaConverter(gonda);
    expect(c.convert(1, AreaUnit.sqyd, AreaUnit.sqft), 9);
    expect(c.convert(1, AreaUnit.acre, AreaUnit.sqft), 43560);
    expect(c.convert(1, AreaUnit.sqm, AreaUnit.sqft), closeTo(10.7639, 1e-4));
  });

  test('round trip', () {
    const c = AreaConverter(ayodhya);
    for (final u in AreaUnit.values) {
      expect(c.convert(c.convert(7.5, AreaUnit.acre, u), u, AreaUnit.acre),
          closeTo(7.5, 1e-9));
    }
  });

  test('total price', () {
    expect(
        const AreaConverter(gonda).totalPrice(
            area: 2, areaUnit: AreaUnit.bigha, rate: 1000, rateUnit: AreaUnit.biswa),
        40000);
    expect(
        const AreaConverter(gonda).totalPrice(
            area: 500, areaUnit: AreaUnit.sqft, rate: 10, rateUnit: AreaUnit.sqft),
        5000);
  });
}
