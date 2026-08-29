import '../../../jobs/domain/entities/job.dart';
import '../../../economy/domain/services/economy_index_service.dart';
import '../entities/city.dart';
import 'city_catalog.dart';

class CitySalaryService {
  CitySalaryService({EconomyIndexService? economyIndexService})
    : _economyIndexService = economyIndexService ?? const EconomyIndexService();

  final EconomyIndexService _economyIndexService;

  int calculate(Job job, int cityId, {int day = 1}) {
    final city = CityCatalog.findById(cityId);
    return city == null
        ? _economyIndexService.apply(job.salary, day)
        : calculateForCity(job, city, day: day);
  }

  int calculateForCity(Job job, City city, {int day = 1}) =>
      _economyIndexService.apply(
        (job.salary * city.salaryMultiplier).round(),
        day,
      );
}
