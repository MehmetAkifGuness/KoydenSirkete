import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_season_rule_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const ruleService = CompanySeasonRuleService();

  test('four distinct season rules expose bounded economic effects', () {
    final rules = CompanySeasonRuleService.rules;

    expect(rules, hasLength(4));
    expect(rules.map((rule) => rule.id).toSet(), hasLength(4));
    expect(rules.map((rule) => rule.title).toSet(), hasLength(4));
    expect(rules.map((rule) => rule.favoredSpecialty).toSet(), hasLength(4));
    for (final rule in rules) {
      expect(rule.description, isNotEmpty);
      expect(rule.revenuePercent, inInclusiveRange(0, 10));
      expect(rule.payrollPercent, inInclusiveRange(0, 10));
      expect(rule.specialtyStrengthBonus, 5);
    }
  });

  test('one rule stays active for thirty days and rotates by season', () {
    for (var season = 1; season <= 4; season++) {
      final expected = ruleService.ruleForSeason(season);

      expect(
        ruleService.ruleForDay(CompanyCompetitionState.startDay(season)),
        same(expected),
      );
      expect(
        ruleService.ruleForDay(CompanyCompetitionState.endDay(season)),
        same(expected),
      );
    }

    expect(ruleService.ruleForSeason(5), same(ruleService.ruleForSeason(1)));
  });

  test('market funds apply daily and season percentages together', () {
    final state = _stateWithRole('Operasyon uzmanı');
    final service = CompanyMarketService();
    final forecast = service.forecast(state, day: 7);
    final revenue = CompanyService().dailyRevenue(state);
    final payroll = CompanyService().dailyPayroll(state);
    final economicDelta =
        revenue * forecast.totalRevenuePercent ~/ 100 -
        payroll * forecast.totalPayrollPercent ~/ 100;
    final stake = 20;
    final competitionDelta = forecast.won ? stake : -(stake ~/ 2);

    expect(forecast.seasonRule.title, 'Talep patlaması');
    expect(forecast.totalRevenuePercent, 10);
    expect(forecast.totalPayrollPercent, 2);
    expect(forecast.fundsDelta, economicDelta + competitionDelta);
  });

  test('favored specialists receive the same visible strength rule', () {
    final service = CompanyMarketService();
    final sales = service.forecast(_stateWithRole('Satış uzmanı'), day: 7);
    final operations = service.forecast(
      _stateWithRole('Operasyon uzmanı'),
      day: 7,
    );

    expect(sales.playerSeasonRuleModifier, 5);
    expect(operations.playerSeasonRuleModifier, 0);
    expect(sales.playerScore, operations.playerScore + 5);
    expect(sales.competitor.name, 'Atlas Global');
    expect(sales.competitorSeasonRuleModifier, 5);
  });
}

PlayerState _stateWithRole(String role) => PlayerState.initial.copyWith(
  day: 7,
  companyLevel: 1,
  companyFunds: 10000,
  employeeCount: 1,
  employees: [
    CompanyEmployee(
      id: 999,
      name: 'Test Çalışanı',
      role: role,
      performance: 70,
      dailySalary: 40,
    ),
  ],
);
