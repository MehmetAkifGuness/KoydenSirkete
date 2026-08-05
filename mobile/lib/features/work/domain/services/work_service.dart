import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../jobs/domain/entities/job.dart';
import '../entities/work_task.dart';

class WorkResult {
  const WorkResult({required this.state, required this.income});

  final PlayerState state;
  final int income;
}

class WorkService {
  WorkResult execute(PlayerState state, Job job, WorkTask task) {
    if (state.currentJobId != job.id) {
      throw const GameRuleException('Bu görevi yapmak için aktif işin olmalı.');
    }
    if (task.jobId != job.id) {
      throw const GameRuleException('Bu görev aktif işine ait değil.');
    }
    if (state.energy < task.energyCost) {
      throw const GameRuleException('Çalışmak için yeterli enerjin yok.');
    }

    final progressed = state.advanceHours(task.durationHours);
    final income = (job.salary * task.salaryMultiplier * _performanceMultiplier(state.performance)).round();
    final nextState = progressed.copyWith(
      money: state.money + income,
      energy: state.energy - task.energyCost,
      experience: state.experience + task.experienceGain,
      performance: (state.performance + task.performanceGain).clamp(0, 100),
      workSessionsToday: progressed.day == state.day ? state.workSessionsToday + 1 : 1,
      totalEarned: state.totalEarned + income,
      totalWorkSessions: state.totalWorkSessions + 1,
    );
    return WorkResult(state: nextState, income: income);
  }

  double _performanceMultiplier(int performance) {
    if (performance >= 80) {
      return 1.15;
    }
    if (performance >= 50) {
      return 1.05;
    }
    return 1;
  }
}
