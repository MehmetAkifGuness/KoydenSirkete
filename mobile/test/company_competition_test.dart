import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_trophy.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_reward.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_competition_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/company_competition_codec.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  test('market results award three points for each win', () {
    final result = CompanyCompetitionService().process(_companyState(day: 3), [
      _outcome(2, won: true),
      _outcome(3, won: false),
    ]);

    expect(result.state.companyCompetition.points, 3);
    expect(result.state.companyCompetition.wins, 1);
    expect(result.state.companyCompetition.losses, 1);
  });

  test('season settlement deposits a company reward only once', () {
    final service = CompanyCompetitionService();
    final state = _companyState(day: 32).copyWith(
      companyFunds: 1000,
      companyCompetition: const CompanyCompetitionState(points: 100, wins: 30),
    );

    final settled = service.process(state, const []);
    final repeated = service.process(settled.state, const []);

    expect(settled.state.companyCompetition.seasonNumber, 2);
    expect(settled.state.companyCompetition.lastRank, 1);
    expect(settled.state.companyCompetition.bestRank, 1);
    expect(settled.state.companyCompetition.championships, 1);
    expect(settled.state.companyCompetition.trophies, hasLength(1));
    expect(settled.state.companyCompetition.trophies.single.seasonNumber, 1);
    expect(settled.state.companyCompetition.trophies.single.points, 100);
    expect(
      settled.state.companyCompetition.seasonRewards.single.type,
      CompanySeasonRewardType.trophy,
    );
    expect(settled.state.companyFunds, 7000);
    expect(settled.messages.single, contains('Proje güvencesi'));
    expect(repeated.state.companyFunds, 7000);
    expect(repeated.state.companyCompetition.trophies, hasLength(1));
    expect(
      settled.state.financeLedger.entries.single.category,
      FinanceCategory.companySeason,
    );
    expect(
      settled.state.financeLedger.entries.single.account,
      FinanceAccount.company,
    );
  });

  test('rival standings are deterministic and become harder by season', () {
    final service = CompanyCompetitionService();
    final first = service.standings(_companyState(day: 20));
    final second = service.standings(
      _companyState(day: 50).copyWith(
        companyCompetition: const CompanyCompetitionState(seasonNumber: 2),
      ),
    );

    expect(first, hasLength(5));
    expect(first.map((entry) => entry.rank), [1, 2, 3, 4, 5]);
    for (final rival in first.where((entry) => !entry.isPlayer)) {
      final later = second.singleWhere((entry) => entry.name == rival.name);
      expect(later.strength, greaterThan(rival.strength));
    }
  });

  test('legacy saves start in the current calendar season', () {
    final competition = CompanyCompetitionCodec().decode(null, day: 75);

    expect(competition.seasonNumber, 3);
    expect(competition.points, 0);
  });

  test('legacy season data uses the last rank as the best rank', () {
    final competition = CompanyCompetitionCodec().decode(
      '{"seasonNumber":2,"lastRank":3}',
      day: 32,
    );

    expect(competition.bestRank, 3);
  });

  test('competition codec persists trophies and imports legacy counts', () {
    final codec = CompanyCompetitionCodec();
    const expected = CompanyCompetitionState(
      championships: 1,
      strategyId: 'quality_advantage',
      trophies: [
        CompanySeasonTrophy(seasonNumber: 2, points: 84, reward: 6000),
      ],
      seasonRewards: [
        CompanySeasonReward(
          seasonNumber: 2,
          rank: 3,
          type: CompanySeasonRewardType.projectInvitation,
          value: 1,
          consumed: true,
        ),
      ],
    );
    final actual = codec.decode(codec.encode(expected), day: 62);
    final legacy = codec.decode('{"championships":2}', day: 62);

    expect(actual.trophies.single.seasonNumber, 2);
    expect(actual.trophies.single.points, 84);
    expect(actual.trophies.single.reward, 6000);
    expect(actual.strategyId, 'quality_advantage');
    expect(
      actual.seasonRewards.single.type,
      CompanySeasonRewardType.projectInvitation,
    );
    expect(actual.seasonRewards.single.consumed, isTrue);
    expect(legacy.championships, 2);
    expect(legacy.strategyId, isEmpty);
    expect(legacy.seasonRewards, isEmpty);
    expect(legacy.trophies, hasLength(2));
    expect(legacy.trophies.every((trophy) => trophy.isImported), isTrue);

    final invalid = codec.decode('{"strategyId":"unknown"}', day: 2);
    expect(invalid.strategyId, isEmpty);
    final invalidReward = codec.decode(
      '{"seasonRewards":[{"seasonNumber":1,"rank":2,"type":"cash","value":999}]}',
      day: 2,
    );
    expect(invalidReward.seasonRewards, isEmpty);
  });
}

PlayerState _companyState({required int day}) => PlayerState.initial.copyWith(
  day: day,
  companyLevel: 3,
  companyFunds: 10000,
);

DailyMarketOutcome _outcome(int day, {required bool won}) => DailyMarketOutcome(
  day: day,
  forecast: CompanyMarketForecast(
    event: CompanyMarketService.events.first,
    competitor: CompanyMarketService.competitors.first,
    playerScore: won ? 60 : 40,
    competitorScore: 50,
    fundsDelta: 0,
    activeEmployeeCount: 1,
    daysRemaining: 1,
  ),
  actualFundsDelta: 0,
);
