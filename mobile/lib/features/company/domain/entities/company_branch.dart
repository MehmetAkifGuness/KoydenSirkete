import 'company_employee.dart';

class CompanyBranch {
  const CompanyBranch({
    required this.id,
    required this.cityId,
    this.level = 1,
    this.employees = const <CompanyEmployee>[],
  });

  final int id;
  final int cityId;
  final int level;
  final List<CompanyEmployee> employees;

  CompanyBranch copyWith({
    int? level,
    List<CompanyEmployee>? employees,
  }) => CompanyBranch(
        id: id,
        cityId: cityId,
        level: level ?? this.level,
        employees: employees ?? this.employees,
      );
}
