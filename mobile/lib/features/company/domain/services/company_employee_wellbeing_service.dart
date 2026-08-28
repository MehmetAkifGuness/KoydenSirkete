import '../../../game/domain/entities/player_state.dart';
import '../entities/company_employee.dart';
import '../entities/company_branch.dart';
import 'company_market_service.dart';
import 'company_service.dart';
import 'company_region_service.dart';

class EmployeeWellbeingSummary {
  const EmployeeWellbeingSummary({
    required this.averageMorale,
    required this.averageLoyalty,
    required this.atRiskCount,
    required this.burnoutRiskCount,
    required this.employeeCount,
  });

  final int averageMorale;
  final int averageLoyalty;
  final int atRiskCount;
  final int burnoutRiskCount;
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
        burnoutRiskCount: 0,
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
      burnoutRiskCount: employees.where((item) => item.burnout >= 80).length,
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
      final raiseRequests = <String>[];
      final burnoutWarnings = <String>[];
      final moraleProtection = _regionService.moraleProtection(current);
      final employees = _updateEmployees(
        CompanyService.employeesFor(current),
        outcome,
        resigned,
        raiseRequests,
        burnoutWarnings,
        moraleProtection,
      );
      final branches = [
        for (final branch in current.branches)
          _updateBranch(
            branch,
            outcome,
            resigned,
            raiseRequests,
            burnoutWarnings,
            moraleProtection,
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
      for (final request in raiseRequests) {
        messages.add(request);
      }
      for (final warning in burnoutWarnings) {
        messages.add(warning);
      }
    }
    return EmployeeWellbeingResult(state: current, messages: messages);
  }

  CompanyBranch _updateBranch(
    CompanyBranch branch,
    DailyMarketOutcome outcome,
    List<String> resigned,
    List<String> raiseRequests,
    List<String> burnoutWarnings,
    int moraleProtection,
  ) {
    final employees = _updateEmployees(
      branch.employees,
      outcome,
      resigned,
      raiseRequests,
      burnoutWarnings,
      moraleProtection,
    );
    final managerStillEmployed = employees.any(
      (employee) => employee.id == branch.managerEmployeeId,
    );
    return branch.copyWith(
      employees: employees,
      managerEmployeeId: managerStillEmployed
          ? branch.managerEmployeeId
          : null,
    );
  }

  List<CompanyEmployee> _updateEmployees(
    List<CompanyEmployee> employees,
    DailyMarketOutcome outcome,
    List<String> resigned,
    List<String> raiseRequests,
    List<String> burnoutWarnings,
    int moraleProtection,
  ) {
    final updated = <CompanyEmployee>[];
    for (final employee in employees) {
      final morale = (employee.morale + _moraleDelta(outcome, moraleProtection))
          .clamp(0, 100)
          .toInt();
      final loyalty =
          (employee.loyalty +
                  _loyaltyDelta(morale, outcome, employee.hasRaiseRequest))
              .clamp(0, 100)
              .toInt();
      final experience = employee.experience + (outcome.won ? 4 : 2);
      final burnout = (employee.burnout + _burnoutDelta(employee, outcome))
          .clamp(0, 100)
          .toInt();
      var requestedDailySalary = employee.requestedDailySalary;
      if (requestedDailySalary == null &&
          experience >= 60 &&
          (outcome.day + employee.id * 11) % 30 == 0) {
        requestedDailySalary =
            (employee.dailySalary * (110 + employee.seniority.index * 2) / 100)
                .ceil();
        raiseRequests.add(
          '${employee.name} günlük maaşının ₺$requestedDailySalary olmasını istedi.',
        );
      }
      if (employee.burnout < 80 && burnout >= 80) {
        burnoutWarnings.add(
          '${employee.name} yüksek tükenmişlik nedeniyle performans kaybediyor.',
        );
      }
      if (loyalty <= 15 && (outcome.day + employee.id * 7) % 3 == 0) {
        resigned.add(employee.name);
      } else {
        updated.add(
          employee.copyWith(
            morale: morale,
            loyalty: loyalty,
            experience: experience,
            burnout: burnout,
            requestedDailySalary: requestedDailySalary,
          ),
        );
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

  int _loyaltyDelta(
    int morale,
    DailyMarketOutcome outcome,
    bool hasRaiseRequest,
  ) {
    var delta = 0;
    if (morale <= 30) {
      delta = -2;
    } else if (morale <= 45) {
      delta = -1;
    } else if (morale >= 80 && outcome.won) {
      delta = 1;
    }
    return delta - (hasRaiseRequest ? 1 : 0);
  }

  int _burnoutDelta(CompanyEmployee employee, DailyMarketOutcome outcome) {
    var delta = outcome.won ? -1 : 2;
    if (outcome.forecast.event.revenuePercent < 0) delta++;
    if (outcome.forecast.event.payrollPercent > 5) delta++;
    if (outcome.actualFundsDelta < 0) delta++;
    if (employee.morale >= 80) delta--;
    return delta.clamp(-3, 5).toInt();
  }

  List<CompanyEmployee> _allEmployees(PlayerState state) => [
    ...CompanyService.employeesFor(state),
    for (final branch in state.branches) ...branch.employees,
  ];
}
