enum CompanyEmployeeSeniority {
  junior('Başlangıç', 60),
  specialist('Uzman', 180),
  senior('Kıdemli', 360),
  lead('Lider', null);

  const CompanyEmployeeSeniority(this.label, this.nextPromotionExperience);

  final String label;
  final int? nextPromotionExperience;

  CompanyEmployeeSeniority? get next => switch (this) {
    CompanyEmployeeSeniority.junior => CompanyEmployeeSeniority.specialist,
    CompanyEmployeeSeniority.specialist => CompanyEmployeeSeniority.senior,
    CompanyEmployeeSeniority.senior => CompanyEmployeeSeniority.lead,
    CompanyEmployeeSeniority.lead => null,
  };
}

class CompanyEmployee {
  static const _unset = Object();

  const CompanyEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.performance,
    required this.dailySalary,
    this.requiredCompanyLevel = 1,
    this.morale = 70,
    this.loyalty = 70,
    this.experience = 0,
    this.seniority = CompanyEmployeeSeniority.junior,
    this.burnout = 0,
    this.requestedDailySalary,
  });

  final int id;
  final String name;
  final String role;
  final int performance;
  final int dailySalary;
  final int requiredCompanyLevel;
  final int morale;
  final int loyalty;
  final int experience;
  final CompanyEmployeeSeniority seniority;
  final int burnout;
  final int? requestedDailySalary;

  int get effectivePerformance =>
      (performance * (1 + (morale - 70) / 200) * (1 - burnout * .004))
          .round()
          .clamp(0, 100)
          .toInt();
  bool get isFullyDeveloped =>
      performance >= 100 && morale >= 100 && loyalty >= 100 && burnout <= 0;
  bool get hasRaiseRequest => requestedDailySalary != null;
  bool get canBePromoted =>
      seniority.next != null &&
      experience >= (seniority.nextPromotionExperience ?? 1 << 30);

  CompanyEmployee copyWith({
    int? performance,
    int? dailySalary,
    int? morale,
    int? loyalty,
    int? experience,
    CompanyEmployeeSeniority? seniority,
    int? burnout,
    Object? requestedDailySalary = _unset,
  }) => CompanyEmployee(
    id: id,
    name: name,
    role: role,
    performance: performance ?? this.performance,
    dailySalary: dailySalary ?? this.dailySalary,
    requiredCompanyLevel: requiredCompanyLevel,
    morale: morale ?? this.morale,
    loyalty: loyalty ?? this.loyalty,
    experience: experience ?? this.experience,
    seniority: seniority ?? this.seniority,
    burnout: burnout ?? this.burnout,
    requestedDailySalary: identical(requestedDailySalary, _unset)
        ? this.requestedDailySalary
        : requestedDailySalary as int?,
  );
}
