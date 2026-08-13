import '../../domain/entities/job_listing.dart';

enum JobListingFilter { all, sales, finance, logistics, digital, accessible, highestSalary }

extension JobListingFilterLabels on JobListingFilter {
  String get label => switch (this) {
    JobListingFilter.all => 'Tümü',
    JobListingFilter.sales => 'Satış',
    JobListingFilter.finance => 'Finans',
    JobListingFilter.logistics => 'Lojistik',
    JobListingFilter.digital => 'Dijital',
    JobListingFilter.accessible => 'Uygun ilanlar',
    JobListingFilter.highestSalary => 'Yüksek maaş',
  };
}

List<JobListing> filterJobListings(
  Iterable<JobListing> listings,
  JobListingFilter filter,
  bool Function(JobListing listing) isEligible,
) {
  final result = listings.where((listing) {
    final track = listing.job.careerTrack;
    return switch (filter) {
      JobListingFilter.all => true,
      JobListingFilter.sales => track == 'satış ve perakende',
      JobListingFilter.finance => track == 'finans',
      JobListingFilter.logistics => track == 'lojistik',
      JobListingFilter.digital => track == 'dijital ve operasyon',
      JobListingFilter.accessible => isEligible(listing),
      JobListingFilter.highestSalary => true,
    };
  }).toList(growable: false);
  if (filter != JobListingFilter.highestSalary) return result;
  return [...result]..sort((left, right) => right.salary.compareTo(left.salary));
}
