import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/cities/domain/entities/city.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_salary_service.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/living_cost_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/daily_goals/domain/entities/daily_goal.dart';
import 'package:kariyerden_sirkete/features/earning/domain/entities/earning_performance.dart';
import 'package:kariyerden_sirkete/features/earning/domain/services/earning_service.dart';
import 'package:kariyerden_sirkete/features/employment/domain/entities/employment.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/entities/job.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_catalog.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/employer_task_generator.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/work_service.dart';

void main() {
  test('city economy stays within the playable salary curve', () {
    final salaries = CitySalaryService();
    final dailyCosts = CityCatalog.cities.map((city) => city.dailyCost);
    final multipliers = CityCatalog.cities.map((city) => city.salaryMultiplier);

    expect(dailyCosts.reduce((left, right) => left < right ? left : right), 90);
    expect(
      dailyCosts.reduce((left, right) => left > right ? left : right),
      1000,
    );
    expect(multipliers.every((value) => value >= .95 && value <= 1.25), isTrue);

    for (final city in CityCatalog.cities) {
      final availableJobs = JobCatalog.jobs.where(
        (job) => job.level <= city.maximumJobLevel,
      );
      final bestDailySalary = availableJobs
          .map((job) => salaries.calculateForCity(job, city))
          .reduce((left, right) => left > right ? left : right);
      expect(city.dailyCost, lessThanOrEqualTo(bestDailySalary * 2));
    }
  });

  test('beginner reaches company capital gradually over thirty days', () {
    final city = CityCatalog.cities.first;
    final job = JobCatalog.jobs.first;
    final result = _playCareerDays(
      state: _employedState(job, city),
      job: job,
      days: 30,
    );

    expect(result.money, inInclusiveRange(10000, 15000));
    expect(result.money, lessThan(CompanyService.establishmentCost));
  });

  test(
    'metropolis career is viable without making a home a quick purchase',
    () {
      final city = CityCatalog.cities[2];
      final job = JobCatalog.findById(18)!;
      final result = _playCareerDays(
        state: _employedState(job, city),
        job: job,
        days: 100,
      );

      expect(result.money, inInclusiveRange(90000, 170000));
      expect(result.money, lessThan(200000));
    },
  );

  test('company and branch investments use multi-month payback periods', () {
    final employees = CompanyEmployeeCatalog.candidates.take(4).toList();
    final company = PlayerState.initial.copyWith(
      careerLevel: 3,
      companyLevel: 1,
      companyFunds: 500,
      employeeCount: employees.length,
      employees: employees,
      activeProjectId: 6,
    );
    final service = CompanyService();
    final firstMonth = service.processDailyOperations(company, days: 30).state;
    final dayOneHundred = service
        .processDailyOperations(firstMonth, days: 70)
        .state;
    final totalUpgradeCost =
        CompanyService.upgradeCost(1) + CompanyService.upgradeCost(2);

    expect(firstMonth.companyFunds, lessThan(totalUpgradeCost));
    expect(
      dayOneHundred.companyFunds,
      greaterThan(CompanyService.upgradeCost(1)),
    );
    expect(dayOneHundred.companyFunds, lessThan(totalUpgradeCost));

    final branchService = CompanyBranchService();
    for (final city in CityCatalog.cities) {
      final employee = CompanyEmployeeCatalog.availableForCity(
        cityId: city.id,
        occupiedSlots: 0,
        hiredIds: const <int>[],
      ).first;
      final branch = CompanyBranch(
        id: city.id,
        cityId: city.id,
        employees: [employee],
      );
      final dailyNet =
          branchService.dailyRevenue(branch) -
          branchService.dailyPayroll(branch);
      final paybackDays = (CompanyBranchService.openingCost(city) / dailyNet)
          .ceil();

      expect(paybackDays, inInclusiveRange(60, 220));
    }
  });
}

PlayerState _employedState(Job job, City city) {
  final salary = CitySalaryService().calculateForCity(job, city);
  return PlayerState.initial.copyWith(
    currentCityId: city.id,
    currentJobId: job.id,
    careerLevel: job.level,
    employment: Employment(
      jobId: job.id,
      cityId: city.id,
      salary: salary,
      company: job.company,
      startedDay: 1,
    ),
  );
}

PlayerState _playCareerDays({
  required PlayerState state,
  required Job job,
  required int days,
}) {
  final tasks = EmployerTaskGenerator();
  final work = WorkService();
  final earning = EarningService();
  final goals = DailyGoalService();
  final livingCosts = LivingCostService();
  var current = state;

  for (var index = 0; index < days; index++) {
    final dailyTasks = tasks.generate(
      job: job,
      cityId: current.currentCityId,
      day: current.day,
    );
    for (final task in dailyTasks.take(2)) {
      current = work
          .complete(current, job, task, salary: current.employment!.salary)
          .state;
    }
    current = earning
        .complete(current, performance: const EarningPerformance(hits: 10))
        .state;
    current = goals.claim(current);
    current = livingCosts.settle(
      current.copyWith(
        day: current.day + 1,
        earningSessionsToday: 0,
        workSessionsToday: 0,
        trainingSessionsToday: 0,
      ),
    );
  }
  return current;
}
