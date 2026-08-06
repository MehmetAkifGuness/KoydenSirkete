import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_opportunity_service.dart';
import 'package:kariyerden_sirkete/features/employment/domain/entities/employment.dart';
import 'package:kariyerden_sirkete/features/employment/domain/services/employment_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/entities/job_listing.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/competition_service.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_catalog.dart';
import 'package:kariyerden_sirkete/features/skills/domain/entities/skill_id.dart';
import 'package:kariyerden_sirkete/features/skills/domain/entities/skill_profile.dart';
import 'package:kariyerden_sirkete/features/sport/domain/services/sport_service.dart';
import 'package:kariyerden_sirkete/features/training/domain/services/training_catalog.dart';
import 'package:kariyerden_sirkete/features/training/domain/services/training_service.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/employer_task_generator.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/task_efficiency_service.dart';

void main() {
  test('catalogs expose the locked content counts', () {
    expect(SkillId.values, hasLength(10));
    expect(JobCatalog.jobs, hasLength(20));
    expect(TrainingCatalog.courses.length, greaterThanOrEqualTo(10));
    expect(CityCatalog.cities, hasLength(81));
    expect(CityCatalog.cities.map((city) => city.name).toSet(), hasLength(81));
  });

  test('city opportunities and bots are deterministic for the same day', () {
    final cityService = CityOpportunityService();
    final first = cityService.listings(cityId: 3, day: 4);
    final second = cityService.listings(cityId: 3, day: 4);
    expect(first.map((listing) => listing.id), orderedEquals(second.map((listing) => listing.id)));

    final listing = JobListing(job: JobCatalog.jobs.first, cityId: 3, salary: 120, opportunityIndex: 0);
    final competition = CompetitionService();
    final botsA = competition.generateBots(listing, day: 4);
    final botsB = competition.generateBots(listing, day: 4);
    expect(botsA.length, inInclusiveRange(12, 24));
    expect(botsA.map((bot) => bot.score), orderedEquals(botsB.map((bot) => bot.score)));
  });

  test('training applies skill gains without changing general knowledge rules', () {
    final course = TrainingCatalog.findById('commercial-negotiation')!;
    final service = TrainingService();
    final started = service.start(PlayerState.initial.copyWith(money: 500), course);
    final completed = service.complete(PlayerState.initial.copyWith(money: 500), course);

    expect(started.totalHours, course.durationHours);
    expect(completed.knowledge, course.knowledge);
    expect(completed.skills[SkillId.sales], 8);
    expect(completed.skills[SkillId.negotiation], 8);
  });

  test('skills reduce task cost and duration within configured limits', () {
    final task = EmployerTaskGenerator().generate(job: JobCatalog.jobs[2], cityId: 3, day: 1).first;
    final state = PlayerState.initial.copyWith(skills: SkillProfile({
      for (final skill in SkillId.values) skill: 100,
    }));
    final effective = TaskEfficiencyService().calculate(state, task);

    expect(effective.durationHours, lessThanOrEqualTo((task.durationHours * .65).ceil()));
    expect(effective.energyCost, lessThanOrEqualTo((task.energyCost * .70).ceil()));
    expect(effective.durationHours, greaterThanOrEqualTo(1));
    expect(effective.energyCost, greaterThanOrEqualTo(5));
  });

  test('employment is dismissed after two active game days without a task', () {
    final state = PlayerState.initial.copyWith(
      day: 3,
      currentJobId: 1,
      employment: const Employment(jobId: 1, cityId: 1, salary: 120, company: 'Test', startedDay: 1, lastTaskDay: 1),
    );
    final dismissed = EmploymentService().checkAttendance(state);

    expect(dismissed.currentJobId, isNull);
    expect(dismissed.employment, isNull);
    expect(dismissed.dismissedDay, 3);
    expect(dismissed.lastJobEvent, contains('iki oyun günü'));
  });

  test('sport cannot increase max energy over 200', () {
    final service = SportService();
    final activity = service.start(PlayerState.initial.copyWith(maxEnergy: 198, energy: 198));
    final completed = service.complete(PlayerState.initial.copyWith(maxEnergy: 198, energy: 198));
    expect(activity.energyCost, 20);
    expect(completed.maxEnergy, 200);
  });
}
