import '../../domain/entities/city.dart';

enum CityFilter {
  all,
  regional,
  developing,
  metropolis,
  economicCenter,
  highestTechnology,
}

extension CityFilterLabels on CityFilter {
  String get label => switch (this) {
    CityFilter.all => 'Tümü',
    CityFilter.regional => 'Bölgesel',
    CityFilter.developing => 'Gelişen',
    CityFilter.metropolis => 'Metropol',
    CityFilter.economicCenter => 'Ekonomik merkez',
    CityFilter.highestTechnology => 'Yüksek teknoloji',
  };
}

List<City> filterCities(Iterable<City> cities, CityFilter filter) {
  final result = cities
      .where((city) {
        return switch (filter) {
          CityFilter.all => true,
          CityFilter.regional =>
            city.economicLevel == CityEconomicLevel.regional,
          CityFilter.developing =>
            city.economicLevel == CityEconomicLevel.developing,
          CityFilter.metropolis =>
            city.economicLevel == CityEconomicLevel.metropolis,
          CityFilter.economicCenter =>
            city.economicLevel == CityEconomicLevel.economicCenter,
          CityFilter.highestTechnology => city.technologyLevel >= 70,
        };
      })
      .toList(growable: false);
  if (filter != CityFilter.highestTechnology) return result;
  return [...result]..sort(
    (left, right) => right.technologyLevel.compareTo(left.technologyLevel),
  );
}
