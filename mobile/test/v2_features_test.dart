import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/app/theme/app_palette.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/asset_service.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/car_catalog.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/home_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/living_cost_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
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
  test('offline theme catalog exposes ten unique palettes', () {
    expect(AppPalette.schemes, hasLength(10));
    expect(AppPalette.schemes.map((scheme) => scheme.id).toSet(), hasLength(10));
    expect(AppPalette.schemes.map((scheme) => scheme.name).toSet(), hasLength(10));
    expect(AppPalette.schemes.map((scheme) => scheme.background).toSet(), hasLength(10));
    expect(AppPalette.schemes.map((scheme) => scheme.surface).toSet(), hasLength(10));
  });

  test('catalogs expose the locked content counts', () {
    expect(SkillId.values, hasLength(10));
    expect(JobCatalog.jobs, hasLength(20));
    expect(TrainingCatalog.courses.length, greaterThanOrEqualTo(10));
    expect(CityCatalog.cities, hasLength(81));
    expect(CityCatalog.cities.map((city) => city.name).toSet(), hasLength(81));
    expect(CityCatalog.cities.every((city) => city.population > 0 && city.technologyLevel >= 20), isTrue);
    expect(CityCatalog.cities[2].technologyLevel, greaterThan(CityCatalog.cities[0].technologyLevel));
    expect(CityCatalog.cities[2].opportunityCount, greaterThan(CityCatalog.cities[0].opportunityCount));
    expect(CityCatalog.cities[2].salaryMultiplier, greaterThan(CityCatalog.cities[0].salaryMultiplier));
  });

  test('city rent follows population and rank requirements stay progressive', () {
    expect(CityCatalog.dailyCostForPopulation(100000), 50);
    expect(CityCatalog.dailyCostForPopulation(1000000), 500);
    expect(JobCatalog.findById(13)!.scaledSkillRequirements[SkillId.operations], 228);
    expect(JobCatalog.findById(15)!.scaledSkillRequirements[SkillId.operations], greaterThan(228));
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

  test('city listings vary by career track and respect city rank limits', () {
    final service = CityOpportunityService();
    final smallCity = CityCatalog.cities.firstWhere((city) => city.maximumJobLevel == 2);
    final smallListings = service.listings(cityId: smallCity.id, day: 4);
    final largeListings = service.listings(cityId: 3, day: 4);

    expect(smallListings.every((listing) => listing.job.level <= smallCity.maximumJobLevel), isTrue);
    expect(smallListings.map((listing) => listing.job.careerTrack).toSet(), hasLength(smallListings.length));
    expect(largeListings.any((listing) => listing.job.level >= 4), isTrue);
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

  test('skill profiles use the 1000 point career scale', () {
    final profile = SkillProfile({SkillId.operations: 1500});
    expect(profile[SkillId.operations], SkillProfile.maxValue);
  });

  test('skills reduce task cost and duration within configured limits', () {
    final task = EmployerTaskGenerator().generate(job: JobCatalog.jobs[2], cityId: 3, day: 1).first;
    final state = PlayerState.initial.copyWith(skills: SkillProfile({
      for (final skill in SkillId.values) skill: SkillProfile.maxValue,
    }));
    final effective = TaskEfficiencyService().calculate(state, task);

    expect(effective.durationHours, lessThanOrEqualTo((task.durationHours * .65).ceil()));
    expect(effective.energyCost, lessThanOrEqualTo((task.energyCost * .70).ceil()));
    expect(effective.durationHours, greaterThanOrEqualTo(1));
    expect(effective.energyCost, greaterThanOrEqualTo(5));
  });

  test('employer tasks use the six locked base schedules', () {
    const expected = {
      '10/2/5',
      '12/3/6',
      '14/4/7',
      '16/5/8',
      '18/6/9',
      '20/7/10',
    };
    final generator = EmployerTaskGenerator();
    final schedules = <String>{};
    for (final job in JobCatalog.jobs) {
      for (var cityId = 1; cityId <= 5; cityId++) {
        for (var day = 1; day <= 10; day++) {
          schedules.addAll(generator.generate(job: job, cityId: cityId, day: day).map((task) => '${task.energyCost}/${task.durationHours}/${task.experienceGain}'));
        }
      }
    }
    expect(schedules, containsAll(expected));
    expect(schedules.difference(expected), isEmpty);
  });

  test('city branch recruits employees and produces daily company income', () {
    final company = CompanyService().establish(PlayerState.initial.copyWith(money: 1500, careerLevel: 3)).copyWith(companyFunds: 100000);
    final city = CityCatalog.cities[1];
    final branchService = CompanyBranchService();
    final opened = branchService.open(company, city);
    final branch = opened.branches.single;
    final employee = branchService.availableEmployees(opened, branch).first;
    final staffed = branchService.recruit(opened, city.id, employee);
    final operated = branchService.processDailyOperations(staffed);

    expect(opened.companyFunds, lessThan(company.companyFunds));
    expect(staffed.branches.single.employees.single.id, employee.id);
    expect(operated.state.companyFunds, greaterThan(staffed.companyFunds));
  });

  test('owned home removes rent in its city and car reduces moving cost', () {
    final city = CityCatalog.cities.first;
    final home = HomeCatalog.forCity(city).first;
    final assetService = AssetService();
    final homeState = assetService.buyHome(PlayerState.initial.copyWith(money: home.price), home, city);
    final settled = LivingCostService().settle(homeState.copyWith(day: 2));
    final car = CarCatalog.cars.first;
    final target = CityCatalog.cities[1];
    final carState = assetService.buyCar(PlayerState.initial.copyWith(money: car.price + target.moveCost, careerLevel: 3), car);
    final moved = CityService().move(carState, target);

    expect(settled.money, homeState.money);
    expect(moved.money, carState.money - (target.moveCost * .8).ceil());
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

  test('new employment has a two-day attendance grace period', () {
    final state = PlayerState.initial.copyWith(
      day: 2,
      currentJobId: 1,
      employment: const Employment(jobId: 1, cityId: 1, salary: 120, company: 'Test', startedDay: 2),
    );
    final nextDay = EmploymentService().checkAttendance(state.copyWith(day: 3));
    final dismissed = EmploymentService().checkAttendance(state.copyWith(day: 4));

    expect(nextDay.employment, isNotNull);
    expect(dismissed.employment, isNull);
  });

  test('sport cannot increase max energy over 1000', () {
    final service = SportService();
    final activity = service.start(PlayerState.initial.copyWith(maxEnergy: 998, energy: 998));
    final completed = service.complete(PlayerState.initial.copyWith(maxEnergy: 998, energy: 998));
    expect(activity.energyCost, 20);
    expect(completed.maxEnergy, 1000);
  });
}
