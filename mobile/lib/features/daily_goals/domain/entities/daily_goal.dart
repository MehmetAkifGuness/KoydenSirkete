import '../../../game/domain/entities/player_state.dart';
import '../../../../core/errors/game_rule_exception.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class DailyGoalStatus {
  const DailyGoalStatus({
    required this.progress,
    required this.target,
    required this.reward,
    required this.isClaimed,
  });

  final int progress;
  final int target;
  final int reward;
  final bool isClaimed;

  bool get isComplete => progress >= target;
  double get ratio => (progress / target).clamp(0, 1).toDouble();
}

class DailyGoalService {
  static const target = 3;
  static const reward = 120;

  DailyGoalStatus status(PlayerState state) {
    final progress =
        (state.earningSessionsToday +
                state.workSessionsToday +
                state.trainingSessionsToday)
            .clamp(0, target);
    return DailyGoalStatus(
      progress: progress,
      target: target,
      reward: reward,
      isClaimed: state.dailyGoalClaimedDay == state.day,
    );
  }

  PlayerState claim(PlayerState state) {
    final current = status(state);
    if (current.isClaimed) {
      throw const GameRuleException('Günlük hedef ödülü zaten alındı.');
    }
    if (!current.isComplete) {
      throw const GameRuleException('Günlük hedef henüz tamamlanmadı.');
    }
    return state.copyWith(
      money: state.money + reward,
      dailyGoalClaimedDay: state.day,
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.rewards,
        amount: reward,
      ),
    );
  }
}
