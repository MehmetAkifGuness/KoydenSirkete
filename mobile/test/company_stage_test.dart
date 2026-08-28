import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_stage.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_stage_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/application/game_session_application_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/repositories/player_state_repository.dart';

void main() {
  test('new companies start as a local enterprise', () {
    final state = PlayerState.initial.copyWith(companyLevel: 1);
    final service = CompanyStageService();

    expect(service.current(state), CompanyStage.localEnterprise);
    expect(service.roadmap(state), hasLength(4));
    expect(service.roadmap(state)[1].isUnlocked, isFalse);
  });

  test('regional stage requires every business and season metric', () {
    final service = CompanyStageService();
    final missingRank = _regionalState(
      competition: const CompanyCompetitionState(),
    );
    final eligible = _regionalState(
      competition: const CompanyCompetitionState(bestRank: 3, lastRank: 3),
    );

    expect(service.evaluate(missingRank).companyStageIndex, 0);
    expect(service.evaluate(eligible).companyStageIndex, 1);
  });

  test('national and holding stages unlock sequentially', () {
    final service = CompanyStageService();

    expect(service.evaluate(_nationalState()).companyStageIndex, 2);
    expect(service.evaluate(_holdingState()).companyStageIndex, 3);
  });

  test('an unlocked company stage never regresses', () {
    final service = CompanyStageService();
    final regional = service.evaluate(
      _regionalState(
        competition: const CompanyCompetitionState(bestRank: 2, lastRank: 2),
      ),
    );
    final weakened = regional.copyWith(
      employees: const <CompanyEmployee>[],
      employeeCount: 0,
      branches: const <CompanyBranch>[],
      companyFunds: 0,
    );

    expect(service.evaluate(weakened).companyStageIndex, 1);
  });

  test('mature legacy companies are evaluated when loaded', () async {
    final repository = _MemoryRepository(_nationalState());
    final loaded = await GameSessionApplicationService(
      repository: repository,
    ).load();

    expect(loaded.companyStageIndex, 2);
    expect(repository.state?.companyStageIndex, 2);
  });
}

PlayerState _regionalState({required CompanyCompetitionState competition}) =>
    PlayerState.initial.copyWith(
      companyLevel: 2,
      companyFunds: 100000,
      completedProjects: 10,
      employeeCount: 6,
      employees: _employees(6, performance: 65),
      branches: _branches(2),
      companyCompetition: competition,
    );

PlayerState _nationalState() => PlayerState.initial.copyWith(
  companyLevel: 3,
  companyFunds: 100000,
  completedProjects: 20,
  employeeCount: 15,
  employees: _employees(15, performance: 75),
  branches: _branches(5),
  companyCompetition: const CompanyCompetitionState(
    bestRank: 1,
    lastRank: 1,
    championships: 1,
  ),
);

PlayerState _holdingState() => PlayerState.initial.copyWith(
  companyLevel: 3,
  companyFunds: 700000,
  completedProjects: 35,
  employeeCount: 25,
  employees: _employees(25, performance: 85),
  branches: _branches(10),
  companyCompetition: const CompanyCompetitionState(
    bestRank: 1,
    lastRank: 1,
    championships: 3,
  ),
);

List<CompanyEmployee> _employees(int count, {required int performance}) => [
  for (var index = 0; index < count; index++)
    CompanyEmployee(
      id: index + 1,
      name: 'Çalışan ${index + 1}',
      role: 'Uzman',
      performance: performance,
      dailySalary: 50,
    ),
];

List<CompanyBranch> _branches(int count) => [
  for (var index = 0; index < count; index++)
    CompanyBranch(id: index + 1, cityId: index + 1),
];

class _MemoryRepository implements PlayerStateRepository {
  _MemoryRepository(this.state);

  PlayerState? state;

  @override
  Future<PlayerState?> load() async => state;

  @override
  Future<void> save(PlayerState value) async => state = value;
}
