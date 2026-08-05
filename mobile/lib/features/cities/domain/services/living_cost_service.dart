import '../../../game/domain/entities/player_state.dart';
import '../services/city_catalog.dart';

class LivingCostService {
  PlayerState settle(PlayerState state) {
    if (state.day <= state.lastLivingCostDay) {
      return state;
    }
    final city = CityCatalog.findById(state.currentCityId);
    if (city == null) {
      return state.copyWith(lastLivingCostDay: state.day);
    }
    final elapsedDays = state.day - state.lastLivingCostDay;
    return state.copyWith(
      money: state.money - city.dailyCost * elapsedDays,
      lastLivingCostDay: state.day,
    );
  }
}
