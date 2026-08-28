import 'dart:convert';

import '../../../company/domain/entities/company_project_team_state.dart';

class CompanyProjectTeamCodec {
  const CompanyProjectTeamCodec();

  String encode(CompanyProjectTeamState value) => jsonEncode({
    for (final entry in value.employeeIdsByProject.entries)
      '${entry.key}': entry.value,
  });

  CompanyProjectTeamState decode(String? raw) {
    if (raw == null || raw.isEmpty) return const CompanyProjectTeamState();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const CompanyProjectTeamState();
      }
      final assignments = <int, List<int>>{};
      for (final entry in decoded.entries.take(100)) {
        final projectId = int.tryParse(entry.key);
        if (projectId == null || projectId <= 0 || entry.value is! List) {
          continue;
        }
        assignments[projectId] = List<int>.unmodifiable(
          (entry.value as List)
              .whereType<int>()
              .where((id) => id > 0)
              .take(100)
              .toSet(),
        );
      }
      return CompanyProjectTeamState(
        employeeIdsByProject: Map.unmodifiable(assignments),
      );
    } catch (_) {
      return const CompanyProjectTeamState();
    }
  }
}
