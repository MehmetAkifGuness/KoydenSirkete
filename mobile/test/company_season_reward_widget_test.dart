import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_reward.dart';
import 'package:kariyerden_sirkete/features/company/presentation/widgets/company_season_reward_panel.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  testWidgets('season reward panel exposes rank rewards and active rights', (
    tester,
  ) async {
    final state = PlayerState.initial.copyWith(
      companyLevel: 2,
      companyCompetition: const CompanyCompetitionState(
        seasonNumber: 2,
        seasonRewards: [
          CompanySeasonReward(
            seasonNumber: 1,
            rank: 2,
            type: CompanySeasonRewardType.sponsorship,
            value: 8,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanySeasonRewardPanel(state: state),
          ),
        ),
      ),
    );

    expect(find.text('Sponsor +%8 gelir'), findsOneWidget);
    expect(find.text('1. Şampiyonluk kupası'), findsOneWidget);
    expect(find.text('2. Gelir sponsorluğu'), findsOneWidget);
    expect(find.text('3. Özel proje daveti'), findsOneWidget);
    expect(find.text('4. Sektör itibarı'), findsOneWidget);
    expect(find.text('1. sezon · Gelir sponsorluğu'), findsOneWidget);
  });
}
