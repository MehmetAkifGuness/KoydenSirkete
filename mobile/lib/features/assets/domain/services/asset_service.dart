import '../../../../core/errors/game_rule_exception.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/car_asset.dart';
import '../entities/home_asset.dart';
import 'car_catalog.dart';
import 'home_catalog.dart';

class AssetCheck {
  const AssetCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class AssetService {
  AssetCheck checkHome(PlayerState state, HomeAsset home, City city) {
    if (home.cityId != city.id || state.currentCityId != city.id) {
      return const AssetCheck(isEligible: false, reason: 'Ev yalnızca yaşadığın şehirden alınabilir.');
    }
    if (state.ownedHomeIds.contains(home.id)) {
      return const AssetCheck(isEligible: false, reason: 'Bu eve zaten sahipsin.');
    }
    if (state.careerLevel < home.requiredCareerLevel) {
      return AssetCheck(isEligible: false, reason: 'En az kariyer seviyesi ${home.requiredCareerLevel} gerekiyor.');
    }
    if (state.money < home.price) {
      return AssetCheck(isEligible: false, reason: 'Bu ev için yeterli paran yok.');
    }
    return const AssetCheck(isEligible: true, reason: 'Evi satın almaya hazırsın.');
  }

  PlayerState buyHome(PlayerState state, HomeAsset home, City city) {
    final check = checkHome(state, home, city);
    if (!check.isEligible) throw GameRuleException(check.reason);
    return state.copyWith(
      money: state.money - home.price,
      ownedHomeIds: <int>[...state.ownedHomeIds, home.id],
    );
  }

  AssetCheck checkCar(PlayerState state, CarAsset car) {
    if (state.ownedCarId != null) {
      return const AssetCheck(isEligible: false, reason: 'Zaten bir araban var.');
    }
    if (state.money < car.price) {
      return const AssetCheck(isEligible: false, reason: 'Bu araba için yeterli paran yok.');
    }
    return const AssetCheck(isEligible: true, reason: 'Arabayı satın almaya hazırsın.');
  }

  PlayerState buyCar(PlayerState state, CarAsset car) {
    final check = checkCar(state, car);
    if (!check.isEligible) throw GameRuleException(check.reason);
    return state.copyWith(money: state.money - car.price, ownedCarId: car.id);
  }

  bool hasHomeInCity(PlayerState state, int cityId) {
    return state.ownedHomeIds.any((id) => HomeCatalog.findById(id)?.cityId == cityId);
  }

  int moveCost(PlayerState state, int baseCost) {
    final car = CarCatalog.findById(state.ownedCarId);
    if (car == null) return baseCost;
    return (baseCost * (100 - car.moveDiscountPercent) / 100).ceil();
  }
}
