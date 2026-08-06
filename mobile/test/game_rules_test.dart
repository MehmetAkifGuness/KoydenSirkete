import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';
import 'package:kariyerden_sirkete/features/earning/domain/services/earning_service.dart';
import 'package:kariyerden_sirkete/features/earning/domain/entities/earning_performance.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/training/domain/services/training_catalog.dart';
import 'package:kariyerden_sirkete/features/training/domain/services/training_service.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_application_service.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_catalog.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/work_service.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/work_task_catalog.dart';
import 'package:kariyerden_sirkete/features/career/domain/services/career_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/living_cost_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/skills/domain/entities/skill_id.dart';
import 'package:kariyerden_sirkete/features/skills/domain/entities/skill_profile.dart';

void main() {
  group('earning rules', () {
    test('spends energy, adds reward and advances time', () {
      final service = EarningService();
      final activity = service.start(PlayerState.initial);
      final result = service.complete(PlayerState.initial.copyWith(energy: 80, activeActivity: activity),);

      expect(result.reward, 100);
      expect(result.state.money, 340);
      expect(result.state.energy, 80);
      expect(result.state.hour, 8);
      expect(result.state.earningSessionsToday, 1);
    });

    test('reduces reward after the first two daily sessions', () {
      final service = EarningService();
      final first = service.complete(PlayerState.initial.copyWith(energy: 80),).state;
      final second = service.complete(first.copyWith(energy: 60, earningSessionsToday: 1)).state;
      final third = service.complete(second.copyWith(energy: 40, earningSessionsToday: 2));

      expect(third.reward, 80);
      expect(third.state.earningSessionsToday, 3);
    });

    test('applies mini game performance bonus without changing base rules', () {
      final service = EarningService();
      final result = service.complete(
        PlayerState.initial.copyWith(energy: 80),
        performance: const EarningPerformance(hits: 12),
      );

      expect(result.reward, 135);
      expect(result.bonusPercent, 35);
      expect(result.state.energy, 80);
    });

    test('rejects earning without enough energy', () {
      final state = PlayerState.initial.copyWith(energy: 14);

      expect(() => EarningService().start(state), throwsA(isA<GameRuleException>()));
    });
  });

  group('training rules', () {
    test('applies standard course cost, energy and knowledge', () {
      final course = TrainingCatalog.courses[1];
      final service = TrainingService();
      final activity = service.start(PlayerState.initial, course);
      final result = service.complete(PlayerState.initial.copyWith(energy: 85, activeActivity: activity), course);

      expect(result.money, 160);
      expect(result.energy, 85);
      expect(result.knowledge, 12);
      expect(result.experience, 2);
      expect(result.hour, 8);
    });

    test('allows free practice without money', () {
      final service = TrainingService();
      final course = TrainingCatalog.courses.first;
      final activity = service.start(PlayerState.initial, course);
      final result = service.complete(PlayerState.initial.copyWith(activeActivity: activity), course);

      expect(result.money, PlayerState.initial.money);
      expect(result.knowledge, 3);
    });

    test('rejects a course when money is insufficient', () {
      final state = PlayerState.initial.copyWith(money: 10);

      expect(
        () => TrainingService().start(state, TrainingCatalog.courses[1]),
        throwsA(isA<GameRuleException>()),
      );
    });
  });

  group('job application rules', () {
    test('allows an eligible player to apply and stores the active job', () {
      final job = JobCatalog.jobs.first;
      final result = JobApplicationService().apply(PlayerState.initial, job);

      expect(result.currentJobId, job.id);
    });

    test('rejects a job when knowledge is insufficient', () {
      final job = JobCatalog.jobs[1];

      expect(
        () => JobApplicationService().apply(PlayerState.initial, job),
        throwsA(isA<GameRuleException>()),
      );
    });

    test('rejects a second application while a job is active', () {
      final service = JobApplicationService();
      final first = service.apply(PlayerState.initial, JobCatalog.jobs.first);

      expect(
        () => service.apply(first, JobCatalog.jobs[1]),
        throwsA(isA<GameRuleException>()),
      );
    });
  });

  group('work and career rules', () {
    test('work task pays salary and increases performance', () {
      final job = JobCatalog.jobs.first;
      final state = PlayerState.initial.copyWith(currentJobId: job.id);
      final result = WorkService().execute(state, job, WorkTaskCatalog.tasks.first);

      expect(result.income, 120);
      expect(result.state.energy, 80);
      expect(result.state.performance, 5);
      expect(result.state.experience, 4);
    });

    test('promotion requires performance and progression', () {
      final current = JobCatalog.jobs.first;
      final next = JobCatalog.jobs[1];
      final state = PlayerState.initial.copyWith(currentJobId: current.id, performance: 70, knowledge: 12, experience: 10, skills: SkillProfile({SkillId.sales: 20, SkillId.leadership: 12}));
      final result = CareerService().promote(state, current, next);

      expect(result.currentJobId, next.id);
      expect(result.careerLevel, 2);
      expect(result.performance, 50);
    });
  });

  group('city and company rules', () {
    test('city move charges the move cost and living costs settle by day', () {
      final city = CityCatalog.cities[1];
      final moved = CityService().move(PlayerState.initial.copyWith(money: 500), city);
      final settled = LivingCostService().settle(moved.copyWith(day: 2));

      expect(moved.currentCityId, city.id);
      expect(moved.money, 400);
      expect(settled.money, 380);
      expect(settled.lastLivingCostDay, 2);
    });

    test('company can be established, staffed and progressed', () {
      final service = CompanyService();
      final ready = PlayerState.initial.copyWith(money: 1500, careerLevel: 3);
      final company = service.establish(ready);
      final staffed = service.recruit(company);
      final progress = service.advanceProject(staffed);

      expect(company.companyLevel, 1);
      expect(company.currentJobId, isNull);
      expect(staffed.employeeCount, 1);
      expect(progress.state.projectProgress, 10);
      expect(progress.state.experience, 5);
    });
  });

  test('v1.1 local catalogs expose new content', () {
    expect(JobCatalog.version, 3);
    expect(JobCatalog.jobs.length, 20);
    expect(WorkTaskCatalog.forJob(4), isNotEmpty);
    expect(TrainingCatalog.version, 3);
    expect(TrainingCatalog.courses.length, greaterThanOrEqualTo(10));
    expect(CityCatalog.version, 3);
    expect(CityCatalog.cities.length, 81);
  });
}
