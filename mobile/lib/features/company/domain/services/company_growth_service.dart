import '../../../game/domain/entities/player_state.dart';
import '../entities/company_growth_goal.dart';
import 'company_branch_service.dart';
import 'company_service.dart';

class CompanyGrowthService {
  CompanyGrowthService({
    CompanyService? companyService,
    CompanyBranchService? branchService,
  }) : _companyService = companyService ?? CompanyService(),
       _branchService = branchService ?? CompanyBranchService();

  final CompanyService _companyService;
  final CompanyBranchService _branchService;

  static final goals = <CompanyGrowthGoal>[
    CompanyGrowthGoal(
      title: 'Güçlü ekip',
      description: 'Merkez ve bayilerde toplam 10 çalışana ulaş.',
      target: 10,
      measure: totalEmployees,
    ),
    CompanyGrowthGoal(
      title: 'Bölgesel ağ',
      description: '3 farklı şehirde bayi aç.',
      target: 3,
      measure: (state) => state.branches.length,
    ),
    CompanyGrowthGoal(
      title: 'Büyük sözleşmeler',
      description: '25 şirket projesi veya büyük sözleşme tamamla.',
      target: 25,
      measure: (state) => state.completedProjects,
    ),
    CompanyGrowthGoal(
      title: 'Ulusal marka',
      description: '10 farklı şehirde bayi aç.',
      target: 10,
      measure: (state) => state.branches.length,
    ),
    CompanyGrowthGoal(
      title: 'Kurumsal değer',
      description: '₺250.000 şirket değerlemesine ulaş.',
      target: 250000,
      measure: valuationFor,
    ),
    CompanyGrowthGoal(
      title: 'Pazar lideri',
      description: 'Ulusal pazar payını %30 seviyesine çıkar.',
      target: 30,
      measure: marketShareFor,
    ),
  ];

  static int totalEmployees(PlayerState state) =>
      CompanyService.employeesFor(state).length +
      state.branches.fold(0, (total, branch) => total + branch.employees.length);

  static int valuationFor(PlayerState state) =>
      CompanyGrowthService().valuation(state);

  static int marketShareFor(PlayerState state) =>
      CompanyGrowthService().marketShare(state).floor();

  int dailyNetIncome(PlayerState state) {
    var net = _companyService.dailyRevenue(state) -
        _companyService.dailyPayroll(state);
    for (final branch in state.branches) {
      net +=
          _branchService.dailyRevenue(branch) -
          _branchService.dailyPayroll(branch);
    }
    return net;
  }

  int valuation(PlayerState state) {
    if (state.companyLevel == 0) return 0;
    return (state.companyFunds.clamp(0, 1 << 62) +
            dailyNetIncome(state).clamp(0, 1 << 62) * 120 +
            state.completedProjects * 10000 +
            state.branches.length * 35000 +
            state.companyLevel * 20000)
        .toInt();
  }

  int reputation(PlayerState state) =>
      (state.companyLevel * 10 +
              state.completedProjects * 2 +
              state.branches.length * 5 +
              totalEmployees(state))
          .clamp(0, 100)
          .toInt();

  double marketShare(PlayerState state) =>
      (state.branches.length / 81 * 60 +
              state.completedProjects.clamp(0, 50) / 50 * 20 +
              state.companyLevel / CompanyService.maxCompanyLevel * 20)
          .clamp(0, 100)
          .toDouble();
}
