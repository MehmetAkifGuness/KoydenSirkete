import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/database/player_state_store.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/player_state_mapper.dart';
import 'package:kariyerden_sirkete/features/game/data/repositories/local_player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  test('player state repository persists the latest state', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(database: store, mapper: PlayerStateMapper());
    final expected = PlayerState.initial.copyWith(
      money: 340,
      energy: 85,
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
      isOnboarded: true,
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.money, expected.money);
    expect(actual?.energy, expected.energy);
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
    expect(actual?.isOnboarded, expected.isOnboarded);
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
