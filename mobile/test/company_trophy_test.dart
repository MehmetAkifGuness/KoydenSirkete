import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_strategy_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_trophy_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  test('trophy benefits unlock only at one, three, five and eight cups', () {
    final zero = _state(0);
    final one = _state(1);
    final three = _state(3);
    final five = _state(5);
    final eight = _state(8);

    expect(CompanyTrophyService.projectSuccessBonus(zero), 0);
    expect(CompanyTrophyService.projectSuccessBonus(one), 3);
    expect(CompanyTrophyService.branchRevenueBonus(one), 0);
    expect(CompanyTrophyService.branchRevenueBonus(three), 4);
    expect(CompanyTrophyService.branchPayrollDiscount(three), 0);
    expect(CompanyTrophyService.branchPayrollDiscount(five), 4);
    expect(CompanyTrophyService.marketScoreBonus(five), 0);
    expect(CompanyTrophyService.marketScoreBonus(eight), 5);
    expect(CompanyTrophyService.nextBenefit(eight), isNull);
  });

  test('cup milestones affect projects, branches and market competition', () {
    const employee = CompanyEmployee(
      id: 1,
      name: 'Operasyon Uzmanı',
      role: 'Operasyon uzmanı',
      performance: 70,
      dailySalary: 100,
    );
    const branch = CompanyBranch(id: 1, cityId: 1, employees: [employee]);
    final base = _state(0).copyWith(
      companyLevel: 1,
      employees: const [employee],
      employeeCount: 1,
      branches: const [branch],
    );
    final projectService = CompanyProjectStrategyService();
    final branchService = CompanyBranchService();
    final marketService = CompanyMarketService();
    final project = CompanyProjectCatalog.projects.first;
    final baseChance = projectService
        .forecast(state: base, project: project, employees: const [employee])
        .successChance;

    final oneCup = base.copyWith(
      companyCompetition: const CompanyCompetitionState(championships: 1),
    );
    final threeCups = base.copyWith(
      companyCompetition: const CompanyCompetitionState(championships: 3),
    );
    final fiveCups = base.copyWith(
      companyCompetition: const CompanyCompetitionState(championships: 5),
    );
    final eightCups = base.copyWith(
      companyCompetition: const CompanyCompetitionState(championships: 8),
    );

    expect(
      projectService
          .forecast(
            state: oneCup,
            project: project,
            employees: const [employee],
          )
          .successChance,
      baseChance + CompanyTrophyService.projectSuccessBonusPercent,
    );
    expect(
      branchService.dailyRevenueFor(threeCups, branch),
      (branchService.dailyRevenue(branch) * 1.04).round(),
    );
    expect(
      branchService.dailyPayrollFor(fiveCups, branch),
      (branchService.dailyPayroll(branch) * .96).round(),
    );
    expect(
      marketService.forecast(eightCups).playerScore,
      marketService.forecast(base).playerScore +
          CompanyTrophyService.marketStrengthBonus,
    );
  });
}

PlayerState _state(int championships) => PlayerState.initial.copyWith(
  companyLevel: 3,
  companyFunds: 10000,
  companyCompetition: CompanyCompetitionState(championships: championships),
);
