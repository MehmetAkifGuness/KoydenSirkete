import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/domain/entities/job_listing.dart';
import '../../../jobs/domain/services/job_catalog.dart';
import 'city_catalog.dart';

class CityOpportunityService {
  List<JobListing> listings({required int cityId, required int day}) {
    final city = CityCatalog.findById(cityId) ?? CityCatalog.cities.first;
    final ranked = JobCatalog.jobs
        .where((job) => job.level <= city.maximumJobLevel)
        .map((job) => _Ranked(job: job, score: _score(job.id, city.id, day)))
        .toList()
      ..sort((left, right) => right.score.compareTo(left.score));
    final count = city.opportunityCount.clamp(1, ranked.length);
    final selected = _diversify(ranked, count);
    return [
      for (var index = 0; index < selected.length; index++)
        JobListing(job: selected[index].job, cityId: city.id, salary: (selected[index].job.salary * city.salaryMultiplier).round(), opportunityIndex: index),
    ];
  }

  JobListing? find({required int cityId, required int day, required int jobId}) {
    for (final listing in listings(cityId: cityId, day: day)) {
      if (listing.job.id == jobId) return listing;
    }
    return null;
  }

  int _score(int jobId, int cityId, int day) => (jobId * 37 + cityId * 19 + day * 11) % 101;

  List<_Ranked> _diversify(List<_Ranked> ranked, int count) {
    final selected = <_Ranked>[];
    final tracks = <String>{};
    for (final item in ranked) {
      if (selected.length == count) break;
      if (tracks.add(item.job.careerTrack)) selected.add(item);
    }
    for (final item in ranked) {
      if (selected.length == count) break;
      if (selected.every((chosen) => chosen.job.id != item.job.id)) selected.add(item);
    }
    return selected;
  }
}

class _Ranked {
  const _Ranked({required this.job, required this.score});

  final Job job;
  final int score;
}
