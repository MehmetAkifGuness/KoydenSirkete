import '../../../jobs/domain/entities/job.dart';
import '../entities/city.dart';
import 'city_catalog.dart';

class CitySalaryService {
  int calculate(Job job, int cityId) {
    final city = CityCatalog.findById(cityId);
    return city == null ? job.salary : calculateForCity(job, city);
  }

  int calculateForCity(Job job, City city) {
    return (job.salary * city.salaryMultiplier).round();
  }
}
