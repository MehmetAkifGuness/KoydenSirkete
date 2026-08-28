import 'company_employee.dart';
import 'company_specialty.dart';

enum CompanyBranchLocalGoal {
  balanced(
    'Dengeli operasyon',
    'Gelir, maliyet ve ekip yükünü dengede tutar.',
    revenuePercent: 0,
    payrollPercent: 0,
  ),
  marketGrowth(
    'Pazar büyümesi',
    'Daha yüksek gelir için satış temposunu ve giderleri artırır.',
    revenuePercent: 12,
    payrollPercent: 5,
    burnoutDelta: 1,
  ),
  costControl(
    'Maliyet kontrolü',
    'Gelirden bir miktar vazgeçerek maaş maliyetini düşürür.',
    revenuePercent: -3,
    payrollPercent: -10,
    burnoutDelta: 1,
  ),
  teamDevelopment(
    'Ekip gelişimi',
    'Günlük gelir karşılığında deneyim ve dinlenme sağlar.',
    revenuePercent: -8,
    payrollPercent: 0,
    experienceGain: 2,
    burnoutDelta: -1,
  );

  const CompanyBranchLocalGoal(
    this.label,
    this.description, {
    required this.revenuePercent,
    required this.payrollPercent,
    this.experienceGain = 0,
    this.burnoutDelta = 0,
  });

  final String label;
  final String description;
  final int revenuePercent;
  final int payrollPercent;
  final int experienceGain;
  final int burnoutDelta;
}

class CompanyBranch {
  static const _unset = Object();

  const CompanyBranch({
    required this.id,
    required this.cityId,
    this.level = 1,
    this.employees = const <CompanyEmployee>[],
    this.managerEmployeeId,
    this.localGoal = CompanyBranchLocalGoal.balanced,
    this.specialty,
  });

  final int id;
  final int cityId;
  final int level;
  final List<CompanyEmployee> employees;
  final int? managerEmployeeId;
  final CompanyBranchLocalGoal localGoal;
  final CompanySpecialty? specialty;

  CompanyBranch copyWith({
    int? level,
    List<CompanyEmployee>? employees,
    Object? managerEmployeeId = _unset,
    CompanyBranchLocalGoal? localGoal,
    Object? specialty = _unset,
  }) => CompanyBranch(
    id: id,
    cityId: cityId,
    level: level ?? this.level,
    employees: employees ?? this.employees,
    managerEmployeeId: identical(managerEmployeeId, _unset)
        ? this.managerEmployeeId
        : managerEmployeeId as int?,
    localGoal: localGoal ?? this.localGoal,
    specialty: identical(specialty, _unset)
        ? this.specialty
        : specialty as CompanySpecialty?,
  );
}
