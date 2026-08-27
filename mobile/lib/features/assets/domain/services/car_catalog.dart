import '../entities/car_asset.dart';

abstract final class CarCatalog {
  static const cars = <CarAsset>[
    CarAsset(
      id: 1,
      name: 'Şehir otomobili',
      description: 'Ekonomik ve güvenilir ulaşım.',
      price: 15000,
      moveDiscountPercent: 20,
    ),
    CarAsset(
      id: 2,
      name: 'Konfor sedanı',
      description: 'Taşınma masraflarını ciddi ölçüde azaltır.',
      price: 45000,
      moveDiscountPercent: 45,
    ),
    CarAsset(
      id: 3,
      name: 'Yönetici SUV',
      description: 'En yüksek taşınma avantajını sağlar.',
      price: 120000,
      moveDiscountPercent: 70,
    ),
  ];

  static CarAsset? findById(int? id) {
    for (final car in cars) {
      if (car.id == id) return car;
    }
    return null;
  }
}
