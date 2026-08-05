import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/course.dart';

class TrainingService {
  PlayerState execute(PlayerState state, Course course) {
    if (state.money < course.cost) {
      throw GameRuleException('${course.name} için yeterli paran yok.');
    }
    if (state.energy < course.energyCost) {
      throw GameRuleException('${course.name} için en az ${course.energyCost} enerji gerekir.');
    }

    final progressed = state.advanceHours(course.durationHours);
    return progressed.copyWith(
      money: state.money - course.cost,
      energy: state.energy - course.energyCost,
      knowledge: state.knowledge + course.knowledge,
      experience: state.experience + course.experience,
    );
  }
}
