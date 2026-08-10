import 'dart:math';

import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/esnaf_wheel_reward.dart';

class WheelAvailability {
  const WheelAvailability({required this.isAvailable, required this.reason});

  final bool isAvailable;
  final String reason;
}

class WheelSpinOutcome {
  const WheelSpinOutcome({required this.state, required this.reward, required this.sectorIndex});

  final PlayerState state;
  final EsnafWheelReward reward;
  final int sectorIndex;

  String get message => '${reward.title}: ${reward.description}';
}

class EsnafWheelService {
  EsnafWheelService({Random? random}) : _random = random ?? Random();

  static const spinCost = 50;
  static const dailyMajorRewardLimit = 3;
  static const buffTaskCount = 2;

  final Random _random;

  WheelAvailability availability(PlayerState state) {
    if (state.money < spinCost) {
      return const WheelAvailability(isAvailable: false, reason: 'Çarkı çevirmek için 50 TL gerekir.');
    }
    return const WheelAvailability(isAvailable: true, reason: 'Çark çevirmeye hazırsın.');
  }

  WheelSpinOutcome spin(PlayerState state) {
    final availability = this.availability(state);
    if (!availability.isAvailable) {
      throw GameRuleException(availability.reason);
    }

    final drawn = _drawReward();
    var reward = drawn.reward;
    var sectorIndex = drawn.index;
    if (reward.isMajor && state.wheelMajorRewardsToday >= dailyMajorRewardLimit) {
      reward = EsnafWheelRewardCatalog.byType(EsnafWheelRewardType.tipRain);
      final tipSectors = [
        for (var index = 0; index < EsnafWheelRewardCatalog.sectorTypes.length; index++)
          if (EsnafWheelRewardCatalog.sectorTypes[index] == EsnafWheelRewardType.tipRain) index,
      ];
      sectorIndex = tipSectors[_random.nextInt(tipSectors.length)];
    }
    var nextState = state.copyWith(
      money: state.money - spinCost,
      wheelCooldownSeconds: 0,
      wheelMajorRewardsToday: state.wheelMajorRewardsToday + (reward.isMajor ? 1 : 0),
    );
    nextState = _applyReward(nextState, reward.type);
    return WheelSpinOutcome(state: nextState, reward: reward, sectorIndex: sectorIndex);
  }

  PlayerState consumeWorkBuffs(PlayerState state) {
    return state.copyWith(
      wheelDurationBuffTasks: _remainingTasks(state.wheelDurationBuffTasks),
      wheelDurationBuffPercent: state.wheelDurationBuffTasks <= 1 ? 0 : state.wheelDurationBuffPercent,
      wheelEnergyBuffTasks: _remainingTasks(state.wheelEnergyBuffTasks),
      wheelEnergyBuffPercent: state.wheelEnergyBuffTasks <= 1 ? 0 : state.wheelEnergyBuffPercent,
    );
  }

  _DrawnReward _drawReward() {
    final index = _random.nextInt(EsnafWheelRewardCatalog.sectorTypes.length);
    return _DrawnReward(index: index, reward: EsnafWheelRewardCatalog.byType(EsnafWheelRewardCatalog.sectorTypes[index]));
  }

  PlayerState _applyReward(PlayerState state, EsnafWheelRewardType type) {
    return switch (type) {
      EsnafWheelRewardType.luckyDay => state.copyWith(
          wheelDurationBuffPercent: max(state.wheelDurationBuffPercent, 50),
          wheelDurationBuffTasks: max(state.wheelDurationBuffTasks, buffTaskCount),
          wheelEnergyBuffPercent: max(state.wheelEnergyBuffPercent, 50),
          wheelEnergyBuffTasks: max(state.wheelEnergyBuffTasks, buffTaskCount),
          wheelRewardBuffPercent: max(state.wheelRewardBuffPercent, 100),
          wheelRewardBuffTasks: max(state.wheelRewardBuffTasks, buffTaskCount),
        ),
      EsnafWheelRewardType.esnafBlessing => state.copyWith(money: state.money + 100),
      EsnafWheelRewardType.customerPenalty => state.copyWith(money: state.money - 50),
      EsnafWheelRewardType.supplierDiscount => state.copyWith(
          wheelEnergyBuffPercent: max(state.wheelEnergyBuffPercent, 20),
          wheelEnergyBuffTasks: max(state.wheelEnergyBuffTasks, buffTaskCount),
        ),
      EsnafWheelRewardType.empty || EsnafWheelRewardType.staleDoner => state,
      EsnafWheelRewardType.apprenticeMistake => _addWorkHour(state),
      EsnafWheelRewardType.fastService => state.copyWith(
          wheelDurationBuffPercent: max(state.wheelDurationBuffPercent, 25),
          wheelDurationBuffTasks: max(state.wheelDurationBuffTasks, buffTaskCount),
        ),
      EsnafWheelRewardType.tipRain => state.copyWith(money: state.money + 100),
      EsnafWheelRewardType.bigTender => state.copyWith(money: state.money + 1000),
    };
  }

  PlayerState _addWorkHour(PlayerState state) {
    final index = state.activities.indexWhere((activity) => activity.type == ActivityType.work);
    if (index < 0) {
      return state;
    }
    final activities = [...state.activities];
    final activity = activities[index];
    activities[index] = activity.copyWith(
      remainingHours: activity.remainingHours + 1,
      totalHours: activity.totalHours + 1,
    );
    return state.copyWith(activeActivity: null, activeActivities: activities);
  }

  int _remainingTasks(int tasks) => max(0, tasks - 1);
}

class _DrawnReward {
  const _DrawnReward({required this.index, required this.reward});

  final int index;
  final EsnafWheelReward reward;
}
