import '../entities/city.dart';

abstract final class CityCatalog {
  static const version = 3;

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
    if (id == 1) return const City(id: 1, name: 'Kırşehir', description: 'Düşük giderli başlangıç şehri.', dailyCost: 0, moveCost: 0, minimumCareerLevel: 1);
    if (id == 2) return const City(id: 2, name: 'Ankara', description: 'Dengeli yaşam maliyeti ve geniş kamu/özel sektör fırsatı.', dailyCost: 20, moveCost: 100, minimumCareerLevel: 1, salaryMultiplier: 1.15, opportunityCount: 7, economicLevel: CityEconomicLevel.developing);
    if (id == 3) return const City(id: 3, name: 'İstanbul', description: 'En yoğun iş ağına sahip ekonomik merkez.', dailyCost: 45, moveCost: 300, minimumCareerLevel: 2, salaryMultiplier: 1.5, opportunityCount: 14, economicLevel: CityEconomicLevel.economicCenter);
    if (id == 4) return const City(id: 4, name: 'Antalya', description: 'Turizm ve ticaret fırsatları güçlü metropol.', dailyCost: 35, moveCost: 200, minimumCareerLevel: 1, salaryMultiplier: 1.3, opportunityCount: 10, economicLevel: CityEconomicLevel.metropolis);
    if (id == 5) return const City(id: 5, name: 'İzmir', description: 'Ticaret, teknoloji ve üretim fırsatları güçlü merkez.', dailyCost: 60, moveCost: 400, minimumCareerLevel: 2, salaryMultiplier: 1.45, opportunityCount: 13, economicLevel: CityEconomicLevel.economicCenter);
    final level = id >= 70
        ? CityEconomicLevel.economicCenter
        : id >= 40
            ? CityEconomicLevel.metropolis
            : id >= 16
                ? CityEconomicLevel.developing
                : CityEconomicLevel.regional;
    final factor = switch (level) {
      CityEconomicLevel.regional => (daily: 15, move: 80, salary: 1.0, opportunities: 4, career: 1),
      CityEconomicLevel.developing => (daily: 25, move: 150, salary: 1.15, opportunities: 7, career: 1),
      CityEconomicLevel.metropolis => (daily: 45, move: 300, salary: 1.3, opportunities: 10, career: 2),
      CityEconomicLevel.economicCenter => (daily: 70, move: 500, salary: 1.5, opportunities: 14, career: 3),
    };
    return City(
      id: id,
      name: name,
      description: '${level.name} ekonomik seviyesinde şehir.',
      dailyCost: factor.daily,
      moveCost: factor.move,
      minimumCareerLevel: factor.career,
      salaryMultiplier: factor.salary,
      opportunityCount: factor.opportunities,
      economicLevel: level,
    );
  }
}
