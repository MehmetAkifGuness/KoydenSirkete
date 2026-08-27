import 'job.dart';

class JobListing {
  const JobListing({
    required this.job,
    required this.cityId,
    required this.salary,
    required this.opportunityIndex,
    this.employer,
  });

  final Job job;
  final int cityId;
  final int salary;
  final int opportunityIndex;
  final String? employer;

  int get id => job.id;
  String get company => employer ?? job.company;
}
