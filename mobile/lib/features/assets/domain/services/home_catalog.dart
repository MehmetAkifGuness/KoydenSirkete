import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../entities/home_asset.dart';

abstract final class HomeCatalog {
  static const _prices = <int>[200000, 400000, 600000];

  static List<HomeAsset> forCity(City city) {
    return [
      HomeAsset(
        id: city.id * 100 + 1,
        cityId: city.id,
        name: 'Başlangıç dairesi',
        description:
            'Yaşadığın şehirde konut kirasını kaldıran güvenli bir ev.',
        price: _prices[0],
        comfort: 40,
        energyRecoveryBonus: 2,
        requiredCareerLevel: 1,
      ),
      HomeAsset(
        id: city.id * 100 + 2,
        cityId: city.id,
        name: 'Merkez rezidans',
        description: 'Daha konforlu ve prestijli bir şehir evi.',
        price: _prices[1],
        comfort: 70,
        energyRecoveryBonus: 5,
        requiredCareerLevel: 2,
      ),
      HomeAsset(
        id: city.id * 100 + 3,
        cityId: city.id,
        name: 'Geniş villa',
        description: 'Şehirdeki en yüksek konfor seviyesine sahip ev.',
        price: _prices[2],
        comfort: 100,
        energyRecoveryBonus: 8,
        requiredCareerLevel: 3,
      ),
    ];
  }

  static HomeAsset? findById(int? id) {
    if (id == null || id < 101) return null;
    final cityId = id ~/ 100;
    for (final home in forCityById(cityId)) {
      if (home.id == id) return home;
    }
    return null;
  }

  static List<HomeAsset> forCityById(int cityId) {
    final city = CityCatalog.findById(cityId);
    return city == null ? const <HomeAsset>[] : forCity(city);
  }
}
