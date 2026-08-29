import '../../../../core/errors/game_rule_exception.dart';
import '../entities/earning_performance.dart';
import 'earning_mini_game_service.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class EarningResult {
  const EarningResult({
    required this.state,
    required this.reward,
    required this.bonusPercent,
  });

  final PlayerState state;
  final int reward;
  final int bonusPercent;
}

class EarningService {
  EarningService({EarningMiniGameService? miniGameService})
    : _miniGameService = miniGameService ?? EarningMiniGameService();

  static const energyCost = 20;
  static const durationHours = 2;
  static const baseReward = 100;
  static const maxPaidSessionsPerDay = 4;

  final EarningMiniGameService _miniGameService;

  ActiveActivity start(
    PlayerState state, {
    EarningPerformance performance = EarningPerformance.none,
  }) {
    if (state.earningSessionsToday >= maxPaidSessionsPerDay) {
      throw const GameRuleException(
        'Günlük hızlı kazanç sınırına ulaştın. Yeni gün başlayınca tekrar deneyebilirsin.',
      );
    }
    if (state.energy < energyCost) {
      throw const GameRuleException(
        'Para kazanmak için en az 20 enerji gerekir.',
      );
    }

    return ActiveActivity(
      type: ActivityType.earning,
      sourceId: 'earning',
      remainingHours: durationHours,
      totalHours: durationHours,
      energyCost: energyCost,
      startedDay: state.day,
      startedHour: state.hour,
      payload: {'hits': '${performance.hits}'},
    );
  }

  EarningResult complete(
    PlayerState state, {
    EarningPerformance performance = EarningPerformance.none,
  }) {
    final dailyReward =
        (baseReward * _dailyMultiplier(state.earningSessionsToday)).round();
    final reward =
        (dailyReward * _miniGameService.rewardMultiplier(performance)).round();
    final nextState = state.copyWith(
      money: state.money + reward,
      totalEarned: state.totalEarned + reward,
      earningSessionsToday: state.earningSessionsToday + 1,
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.casualIncome,
        amount: reward,
      ),
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
    return 0;
  }
}
