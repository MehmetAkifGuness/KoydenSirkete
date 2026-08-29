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
import 'package:kariyerden_sirkete/features/jobs/domain/entities/job.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/entities/job_listing.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/work_service.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/work_task_catalog.dart';
import 'package:kariyerden_sirkete/features/career/domain/services/career_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/living_cost_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_salary_service.dart';
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
      expect(
        controller.state.targetCell,
        inInclusiveRange(0, EarningMiniGameService.cellCount - 1),
      );
      controller.dispose();
    });

    test('spends energy, adds reward and advances time', () {
      final service = EarningService();
      final activity = service.start(PlayerState.initial);
      final result = service.complete(
        PlayerState.initial.copyWith(energy: 80, activeActivity: activity),
      );

      expect(result.reward, 100);
      expect(result.state.money, 340);
      expect(result.state.energy, 80);
      expect(result.state.hour, 8);
      expect(result.state.earningSessionsToday, 1);
    });

    test('reduces reward after the first two daily sessions', () {
      final service = EarningService();
      final first = service
          .complete(PlayerState.initial.copyWith(energy: 80))
          .state;
      final second = service
          .complete(first.copyWith(energy: 60, earningSessionsToday: 1))
          .state;
      final third = service.complete(
        second.copyWith(energy: 40, earningSessionsToday: 2),
      );

      expect(third.reward, 80);
      expect(third.state.earningSessionsToday, 3);
    });

    test('balances the hit bonus and caps the maximum reward', () {
      final service = EarningService();
      final tenHits = service.complete(
        PlayerState.initial.copyWith(energy: 80),
        performance: const EarningPerformance(hits: 10),
      );
      final elevenHits = service.complete(
        PlayerState.initial.copyWith(energy: 80),
        performance: const EarningPerformance(hits: 11),
      );
      final twentyHits = service.complete(
        PlayerState.initial.copyWith(energy: 80),
        performance: const EarningPerformance(hits: 20),
      );

      expect(tenHits.reward, 150);
      expect(elevenHits.reward, 165);
      expect(elevenHits.reward, (tenHits.reward * 1.10).round());
      expect(elevenHits.bonusPercent, 65);
      expect(twentyHits.reward, 300);
      expect(twentyHits.bonusPercent, 200);
      expect(elevenHits.state.energy, 80);
    });

    test('rejects earning without enough energy', () {
      final state = PlayerState.initial.copyWith(energy: 14);

      expect(
        () => EarningService().start(state),
        throwsA(isA<GameRuleException>()),
      );
    });

    test('caps paid quick earning sessions per day', () {
      final service = EarningService();
      final capped = PlayerState.initial.copyWith(
        earningSessionsToday: EarningService.maxPaidSessionsPerDay,
      );

      expect(() => service.start(capped), throwsA(isA<GameRuleException>()));
      expect(service.complete(capped).reward, 0);
    });
  });

  group('training rules', () {
    test('applies standard course cost, energy and knowledge', () {
      final course = TrainingCatalog.courses[1];
      final service = TrainingService();
      final activity = service.start(PlayerState.initial, course);
      final result = service.complete(
        PlayerState.initial.copyWith(energy: 85, activeActivity: activity),
        course,
      );

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
      final result = service.complete(
        PlayerState.initial.copyWith(activeActivity: activity),
        course,
      );

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

    test(
      'stores the listed second-rank job instead of falling back to rank one',
      () {
        final job = JobCatalog.jobs[1];
        final state = PlayerState.initial.copyWith(
          knowledge: 100,
          experience: 100,
          skills: SkillProfile({
            for (final skill in SkillId.values) skill: 1000,
          }),
        );
        final result = JobApplicationService().apply(state, job);

        expect(result.currentJobId, job.id);
        expect(result.employment?.jobId, job.id);
        expect(result.careerLevel, job.level);
      },
    );

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

    test('stores the employer selected by the job listing', () {
      final job = JobCatalog.jobs.first;
      final listing = JobListing(
        job: job,
        cityId: 1,
        salary: job.salary,
        opportunityIndex: 0,
        employer: 'Pusula Perakende',
      );
      final state = PlayerState.initial.copyWith(
        knowledge: 1000,
        experience: 1000,
        skills: SkillProfile({
          for (final skill in SkillId.values) skill: SkillProfile.maxValue,
        }),
      );
      final service = JobApplicationService();
      final activity = service.start(state, listing);
      final result = service.complete(state, listing, competitionDay: 1);

      expect(activity.payload['employer'], 'Pusula Perakende');
      expect(result.employment?.company, 'Pusula Perakende');
    });

    test('reports missing skills below the current job warning', () {
      final check = JobApplicationService().check(
        PlayerState.initial.copyWith(currentJobId: 1),
        JobCatalog.jobs[1],
      );

      expect(check.isEligible, isFalse);
      expect(check.reason, contains('Önce mevcut işinden ayrılmalısın'));
      expect(check.missingSkills[SkillId.sales], 130);
    });
  });

  group('work and career rules', () {
    test('catalog exposes ordered specialization and management stages', () {
      final path = JobCatalog.careerPathFor(JobCatalog.jobs.first);

      expect(path.map((job) => job.level), [1, 2, 3, 4, 5]);
      expect(path[1].careerStage, CareerStage.specialist);
      expect(path[2].careerStage, CareerStage.senior);
      expect(path[2].careerDirection, 'Yönetici yolu');
      expect(path[3].careerStage, CareerStage.manager);
      expect(path[3].careerDirection, 'Yönetici yolu');
    });

    test('work task pays salary and increases performance', () {
      final job = JobCatalog.jobs.first;
      final state = PlayerState.initial.copyWith(currentJobId: job.id);
      final result = WorkService().execute(
        state,
        job,
        WorkTaskCatalog.tasks.first,
      );

      expect(result.income, 120);
      expect(result.state.energy, 90);
      expect(result.state.performance, 5);
      expect(result.state.experience, 5);
    });

    test('promotion requires performance and progression', () {
      final current = JobCatalog.jobs.first;
      final next = JobCatalog.jobs[1];
      final state = PlayerState.initial.copyWith(
        currentJobId: current.id,
        employment: const Employment(
          jobId: 1,
          cityId: 1,
          salary: 120,
          company: 'Pusula Perakende',
          startedDay: 1,
        ),
        performance: 70,
        knowledge: 12,
        experience: 10,
        skills: SkillProfile({SkillId.sales: 130, SkillId.leadership: 78}),
      );
      final result = CareerService().promote(state, current, next);

      expect(result.currentJobId, next.id);
      expect(result.careerLevel, 2);
      expect(result.performance, 50);
      expect(result.employment?.jobId, next.id);
      expect(result.employment?.company, 'Pusula Perakende');
      expect(
        result.employment?.salary,
        CitySalaryService().calculate(next, state.currentCityId),
      );
    });
  });

  group('esnaf wheel rules', () {
    test('charges 50 TL when the wheel lands on empty', () {
      final state = PlayerState.initial.copyWith(money: 100);
      final outcome = EsnafWheelService(random: _FixedRandom(0)).spin(state);

      expect(outcome.reward.type, EsnafWheelRewardType.empty);
      expect(outcome.state.money, 50);
    });

    test('uses the requested weighted twenty-sector distribution', () {
      final sectors = EsnafWheelRewardCatalog.sectorTypes;
      int count(EsnafWheelRewardType type) =>
          sectors.where((sector) => sector == type).length;

      expect(sectors, hasLength(20));
      expect(count(EsnafWheelRewardType.empty), 7);
      expect(count(EsnafWheelRewardType.majorPenalty), 3);
      expect(count(EsnafWheelRewardType.customerPenalty), 5);
      expect(count(EsnafWheelRewardType.luckyDay), 1);
      expect(count(EsnafWheelRewardType.bigTender), 1);
      expect(count(EsnafWheelRewardType.tipRain), 1);
      expect(count(EsnafWheelRewardType.smallTip), 2);
      for (var index = 0; index < sectors.length; index++) {
        expect(sectors[index], isNot(sectors[(index + 1) % sectors.length]));
      }
    });

    test('applies every cash reward and penalty amount', () {
      final sectors = EsnafWheelRewardCatalog.sectorTypes;
      final penalty50 = EsnafWheelService(
        random: _FixedRandom(
          sectors.indexOf(EsnafWheelRewardType.customerPenalty),
        ),
      ).spin(PlayerState.initial.copyWith(money: 100));
      final penalty100 = EsnafWheelService(
        random: _FixedRandom(
          sectors.indexOf(EsnafWheelRewardType.majorPenalty),
        ),
      ).spin(PlayerState.initial.copyWith(money: 150));
      final tender = EsnafWheelService(
        random: _FixedRandom(sectors.indexOf(EsnafWheelRewardType.bigTender)),
      ).spin(PlayerState.initial.copyWith(money: 100));
      final reward100 = EsnafWheelService(
        random: _FixedRandom(sectors.indexOf(EsnafWheelRewardType.tipRain)),
      ).spin(PlayerState.initial.copyWith(money: 100));
      final reward50 = EsnafWheelService(
        random: _FixedRandom(sectors.indexOf(EsnafWheelRewardType.smallTip)),
      ).spin(PlayerState.initial.copyWith(money: 100));

      expect(penalty50.state.money, 0);
      expect(penalty100.state.money, 0);
      expect(tender.state.money, 1050);
      expect(reward100.state.money, 150);
      expect(reward50.state.money, 100);
    });

    test(
      'chance reward halves work costs and doubles the next two incomes',
      () {
        final chanceIndex = EsnafWheelRewardCatalog.sectorTypes.indexOf(
          EsnafWheelRewardType.luckyDay,
        );
        final outcome = EsnafWheelService(
          random: _FixedRandom(chanceIndex),
        ).spin(PlayerState.initial.copyWith(money: 100));

        expect(outcome.state.wheelDurationBuffPercent, 50);
        expect(outcome.state.wheelEnergyBuffPercent, 50);
        expect(outcome.state.wheelRewardBuffPercent, 100);
        expect(outcome.state.wheelRewardBuffTasks, 2);
      },
    );

    test('converts major rewards to a tip after the daily limit', () {
      final state = PlayerState.initial.copyWith(
        money: 100,
        wheelMajorRewardsToday: 3,
      );
      final tenderIndex = EsnafWheelRewardCatalog.sectorTypes.indexOf(
        EsnafWheelRewardType.bigTender,
      );
      final outcome = EsnafWheelService(
        random: _FixedRandom(tenderIndex),
      ).spin(state);

      expect(outcome.reward.type, EsnafWheelRewardType.tipRain);
      expect(outcome.state.wheelMajorRewardsToday, 3);
    });
  });

  group('city and company rules', () {
    test('city move charges the move cost and living costs settle by day', () {
      final city = CityCatalog.cities[1];
      final startingMoney = city.moveCost + city.dailyCost;
      final moved = CityService().move(
        PlayerState.initial.copyWith(
          money: startingMoney,
          careerLevel: city.minimumCareerLevel,
        ),
        city,
      );
      final settled = LivingCostService().settle(moved.copyWith(day: 2));

      expect(moved.currentCityId, city.id);
      expect(moved.money, startingMoney - city.moveCost);
      expect(settled.money, moved.money - city.dailyCost);
      expect(settled.lastLivingCostDay, 2);
    });

    test('company can be established, staffed and progressed', () {
      final service = CompanyService();
      final ready = PlayerState.initial.copyWith(
        money: CompanyService.establishmentCost + 500,
        careerLevel: 3,
        currentJobId: 1,
        employment: const Employment(
          jobId: 1,
          cityId: 1,
          salary: 120,
          company: 'Bereket Market',
          startedDay: 1,
        ),
      );
      final company = service.establish(ready);
      final staffed = service.recruit(
        company,
        employee: service.availableEmployees(company).first,
      );
      final progress = service.advanceProject(staffed);

      expect(company.companyLevel, 1);
      expect(company.currentJobId, isNull);
      expect(company.employment, isNull);
      expect(staffed.employeeCount, 1);
      expect(staffed.companyFunds, company.companyFunds);
      expect(staffed.employees.single.performance, greaterThan(0));
      expect(
        progress.state.projectProgress,
        service.dailyProjectProgress(staffed),
      );
      expect(progress.state.experience, 0);
    });
  });

  test('v1.1 local catalogs expose new content', () {
    expect(JobCatalog.version, 3);
    expect(JobCatalog.jobs.length, 20);
    expect(WorkTaskCatalog.forJob(4), isNotEmpty);
    expect(TrainingCatalog.version, 3);
    expect(TrainingCatalog.courses.length, greaterThanOrEqualTo(10));
    expect(CityCatalog.version, 7);
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
