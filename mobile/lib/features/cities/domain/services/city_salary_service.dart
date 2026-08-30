import '../../../jobs/domain/entities/job.dart';
import '../../../economy/domain/services/economy_index_service.dart';
import '../entities/city.dart';
import 'city_catalog.dart';
import '../../../economy/domain/entities/economy_difficulty.dart';

class CitySalaryService {
  CitySalaryService({EconomyIndexService? economyIndexService})
    : _economyIndexService = economyIndexService ?? const EconomyIndexService();

  final EconomyIndexService _economyIndexService;

  int calculate(
    Job job,
    int cityId, {
    int day = 1,
    EconomyDifficulty difficulty = EconomyDifficulty.normal,
  }) {
    final city = CityCatalog.findById(cityId);
    return city == null
        ? _economyIndexService.applyIncome(
            job.salary,
            day,
            difficulty: difficulty,
          )
        : calculateForCity(job, city, day: day, difficulty: difficulty);
  }

  int calculateForCity(
    Job job,
    City city, {
    int day = 1,
    EconomyDifficulty difficulty = EconomyDifficulty.normal,
  }) => _economyIndexService.applyIncome(
    (job.salary * city.salaryMultiplier).round(),
    day,
    difficulty: difficulty,
  );
}
