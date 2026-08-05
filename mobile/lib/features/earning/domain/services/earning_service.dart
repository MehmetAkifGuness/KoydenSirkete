import '../../../../core/errors/game_rule_exception.dart';
import '../entities/earning_performance.dart';
import 'earning_mini_game_service.dart';
import '../../../game/domain/entities/player_state.dart';

class EarningResult {
  const EarningResult({required this.state, required this.reward, required this.bonusPercent});

  final PlayerState state;
  final int reward;
  final int bonusPercent;
}

class EarningService {
  EarningService({EarningMiniGameService? miniGameService}) : _miniGameService = miniGameService ?? EarningMiniGameService();

  static const energyCost = 15;
  static const durationHours = 2;
  static const baseReward = 100;

  final EarningMiniGameService _miniGameService;

  EarningResult execute(PlayerState state, {EarningPerformance performance = EarningPerformance.none}) {
    if (state.energy < energyCost) {
      throw const GameRuleException('Para kazanmak için en az 15 enerji gerekir.');
    }

    final dailyReward = (baseReward * _dailyMultiplier(state.earningSessionsToday)).round();
    final reward = (dailyReward * _miniGameService.rewardMultiplier(performance)).round();
    final progressed = state.advanceHours(durationHours);
    final nextState = progressed.copyWith(
      money: state.money + reward,
      totalEarned: state.totalEarned + reward,
      energy: state.energy - energyCost,
      earningSessionsToday: progressed.day == state.day ? state.earningSessionsToday + 1 : 1,
    );
    return EarningResult(
      state: nextState,
      reward: reward,
      bonusPercent: _miniGameService.bonusPercent(performance),
    );
  }

  double _dailyMultiplier(int sessions) {
    if (sessions < 2) {
      return 1;
    }
    if (sessions == 2) {
      return .8;
    }
    if (sessions == 3) {
      return .6;
    }
    return .4;
  }
}
