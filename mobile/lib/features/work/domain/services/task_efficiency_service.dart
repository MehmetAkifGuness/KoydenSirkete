import '../../../game/domain/entities/player_state.dart';
import '../entities/work_task.dart';

class EffectiveWorkTask {
  const EffectiveWorkTask({required this.durationHours, required this.energyCost});

  final int durationHours;
  final int energyCost;
}

class TaskEfficiencyService {
  EffectiveWorkTask calculate(PlayerState state, WorkTask task) {
    final average = task.skillRequirements.isEmpty
        ? 0
        : task.skillRequirements.entries
                .map((entry) => state.skills[entry.key] / entry.value)
                .fold<double>(0, (total, ratio) => total + ratio) /
            task.skillRequirements.length;
    final skillDurationReduction = (average * .35).clamp(0, .35);
    final skillEnergyReduction = (average * .30).clamp(0, .30);
    final wheelDurationReduction = state.wheelDurationBuffTasks > 0 ? state.wheelDurationBuffPercent / 100 : 0;
    final wheelEnergyReduction = state.wheelEnergyBuffTasks > 0 ? state.wheelEnergyBuffPercent / 100 : 0;
    final durationReduction = (1 - (1 - skillDurationReduction) * (1 - wheelDurationReduction)).clamp(0, .75);
    final energyReduction = (1 - (1 - skillEnergyReduction) * (1 - wheelEnergyReduction)).clamp(0, .75);
    return EffectiveWorkTask(
      durationHours: (task.durationHours * (1 - durationReduction)).ceil().clamp(1, task.durationHours),
      energyCost: (task.energyCost * (1 - energyReduction)).ceil().clamp(5, task.energyCost),
    );
  }
}
