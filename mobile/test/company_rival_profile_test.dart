import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_competition_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_season_rule_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  test('four rivals have distinct complete strategic profiles', () {
    final competitors = CompanyMarketService.competitors;

    expect(competitors, hasLength(4));
    expect(competitors.map((item) => item.id).toSet(), hasLength(4));
    expect(competitors.map((item) => item.name).toSet(), hasLength(4));
    expect(competitors.map((item) => item.leaderName).toSet(), hasLength(4));
    expect(competitors.map((item) => item.specialty).toSet(), hasLength(4));
    for (final competitor in competitors) {
      expect(competitor.personality, isNotEmpty);
      expect(competitor.growthFocus, isNotEmpty);
      expect(competitor.branchIntervalDays, greaterThan(0));
      expect(competitor.hiringIntervalDays, greaterThan(0));
      expect(competitor.dailyFinanceGrowth, greaterThan(0));
      expect(competitor.dailyProjectProgress, greaterThan(0));
      expect(competitor.strengthDescription, isNotEmpty);
      expect(competitor.weaknessDescription, isNotEmpty);
      expect(competitor.strongEventId, isNot(competitor.weakEventId));
    }
  });

  test('every rival gains strength and suffers weakness in its event', () {
    for (final competitor in CompanyMarketService.competitors) {
      final strongEvent = CompanyMarketService.events.singleWhere(
        (event) => event.id == competitor.strongEventId,
      );
      final weakEvent = CompanyMarketService.events.singleWhere(
        (event) => event.id == competitor.weakEventId,
      );

      expect(
        CompanyMarketService.competitorProfileModifier(competitor, strongEvent),
        greaterThan(0),
      );
      expect(
        CompanyMarketService.competitorProfileModifier(competitor, weakEvent),
        lessThan(0),
      );
    }
  });

  test('daily forecast includes the active rival profile modifier', () {
    final service = CompanyMarketService();
    final state = PlayerState.initial.copyWith(companyLevel: 1);

    for (var day = 1; day <= 42; day++) {
      final forecast = service.forecast(state, day: day);
      final variation = (day * 13 + forecast.competitor.baseStrength * 7) % 11;
      final seasonRuleModifier = const CompanySeasonRuleService()
          .competitorStrengthModifier(forecast.competitor, forecast.seasonRule);
      final expected =
          (forecast.competitor.baseStrength +
                  variation +
                  forecast.competitorProfileModifier +
                  seasonRuleModifier)
              .clamp(0, 100)
              .toInt();

      expect(forecast.competitorScore, expected, reason: 'Gün $day');
      expect(forecast.competitorProfileReason, isNotEmpty);
    }
  });

  test('season standings include daily rival profile effects', () {
    const season = 1;
    final throughDay = CompanyCompetitionState.endDay(season);
    final state = PlayerState.initial.copyWith(
      day: throughDay,
      companyLevel: 3,
      companyCompetition: const CompanyCompetitionState(seasonNumber: season),
    );
    final service = CompanyCompetitionService();
    final standings = service.standings(state);

    for (final competitor in CompanyMarketService.competitors) {
      final standing = standings.singleWhere(
        (entry) => entry.name == competitor.name,
      );
      expect(
        standing.points,
        _expectedRivalPoints(service, competitor, season, throughDay),
      );
    }
  });
}

int _expectedRivalPoints(
  CompanyCompetitionService service,
  CompanyCompetitor competitor,
  int season,
  int throughDay,
) {
  var points = 0;
  final seasonRuleService = const CompanySeasonRuleService();
  final seasonRule = seasonRuleService.ruleForSeason(season);
  final seasonRuleModifier = seasonRuleService.competitorStrengthModifier(
    competitor,
    seasonRule,
  );
  for (
    var day = CompanyCompetitionState.startDay(season);
    day <= throughDay;
    day++
  ) {
    final modifier = CompanyMarketService.competitorProfileModifier(
      competitor,
      CompanyMarketService.eventForDay(day),
    );
    final strength = service.rivalStrength(competitor, season, day);
    final winChance = (30 + strength + modifier + seasonRuleModifier)
        .clamp(40, 90)
        .toInt();
    final roll = (day * 17 + competitor.baseStrength * 13 + season * 19) % 100;
    points += roll < winChance
        ? 3
        : roll < winChance + 8
        ? 1
        : 0;
  }
  return points;
}
