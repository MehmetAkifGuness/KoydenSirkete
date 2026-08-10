class CompanyEmployee {
  const CompanyEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.performance,
    required this.dailySalary,
    this.requiredCompanyLevel = 1,
  });

  final int id;
  final String name;
  final String role;
  final int performance;
  final int dailySalary;
  final int requiredCompanyLevel;
}
