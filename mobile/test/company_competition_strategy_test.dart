import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_strategy.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_competition_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_competition_strategy_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const service = CompanyCompetitionStrategyService();

  test(
    'four strategies counter every rival specialty with bounded tradeoffs',
    () {
      final strategies = CompanyCompetitionStrategyService.strategies;
      final rivalSpecialties = CompanyMarketService.competitors
          .map((competitor) => competitor.specialty)
          .toSet();

      expect(strategies, hasLength(4));
      expect(strategies.map((strategy) => strategy.id).toSet(), hasLength(4));
      expect(
        strategies.map((strategy) => strategy.counteredSpecialty).toSet(),
        rivalSpecialties,
      );
      for (final strategy in strategies) {
        expect(strategy.description, isNotEmpty);
        expect(strategy.baseStrengthBonus, inInclusiveRange(2, 3));
        expect(strategy.counterStrengthBonus, 4);
        expect(strategy.revenuePercent, inInclusiveRange(-8, -2));
        expect(strategy.payrollPercent, inInclusiveRange(0, 4));
      }
    },
  );

  test(
    'strategy selection is valid once per season and resets next season',
    () {
      final strategy = CompanyCompetitionStrategyService.strategies.first;
      final selected = service.select(_preparedState(), strategy);

      expect(selected.companyCompetition.strategyId, strategy.id);
      expect(
        () => service.select(selected, strategy),
        throwsA(isA<GameRuleException>()),
      );

      final settled = CompanyCompetitionService().process(
        selected.copyWith(
          day: CompanyCompetitionState.startDay(2),
          companyCompetition: selected.companyCompetition.copyWith(points: 100),
        ),
        const [],
      );
      expect(settled.state.companyCompetition.seasonNumber, 2);
      expect(settled.state.companyCompetition.strategyId, isEmpty);
    },
  );

  test('strategy rejects unavailable companies and unknown definitions', () {
    final strategy = CompanyCompetitionStrategyService.strategies.first;
    final unknown = CompanyCompetitionStrategy(
      id: 'unknown',
      title: 'Bilinmeyen',
      description: 'Geçersiz',
      counteredSpecialty: strategy.counteredSpecialty,
      baseStrengthBonus: 2,
      counterStrengthBonus: 4,
      revenuePercent: -2,
      payrollPercent: 0,
    );

    expect(
      () => service.select(PlayerState.initial, strategy),
      throwsA(isA<GameRuleException>()),
    );
    expect(
      () => service.select(_preparedState(), unknown),
      throwsA(isA<GameRuleException>()),
    );
  });

  test('prepared strategy gains extra strength against its target rival', () {
    final state = _preparedState();

    for (final strategy in CompanyCompetitionStrategyService.strategies) {
      final target = CompanyMarketService.competitors.singleWhere(
        (competitor) => competitor.specialty == strategy.counteredSpecialty,
      );
      final other = CompanyMarketService.competitors.firstWhere(
        (competitor) => competitor.specialty != strategy.counteredSpecialty,
      );
      final targetEffect = service.effectFor(state, strategy, target);
      final otherEffect = service.effectFor(state, strategy, other);

      expect(
        targetEffect.strengthModifier - otherEffect.strengthModifier,
        strategy.counterStrengthBonus,
      );
      expect(targetEffect.strengthModifier, inInclusiveRange(6, 10));
      expect(targetEffect.reason, contains('rakibe karşı'));
    }
  });

  test(
    'selected strategy changes market strength and economic percentages',
    () {
      final strategy = CompanyCompetitionStrategyService.strategies[1];
      final base = _preparedState().copyWith(day: 7);
      final selected = base.copyWith(
        companyCompetition: base.companyCompetition.copyWith(
          strategyId: strategy.id,
        ),
      );
      final service = CompanyMarketService();
      final baseForecast = service.forecast(base);
      final strategyForecast = service.forecast(selected);

      expect(strategyForecast.competitor.name, 'Atlas Global');
      expect(strategyForecast.strategy.title, 'Fiyat liderliği');
      expect(strategyForecast.strategyStrengthModifier, 8);
      expect(
        strategyForecast.playerScore,
        baseForecast.playerScore + strategyForecast.strategyStrengthModifier,
      );
      expect(
        strategyForecast.totalRevenuePercent,
        baseForecast.totalRevenuePercent + strategy.revenuePercent,
      );
      expect(
        strategyForecast.totalPayrollPercent,
        baseForecast.totalPayrollPercent + strategy.payrollPercent,
      );
    },
  );
}

PlayerState _preparedState() => PlayerState.initial.copyWith(
  companyLevel: 3,
  companyFunds: 10000,
  employeeCount: 1,
  projectProgress: 68,
  completedProjects: 1,
  employees: const [
    CompanyEmployee(
      id: 999,
      name: 'Test Çalışanı',
      role: 'Kalite uzmanı',
      performance: 90,
      dailySalary: 50,
      morale: 90,
    ),
  ],
  branches: const [
    CompanyBranch(id: 1, cityId: 1),
    CompanyBranch(id: 2, cityId: 2),
  ],
);
