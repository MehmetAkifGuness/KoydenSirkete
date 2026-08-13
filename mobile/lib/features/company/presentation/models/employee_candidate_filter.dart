import '../../domain/entities/company_employee.dart';

enum EmployeeCandidateFilter { all, lowCost, highPerformance, bestValue }

extension EmployeeCandidateFilterLabels on EmployeeCandidateFilter {
  String get label => switch (this) {
    EmployeeCandidateFilter.all => 'Tümü',
    EmployeeCandidateFilter.lowCost => 'Ucuz',
    EmployeeCandidateFilter.highPerformance => 'Yüksek kabiliyet',
    EmployeeCandidateFilter.bestValue => 'Dengeli',
  };
}

List<CompanyEmployee> filterEmployeeCandidates(
  Iterable<CompanyEmployee> candidates,
  EmployeeCandidateFilter filter,
) {
  final result = candidates.toList(growable: false);
  if (filter == EmployeeCandidateFilter.all) return result;

  final sorted = [...result];
  sorted.sort((left, right) {
    final comparison = switch (filter) {
      EmployeeCandidateFilter.lowCost => left.dailySalary.compareTo(right.dailySalary),
      EmployeeCandidateFilter.highPerformance => right.performance.compareTo(left.performance),
      EmployeeCandidateFilter.bestValue => _valueScore(right).compareTo(_valueScore(left)),
      EmployeeCandidateFilter.all => 0,
    };
    if (comparison != 0) return comparison;
    return left.id.compareTo(right.id);
  });
  return sorted;
}

double _valueScore(CompanyEmployee employee) =>
    employee.performance / employee.dailySalary.clamp(1, double.infinity);
