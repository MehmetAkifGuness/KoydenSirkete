class CompanyProjectTeamState {
  const CompanyProjectTeamState({
    this.employeeIdsByProject = const <int, List<int>>{},
  });

  final Map<int, List<int>> employeeIdsByProject;

  bool isConfigured(int projectId) =>
      employeeIdsByProject.containsKey(projectId);

  List<int> employeeIdsFor(int projectId) =>
      List<int>.unmodifiable(employeeIdsByProject[projectId] ?? const <int>[]);

  CompanyProjectTeamState setTeam(int projectId, Iterable<int> employeeIds) {
    final next = <int, List<int>>{
      for (final entry in employeeIdsByProject.entries)
        entry.key: List<int>.unmodifiable(entry.value),
      projectId: List<int>.unmodifiable(employeeIds.toSet()),
    };
    return CompanyProjectTeamState(
      employeeIdsByProject: Map.unmodifiable(next),
    );
  }

  CompanyProjectTeamState removeEmployee(int employeeId) {
    final next = <int, List<int>>{
      for (final entry in employeeIdsByProject.entries)
        entry.key: List<int>.unmodifiable(
          entry.value.where((id) => id != employeeId),
        ),
    };
    return CompanyProjectTeamState(
      employeeIdsByProject: Map.unmodifiable(next),
    );
  }
}
