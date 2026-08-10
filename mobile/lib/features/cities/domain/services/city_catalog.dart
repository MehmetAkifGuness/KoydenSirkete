import 'dart:math' as math;

import '../entities/city.dart';

abstract final class CityCatalog {
  static const version = 5;
  static const _minimumPopulation = 82836;
  static const _maximumPopulation = 15754053;

  static const _names = <String>[
    'Kırşehir', 'Ankara', 'İstanbul', 'Antalya', 'İzmir', 'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya',
    'Artvin', 'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale',
    'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep',
    'Giresun', 'Gümüşhane', 'Hakkari', 'Hatay', 'Isparta', 'Mersin', 'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli',
    'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş', 'Nevşehir',
    'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Tekirdağ', 'Tokat',
    'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman',
    'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce',
  ];

  static const _populations = <int>[
    242777, 5910320, 15754053, 2777677, 4504185, 2283609, 617821, 751808, 491489, 342242,
    167531, 1172107, 1284517, 228995, 282299, 360423, 327173, 277226, 3263011, 573976,
    200549, 519590, 1060975, 1852356, 422438, 605678, 239625, 736877, 927956, 2222415,
    455074, 138807, 279681, 1577531, 445303, 1956428, 268991, 379934, 1458991, 379595,
    2161171, 2343409, 570478, 755854, 1477756, 1146278, 903576, 1099547, 389127, 320150,
    374492, 768087, 346947, 1123693, 1392403, 332369, 225848, 631401, 1208441, 614141,
    823323, 85083, 2265800, 374405, 1112013, 413208, 585203, 441136, 82836, 262355,
    282830, 662626, 573666, 206663, 90392, 205071, 311635, 249614, 157363, 564123, 415622,
  ];

  static final cities = List<City>.unmodifiable(
    List.generate(_names.length, (index) => _create(index + 1, _names[index])),
  );

  static City? findById(int id) {
    for (final city in cities) {
      if (city.id == id) return city;
    }
    return null;
  }

  static City _create(int id, String name) {
    final population = _populations[id - 1];
    final technology = _technologyFor(population);
    final level = _economicLevelFor(technology);
    final market = (population / 250000).round().clamp(1, 20);
    final dailyCost = dailyCostForPopulation(population);
    final moveCost = (dailyCost * (4 + technology ~/ 20)).round();
    return City(
      id: id,
      name: name,
      description: '${level.name} ekonomik seviyesinde, nüfus ve pazar büyüklüğüne göre hesaplanan şehir.',
      dailyCost: dailyCost,
      moveCost: moveCost,
      minimumCareerLevel: technology >= 90 ? 3 : technology >= 60 ? 2 : 1,
      salaryMultiplier: (0.8 + population / 1000000 * .8).clamp(.8, 16.0),
      opportunityCount: (3 + market ~/ 2).clamp(3, 14),
      maximumJobLevel: _maximumJobLevelFor(level),
      economicLevel: level,
      population: population,
      technologyLevel: technology,
      marketLevel: market,
    );
  }

  static int _technologyFor(int population) {
    final ratio = math.log(population / _minimumPopulation) / math.log(_maximumPopulation / _minimumPopulation);
    return (20 + ratio * 80).round().clamp(20, 100);
  }

  static int dailyCostForPopulation(int population) => (population / 2000).round().clamp(1, 100000);

  static CityEconomicLevel _economicLevelFor(int technology) {
    if (technology >= 80) return CityEconomicLevel.economicCenter;
    if (technology >= 60) return CityEconomicLevel.metropolis;
    if (technology >= 35) return CityEconomicLevel.developing;
    return CityEconomicLevel.regional;
  }

  static int _maximumJobLevelFor(CityEconomicLevel level) => switch (level) {
        CityEconomicLevel.regional => 2,
        CityEconomicLevel.developing => 3,
        CityEconomicLevel.metropolis => 4,
        CityEconomicLevel.economicCenter => 5,
      };
}
