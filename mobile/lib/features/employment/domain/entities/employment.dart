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

  Employment copyWith({int? lastTaskDay}) {
    return Employment(
      jobId: jobId,
      cityId: cityId,
      salary: salary,
      company: company,
      startedDay: startedDay,
      lastTaskDay: lastTaskDay ?? this.lastTaskDay,
    );
  }
}
