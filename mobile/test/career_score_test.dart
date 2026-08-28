import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_expansion_state.dart';
import 'package:kariyerden_sirkete/features/progress/domain/services/career_score_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  final service = CareerScoreService();

  test('career score combines four transparent progression categories', () {
    final summary = service.summarize(PlayerState.initial);

    expect(summary.categories, hasLength(4));
    expect(summary.categories.map((item) => item.title), [
      'Kişisel kariyer',
      'Şirket gücü',
      'Stratejik miras',
      'Varlıklar',
    ]);
    expect(
      summary.totalScore,
      summary.categories.fold(0, (total, item) => total + item.score),
    );
    expect(summary.title, 'Yeni başlangıç');
    expect(summary.nextTarget, 800);
  });

  test('work, training, projects, trophies and deals grow the score', () {
    final base = PlayerState.initial.copyWith(companyLevel: 3);
    final advanced = base.copyWith(
      day: 100,
      careerLevel: 3,
      experience: 10000,
      totalEarned: 500000,
      totalWorkSessions: 50,
      totalTrainingSessions: 30,
      companyStageIndex: 2,
      completedProjects: 20,
      companyCompetition: const CompanyCompetitionState(championships: 3),
      companyExpansion: const CompanyExpansionState(
        completedDealIds: ['rota_logistics', 'mavi_software'],
      ),
      ownedHomeIds: const [1],
      rentedHomeIds: const [1],
      ownedCarId: 1,
    );

    expect(
      service.summarize(advanced).totalScore,
      greaterThan(service.summarize(base).totalScore),
    );
  });

  test('prestige targets continue indefinitely after the final named rank', () {
    final first = service.summarize(
      PlayerState.initial.copyWith(totalWorkSessions: 2000),
    );
    final later = service.summarize(
      PlayerState.initial.copyWith(totalWorkSessions: 3000),
    );

    expect(
      first.totalScore,
      greaterThanOrEqualTo(CareerScoreService.prestigeStart),
    );
    expect(first.nextTarget, greaterThan(first.totalScore));
    expect(first.title, contains('Prestij'));
    expect(later.prestigeLevel, greaterThan(first.prestigeLevel));
    expect(later.nextTarget, greaterThan(later.totalScore));
  });

  test(
    'repeatable goals roll into a new cycle instead of completing forever',
    () {
      final almost = service.summarize(
        PlayerState.initial.copyWith(totalWorkSessions: 4),
      );
      final nextCycle = service.summarize(
        PlayerState.initial.copyWith(totalWorkSessions: 5),
      );
      final almostGoal = almost.goals.first;
      final nextGoal = nextCycle.goals.first;

      expect(almostGoal.current, 4);
      expect(almostGoal.target, 5);
      expect(nextGoal.current, 0);
      expect(nextGoal.target, 5);
      expect(nextGoal.scoreReward, 75);
    },
  );

  test('every completed work session keeps adding score', () {
    final hundred = service.summarize(
      PlayerState.initial.copyWith(totalWorkSessions: 100),
    );
    final hundredOne = service.summarize(
      PlayerState.initial.copyWith(totalWorkSessions: 101),
    );

    expect(hundredOne.totalScore - hundred.totalScore, 15);
  });
}
