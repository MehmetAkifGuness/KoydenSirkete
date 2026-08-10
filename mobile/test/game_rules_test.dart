import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';
import 'package:kariyerden_sirkete/features/earning/domain/services/earning_service.dart';
import 'package:kariyerden_sirkete/features/earning/domain/services/earning_mini_game_service.dart';
import 'package:kariyerden_sirkete/features/earning/presentation/state/earning_mini_game_controller.dart';
import 'package:kariyerden_sirkete/features/wheel/domain/entities/esnaf_wheel_reward.dart';
import 'package:kariyerden_sirkete/features/wheel/domain/services/esnaf_wheel_service.dart';
import 'package:kariyerden_sirkete/features/earning/domain/entities/earning_performance.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/employment/domain/entities/employment.dart';
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
    test('mini game uses a three by three field and ten second round', () {
      expect(EarningMiniGameService.durationSeconds, 10);
      expect(EarningMiniGameService.gridSize, 3);
    });

    test('mini game selects a different random target cell after each hit', () {
      final controller = EarningMiniGameController(random: Random(7));
      controller.start();
      final firstCell = controller.state.targetCell;
      controller.hit();

      expect(controller.state.targetCell, isNot(firstCell));
      expect(controller.state.targetCell, inInclusiveRange(0, EarningMiniGameService.cellCount - 1));
      controller.dispose();
    });

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

    test('stores the listed second-rank job instead of falling back to rank one', () {
      final job = JobCatalog.jobs[1];
      final state = PlayerState.initial.copyWith(
        knowledge: 100,
        experience: 100,
        skills: SkillProfile({for (final skill in SkillId.values) skill: 1000}),
      );
      final result = JobApplicationService().apply(state, job);

      expect(result.currentJobId, job.id);
      expect(result.employment?.jobId, job.id);
      expect(result.careerLevel, job.level);
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

    test('reports missing skills below the current job warning', () {
      final check = JobApplicationService().check(PlayerState.initial.copyWith(currentJobId: 1), JobCatalog.jobs[1]);

      expect(check.isEligible, isFalse);
      expect(check.reason, contains('Önce mevcut işinden ayrılmalısın'));
      expect(check.missingSkills[SkillId.sales], 130);
    });
  });

  group('work and career rules', () {
    test('work task pays salary and increases performance', () {
      final job = JobCatalog.jobs.first;
      final state = PlayerState.initial.copyWith(currentJobId: job.id);
      final result = WorkService().execute(state, job, WorkTaskCatalog.tasks.first);

      expect(result.income, 120);
      expect(result.state.energy, 90);
      expect(result.state.performance, 5);
      expect(result.state.experience, 5);
    });

    test('promotion requires performance and progression', () {
      final current = JobCatalog.jobs.first;
      final next = JobCatalog.jobs[1];
      final state = PlayerState.initial.copyWith(currentJobId: current.id, employment: const Employment(jobId: 1, cityId: 1, salary: 120, company: 'Bereket Market', startedDay: 1), performance: 70, knowledge: 12, experience: 10, skills: SkillProfile({SkillId.sales: 130, SkillId.leadership: 78}));
      final result = CareerService().promote(state, current, next);

      expect(result.currentJobId, next.id);
      expect(result.careerLevel, 2);
      expect(result.performance, 50);
      expect(result.employment?.jobId, next.id);
      expect(result.employment?.salary, next.salary);
    });
  });

  group('esnaf wheel rules', () {
    test('charges 50 TL without a cooldown and without active work', () {
      final state = PlayerState.initial.copyWith(money: 100);
      final outcome = EsnafWheelService(random: _FixedRandom(15)).spin(state);

      expect(outcome.state.money, 150);
      expect(outcome.state.wheelCooldownSeconds, 0);
    });

    test('uses 20 sectors with separated premium rewards', () {
      final sectors = EsnafWheelRewardCatalog.sectorTypes;
      expect(sectors, hasLength(20));
      expect(sectors.where((type) => type == EsnafWheelRewardType.bigTender), hasLength(1));
      expect(sectors.where((type) => type == EsnafWheelRewardType.luckyDay), hasLength(1));
      expect(sectors.where((type) => type == EsnafWheelRewardType.tipRain), hasLength(2));
      expect(sectors.where((type) => type != EsnafWheelRewardType.bigTender && type != EsnafWheelRewardType.luckyDay && type != EsnafWheelRewardType.tipRain), hasLength(16));
      expect([0, 5, 10, 15].map((index) => sectors[index]), orderedEquals([
        EsnafWheelRewardType.bigTender,
        EsnafWheelRewardType.luckyDay,
        EsnafWheelRewardType.tipRain,
        EsnafWheelRewardType.tipRain,
      ]));
    });

    test('uses 50 TL penalty and 1000 TL tender rewards', () {
      final penalty = EsnafWheelService(random: _FixedRandom(2)).spin(PlayerState.initial.copyWith(money: 100));
      final tender = EsnafWheelService(random: _FixedRandom(0)).spin(PlayerState.initial.copyWith(money: 100));

      expect(penalty.state.money, 0);
      expect(tender.state.money, 1050);
    });

    test('chance reward halves work costs and doubles the next two incomes', () {
      final outcome = EsnafWheelService(random: _FixedRandom(5)).spin(PlayerState.initial.copyWith(money: 100));

      expect(outcome.state.wheelDurationBuffPercent, 50);
      expect(outcome.state.wheelEnergyBuffPercent, 50);
      expect(outcome.state.wheelRewardBuffPercent, 100);
      expect(outcome.state.wheelRewardBuffTasks, 2);
    });

    test('converts major rewards to a tip after the daily limit', () {
      final job = JobCatalog.jobs.first;
      final activity = WorkService().start(PlayerState.initial.copyWith(currentJobId: job.id), job, WorkTaskCatalog.tasks.first);
      final state = PlayerState.initial.copyWith(money: 100, currentJobId: job.id, activeActivity: activity, wheelMajorRewardsToday: 3);
      final outcome = EsnafWheelService(random: _FixedRandom(0)).spin(state);

      expect(outcome.reward.type, EsnafWheelRewardType.tipRain);
      expect(outcome.state.wheelMajorRewardsToday, 3);
    });
  });

  group('city and company rules', () {
    test('city move charges the move cost and living costs settle by day', () {
      final city = CityCatalog.cities[1];
      final startingMoney = city.moveCost + city.dailyCost;
      final moved = CityService().move(PlayerState.initial.copyWith(money: startingMoney, careerLevel: city.minimumCareerLevel), city);
      final settled = LivingCostService().settle(moved.copyWith(day: 2));

      expect(moved.currentCityId, city.id);
      expect(moved.money, startingMoney - city.moveCost);
      expect(settled.money, moved.money - city.dailyCost);
      expect(settled.lastLivingCostDay, 2);
    });

    test('company can be established, staffed and progressed', () {
      final service = CompanyService();
      final ready = PlayerState.initial.copyWith(money: 1500, careerLevel: 3, currentJobId: 1, employment: const Employment(jobId: 1, cityId: 1, salary: 120, company: 'Bereket Market', startedDay: 1));
      final company = service.establish(ready);
      final staffed = service.recruit(company, employee: service.availableEmployees(company).first);
      final progress = service.advanceProject(staffed);

      expect(company.companyLevel, 1);
      expect(company.currentJobId, isNull);
      expect(company.employment, isNull);
      expect(staffed.employeeCount, 1);
      expect(staffed.companyFunds, company.companyFunds);
      expect(staffed.employees.single.performance, greaterThan(0));
      expect(progress.state.projectProgress, service.dailyProjectProgress(staffed));
      expect(progress.state.experience, 0);
    });
  });

  test('v1.1 local catalogs expose new content', () {
    expect(JobCatalog.version, 3);
    expect(JobCatalog.jobs.length, 20);
    expect(WorkTaskCatalog.forJob(4), isNotEmpty);
    expect(TrainingCatalog.version, 3);
    expect(TrainingCatalog.courses.length, greaterThanOrEqualTo(10));
    expect(CityCatalog.version, 5);
    expect(CityCatalog.cities.length, 81);
  });
}

class _FixedRandom implements Random {
  const _FixedRandom(this.value);

  final int value;

  @override
  bool nextBool() => value.isOdd;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => value.clamp(0, max - 1);
}
