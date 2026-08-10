import '../../../game/domain/entities/player_state.dart';
import '../services/city_catalog.dart';
import '../../../assets/domain/services/asset_service.dart';

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
    final dailyCost = AssetService().hasHomeInCity(state, state.currentCityId) ? 0 : city.dailyCost;
    return state.copyWith(
      money: state.money - dailyCost * elapsedDays,
      lastLivingCostDay: state.day,
    );
  }
}
