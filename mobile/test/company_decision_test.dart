import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_decision_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_growth_service.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/company_competition_codec.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const service = CompanyDecisionService();
  final employee = CompanyEmployeeCatalog.candidates.first.copyWith(
    morale: 60,
    burnout: 20,
  );

  PlayerState readyState({int day = 2}) => PlayerState.initial.copyWith(
    day: day,
    companyLevel: 2,
    companyFunds: 1000,
    employeeCount: 1,
    employees: [employee],
    companyCompetition: CompanyCompetitionState.forDay(day),
  );

  test('each market period accepts one meaningful company decision', () {
    final state = readyState();
    final choice = CompanyDecisionService.choices.first;
    final result = service.resolve(state, choice);

    expect(result.money, state.money);
    expect(result.companyFunds, 760);
    expect(result.projectProgress, 8);
    expect(result.employees.single.morale, 57);
    expect(result.employees.single.burnout, 24);
    expect(result.companyCompetition.decisionReputation, 2);
    expect(
      CompanyGrowthService().reputation(result),
      2 + CompanyGrowthService().reputation(state),
    );
    expect(
      result.financeLedger.entries
          .singleWhere(
            (entry) => entry.category == FinanceCategory.companyMarket,
          )
          .amount,
      -240,
    );
    expect(
      () => service.resolve(result, choice),
      throwsA(isA<GameRuleException>()),
    );
    expect(service.isResolved(result.copyWith(day: 9)), isFalse);
  });

  test('unaffordable choices are rejected without changing state', () {
    final state = readyState().copyWith(companyFunds: 10);
    expect(
      () => service.resolve(state, CompanyDecisionService.choices.first),
      throwsA(isA<GameRuleException>()),
    );
    expect(state.companyFunds, 10);
  });

  test('decision history and reputation survive competition JSON', () {
    final resolved = service.resolve(
      readyState(),
      CompanyDecisionService.choices[1],
    );
    final codec = CompanyCompetitionCodec();
    final decoded = codec.decode(
      codec.encode(resolved.companyCompetition),
      day: resolved.day,
    );

    expect(
      decoded.resolvedDecisionKeys,
      resolved.companyCompetition.resolvedDecisionKeys,
    );
    expect(decoded.lastDecisionChoiceId, 'people');
    expect(decoded.decisionReputation, 1);
  });
}
