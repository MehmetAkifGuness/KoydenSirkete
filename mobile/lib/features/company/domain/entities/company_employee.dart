class CompanyEmployee {
  const CompanyEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.performance,
    required this.dailySalary,
    this.requiredCompanyLevel = 1,
    this.morale = 70,
    this.loyalty = 70,
  });

  final int id;
  final String name;
  final String role;
  final int performance;
  final int dailySalary;
  final int requiredCompanyLevel;
  final int morale;
  final int loyalty;

  int get effectivePerformance =>
      (performance * (1 + (morale - 70) / 200)).round().clamp(0, 100).toInt();
  bool get isFullyDeveloped =>
      performance >= 100 && morale >= 100 && loyalty >= 100;

  CompanyEmployee copyWith({int? performance, int? morale, int? loyalty}) =>
      CompanyEmployee(
        id: id,
        name: name,
        role: role,
        performance: performance ?? this.performance,
        dailySalary: dailySalary,
        requiredCompanyLevel: requiredCompanyLevel,
        morale: morale ?? this.morale,
        loyalty: loyalty ?? this.loyalty,
      );
}
