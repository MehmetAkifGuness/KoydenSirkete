class Employment {
  const Employment({
    required this.jobId,
    required this.cityId,
    required this.salary,
    required this.company,
    required this.startedDay,
    this.lastTaskDay = 0,
  });

  final int jobId;
  final int cityId;
  final int salary;
  final String company;
  final int startedDay;
  final int lastTaskDay;

  Employment copyWith({int? jobId, int? cityId, int? salary, String? company, int? startedDay, int? lastTaskDay}) {
    return Employment(
      jobId: jobId ?? this.jobId,
      cityId: cityId ?? this.cityId,
      salary: salary ?? this.salary,
      company: company ?? this.company,
      startedDay: startedDay ?? this.startedDay,
      lastTaskDay: lastTaskDay ?? this.lastTaskDay,
    );
  }
}
