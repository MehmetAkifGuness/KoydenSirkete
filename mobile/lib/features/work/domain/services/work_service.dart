import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../../../jobs/domain/entities/job.dart';
import '../entities/work_task.dart';
import 'task_efficiency_service.dart';

class WorkResult {
  const WorkResult({required this.state, required this.income});

  final PlayerState state;
  final int income;
}

class WorkService {
  WorkService({TaskEfficiencyService? efficiencyService}) : _efficiencyService = efficiencyService ?? TaskEfficiencyService();

  final TaskEfficiencyService _efficiencyService;

  ActiveActivity start(PlayerState state, Job job, WorkTask task) {
    if (state.currentJobId != job.id) {
      throw const GameRuleException('Bu görevi yapmak için aktif işin olmalı.');
    }
    if (task.jobId != job.id) {
      throw const GameRuleException('Bu görev aktif işine ait değil.');
    }
    final effective = _efficiencyService.calculate(state, task);
    if (state.energy < effective.energyCost) {
      throw const GameRuleException('Çalışmak için yeterli enerjin yok.');
    }

    return ActiveActivity(
      type: ActivityType.work,
      sourceId: '${task.id}',
      remainingHours: effective.durationHours,
      totalHours: effective.durationHours,
      energyCost: effective.energyCost,
      startedDay: state.day,
      startedHour: state.hour,
      payload: {'job_id': '${job.id}', 'task_id': '${task.id}'},
    );
  }

  WorkResult complete(PlayerState state, Job job, WorkTask task, {int? salary}) {
    final income = ((salary ?? job.salary) * task.salaryMultiplier * _performanceMultiplier(state.performance)).round();
    final nextState = state.copyWith(
      money: state.money + income,
      experience: state.experience + task.experienceGain,
      performance: (state.performance + task.performanceGain).clamp(0, 100),
      workSessionsToday: state.workSessionsToday + 1,
      totalEarned: state.totalEarned + income,
      totalWorkSessions: state.totalWorkSessions + 1,
    );
    return WorkResult(state: nextState, income: income);
  }

  WorkResult execute(PlayerState state, Job job, WorkTask task) {
    final activity = start(state, job, task);
    return complete(state.copyWith(energy: state.energy - activity.energyCost), job, task);
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
