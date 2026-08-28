import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/app/theme/app_theme.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_result.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_reward.dart';
import 'package:kariyerden_sirkete/features/company/presentation/widgets/company_competition_panel.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  testWidgets('competition panel opens persisted season history', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = PlayerState.initial.copyWith(
      day: 33,
      companyLevel: 3,
      companyCompetition: const CompanyCompetitionState(
        seasonNumber: 2,
        lastRank: 2,
        lastReward: 3000,
        seasonHistory: [
          CompanySeasonResult(
            seasonNumber: 1,
            rank: 2,
            points: 78,
            wins: 26,
            losses: 4,
            cashReward: 3000,
            reward: CompanySeasonReward(
              seasonNumber: 1,
              rank: 2,
              type: CompanySeasonRewardType.sponsorship,
              value: 8,
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyCompetitionPanel(state: state),
          ),
        ),
      ),
    );
    final action = find.byKey(const ValueKey('open-season-history'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(find.text('Sezon geçmişi'), findsOneWidget);
    expect(find.byKey(const ValueKey('season-history-1')), findsOneWidget);
    expect(find.text('78 puan'), findsOneWidget);
    expect(find.text('26G · 4M'), findsOneWidget);
    expect(find.text('Nakit +₺3000'), findsOneWidget);
    expect(find.text('Gelir sponsorluğu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
