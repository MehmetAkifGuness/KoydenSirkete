import 'dart:convert';

import '../../../company/domain/entities/company_project_outcome.dart';

class CompanyProjectOutcomeCodec {
  String? encode(CompanyProjectOutcome? value) => value == null
      ? null
      : jsonEncode(<String, Object>{
          'projectId': value.projectId,
          'completedDay': value.completedDay,
          'elapsedDays': value.elapsedDays,
          'delayed': value.delayed,
          'succeeded': value.succeeded,
          'quality': value.quality.name,
          'netIncome': value.netIncome,
        });

  CompanyProjectOutcome? decode(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) return null;
      final projectId = decoded['projectId'];
      final completedDay = decoded['completedDay'];
      final elapsedDays = decoded['elapsedDays'];
      final delayed = decoded['delayed'];
      final succeeded = decoded['succeeded'];
      final netIncome = decoded['netIncome'];
      final quality = _quality(decoded['quality']);
      if (projectId is! int ||
          projectId < 1 ||
          completedDay is! int ||
          completedDay < 1 ||
          elapsedDays is! int ||
          elapsedDays < 1 ||
          delayed is! bool ||
          succeeded is! bool ||
          netIncome is! int ||
          quality == null ||
          succeeded == (quality == CompanyProjectQuality.rejected)) {
        return null;
      }
      return CompanyProjectOutcome(
        projectId: projectId,
        completedDay: completedDay,
        elapsedDays: elapsedDays.clamp(1, 10000).toInt(),
        delayed: delayed,
        succeeded: succeeded,
        quality: quality,
        netIncome: netIncome.clamp(-(1 << 62), 1 << 62).toInt(),
      );
    } on FormatException {
      return null;
    }
  }

  CompanyProjectQuality? _quality(Object? value) {
    if (value is! String) return null;
    for (final quality in CompanyProjectQuality.values) {
      if (quality.name == value) return quality;
    }
    return null;
  }
}
