import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../../../employment/domain/entities/employment.dart';
import '../entities/job.dart';
import '../entities/job_listing.dart';
import '../../../skills/domain/entities/skill_id.dart';
import '../../../cities/domain/services/city_salary_service.dart';
import 'competition_service.dart';

class JobApplicationCheck {
  const JobApplicationCheck({
    required this.isEligible,
    required this.reason,
    this.missingSkills = const {},
  });

  final bool isEligible;
  final String reason;
  final Map<SkillId, int> missingSkills;
}

class JobApplicationService {
  JobApplicationService({
    CompetitionService? competitionService,
    CitySalaryService? salaryService,
  }) : _competitionService = competitionService ?? CompetitionService(),
       _salaryService = salaryService ?? CitySalaryService();

  final CompetitionService _competitionService;
  final CitySalaryService _salaryService;

  JobApplicationCheck check(PlayerState state, Job job) {
    final missingSkills = _missingSkills(state, job);
    if (state.currentJobId != null || state.employment != null) {
      return JobApplicationCheck(
        isEligible: false,
        reason: 'Önce mevcut işinden ayrılmalısın.',
        missingSkills: missingSkills,
      );
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
    for (final requirement in missingSkills.entries) {
      if (requirement.value > 0) {
        return JobApplicationCheck(
          isEligible: false,
          reason:
              '${requirement.key.label} yeteneği en az ${requirement.value} olmalı.',
        );
      }
    }
    return const JobApplicationCheck(
      isEligible: true,
      reason: 'Şartları karşılıyorsun; sonuç aday rekabetine bağlı.',
    );
  }

  Map<SkillId, int> _missingSkills(PlayerState state, Job job) => {
    for (final entry in job.scaledSkillRequirements.entries)
      if (entry.value > state.skills[entry.key]) entry.key: entry.value,
  };

  PlayerState apply(PlayerState state, Job job) {
    final checkResult = check(state, job);
    if (!checkResult.isEligible) {
      throw GameRuleException(checkResult.reason);
    }
    return _hire(
      state,
      JobListing(
        job: job,
        cityId: state.currentCityId,
        salary: _salaryService.calculate(
          job,
          state.currentCityId,
          day: state.day,
        ),
        opportunityIndex: 0,
      ),
    );
  }

  ActiveActivity start(PlayerState state, JobListing listing) {
    final result = check(state, listing.job);
    if (!result.isEligible) throw GameRuleException(result.reason);
    if (state.applicationBlockedJobId == listing.job.id &&
        state.day < state.applicationBlockedUntilDay) {
      throw const GameRuleException('Bu ilana bugün tekrar başvuramazsın.');
    }
    if (state.energy < 10) {
      throw const GameRuleException(
        'Başvuru karşılaşması için en az 10 enerji gerekir.',
      );
    }
    return ActiveActivity(
      type: ActivityType.jobApplication,
      sourceId: '${listing.job.id}',
      remainingHours: 1,
      totalHours: 1,
      energyCost: 10,
      startedDay: state.day,
      startedHour: state.hour,
      payload: {
        'city_id': '${listing.cityId}',
        'salary': '${listing.salary}',
        'employer': listing.company,
      },
    );
  }

  PlayerState complete(
    PlayerState state,
    JobListing listing, {
    required int competitionDay,
  }) {
    final competition = _competitionService.resolve(
      state,
      listing,
      day: competitionDay,
    );
    if (competition.applicationSucceeded) {
      return _hire(
        state.copyWith(
          applicationBlockedJobId: null,
          applicationBlockedUntilDay: 0,
        ),
        listing,
        event:
            'Rekabeti ${competition.playerScore}-${competition.strongestBotScore} kazanarak ${listing.job.title} pozisyonuna işe alındın.',
      );
    }
    final event = competition.employerConnectionHired
        ? 'Rekabeti kazandın ancak patronun tanıdığı işe alındı.'
        : 'Başka bir aday rekabeti ${competition.strongestBotScore}-${competition.playerScore} kazandı.';
    return state.copyWith(
      applicationBlockedJobId: listing.job.id,
      applicationBlockedUntilDay: state.day + 1,
      lastJobEvent: 'Başvuru sonucu: $event',
    );
  }

  PlayerState _hire(PlayerState state, JobListing listing, {String? event}) {
    return state.copyWith(
      currentJobId: listing.job.id,
      careerLevel: listing.job.level,
      employment: Employment(
        jobId: listing.job.id,
        cityId: listing.cityId,
        salary: listing.salary,
        company: listing.company,
        startedDay: state.day,
      ),
      lastJobEvent: event ?? '${listing.job.title} pozisyonuna işe alındın.',
    );
  }
}
