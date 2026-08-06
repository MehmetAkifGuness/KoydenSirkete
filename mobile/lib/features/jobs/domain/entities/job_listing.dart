import 'job.dart';

class JobListing {
  const JobListing({required this.job, required this.cityId, required this.salary, required this.opportunityIndex});

  final Job job;
  final int cityId;
  final int salary;
  final int opportunityIndex;

  int get id => job.id;
}
