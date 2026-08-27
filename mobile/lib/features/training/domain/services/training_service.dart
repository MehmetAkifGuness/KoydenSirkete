import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../entities/course.dart';
import '../../../skills/domain/services/skill_service.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class TrainingService {
  TrainingService({SkillService? skillService})
    : _skillService = skillService ?? SkillService();

  final SkillService _skillService;

  ActiveActivity start(PlayerState state, Course course) {
    if (state.money < course.cost) {
      throw GameRuleException('${course.name} için yeterli paran yok.');
    }
    if (state.energy < course.energyCost) {
      throw GameRuleException(
        '${course.name} için en az ${course.energyCost} enerji gerekir.',
      );
    }

    return ActiveActivity(
      type: ActivityType.training,
      sourceId: course.id,
      remainingHours: course.durationHours,
      totalHours: course.durationHours,
      energyCost: course.energyCost,
      startedDay: state.day,
      startedHour: state.hour,
    );
  }

  PlayerState complete(PlayerState state, Course course) {
    final trained = state.copyWith(
      money: state.money - course.cost,
      knowledge: state.knowledge + course.knowledge,
      experience: state.experience + course.experience,
      trainingSessionsToday: state.trainingSessionsToday + 1,
      totalTrainingSessions: state.totalTrainingSessions + 1,
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.training,
        amount: -course.cost,
      ),
    );
    return _skillService.improve(trained, course.skillDeltas);
  }
}
