import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/assets/domain/services/asset_service.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/car_catalog.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/home_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_salary_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/living_cost_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_development_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_growth_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_specialty.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_strategy_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_treasury_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_opportunity_service.dart';
import 'package:kariyerden_sirkete/features/employment/domain/entities/employment.dart';
import 'package:kariyerden_sirkete/features/employment/domain/services/employment_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/entities/job_listing.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/competition_service.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_application_service.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_catalog.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_employer_catalog.dart';
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
    expect(JobEmployerCatalog.employers, hasLength(24));
    expect(JobEmployerCatalog.employers.toSet(), hasLength(24));
    expect(TrainingCatalog.courses.length, greaterThanOrEqualTo(10));
    expect(
      CompanyEmployeeCatalog.candidates
          .map((employee) => employee.specialty)
          .toSet(),
      containsAll(CompanySpecialty.values),
    );
    expect(CityCatalog.cities, hasLength(81));
    expect(CityCatalog.cities.map((city) => city.name).toSet(), hasLength(81));
    expect(
      CityCatalog.cities.every(
        (city) => city.population > 0 && city.technologyLevel >= 20,
      ),
      isTrue,
    );
    expect(
      CityCatalog.cities[2].technologyLevel,
      greaterThan(CityCatalog.cities[0].technologyLevel),
    );
    expect(
      CityCatalog.cities[2].opportunityCount,
      greaterThan(CityCatalog.cities[0].opportunityCount),
    );
    expect(
      CityCatalog.cities[2].salaryMultiplier,
      greaterThan(CityCatalog.cities[0].salaryMultiplier),
    );
    expect(
      CityCatalog.cities.map((city) => city.salaryMultiplier),
      everyElement(inInclusiveRange(.95, 1.25)),
    );
  });

  test('city costs follow a bounded curve and ranks stay progressive', () {
    expect(
      CityCatalog.dailyCostForPopulation(100000),
      inInclusiveRange(90, 110),
    );
    expect(
      CityCatalog.dailyCostForPopulation(1000000),
      inInclusiveRange(300, 450),
    );
    expect(
      CityCatalog.dailyCostForPopulation(15754053),
      CityCatalog.maximumDailyCost,
    );
    expect(
      JobCatalog.findById(13)!.scaledSkillRequirements[SkillId.operations],
      228,
    );
    expect(
      JobCatalog.findById(15)!.scaledSkillRequirements[SkillId.operations],
      greaterThan(228),
    );
  });

  test('city opportunities and bots are deterministic for the same day', () {
    final cityService = CityOpportunityService();
    final first = cityService.listings(cityId: 3, day: 4);
    final second = cityService.listings(cityId: 3, day: 4);
    expect(
      first.map((listing) => listing.id),
      orderedEquals(second.map((listing) => listing.id)),
    );
    expect(
      first.map((listing) => listing.company),
      orderedEquals(second.map((listing) => listing.company)),
    );

    final listing = JobListing(
      job: JobCatalog.jobs.first,
      cityId: 3,
      salary: 120,
      opportunityIndex: 0,
    );
    final competition = CompetitionService();
    final botsA = competition.generateBots(listing, day: 4);
    final botsB = competition.generateBots(listing, day: 4);
    expect(botsA.length, inInclusiveRange(12, 24));
    expect(
      botsA.map((bot) => bot.score),
      orderedEquals(botsB.map((bot) => bot.score)),
    );
  });

  test('every job rank keeps a meaningful candidate competition', () {
    final competition = CompetitionService();
    for (final job in JobCatalog.jobs) {
      final listing = JobListing(
        job: job,
        cityId: 3,
        salary: job.salary,
        opportunityIndex: 0,
      );
      final eligible = PlayerState.initial.copyWith(
        knowledge: job.minimumKnowledge,
        experience: job.minimumExperience,
        skills: SkillProfile(job.scaledSkillRequirements),
      );
      final outcomes = [
        for (var day = 1; day <= 500; day++)
          competition.resolve(eligible, listing, day: day).playerWon,
      ];

      expect(
        outcomes,
        contains(true),
        reason: '${job.title} hiç kazanılamıyor.',
      );
      expect(
        outcomes,
        contains(false),
        reason: '${job.title} hep kazanılıyor.',
      );
    }
  });

  test('a connection hire blocks fifteen percent of won competitions', () {
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
      performance: 100,
      skills: SkillProfile({
        for (final skill in SkillId.values) skill: SkillProfile.maxValue,
      }),
    );
    final competition = CompetitionService();
    final results = [
      for (var day = 1; day <= 100; day++)
        competition.resolve(state, listing, day: day),
    ];
    final connectionDay =
        results.indexWhere((result) => result.employerConnectionHired) + 1;
    final rejected = JobApplicationService().complete(
      state,
      listing,
      competitionDay: connectionDay,
    );

    expect(results.every((result) => result.playerWon), isTrue);
    expect(
      results.where((result) => result.employerConnectionHired),
      hasLength(CompetitionService.employerConnectionChancePercent),
    );
    expect(rejected.employment, isNull);
    expect(rejected.lastJobEvent, contains('patronun tanıdığı işe alındı'));
  });

  test(
    'city salary applies to listings and follows the player when moving',
    () {
      final city = CityCatalog.cities[1];
      final salaryService = CitySalaryService();
      final listing = CityOpportunityService()
          .listings(cityId: city.id, day: 1)
          .first;
      final job = listing.job;
      final employed = PlayerState.initial.copyWith(
        money: city.moveCost * 2,
        careerLevel: 3,
        currentJobId: job.id,
        employment: Employment(
          jobId: job.id,
          cityId: 1,
          salary: job.salary,
          company: job.company,
          startedDay: 1,
        ),
      );

      final moved = CityService().move(employed, city);

      expect(listing.salary, salaryService.calculate(job, city.id));
      expect(moved.employment?.cityId, city.id);
      expect(moved.employment?.salary, salaryService.calculate(job, city.id));
    },
  );

  test('city listings vary by career track and respect city rank limits', () {
    final service = CityOpportunityService();
    final smallCity = CityCatalog.cities.firstWhere(
      (city) => city.maximumJobLevel == 2,
    );
    final smallListings = service.listings(cityId: smallCity.id, day: 4);
    final largeListings = service.listings(cityId: 3, day: 4);

    expect(
      smallListings.every(
        (listing) => listing.job.level <= smallCity.maximumJobLevel,
      ),
      isTrue,
    );
    expect(
      smallListings.map((listing) => listing.job.careerTrack).toSet(),
      hasLength(smallListings.length),
    );
    expect(largeListings.any((listing) => listing.job.level >= 4), isTrue);
  });

  test(
    'training applies skill gains without changing general knowledge rules',
    () {
      final course = TrainingCatalog.findById('commercial-negotiation')!;
      final service = TrainingService();
      final started = service.start(
        PlayerState.initial.copyWith(money: 500),
        course,
      );
      final completed = service.complete(
        PlayerState.initial.copyWith(money: 500),
        course,
      );

      expect(started.totalHours, course.durationHours);
      expect(completed.knowledge, course.knowledge);
      expect(completed.skills[SkillId.sales], 8);
      expect(completed.skills[SkillId.negotiation], 8);
    },
  );

  test('skill profiles use the 1000 point career scale', () {
    final profile = SkillProfile({SkillId.operations: 1500});
    expect(profile[SkillId.operations], SkillProfile.maxValue);
  });

  test('skills reduce task cost and duration within configured limits', () {
    final task = EmployerTaskGenerator()
        .generate(job: JobCatalog.jobs[2], cityId: 3, day: 1)
        .first;
    final state = PlayerState.initial.copyWith(
      skills: SkillProfile({
        for (final skill in SkillId.values) skill: SkillProfile.maxValue,
      }),
    );
    final effective = TaskEfficiencyService().calculate(state, task);

    expect(
      effective.durationHours,
      lessThanOrEqualTo((task.durationHours * .65).ceil()),
    );
    expect(
      effective.energyCost,
      lessThanOrEqualTo((task.energyCost * .70).ceil()),
    );
    expect(effective.durationHours, greaterThanOrEqualTo(1));
    expect(effective.energyCost, greaterThanOrEqualTo(5));
  });

  test('employer tasks use the twelve balanced base schedules', () {
    const expected = {
      '8/1/4',
      '10/2/5',
      '12/3/6',
      '14/4/7',
      '16/5/8',
      '18/6/9',
      '9/2/4',
      '15/3/7',
      '11/2/5',
      '13/4/6',
      '17/5/8',
      '19/6/10',
    };
    final generator = EmployerTaskGenerator();
    final schedules = <String>{};
    for (final job in JobCatalog.jobs) {
      for (var cityId = 1; cityId <= 5; cityId++) {
        for (var day = 1; day <= 10; day++) {
          schedules.addAll(
            generator
                .generate(job: job, cityId: cityId, day: day)
                .map(
                  (task) =>
                      '${task.energyCost}/${task.durationHours}/${task.experienceGain}',
                ),
          );
        }
      }
    }
    expect(schedules, containsAll(expected));
    expect(schedules.difference(expected), isEmpty);
  });

  test('city branch recruits employees and produces daily company income', () {
    final company = CompanyService()
        .establish(
          PlayerState.initial.copyWith(
            money: CompanyService.establishmentCost + 500,
            careerLevel: 3,
          ),
        )
        .copyWith(companyFunds: 100000);
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

  test('employee specialty improves matching project speed and success', () {
    const specialist = CompanyEmployee(
      id: 1001,
      name: 'Uzman',
      role: 'Operasyon uzmanı',
      performance: 80,
      dailySalary: 40,
    );
    const mismatched = CompanyEmployee(
      id: 1002,
      name: 'Finansçı',
      role: 'Finans analisti',
      performance: 80,
      dailySalary: 40,
    );
    final project = CompanyProjectCatalog.projects.first;
    final strategy = CompanyProjectStrategyService();
    final specialistForecast = strategy.forecast(
      state: PlayerState.initial.copyWith(companyLevel: 1),
      project: project,
      employees: const [specialist],
    );
    final mismatchedForecast = strategy.forecast(
      state: PlayerState.initial.copyWith(companyLevel: 1),
      project: project,
      employees: const [mismatched],
    );

    expect(specialist.specialty, CompanySpecialty.operations);
    expect(
      specialistForecast.dailyProgress,
      greaterThan(mismatchedForecast.dailyProgress),
    );
    expect(
      specialistForecast.successChance,
      greaterThan(mismatchedForecast.successChance),
    );
    expect(
      specialistForecast.estimatedDays,
      lessThan(mismatchedForecast.estimatedDays),
    );
  });

  test('employee development spends company funds and improves forecasts', () {
    const employee = CompanyEmployee(
      id: 1010,
      name: 'Gelişen Uzman',
      role: 'Operasyon uzmanı',
      performance: 80,
      dailySalary: 40,
    );
    final project = CompanyProjectCatalog.projects.first;
    final development = CompanyEmployeeDevelopmentService();
    final cost = CompanyEmployeeDevelopmentService.developmentCost(employee);
    final state = PlayerState.initial.copyWith(
      companyLevel: 1,
      companyFunds: cost + 100,
      employeeCount: 1,
      employees: const [employee],
    );
    final before = CompanyService().projectForecast(state, project);
    final developed = development.developHeadquarters(state, employee.id);
    final after = CompanyService().projectForecast(developed, project);

    expect(developed.companyFunds, 100);
    expect(developed.employees.single.performance, 85);
    expect(developed.employees.single.morale, 78);
    expect(developed.employees.single.loyalty, 75);
    expect(after.dailyProgress, greaterThan(before.dailyProgress));
    expect(after.successChance, greaterThanOrEqualTo(before.successChance));
  });

  test('maximum performance employee can recover morale and loyalty', () {
    const employee = CompanyEmployee(
      id: 1012,
      name: 'Kıdemli Uzman',
      role: 'Operasyon uzmanı',
      performance: 100,
      dailySalary: 80,
      morale: 40,
      loyalty: 50,
    );
    final cost = CompanyEmployeeDevelopmentService.developmentCost(employee);
    final state = PlayerState.initial.copyWith(
      companyLevel: 1,
      companyFunds: cost,
      employeeCount: 1,
      employees: const [employee],
    );
    final service = CompanyEmployeeDevelopmentService();
    final developed = service.developHeadquarters(state, employee.id);

    expect(service.checkHeadquarters(state, employee.id).isEligible, isTrue);
    expect(developed.employees.single.performance, 100);
    expect(developed.employees.single.morale, 48);
    expect(developed.employees.single.loyalty, 55);
  });

  test('branch employee development updates only its own branch', () {
    const employee = CompanyEmployee(
      id: 1011,
      name: 'Bayi Uzmanı',
      role: 'Satış temsilcisi',
      performance: 70,
      dailySalary: 35,
    );
    final cost = CompanyEmployeeDevelopmentService.developmentCost(employee);
    final state = PlayerState.initial.copyWith(
      companyLevel: 2,
      companyFunds: cost,
      branches: const [
        CompanyBranch(id: 1, cityId: 1, employees: [employee]),
        CompanyBranch(id: 2, cityId: 2),
      ],
    );
    final developed = CompanyEmployeeDevelopmentService().developBranch(
      state,
      1,
      employee.id,
    );

    expect(developed.companyFunds, 0);
    expect(developed.branches.first.employees.single.performance, 75);
    expect(developed.branches.last.employees, isEmpty);
  });

  test('high-risk project can fail and charges its operating cost', () {
    const employee = CompanyEmployee(
      id: 1003,
      name: 'Çalışan',
      role: 'Operasyon uzmanı',
      performance: 70,
      dailySalary: 30,
    );
    final project = CompanyProjectCatalog.projects.reduce(
      (left, right) => left.riskPercent >= right.riskPercent ? left : right,
    );
    final strategy = CompanyProjectStrategyService();
    final base = PlayerState.initial.copyWith(
      companyLevel: 1,
      employees: const [employee],
      employeeCount: 1,
      activeProjectId: project.id,
      projectProgress: 99,
    );
    final funds = Iterable<int>.generate(100, (index) => 10000 + index)
        .firstWhere(
          (value) => !strategy.succeeds(
            state: base.copyWith(companyFunds: value),
            project: project,
            employees: const [employee],
          ),
        );
    final result = CompanyService().advanceProject(
      base.copyWith(companyFunds: funds),
    );

    expect(result.succeeded, isFalse);
    expect(result.state.companyFunds, funds - project.cost);
    expect(result.state.completedProjects, 0);
    expect(result.state.projectProgress, 0);
  });

  test('branch upgrade spends funds and increases capacity and revenue', () {
    final city = CityCatalog.cities[2];
    const employee = CompanyEmployee(
      id: 1004,
      name: 'Dijital Uzman',
      role: 'Dijital uzmanı',
      performance: 85,
      dailySalary: 55,
    );
    final branch = CompanyBranch(
      id: city.id,
      cityId: city.id,
      employees: const [employee],
    );
    final service = CompanyBranchService();
    final cost = CompanyBranchService.upgradeCost(branch);
    final state = PlayerState.initial.copyWith(
      companyLevel: 3,
      companyFunds: cost + 100,
      branches: [branch],
    );
    final upgraded = service.upgrade(state, city.id);
    final upgradedBranch = upgraded.branches.single;

    expect(
      CompanyBranchService.preferredSpecialty(city),
      CompanySpecialty.technology,
    );
    expect(upgraded.companyFunds, 100);
    expect(upgradedBranch.level, 2);
    expect(CompanyBranchService.employeeCapacity(upgradedBranch), 6);
    expect(
      service.dailyRevenue(upgradedBranch),
      greaterThan(service.dailyRevenue(branch)),
    );
  });

  test('residence removes housing and car reduces moving cost', () {
    final city = CityCatalog.cities.first;
    final home = HomeCatalog.forCity(city).first;
    final assetService = AssetService();
    final homeState = assetService.buyHome(
      PlayerState.initial.copyWith(money: home.price),
      home,
      city,
    );
    final livingCosts = LivingCostService();
    final dueState = homeState.copyWith(day: 2);
    final costs = livingCosts.breakdown(dueState, city.id);
    final settled = livingCosts.settle(dueState);
    final car = CarCatalog.cars.first;
    final target = CityCatalog.cities[1];
    final carState = assetService.buyCar(
      PlayerState.initial.copyWith(
        money: car.price + target.moveCost,
        careerLevel: 3,
      ),
      car,
    );
    final moved = CityService().move(carState, target);

    expect(costs.housing, 0);
    expect(costs.totalExpenses, greaterThan(0));
    expect(settled.money, homeState.money - costs.totalExpenses);
    expect(moved.money, carState.money - (target.moveCost * .8).ceil());
  });

  test('residence removes housing only in its own city', () {
    final city = CityCatalog.cities[2];
    final home = HomeCatalog.forCity(city).first;
    final state = PlayerState.initial.copyWith(ownedHomeIds: [home.id]);
    final service = LivingCostService();

    expect(service.breakdown(state, city.id).housing, 0);
    expect(
      service.breakdown(state, state.currentCityId).housing,
      greaterThan(0),
    );
  });

  test('rented homes pay one percent monthly and stop being residences', () {
    final city = CityCatalog.cities.first;
    final homes = HomeCatalog.forCity(city);
    final home = homes.first;
    final assetService = AssetService();
    final livingCosts = LivingCostService(assetService: assetService);
    final rented = assetService.rentOutHome(
      PlayerState.initial.copyWith(ownedHomeIds: [home.id]),
      home,
    );
    final dueState = rented.copyWith(day: 2);
    final costs = livingCosts.breakdown(dueState, city.id);
    final settled = livingCosts.settle(dueState);

    expect(homes.map(assetService.monthlyRent), [2000, 4000, 6000]);
    expect(assetService.dailyRent(home), 67);
    expect(costs.housing, greaterThan(0));
    expect(costs.rentalIncome, 67);
    expect(costs.rentalMaintenance, 5);
    expect(assetService.monthlyNetRentalIncome(rented), 1840);
    expect(
      settled.money,
      rented.money - costs.totalExpenses + costs.rentalIncome,
    );
    expect(settled.totalEarned, rented.totalEarned + costs.rentalIncome);
    expect(
      settled.financeLedger.entries.map((entry) => entry.category),
      containsAll([
        FinanceCategory.rentalIncome,
        FinanceCategory.rentalMaintenance,
        FinanceCategory.housing,
      ]),
    );
  });

  test('finance ledger aggregates categories and retains thirty days', () {
    var ledger = const FinanceLedger();
    ledger = ledger.record(
      day: 1,
      category: FinanceCategory.casualIncome,
      amount: 100,
    );
    ledger = ledger.record(
      day: 1,
      category: FinanceCategory.casualIncome,
      amount: 50,
    );
    expect(ledger.forDay(1).single.amount, 150);
    ledger = ledger.record(
      day: 1,
      category: FinanceCategory.companyRevenue,
      amount: 200,
      account: FinanceAccount.company,
    );
    expect(
      ledger.forDay(1, account: FinanceAccount.personal).single.amount,
      150,
    );
    expect(
      ledger.forDay(1, account: FinanceAccount.company).single.amount,
      200,
    );
    ledger = ledger.record(
      day: 31,
      category: FinanceCategory.food,
      amount: -20,
    );

    expect(ledger.forDay(1), isEmpty);
    expect(ledger.forDay(31).single.amount, -20);
    expect(ledger.totals(fromDay: 2, toDay: 31).expense, 20);
  });

  test('treasury transfers preserve both accounts and apply dividend tax', () {
    final service = CompanyTreasuryService();
    final initial = PlayerState.initial.copyWith(
      money: 10000,
      companyLevel: 1,
      companyFunds: 2000,
    );
    final funded = service.addCapital(initial, 3000);
    final withdrawn = service.withdrawDividend(funded, 2000);

    expect(funded.money, 7000);
    expect(funded.companyFunds, 5000);
    expect(withdrawn.money, 8800);
    expect(withdrawn.companyFunds, 3000);
    expect(CompanyTreasuryService.dividendTax(2000), 200);
    expect(
      withdrawn.financeLedger
          .totals(fromDay: 1, toDay: 1, account: FinanceAccount.personal)
          .net,
      -1200,
    );
    expect(
      withdrawn.financeLedger
          .totals(fromDay: 1, toDay: 1, account: FinanceAccount.company)
          .net,
      1000,
    );
    expect(service.checkCapital(initial, 99).isEligible, isFalse);
    expect(service.checkDividend(initial, 3000).isEligible, isFalse);
  });

  test('company growth exposes valuation and long-term goals', () {
    final state = PlayerState.initial.copyWith(
      companyLevel: 3,
      companyFunds: 50000,
      completedProjects: 10,
      branches: const [
        CompanyBranch(id: 2, cityId: 2),
        CompanyBranch(id: 3, cityId: 3),
        CompanyBranch(id: 4, cityId: 4),
      ],
    );
    final service = CompanyGrowthService();

    expect(service.valuation(state), greaterThan(state.companyFunds));
    expect(service.reputation(state), greaterThan(0));
    expect(service.marketShare(state), greaterThan(0));
    expect(CompanyProjectCatalog.projects, hasLength(7));
    expect(CompanyProjectCatalog.projects.last.progressPerEmployee, 2);
  });

  test('living expenses scale with income, time, and car ownership', () {
    final city = CityCatalog.cities.first;
    final service = LivingCostService();
    final base = service.breakdown(PlayerState.initial, city.id);
    final rich = service.breakdown(
      PlayerState.initial.copyWith(totalEarned: 6000),
      city.id,
    );
    final late = service.breakdown(
      PlayerState.initial.copyWith(day: 61),
      city.id,
    );
    final car = service.breakdown(
      PlayerState.initial.copyWith(ownedCarId: CarCatalog.cars.last.id),
      city.id,
    );

    expect(rich.food, greaterThan(base.food));
    expect(rich.utilities, greaterThan(base.utilities));
    expect(late.totalExpenses, greaterThan(base.totalExpenses));
    expect(car.transportation, lessThan(base.transportation));
  });

  test('home tiers use fixed prices', () {
    final homes = HomeCatalog.forCity(CityCatalog.cities[2]);

    expect(homes.map((home) => home.price), [200000, 400000, 600000]);
  });

  test('homes and cars sell for seventy percent of purchase price', () {
    final city = CityCatalog.cities.first;
    final home = HomeCatalog.forCity(city).first;
    final car = CarCatalog.cars.first;
    final service = AssetService();
    final initial = PlayerState.initial.copyWith(money: home.price + car.price);
    final withHome = service.buyHome(initial, home, city);
    final withAssets = service.buyCar(withHome, car);

    final withoutHome = service.sellHome(withAssets, home);
    final sold = service.sellCar(withoutHome, car);

    expect(withoutHome.ownedHomeIds, isEmpty);
    expect(sold.ownedCarId, isNull);
    expect(sold.money, service.homeSaleValue(home) + service.carSaleValue(car));
  });

  test('employment is dismissed after two active game days without a task', () {
    final state = PlayerState.initial.copyWith(
      day: 3,
      currentJobId: 1,
      employment: const Employment(
        jobId: 1,
        cityId: 1,
        salary: 120,
        company: 'Test',
        startedDay: 1,
        lastTaskDay: 1,
      ),
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
      employment: const Employment(
        jobId: 1,
        cityId: 1,
        salary: 120,
        company: 'Test',
        startedDay: 2,
      ),
    );
    final nextDay = EmploymentService().checkAttendance(state.copyWith(day: 3));
    final dismissed = EmploymentService().checkAttendance(
      state.copyWith(day: 4),
    );

    expect(nextDay.employment, isNotNull);
    expect(dismissed.employment, isNull);
  });

  test('sport cannot increase max energy over 1000', () {
    final service = SportService();
    final activity = service.start(
      PlayerState.initial.copyWith(maxEnergy: 998, energy: 998),
    );
    final completed = service.complete(
      PlayerState.initial.copyWith(maxEnergy: 998, energy: 998),
    );
    expect(activity.energyCost, 20);
    expect(completed.maxEnergy, 1000);
  });
}
