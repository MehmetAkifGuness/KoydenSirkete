import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/entities/company_project_outcome.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_strategy_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/company_project_outcome_codec.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  final project = CompanyProjectCatalog.projects.first;
  final employees = CompanyEmployeeCatalog.candidates.take(2).toList();
  final state = PlayerState.initial.copyWith(
    day: 20,
    companyLevel: 1,
    companyFunds: 1000,
    employeeCount: employees.length,
    employees: employees,
    activeProjectId: project.id,
  );

  test('forecast exposes effective delay risk and expected quality', () {
    final forecast = CompanyProjectStrategyService().forecast(
      state: state,
      project: project,
      employees: employees,
    );

    expect(forecast.delayChance, inInclusiveRange(5, 90));
    expect(forecast.expectedQuality, isNot(CompanyProjectQuality.rejected));
  });

  test('completion resolves deterministic delivery, quality, and income', () {
    final service = CompanyProjectStrategyService();
    final first = service.resolveOutcome(
      state: state,
      project: project,
      employees: employees,
      succeeded: true,
      elapsedDays: project.deliveryDays + 1,
    );
    final repeated = service.resolveOutcome(
      state: state,
      project: project,
      employees: employees,
      succeeded: true,
      elapsedDays: project.deliveryDays + 1,
    );

    expect(first.delayed, isTrue);
    expect(first.quality, isNot(CompanyProjectQuality.rejected));
    expect(first.netIncome, repeated.netIncome);
    expect(first.quality, repeated.quality);

    final failed = service.resolveOutcome(
      state: state,
      project: project,
      employees: employees,
      succeeded: false,
      elapsedDays: 1,
    );
    expect(failed.quality, CompanyProjectQuality.rejected);
    expect(failed.netIncome, -project.cost);
  });

  test('project service tracks elapsed days and retains the last outcome', () {
    final service = CompanyService();
    final progressed = service.advanceProject(state);

    expect(progressed.state.projectElapsedDays, 1);
    expect(progressed.projectOutcome, isNull);

    final completed = service.advanceProject(
      progressed.state.copyWith(projectProgress: 99),
    );
    expect(completed.projectOutcome, isNotNull);
    expect(completed.state.projectElapsedDays, 0);
    expect(completed.state.lastProjectOutcome, completed.projectOutcome);
    expect(completed.message, contains('Kalite:'));
    expect(completed.message, contains('Teslimat:'));
  });

  test('outcome codec rejects malformed data and preserves valid results', () {
    final codec = CompanyProjectOutcomeCodec();
    const outcome = CompanyProjectOutcome(
      projectId: 3,
      completedDay: 18,
      elapsedDays: 12,
      delayed: false,
      succeeded: true,
      quality: CompanyProjectQuality.high,
      netIncome: 1250,
    );

    final decoded = codec.decode(codec.encode(outcome));
    expect(decoded?.projectId, outcome.projectId);
    expect(decoded?.quality, outcome.quality);
    expect(decoded?.netIncome, outcome.netIncome);
    expect(codec.decode('{"quality":"unknown"}'), isNull);
  });
}
