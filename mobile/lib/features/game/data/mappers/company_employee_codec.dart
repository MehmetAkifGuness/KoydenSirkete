import 'dart:convert';

import '../../../company/domain/entities/company_employee.dart';
import '../../../company/domain/services/company_employee_catalog.dart';

class CompanyEmployeeCodec {
  String? encodeList(List<CompanyEmployee> employees) {
    if (employees.isEmpty) {
      return null;
    }
    return jsonEncode(employees.map(_toJson).toList());
  }

  List<CompanyEmployee> decodeList(String? value, {int legacyCount = 0}) {
    if (value != null && value.isNotEmpty) {
      try {
        final json = jsonDecode(value) as List<dynamic>;
        return List<CompanyEmployee>.unmodifiable(
          json.map((item) => _fromJson(item as Map<String, dynamic>)),
        );
      } on Object {
        return CompanyEmployeeCatalog.legacyDefaults(legacyCount);
      }
    }
    return CompanyEmployeeCatalog.legacyDefaults(legacyCount);
  }

  Map<String, dynamic> _toJson(CompanyEmployee employee) => {
    'id': employee.id,
    'name': employee.name,
    'role': employee.role,
    'performance': employee.performance,
    'daily_salary': employee.dailySalary,
    'required_company_level': employee.requiredCompanyLevel,
    'morale': employee.morale,
    'loyalty': employee.loyalty,
  };

  CompanyEmployee _fromJson(Map<String, dynamic> json) => CompanyEmployee(
    id: json['id'] as int,
    name: json['name'] as String,
    role: json['role'] as String,
    performance: json['performance'] as int,
    dailySalary: json['daily_salary'] as int,
    requiredCompanyLevel: json['required_company_level'] as int? ?? 1,
    morale: json['morale'] as int? ?? 70,
    loyalty: json['loyalty'] as int? ?? 70,
  );
}
