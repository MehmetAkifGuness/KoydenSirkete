import 'dart:convert';

import '../../../company/domain/entities/company_expansion_state.dart';

class CompanyExpansionCodec {
  String? encode(CompanyExpansionState value) => value.completedDealIds.isEmpty
      ? null
      : jsonEncode(value.completedDealIds);

  CompanyExpansionState decode(String? value) {
    if (value == null || value.isEmpty) return const CompanyExpansionState();
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List<dynamic>) return const CompanyExpansionState();
      final ids = List<String>.unmodifiable(
        decoded.whereType<String>().toSet(),
      );
      return CompanyExpansionState(completedDealIds: ids);
    } on FormatException {
      return const CompanyExpansionState();
    }
  }
}
