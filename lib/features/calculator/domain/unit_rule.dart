class UnitRule {
  const UnitRule({
    required this.id,
    required this.district,
    required this.unitName,
    required this.biswaPerBigha,
    required this.sqftPerBiswa,
    this.biswansiPerBiswa = 20,
    required this.sourceNote,
    required this.updatedOn,
    this.isDemo = false,
  });

  final String id;
  final String district;
  final String unitName;
  final double biswaPerBigha;
  final double sqftPerBiswa;
  final double biswansiPerBiswa;
  final String sourceNote;
  final String updatedOn;
  final bool isDemo;

  UnitRule copyWith({
    String? district,
    String? unitName,
    double? biswaPerBigha,
    double? sqftPerBiswa,
    double? biswansiPerBiswa,
    String? sourceNote,
    String? updatedOn,
    bool? isDemo,
  }) =>
      UnitRule(
        id: id,
        district: district ?? this.district,
        unitName: unitName ?? this.unitName,
        biswaPerBigha: biswaPerBigha ?? this.biswaPerBigha,
        sqftPerBiswa: sqftPerBiswa ?? this.sqftPerBiswa,
        biswansiPerBiswa: biswansiPerBiswa ?? this.biswansiPerBiswa,
        sourceNote: sourceNote ?? this.sourceNote,
        updatedOn: updatedOn ?? this.updatedOn,
        isDemo: isDemo ?? this.isDemo,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'district': district,
        'unit_name': unitName,
        'biswa_per_bigha': biswaPerBigha,
        'sqft_per_biswa': sqftPerBiswa,
        'biswansi_per_biswa': biswansiPerBiswa,
        'source_note': sourceNote,
        'updated_on': updatedOn,
        'is_demo': isDemo,
      };

  factory UnitRule.fromJson(Map<String, dynamic> j) => UnitRule(
        id: j['id'] as String,
        district: j['district'] as String,
        unitName: j['unit_name'] as String,
        biswaPerBigha: (j['biswa_per_bigha'] as num).toDouble(),
        sqftPerBiswa: (j['sqft_per_biswa'] as num).toDouble(),
        biswansiPerBiswa: (j['biswansi_per_biswa'] as num).toDouble(),
        sourceNote: j['source_note'] as String,
        updatedOn: j['updated_on'] as String,
        isDemo: j['is_demo'] as bool? ?? false,
      );
}
