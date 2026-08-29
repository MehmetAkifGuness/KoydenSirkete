import 'dart:math' as math;

import '../../../assets/domain/services/asset_service.dart';
import '../../../assets/domain/services/car_catalog.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import 'city_catalog.dart';

class LivingCostBreakdown {
  const LivingCostBreakdown({
    required this.housing,
    required this.food,
    required this.utilities,
    required this.transportation,
    required this.rentalMaintenance,
    required this.rentalIncome,
    required this.lifestyleMultiplier,
    required this.inflationMultiplier,
  });

  static const empty = LivingCostBreakdown(
    housing: 0,
    food: 0,
    utilities: 0,
    transportation: 0,
    rentalMaintenance: 0,
    rentalIncome: 0,
    lifestyleMultiplier: 1,
    inflationMultiplier: 1,
  );

  final int housing;
  final int food;
  final int utilities;
  final int transportation;
  final int rentalMaintenance;
  final int rentalIncome;
  final double lifestyleMultiplier;
  final double inflationMultiplier;

  int get totalExpenses =>
      housing + food + utilities + transportation + rentalMaintenance;
  int get netDailyCost => totalExpenses - rentalIncome;
}

class LivingCostService {
  LivingCostService({AssetService? assetService})
    : _assetService = assetService ?? AssetService();

  final AssetService _assetService;

  static const housingPercent = 55;
  static const foodPercent = 20;
  static const utilitiesPercent = 15;
  static const inflationPeriodDays = 30;
  static const inflationPercentPerPeriod = 1;
  static const maximumInflationPercent = 25;

  LivingCostBreakdown breakdown(PlayerState state, int cityId) {
    final city = CityCatalog.findById(cityId);
    if (city == null) return LivingCostBreakdown.empty;
    final inflation = _inflationMultiplier(state.day);
    final cityBase = (city.dailyCost * inflation).round();
    final housingBase = cityBase * housingPercent ~/ 100;
    final foodBase = cityBase * foodPercent ~/ 100;
    final utilitiesBase = cityBase * utilitiesPercent ~/ 100;
    final transportationBase =
        cityBase - housingBase - foodBase - utilitiesBase;
    final lifestyle = _lifestyleMultiplier(state);
    final car = CarCatalog.findById(state.ownedCarId);
    final transportDiscount = (car?.moveDiscountPercent ?? 0) ~/ 2;
    final rentalIncome = _assetService.dailyRentalIncome(state);
    return LivingCostBreakdown(
      housing: _assetService.hasResidence(state, cityId) ? 0 : housingBase,
      food: (foodBase * lifestyle).round(),
      utilities: (utilitiesBase * lifestyle).round(),
      transportation:
          (transportationBase * lifestyle * (100 - transportDiscount) / 100)
              .round(),
      rentalMaintenance: _assetService.dailyRentalMaintenance(state),
      rentalIncome: rentalIncome,
      lifestyleMultiplier: lifestyle,
      inflationMultiplier: inflation,
    );
  }

  int dailyCost(PlayerState state, int cityId) =>
      breakdown(state, cityId).totalExpenses;

  PlayerState settle(PlayerState state) {
    if (state.day <= state.lastLivingCostDay) return state;
    var money = state.money;
    var totalEarned = state.totalEarned;
    var ledger = state.financeLedger;
    for (var day = state.lastLivingCostDay + 1; day <= state.day; day++) {
      final costs = breakdown(
        state.copyWith(day: day, money: money, totalEarned: totalEarned),
        state.currentCityId,
      );
      final netCost = costs.totalExpenses - costs.rentalIncome;
      final support = math.max(0, netCost - money);
      money += costs.rentalIncome - costs.totalExpenses + support;
      totalEarned += costs.rentalIncome;
      ledger = _recordDay(ledger, day, costs);
      ledger = _record(ledger, day, FinanceCategory.hardshipSupport, support);
    }
    return state.copyWith(
      money: money,
      totalEarned: totalEarned,
      financeLedger: ledger,
      lastLivingCostDay: state.day,
    );
  }

  double _lifestyleMultiplier(PlayerState state) {
    final averageIncome = state.totalEarned ~/ math.max(1, state.day);
    final income = math.max(averageIncome, state.employment?.salary ?? 0);
    if (income <= 0) return 1;
    return 1 + math.min(.5, math.sqrt(income / 6000) * .35);
  }

  double _inflationMultiplier(int day) {
    final periods = math.max(0, day - 1) ~/ inflationPeriodDays;
    final percent = math.min(
      maximumInflationPercent,
      periods * inflationPercentPerPeriod,
    );
    return 1 + percent / 100;
  }

  FinanceLedger _recordDay(
    FinanceLedger ledger,
    int day,
    LivingCostBreakdown costs,
  ) {
    var next = ledger;
    next = _record(next, day, FinanceCategory.housing, -costs.housing);
    next = _record(next, day, FinanceCategory.food, -costs.food);
    next = _record(next, day, FinanceCategory.utilities, -costs.utilities);
    next = _record(
      next,
      day,
      FinanceCategory.transportation,
      -costs.transportation,
    );
    next = _record(
      next,
      day,
      FinanceCategory.rentalMaintenance,
      -costs.rentalMaintenance,
    );
    return _record(next, day, FinanceCategory.rentalIncome, costs.rentalIncome);
  }

  FinanceLedger _record(
    FinanceLedger ledger,
    int day,
    FinanceCategory category,
    int amount,
  ) => ledger.record(day: day, category: category, amount: amount);
}
