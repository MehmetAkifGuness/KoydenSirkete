import 'dart:convert';

import '../../../company/domain/entities/company_branch.dart';
import '../../../company/domain/entities/company_employee.dart';

class CompanyBranchCodec {
  String? encodeList(List<CompanyBranch> branches) {
    if (branches.isEmpty) return null;
    return jsonEncode(branches.map((branch) => {
          'id': branch.id,
          'city_id': branch.cityId,
          'level': branch.level,
          'employees': branch.employees.map((employee) => {
                'id': employee.id,
                'name': employee.name,
                'role': employee.role,
                'performance': employee.performance,
                'daily_salary': employee.dailySalary,
                'required_company_level': employee.requiredCompanyLevel,
              }).toList(),
        }).toList());
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
    final employees = (json['employees'] as List<dynamic>? ?? const <dynamic>[]).map((item) {
      final employee = item as Map<String, dynamic>;
      return CompanyEmployee(
        id: employee['id'] as int,
        name: employee['name'] as String,
        role: employee['role'] as String,
        performance: employee['performance'] as int,
        dailySalary: employee['daily_salary'] as int,
        requiredCompanyLevel: employee['required_company_level'] as int? ?? 1,
      );
    }).toList(growable: false);
    return CompanyBranch(
      id: json['id'] as int,
      cityId: json['city_id'] as int,
      level: json['level'] as int? ?? 1,
      employees: employees,
    );
  }
}
