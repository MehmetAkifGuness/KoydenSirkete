import '../../../../core/errors/game_rule_exception.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/car_asset.dart';
import '../entities/home_asset.dart';
import 'car_catalog.dart';
import 'home_catalog.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class AssetCheck {
  const AssetCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class AssetService {
  static const resalePercent = 70;
  static const monthlyRentPercent = 1;
  static const rentalMaintenancePercent = 8;
  static const daysPerMonth = 30;

  AssetCheck checkHome(PlayerState state, HomeAsset home, City city) {
    if (home.cityId != city.id || state.currentCityId != city.id) {
      return const AssetCheck(
        isEligible: false,
        reason: 'Ev yalnızca yaşadığın şehirden alınabilir.',
      );
    }
    if (state.ownedHomeIds.contains(home.id)) {
      return const AssetCheck(
        isEligible: false,
        reason: 'Bu eve zaten sahipsin.',
      );
    }
    if (state.careerLevel < home.requiredCareerLevel) {
      return AssetCheck(
        isEligible: false,
        reason: 'En az kariyer seviyesi ${home.requiredCareerLevel} gerekiyor.',
      );
    }
    if (state.money < home.price) {
      return AssetCheck(
        isEligible: false,
        reason: 'Bu ev için yeterli paran yok.',
      );
    }
    return const AssetCheck(
      isEligible: true,
      reason: 'Evi satın almaya hazırsın.',
    );
  }

  PlayerState buyHome(PlayerState state, HomeAsset home, City city) {
    final check = checkHome(state, home, city);
    if (!check.isEligible) throw GameRuleException(check.reason);
    return state.copyWith(
      money: state.money - home.price,
      ownedHomeIds: <int>[...state.ownedHomeIds, home.id],
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.assetPurchase,
        amount: -home.price,
      ),
    );
  }

  int homeSaleValue(HomeAsset home) => home.price * resalePercent ~/ 100;

  PlayerState sellHome(PlayerState state, HomeAsset home) {
    if (!state.ownedHomeIds.contains(home.id)) {
      throw const GameRuleException('Bu ev sana ait değil.');
    }
    return state.copyWith(
      money: state.money + homeSaleValue(home),
      ownedHomeIds: state.ownedHomeIds
          .where((id) => id != home.id)
          .toList(growable: false),
      rentedHomeIds: state.rentedHomeIds
          .where((id) => id != home.id)
          .toList(growable: false),
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.assetSale,
        amount: homeSaleValue(home),
      ),
    );
  }

  int monthlyRent(HomeAsset home) => home.price * monthlyRentPercent ~/ 100;

  int dailyRent(HomeAsset home) => (monthlyRent(home) / daysPerMonth).round();

  int monthlyRentalIncome(PlayerState state) =>
      _rentedHomes(state).fold(0, (total, home) => total + monthlyRent(home));

  int dailyRentalIncome(PlayerState state) =>
      _rentedHomes(state).fold(0, (total, home) => total + dailyRent(home));

  int monthlyRentalMaintenance(PlayerState state) =>
      (monthlyRentalIncome(state) * rentalMaintenancePercent / 100).round();

  int dailyRentalMaintenance(PlayerState state) =>
      (dailyRentalIncome(state) * rentalMaintenancePercent / 100).round();

  int monthlyNetRentalIncome(PlayerState state) =>
      monthlyRentalIncome(state) - monthlyRentalMaintenance(state);

  PlayerState rentOutHome(PlayerState state, HomeAsset home) {
    if (!state.ownedHomeIds.contains(home.id)) {
      throw const GameRuleException('Bu ev sana ait değil.');
    }
    if (state.rentedHomeIds.contains(home.id)) {
      throw const GameRuleException('Bu ev zaten kirada.');
    }
    return state.copyWith(
      rentedHomeIds: <int>[...state.rentedHomeIds, home.id],
    );
  }

  PlayerState stopRentingHome(PlayerState state, HomeAsset home) {
    if (!state.ownedHomeIds.contains(home.id)) {
      throw const GameRuleException('Bu ev sana ait değil.');
    }
    if (!state.rentedHomeIds.contains(home.id)) {
      throw const GameRuleException('Bu ev kirada değil.');
    }
    return state.copyWith(
      rentedHomeIds: state.rentedHomeIds
          .where((id) => id != home.id)
          .toList(growable: false),
    );
  }

  AssetCheck checkCar(PlayerState state, CarAsset car) {
    if (state.ownedCarId != null) {
      return const AssetCheck(
        isEligible: false,
        reason: 'Zaten bir araban var.',
      );
    }
    if (state.money < car.price) {
      return const AssetCheck(
        isEligible: false,
        reason: 'Bu araba için yeterli paran yok.',
      );
    }
    return const AssetCheck(
      isEligible: true,
      reason: 'Arabayı satın almaya hazırsın.',
    );
  }

  PlayerState buyCar(PlayerState state, CarAsset car) {
    final check = checkCar(state, car);
    if (!check.isEligible) throw GameRuleException(check.reason);
    return state.copyWith(
      money: state.money - car.price,
      ownedCarId: car.id,
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.assetPurchase,
        amount: -car.price,
      ),
    );
  }

  int carSaleValue(CarAsset car) => car.price * resalePercent ~/ 100;

  PlayerState sellCar(PlayerState state, CarAsset car) {
    if (state.ownedCarId != car.id) {
      throw const GameRuleException('Bu araba sana ait değil.');
    }
    return state.copyWith(
      money: state.money + carSaleValue(car),
      ownedCarId: null,
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.assetSale,
        amount: carSaleValue(car),
      ),
    );
  }

  bool hasResidence(PlayerState state, int cityId) {
    final rentedIds = state.rentedHomeIds.toSet();
    return state.ownedHomeIds.any((id) {
      final home = HomeCatalog.findById(id);
      return home?.cityId == cityId && !rentedIds.contains(id);
    });
  }

  int moveCost(PlayerState state, int baseCost) {
    final car = CarCatalog.findById(state.ownedCarId);
    if (car == null) return baseCost;
    return (baseCost * (100 - car.moveDiscountPercent) / 100).ceil();
  }

  Iterable<HomeAsset> _rentedHomes(PlayerState state) sync* {
    final ownedIds = state.ownedHomeIds.toSet();
    for (final id in state.rentedHomeIds) {
      if (!ownedIds.contains(id)) continue;
      final home = HomeCatalog.findById(id);
      if (home != null) yield home;
    }
  }
}
