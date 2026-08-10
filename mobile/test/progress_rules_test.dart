import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/daily_goals/domain/entities/daily_goal.dart';
import 'package:kariyerden_sirkete/features/game/application/game_session_application_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/debug_state_patch.dart';
import 'package:kariyerden_sirkete/features/employment/domain/entities/employment.dart';
import 'package:kariyerden_sirkete/features/skills/domain/entities/skill_id.dart';
import 'package:kariyerden_sirkete/features/game/domain/repositories/player_state_repository.dart';
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
    expect(CompanyService.employeeCapacity(upgraded.companyLevel), 8);
    expect(selected.activeProjectId, 2);
  });

  test('company offers a broad candidate pool and supports employee dismissal', () {
    final service = CompanyService();
    final company = service.establish(PlayerState.initial.copyWith(money: 1500, careerLevel: 3));
    final candidates = service.availableEmployees(company);
    final employee = candidates.first;
    final hired = service.recruit(company, employee: employee);
    final dismissed = service.dismissEmployee(hired, employee.id);

    expect(CompanyEmployeeCatalog.candidates, hasLength(24));
    expect(candidates.length, greaterThan(8));
    expect(hired.employees.single.id, employee.id);
    expect(service.dailyPayroll(hired), employee.dailySalary);
    expect(dismissed.employees, isEmpty);
    expect(dismissed.employeeCount, 0);
    expect(service.dailyPayroll(dismissed), 0);
  });

  test('company earns daily revenue and keeps project rewards in its funds', () async {
    final service = CompanyService();
    final company = service.establish(PlayerState.initial.copyWith(money: 1500, careerLevel: 3)).copyWith(employeeCount: 1);
    final repository = _MemoryRepository(company.copyWith(hour: 23));
    final application = GameSessionApplicationService(repository: repository);
    final tick = await application.tick(company.copyWith(hour: 23));

    expect(tick.state.day, 2);
    expect(
      tick.state.companyFunds,
      company.companyFunds + service.dailyRevenue(company) - service.dailyPayroll(company),
    );
    expect(tick.state.projectProgress, service.dailyProjectProgress(company));

    final completed = service.advanceProject(tick.state.copyWith(projectProgress: 95));
    expect(completed.state.companyFunds, tick.state.companyFunds + 500 - 100);
    expect(completed.state.money, tick.state.money);
  });

  test('load repairs a stale current job id from the employment snapshot', () async {
    final stored = PlayerState.initial.copyWith(
      currentJobId: 1,
      employment: const Employment(jobId: 2, cityId: 1, salary: 220, company: 'Bereket Market', startedDay: 1),
    );
    final repository = _MemoryRepository(stored);
    final loaded = await GameSessionApplicationService(repository: repository).load();

    expect(loaded.currentJobId, 2);
    expect(loaded.employment?.jobId, 2);
    expect(loaded.careerLevel, 2);
  });

  test('debug patch updates bounded player data and persists it', () async {
    final repository = _MemoryRepository(PlayerState.initial);
    final application = GameSessionApplicationService(repository: repository);
    final updated = await application.updateDebugState(
      PlayerState.initial,
      const DebugStatePatch(money: 500, energy: 1200, maxEnergy: 1200, day: 0, hour: 99, careerLevel: 99, performance: -5, skills: {SkillId.operations: 1200}),
    );

    expect(updated.money, 500);
    expect(updated.maxEnergy, 1000);
    expect(updated.energy, 1000);
    expect(updated.day, 1);
    expect(updated.hour, 23);
    expect(updated.careerLevel, 20);
    expect(updated.performance, 0);
    expect(updated.skills[SkillId.operations], 1000);
    expect((await repository.load())?.money, 500);
  });
}

class _MemoryRepository implements PlayerStateRepository {
  _MemoryRepository(this.state);

  PlayerState? state;

  @override
  Future<PlayerState?> load() async => state;

  @override
  Future<void> save(PlayerState value) async => state = value;
}
