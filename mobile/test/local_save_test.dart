import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/database/player_state_store.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/player_state_mapper.dart';
import 'package:kariyerden_sirkete/features/game/data/repositories/local_player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/active_activity.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';

void main() {
  test('player state repository persists the latest state', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(database: store, mapper: PlayerStateMapper());
    final expected = PlayerState.initial.copyWith(
      money: 340,
      energy: 85,
      energyRecoveryAt: DateTime(2026, 1, 1, 12),
      day: 1,
      hour: 10,
      currentJobId: 1,
      performance: 55,
      careerLevel: 2,
      currentCityId: 2,
      companyLevel: 1,
      companyFunds: 300,
      employeeCount: 2,
      projectProgress: 40,
      negativeMoneyHours: 12,
      wheelCooldownSeconds: 160,
      wheelMajorRewardsToday: 2,
      wheelDurationBuffPercent: 50,
      wheelDurationBuffTasks: 2,
      wheelEnergyBuffPercent: 20,
      wheelEnergyBuffTasks: 1,
      wheelRewardBuffPercent: 100,
      wheelRewardBuffTasks: 2,
      themePaletteId: 7,
      isOnboarded: true,
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.money, expected.money);
    expect(actual?.energy, expected.energy);
    expect(actual?.energyRecoveryAt, expected.energyRecoveryAt);
    expect(actual?.hour, expected.hour);
    expect(actual?.currentJobId, expected.currentJobId);
    expect(actual?.performance, expected.performance);
    expect(actual?.careerLevel, expected.careerLevel);
    expect(actual?.currentCityId, expected.currentCityId);
    expect(actual?.companyLevel, expected.companyLevel);
    expect(actual?.companyFunds, expected.companyFunds);
    expect(actual?.employeeCount, expected.employeeCount);
    expect(actual?.projectProgress, expected.projectProgress);
    expect(actual?.negativeMoneyHours, expected.negativeMoneyHours);
    expect(actual?.wheelCooldownSeconds, expected.wheelCooldownSeconds);
    expect(actual?.wheelMajorRewardsToday, expected.wheelMajorRewardsToday);
    expect(actual?.wheelDurationBuffPercent, expected.wheelDurationBuffPercent);
    expect(actual?.wheelDurationBuffTasks, expected.wheelDurationBuffTasks);
    expect(actual?.wheelEnergyBuffPercent, expected.wheelEnergyBuffPercent);
    expect(actual?.wheelEnergyBuffTasks, expected.wheelEnergyBuffTasks);
    expect(actual?.wheelRewardBuffPercent, expected.wheelRewardBuffPercent);
    expect(actual?.wheelRewardBuffTasks, expected.wheelRewardBuffTasks);
    expect(actual?.themePaletteId, expected.themePaletteId);
    expect(actual?.isOnboarded, expected.isOnboarded);
  });

  test('player state repository persists concurrent activities', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(database: store, mapper: PlayerStateMapper());
    const earning = ActiveActivity(
      type: ActivityType.earning,
      sourceId: 'earning',
      remainingHours: 2,
      totalHours: 2,
      energyCost: 20,
      startedDay: 1,
      startedHour: 8,
    );
    const sport = ActiveActivity(
      type: ActivityType.sport,
      sourceId: 'sport',
      remainingHours: 1,
      totalHours: 1,
      energyCost: 20,
      startedDay: 1,
      startedHour: 8,
    );
    final expected = PlayerState.initial.copyWith(
      careerLevel: 2,
      activeActivities: const [earning, sport],
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.activeActivities, hasLength(2));
    expect(actual?.activities.map((activity) => activity.sourceId), ['earning', 'sport']);
  });

  test('player state repository persists selected company employees', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(database: store, mapper: PlayerStateMapper());
    const employee = CompanyEmployee(
      id: 3,
      name: 'Zeynep Yılmaz',
      role: 'Dijital uzmanı',
      performance: 86,
      dailySalary: 55,
    );
    final expected = PlayerState.initial.copyWith(
      companyLevel: 1,
      employeeCount: 1,
      employees: const [employee],
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.employees.single.id, employee.id);
    expect(actual?.employees.single.performance, employee.performance);
    expect(actual?.employees.single.dailySalary, employee.dailySalary);
  });

  test('player state repository persists branches and owned assets', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(database: store, mapper: PlayerStateMapper());
    const branch = CompanyBranch(id: 2, cityId: 2, level: 1);
    final expected = PlayerState.initial.copyWith(
      companyLevel: 1,
      branches: const [branch],
      ownedHomeIds: const [201, 202],
      ownedCarId: 2,
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.branches.single.cityId, 2);
    expect(actual?.ownedHomeIds, [201, 202]);
    expect(actual?.ownedCarId, 2);
  });
}

class _MemoryPlayerStateStore implements PlayerStateStore {
  PlayerStateRecord? _record;

  @override
  Future<PlayerStateRecord?> readPlayerState() async => _record;

  @override
  Future<void> savePlayerState(PlayerStateRecord record) async {
    _record = record;
  }

  @override
  Future<void> close() async {}
}
