import '../entities/skill_id.dart';
import '../../../game/domain/entities/player_state.dart';

class SkillService {
  PlayerState improve(PlayerState state, Map<SkillId, int> deltas) {
    return state.copyWith(skills: state.skills.add(deltas));
  }

  int level(PlayerState state, SkillId skill) => state.skills[skill];
}
