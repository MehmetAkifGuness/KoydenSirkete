import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../entities/home_asset.dart';

abstract final class HomeCatalog {
  static List<HomeAsset> forCity(City city) {
    final base = (city.dailyCost * 180).clamp(5000, 1000000);
    return [
      HomeAsset(id: city.id * 100 + 1, cityId: city.id, name: 'Başlangıç dairesi', description: 'Kira giderini tamamen kaldıran güvenli bir ev.', price: base, comfort: 40, requiredCareerLevel: 1),
      HomeAsset(id: city.id * 100 + 2, cityId: city.id, name: 'Merkez rezidans', description: 'Daha konforlu ve prestijli bir şehir evi.', price: base * 2, comfort: 70, requiredCareerLevel: 2),
      HomeAsset(id: city.id * 100 + 3, cityId: city.id, name: 'Geniş villa', description: 'Şehirdeki en yüksek konfor seviyesine sahip ev.', price: base * 4, comfort: 100, requiredCareerLevel: 3),
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
