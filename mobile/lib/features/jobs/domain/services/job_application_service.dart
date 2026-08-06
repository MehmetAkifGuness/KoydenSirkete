import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../../../employment/domain/entities/employment.dart';
import '../entities/job.dart';
import '../entities/job_listing.dart';
import 'competition_service.dart';

class JobApplicationCheck {
  const JobApplicationCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class JobApplicationService {
  JobApplicationService({CompetitionService? competitionService}) : _competitionService = competitionService ?? CompetitionService();

  final CompetitionService _competitionService;

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
    for (final requirement in job.skillRequirements.entries) {
      if (requirement.value > 0 && state.skills[requirement.key] < requirement.value) {
        return JobApplicationCheck(
          isEligible: false,
          reason: '${requirement.key.label} yeteneği en az ${requirement.value} olmalı.',
        );
      }
    }
    return const JobApplicationCheck(isEligible: true, reason: 'Başvuru için uygunsun.');
  }

  PlayerState apply(PlayerState state, Job job) {
    final checkResult = check(state, job);
    if (!checkResult.isEligible) {
      throw GameRuleException(checkResult.reason);
    }
    return _hire(state, JobListing(job: job, cityId: state.currentCityId, salary: job.salary, opportunityIndex: 0));
  }

  ActiveActivity start(PlayerState state, JobListing listing) {
    final result = check(state, listing.job);
    if (!result.isEligible) throw GameRuleException(result.reason);
    if (state.applicationBlockedJobId == listing.job.id && state.day < state.applicationBlockedUntilDay) {
      throw const GameRuleException('Bu ilana bugün tekrar başvuramazsın.');
    }
    if (state.energy < 10) {
      throw const GameRuleException('Başvuru karşılaşması için en az 10 enerji gerekir.');
    }
    return ActiveActivity(
      type: ActivityType.jobApplication,
      sourceId: '${listing.job.id}',
      remainingHours: 1,
      totalHours: 1,
      energyCost: 10,
      startedDay: state.day,
      startedHour: state.hour,
      payload: {'city_id': '${listing.cityId}', 'salary': '${listing.salary}'},
    );
  }

  PlayerState complete(PlayerState state, JobListing listing, {required int competitionDay}) {
    final competition = _competitionService.resolve(state, listing, day: competitionDay);
    if (competition.playerWon) {
      return _hire(state.copyWith(applicationBlockedJobId: null, applicationBlockedUntilDay: 0), listing);
    }
    return state.copyWith(
      applicationBlockedJobId: listing.job.id,
      applicationBlockedUntilDay: state.day + 1,
      lastJobEvent: 'Başvuru sonucu: ${listing.job.title} için rekabet kaybedildi.',
    );
  }

  PlayerState _hire(PlayerState state, JobListing listing) {
    return state.copyWith(
      currentJobId: listing.job.id,
      employment: Employment(
        jobId: listing.job.id,
        cityId: listing.cityId,
        salary: listing.salary,
        company: listing.job.company,
        startedDay: state.day,
      ),
      lastJobEvent: '${listing.job.title} pozisyonuna işe alındın.',
    );
  }
}
