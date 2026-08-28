import 'dart:convert';

import '../../../company/domain/entities/company_branch.dart';
import '../../../company/domain/entities/company_employee.dart';
import '../../../company/domain/entities/company_specialty.dart';

class CompanyBranchCodec {
  String? encodeList(List<CompanyBranch> branches) {
    if (branches.isEmpty) return null;
    return jsonEncode(
      branches
          .map(
            (branch) => {
              'id': branch.id,
              'city_id': branch.cityId,
              'level': branch.level,
              'manager_employee_id': branch.managerEmployeeId,
              'local_goal': branch.localGoal.name,
              'specialty': branch.specialty?.name,
              'employees': branch.employees
                  .map(
                    (employee) => {
                      'id': employee.id,
                      'name': employee.name,
                      'role': employee.role,
                      'performance': employee.performance,
                      'daily_salary': employee.dailySalary,
                      'required_company_level': employee.requiredCompanyLevel,
                      'morale': employee.morale,
                      'loyalty': employee.loyalty,
                      'experience': employee.experience,
                      'seniority': employee.seniority.name,
                      'burnout': employee.burnout,
                      'requested_daily_salary': employee.requestedDailySalary,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    );
  }

  List<CompanyBranch> decodeList(String? value) {
    if (value == null || value.isEmpty) return const <CompanyBranch>[];
    try {
      final json = jsonDecode(value) as List<dynamic>;
      return List<CompanyBranch>.unmodifiable(json.map(_fromJson));
    } on Object {
      return const <CompanyBranch>[];
    }
  }

  CompanyBranch _fromJson(dynamic value) {
    final json = value as Map<String, dynamic>;
    final employees = (json['employees'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) {
          final employee = item as Map<String, dynamic>;
          return CompanyEmployee(
            id: employee['id'] as int,
            name: employee['name'] as String,
            role: employee['role'] as String,
            performance: employee['performance'] as int,
            dailySalary: employee['daily_salary'] as int,
            requiredCompanyLevel:
                employee['required_company_level'] as int? ?? 1,
            morale: employee['morale'] as int? ?? 70,
            loyalty: employee['loyalty'] as int? ?? 70,
            experience: employee['experience'] as int? ?? 0,
            seniority: _enumValue(
              CompanyEmployeeSeniority.values,
              employee['seniority'],
              CompanyEmployeeSeniority.junior,
            ),
            burnout: employee['burnout'] as int? ?? 0,
            requestedDailySalary: employee['requested_daily_salary'] as int?,
          );
        })
        .toList(growable: false);
    final managerEmployeeId = json['manager_employee_id'] as int?;
    return CompanyBranch(
      id: json['id'] as int,
      cityId: json['city_id'] as int,
      level: json['level'] as int? ?? 1,
      employees: employees,
      managerEmployeeId:
          employees.any((employee) => employee.id == managerEmployeeId)
          ? managerEmployeeId
          : null,
      localGoal: _enumValue(
        CompanyBranchLocalGoal.values,
        json['local_goal'],
        CompanyBranchLocalGoal.balanced,
      ),
      specialty: _optionalEnum(CompanySpecialty.values, json['specialty']),
    );
  }

  T _enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) =>
      _optionalEnum(values, raw) ?? fallback;

  T? _optionalEnum<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String) return null;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}
