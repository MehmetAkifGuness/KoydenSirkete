import 'dart:convert';

import '../../../company/domain/entities/company_budget_state.dart';

class CompanyBudgetCodec {
  const CompanyBudgetCodec();

  String? encode(CompanyBudgetState value) => value.isDisabled
      ? null
      : jsonEncode({
          'office': value.office.name,
          'marketing': value.marketing.name,
          'research': value.research.name,
          'maintenance': value.maintenance.name,
        });

  CompanyBudgetState decode(String? value) {
    if (value == null || value.isEmpty) return const CompanyBudgetState();
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) {
        return const CompanyBudgetState();
      }
      return CompanyBudgetState(
        office: _decodeLevel(decoded['office']),
        marketing: _decodeLevel(decoded['marketing']),
        research: _decodeLevel(decoded['research']),
        maintenance: _decodeLevel(decoded['maintenance']),
      );
    } on FormatException {
      return const CompanyBudgetState();
    }
  }

  CompanyBudgetLevel _decodeLevel(Object? value) {
    if (value is! String) return CompanyBudgetLevel.off;
    for (final level in CompanyBudgetLevel.values) {
      if (level.name == value) return level;
    }
    return CompanyBudgetLevel.off;
  }
}
