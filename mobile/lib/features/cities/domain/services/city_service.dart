import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/city.dart';
import '../../../assets/domain/services/asset_service.dart';

class CityMoveCheck {
  const CityMoveCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class CityService {
  CityMoveCheck check(PlayerState state, City city) {
    if (state.currentCityId == city.id) {
      return const CityMoveCheck(isEligible: false, reason: 'Zaten bu şehirde yaşıyorsun.');
    }
    if (state.careerLevel < city.minimumCareerLevel) {
      return CityMoveCheck(isEligible: false, reason: 'En az kariyer seviyesi ${city.minimumCareerLevel} gerekiyor.');
    }
    if (state.money < moveCost(state, city)) {
      return CityMoveCheck(isEligible: false, reason: 'Taşınmak için yeterli paran yok.');
    }
    return const CityMoveCheck(isEligible: true, reason: 'Taşınmaya hazırsın.');
  }

  PlayerState move(PlayerState state, City city) {
    final result = check(state, city);
    if (!result.isEligible) {
      throw GameRuleException(result.reason);
    }
    return state.copyWith(currentCityId: city.id, money: state.money - moveCost(state, city), lastLivingCostDay: state.day);
  }

  int moveCost(PlayerState state, City city) => AssetService().moveCost(state, city.moveCost);
}
