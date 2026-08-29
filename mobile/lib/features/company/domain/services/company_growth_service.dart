import '../../../game/domain/entities/player_state.dart';
import 'company_branch_service.dart';
import 'company_budget_service.dart';
import 'company_service.dart';
import 'company_region_service.dart';
import 'company_season_reward_service.dart';
import 'company_expansion_service.dart';

class CompanyGrowthService {
  CompanyGrowthService({
    CompanyService? companyService,
    CompanyBranchService? branchService,
    CompanyRegionService? regionService,
    CompanyExpansionService? expansionService,
    CompanySeasonRewardService? seasonRewardService,
  }) : _companyService = companyService ?? CompanyService(),
       _branchService = branchService ?? CompanyBranchService(),
       _regionService = regionService ?? CompanyRegionService(),
       _expansionService = expansionService ?? CompanyExpansionService(),
       _seasonRewardService =
           seasonRewardService ?? const CompanySeasonRewardService();

  final CompanyService _companyService;
  final CompanyBranchService _branchService;
  final CompanyRegionService _regionService;
  final CompanyExpansionService _expansionService;
  final CompanySeasonRewardService _seasonRewardService;

  static int totalEmployees(PlayerState state) =>
      CompanyService.employeesFor(state).length +
      state.branches.fold(
        0,
        (total, branch) => total + branch.employees.length,
      );

  static int valuationFor(PlayerState state) =>
      CompanyGrowthService().valuation(state);

  static int marketShareFor(PlayerState state) =>
      CompanyGrowthService().marketShare(state).floor();

  int dailyNetIncome(PlayerState state) {
    var net =
        _companyService.dailyRevenue(state) -
        _companyService.dailyPayroll(state);
    for (final branch in state.branches) {
      net +=
          _branchService.dailyRevenueFor(state, branch) -
          _branchService.dailyPayrollFor(state, branch);
    }
    return net;
  }

  int valuation(PlayerState state) {
    if (state.companyLevel == 0) return 0;
    return (state.companyFunds.clamp(0, 1 << 62) +
            dailyNetIncome(state).clamp(0, 1 << 62) * 120 +
            state.completedProjects * 10000 +
            state.branches.length * 35000 +
            state.companyLevel * 20000 +
            state.companyCompetition.championships * 50000 +
            _expansionService.valuationGain(state))
        .toInt();
  }

  int reputation(PlayerState state) =>
      (state.companyLevel * 10 +
              state.completedProjects * 2 +
              state.branches.length * 5 +
              state.companyCompetition.championships * 10 +
              _expansionService.reputationGain(state) +
              _seasonRewardService.reputationBonus(state) +
              const CompanyBudgetService().reputationBonus(state) +
              state.companyCompetition.decisionReputation +
              totalEmployees(state))
          .clamp(0, 100)
          .toInt();

  double marketShare(PlayerState state) =>
      (state.branches.length.clamp(0, 14) / 14 * 30 +
              _regionService.controlledCount(state) / 7 * 30 +
              state.completedProjects.clamp(0, 50) / 50 * 20 +
              state.companyLevel / CompanyService.maxCompanyLevel * 10 +
              state.companyCompetition.championships.clamp(0, 5) / 5 * 10 +
              _expansionService.marketShareGain(state))
          .clamp(0, 100)
          .toDouble();
}
