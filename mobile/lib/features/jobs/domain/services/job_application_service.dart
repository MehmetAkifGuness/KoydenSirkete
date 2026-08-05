import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/job.dart';

class JobApplicationCheck {
  const JobApplicationCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class JobApplicationService {
  JobApplicationCheck check(PlayerState state, Job job) {
    if (state.currentJobId != null) {
      return const JobApplicationCheck(isEligible: false, reason: 'Önce mevcut işinden ayrılmalısın.');
    }
    if (state.knowledge < job.minimumKnowledge) {
      return JobApplicationCheck(
        isEligible: false,
        reason: 'En az ${job.minimumKnowledge} bilgi gerekiyor.',
      );
    }
    if (state.experience < job.minimumExperience) {
      return JobApplicationCheck(
        isEligible: false,
        reason: 'En az ${job.minimumExperience} tecrübe gerekiyor.',
      );
    }
    return const JobApplicationCheck(isEligible: true, reason: 'Başvuru için uygunsun.');
  }

  PlayerState apply(PlayerState state, Job job) {
    final checkResult = check(state, job);
    if (!checkResult.isEligible) {
      throw GameRuleException(checkResult.reason);
    }
    return state.copyWith(currentJobId: job.id);
  }
}
