import '../entities/city.dart';

abstract final class CityCatalog {
  static const version = 2;

  static const cities = <City>[
    City(
      id: 1,
      name: 'Köy',
      description: 'Düşük giderli, sakin başlangıç bölgesi.',
      dailyCost: 0,
      moveCost: 0,
      minimumCareerLevel: 1,
    ),
    City(
      id: 2,
      name: 'İlçe merkezi',
      description: 'Daha fazla fırsat ve dengeli yaşam maliyeti.',
      dailyCost: 20,
      moveCost: 100,
      minimumCareerLevel: 1,
    ),
    City(
      id: 3,
      name: 'Büyükşehir',
      description: 'Yüksek giderli ama kariyer ve şirket fırsatları geniş şehir.',
      dailyCost: 45,
      moveCost: 300,
      minimumCareerLevel: 2,
    ),
    City(
      id: 4,
      name: 'Sahil kenti',
      description: 'Turizm ve ticaret fırsatları yüksek, dengeli maliyetli şehir.',
      dailyCost: 35,
      moveCost: 200,
      minimumCareerLevel: 1,
    ),
    City(
      id: 5,
      name: 'Teknoloji vadisi',
      description: 'Yüksek yaşam maliyetine karşılık uzmanlık fırsatları sunan merkez.',
      dailyCost: 60,
      moveCost: 400,
      minimumCareerLevel: 2,
    ),
  ];

  static City? findById(int id) {
    for (final city in cities) {
      if (city.id == id) {
        return city;
      }
    }
    return null;
  }
}
