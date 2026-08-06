import '../../../game/domain/entities/player_state.dart';
import '../entities/work_task.dart';

class EffectiveWorkTask {
  const EffectiveWorkTask({required this.durationHours, required this.energyCost});

  final int durationHours;
  final int energyCost;
}

class TaskEfficiencyService {
  EffectiveWorkTask calculate(PlayerState state, WorkTask task) {
    if (task.skillRequirements.isEmpty) {
      return EffectiveWorkTask(durationHours: task.durationHours, energyCost: task.energyCost);
    }
    final average = task.skillRequirements.entries
            .map((entry) => state.skills[entry.key] / entry.value)
            .fold<double>(0, (total, ratio) => total + ratio) /
        task.skillRequirements.length;
    final durationReduction = (average * .35).clamp(0, .35);
    final energyReduction = (average * .30).clamp(0, .30);
    return EffectiveWorkTask(
      durationHours: (task.durationHours * (1 - durationReduction)).ceil().clamp(1, task.durationHours),
      energyCost: (task.energyCost * (1 - energyReduction)).ceil().clamp(5, task.energyCost),
    );
  }
}
