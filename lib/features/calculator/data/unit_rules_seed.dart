import '../domain/unit_rule.dart';

/// DEMO placeholders. The user has not yet confirmed any of these values.
/// Replace each one from UP revenue department records.
const unitRulesSeed = <UnitRule>[
  UnitRule(
    id: 'demo-ayodhya',
    district: 'Ayodhya / Faizabad',
    unitName: 'Pakka bigha',
    biswaPerBigha: 8,
    sqftPerBiswa: 3403.125,
    sourceNote:
        'DEMO placeholder: 8 biswa per bigha as given by owner; sq ft value is '
        'an assumption (27,225 sq ft / 8). Confirm at tehsil.',
    updatedOn: '2026-10-19',
    isDemo: true,
  ),
  UnitRule(
    id: 'demo-gonda',
    district: 'Gonda',
    unitName: 'Kachcha bigha',
    biswaPerBigha: 20,
    sqftPerBiswa: 136.125,
    sourceNote:
        'DEMO placeholder: 20 biswa per bigha as given by owner; sq ft value is '
        'an assumption. Confirm at tehsil.',
    updatedOn: '2026-10-19',
    isDemo: true,
  ),
];
