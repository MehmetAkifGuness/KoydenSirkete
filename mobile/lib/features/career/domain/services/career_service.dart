import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../cities/domain/services/city_salary_service.dart';

class PromotionCheck {
  const PromotionCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class CareerService {
  CareerService({CitySalaryService? salaryService})
    : _salaryService = salaryService ?? CitySalaryService();

  final CitySalaryService _salaryService;

  PromotionCheck check(PlayerState state, Job currentJob, Job? nextJob) {
    final activeJobId = state.employment?.jobId ?? state.currentJobId;
    if (activeJobId != currentJob.id) {
      return const PromotionCheck(
        isEligible: false,
        reason: 'Bu kariyer hattı aktif işin değil.',
      );
    }
    if (nextJob == null) {
      return const PromotionCheck(
        isEligible: false,
        reason: 'Bu kariyer hattının son seviyesindesin.',
      );
    }
    if (state.performance < 70) {
      return const PromotionCheck(
        isEligible: false,
        reason: 'Terfi için performansın en az %70 olmalı.',
      );
    }
    if (state.knowledge < nextJob.minimumKnowledge) {
      return PromotionCheck(
        isEligible: false,
        reason: 'Terfi için en az ${nextJob.minimumKnowledge} bilgi gerekiyor.',
      );
    }
    if (state.experience < nextJob.minimumExperience) {
      return PromotionCheck(
        isEligible: false,
        reason:
            'Terfi için en az ${nextJob.minimumExperience} tecrübe gerekiyor.',
      );
    }
    for (final requirement in nextJob.scaledSkillRequirements.entries) {
      if (requirement.value > 0 &&
          state.skills[requirement.key] < requirement.value) {
        return PromotionCheck(
          isEligible: false,
          reason:
              '${requirement.key.label} yeteneği en az ${requirement.value} olmalı.',
        );
      }
    }
    return const PromotionCheck(
      isEligible: true,
      reason: 'Terfi için hazırsın.',
    );
  }

  PlayerState promote(PlayerState state, Job currentJob, Job nextJob) {
    final result = check(state, currentJob, nextJob);
    if (!result.isEligible) {
      throw GameRuleException(result.reason);
    }
    return state.copyWith(
      currentJobId: nextJob.id,
      careerLevel: nextJob.level,
      performance: 50,
      employment: state.employment?.copyWith(
        jobId: nextJob.id,
        cityId: state.currentCityId,
        salary: _salaryService.calculate(nextJob, state.currentCityId),
        company: state.employment!.company,
      ),
    );
  }
}
