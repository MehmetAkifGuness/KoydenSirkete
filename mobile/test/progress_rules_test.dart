import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/daily_goals/domain/entities/daily_goal.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/progress/domain/services/achievement_service.dart';

void main() {
  test('v1.2 daily goal tracks actions and pays once', () {
    final service = DailyGoalService();
    final ready = PlayerState.initial.copyWith(
      earningSessionsToday: 1,
      workSessionsToday: 1,
      trainingSessionsToday: 1,
    );

    expect(service.status(ready).isComplete, isTrue);
    final claimed = service.claim(ready);

    expect(claimed.money, PlayerState.initial.money + DailyGoalService.reward);
    expect(service.status(claimed).isClaimed, isTrue);
    expect(() => service.claim(claimed), throwsException);
  });

  test('v1.3 achievements unlock once and award money', () {
    final service = AchievementService();
    final state = PlayerState.initial.copyWith(totalEarned: 100);

    final first = service.evaluate(state);
    final second = service.evaluate(first.state);

    expect(first.unlocked.map((achievement) => achievement.id), contains(1));
    expect(first.state.money, state.money + 50);
    expect(second.unlocked, isEmpty);
  });

  test('v1.4 upgrades company and unlocks project tier', () {
    final service = CompanyService();
    final company = service.establish(PlayerState.initial.copyWith(money: 1500, careerLevel: 3));
    final upgraded = service.upgrade(company.copyWith(companyFunds: CompanyService.upgradeCost(1)));
    final selected = service.selectProject(upgraded, CompanyProjectCatalog.projects[1]);

    expect(upgraded.companyLevel, 2);
    expect(CompanyService.employeeCapacity(upgraded.companyLevel), 4);
    expect(selected.activeProjectId, 2);
  });
}
