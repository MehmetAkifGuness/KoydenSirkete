import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_branch.dart';
import '../entities/company_budget_state.dart';
import '../entities/company_employee.dart';
import 'company_employee_catalog.dart';

class CompanyBudgetBreakdown {
  const CompanyBudgetBreakdown({
    this.office = 0,
    this.marketing = 0,
    this.research = 0,
    this.maintenance = 0,
  });

  final int office;
  final int marketing;
  final int research;
  final int maintenance;

  int get total => office + marketing + research + maintenance;

  int costFor(CompanyBudgetCategory category) => switch (category) {
    CompanyBudgetCategory.office => office,
    CompanyBudgetCategory.marketing => marketing,
    CompanyBudgetCategory.research => research,
    CompanyBudgetCategory.maintenance => maintenance,
  };
}

class CompanyBudgetService {
  const CompanyBudgetService();

  static const _officeDailyCost = 15;
  static const _marketingDailyCost = 20;
  static const _researchDailyCost = 25;
  static const _maintenanceDailyCostPerSite = 10;
  static const _baseDailyLimitPerCompanyLevel = 75;
  static const _dailyLimitPerBranch = 30;

  int dailyLimit(PlayerState state) =>
      state.companyLevel * _baseDailyLimitPerCompanyLevel +
      state.branches.length * _dailyLimitPerBranch;

  CompanyBudgetBreakdown dailyBreakdown(PlayerState state) {
    final budget = state.companyBudget;
    return CompanyBudgetBreakdown(
      office: budget.office.factor * _officeDailyCost,
      marketing: budget.marketing.factor * _marketingDailyCost,
      research: budget.research.factor * _researchDailyCost,
      maintenance:
          budget.maintenance.factor *
          _maintenanceDailyCostPerSite *
          (state.branches.length + 1),
    );
  }

  PlayerState setLevel(
    PlayerState state,
    CompanyBudgetCategory category,
    CompanyBudgetLevel level,
  ) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    final budget = state.companyBudget.withLevel(category, level);
    final candidate = state.copyWith(companyBudget: budget);
    final total = dailyBreakdown(candidate).total;
    final currentTotal = dailyBreakdown(state).total;
    final limit = dailyLimit(state);
    if (total > limit && total >= currentTotal) {
      throw GameRuleException(
        'Günlük bütçe sınırı ₺$limit. Önce başka bir kalemi düşürmelisin.',
      );
    }
    return candidate;
  }

  int marketingRevenueBonusPercent(PlayerState state) =>
      state.companyBudget.marketing.factor * 3;

  int maintenanceRevenueBonusPercent(PlayerState state) =>
      state.companyBudget.maintenance.factor * 2;

  int researchProgressBonus(PlayerState state) =>
      state.companyBudget.research.factor;

  PlayerState applyDailyHeadquartersOfficeEffect(PlayerState state) {
    final factor = state.companyBudget.office.factor;
    if (factor == 0) return state;
    final headquarters = state.employees.isNotEmpty
        ? state.employees
        : CompanyEmployeeCatalog.legacyDefaults(state.employeeCount);
    return state.copyWith(
      employees: [
        for (final employee in headquarters) _support(employee, factor),
      ],
    );
  }

  CompanyBranch applyDailyBranchOfficeEffect(
    PlayerState state,
    CompanyBranch branch,
  ) {
    final factor = state.companyBudget.office.factor;
    return factor == 0 ? branch : _supportBranch(branch, factor);
  }

  String effectFor(CompanyBudgetCategory category, CompanyBudgetLevel level) {
    final factor = level.factor;
    if (factor == 0) return 'Etki kapalı';
    return switch (category) {
      CompanyBudgetCategory.office =>
        'Günlük çalışan morali +$factor, tükenmişlik -$factor',
      CompanyBudgetCategory.marketing =>
        'Merkez ve bayi geliri +%${factor * 3}',
      CompanyBudgetCategory.research =>
        'Aktif proje ilerlemesi günlük +$factor',
      CompanyBudgetCategory.maintenance =>
        'Merkez ve bayi geliri +%${factor * 2}',
    };
  }

  CompanyEmployee _support(CompanyEmployee employee, int factor) =>
      employee.copyWith(
        morale: (employee.morale + factor).clamp(0, 100).toInt(),
        burnout: (employee.burnout - factor).clamp(0, 100).toInt(),
      );

  CompanyBranch _supportBranch(CompanyBranch branch, int factor) =>
      branch.copyWith(
        employees: [
          for (final employee in branch.employees) _support(employee, factor),
        ],
      );
}
