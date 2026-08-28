import '../../../game/domain/entities/player_state.dart';
import '../entities/company_employee.dart';
import 'company_market_service.dart';
import 'company_service.dart';
import 'company_region_service.dart';

class EmployeeWellbeingSummary {
  const EmployeeWellbeingSummary({
    required this.averageMorale,
    required this.averageLoyalty,
    required this.atRiskCount,
    required this.employeeCount,
  });

  final int averageMorale;
  final int averageLoyalty;
  final int atRiskCount;
  final int employeeCount;
}

class EmployeeWellbeingResult {
  const EmployeeWellbeingResult({required this.state, required this.messages});

  final PlayerState state;
  final List<String> messages;
}

class CompanyEmployeeWellbeingService {
  CompanyEmployeeWellbeingService({CompanyRegionService? regionService})
    : _regionService = regionService ?? CompanyRegionService();

  final CompanyRegionService _regionService;

  EmployeeWellbeingSummary summary(PlayerState state) {
    final employees = _allEmployees(state);
    if (employees.isEmpty) {
      return const EmployeeWellbeingSummary(
        averageMorale: 0,
        averageLoyalty: 0,
        atRiskCount: 0,
        employeeCount: 0,
      );
    }
    return EmployeeWellbeingSummary(
      averageMorale:
          employees.fold<int>(0, (total, item) => total + item.morale) ~/
          employees.length,
      averageLoyalty:
          employees.fold<int>(0, (total, item) => total + item.loyalty) ~/
          employees.length,
      atRiskCount: employees.where((item) => item.loyalty <= 30).length,
      employeeCount: employees.length,
    );
  }

  EmployeeWellbeingResult process(
    PlayerState state,
    List<DailyMarketOutcome> outcomes,
  ) {
    var current = state;
    final messages = <String>[];
    for (final outcome in outcomes) {
      final resigned = <String>[];
      final moraleProtection = _regionService.moraleProtection(current);
      final employees = _updateEmployees(
        CompanyService.employeesFor(current),
        outcome,
        resigned,
        moraleProtection,
      );
      final branches = [
        for (final branch in current.branches)
          branch.copyWith(
            employees: _updateEmployees(
              branch.employees,
              outcome,
              resigned,
              moraleProtection,
            ),
          ),
      ];
      current = current.copyWith(
        employees: employees,
        employeeCount: employees.length,
        branches: branches,
      );
      for (final name in resigned) {
        messages.add('$name düşük sadakat nedeniyle şirketten ayrıldı.');
      }
    }
    return EmployeeWellbeingResult(state: current, messages: messages);
  }

  List<CompanyEmployee> _updateEmployees(
    List<CompanyEmployee> employees,
    DailyMarketOutcome outcome,
    List<String> resigned,
    int moraleProtection,
  ) {
    final updated = <CompanyEmployee>[];
    for (final employee in employees) {
      final morale = (employee.morale + _moraleDelta(outcome, moraleProtection))
          .clamp(0, 100)
          .toInt();
      final loyalty = (employee.loyalty + _loyaltyDelta(morale, outcome))
          .clamp(0, 100)
          .toInt();
      if (loyalty <= 15 && (outcome.day + employee.id * 7) % 3 == 0) {
        resigned.add(employee.name);
      } else {
        updated.add(employee.copyWith(morale: morale, loyalty: loyalty));
      }
    }
    return updated;
  }

  int _moraleDelta(DailyMarketOutcome outcome, int protection) {
    var delta = outcome.won ? 2 : -2;
    if (outcome.forecast.event.revenuePercent < 0) delta--;
    if (outcome.forecast.event.payrollPercent > 5) delta--;
    if (outcome.actualFundsDelta < 0) delta--;
    if (delta < 0) delta += protection;
    return delta.clamp(-4, 3).toInt();
  }

  int _loyaltyDelta(int morale, DailyMarketOutcome outcome) {
    if (morale <= 30) return -2;
    if (morale <= 45) return -1;
    if (morale >= 80 && outcome.won) return 1;
    return 0;
  }

  List<CompanyEmployee> _allEmployees(PlayerState state) => [
    ...CompanyService.employeesFor(state),
    for (final branch in state.branches) ...branch.employees,
  ];
}
