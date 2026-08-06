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
  const WheelSpinOutcome({required this.state, required this.reward});

  final PlayerState state;
  final EsnafWheelReward reward;

  String get message => '${reward.title}: ${reward.description}';
}

class EsnafWheelService {
  EsnafWheelService({Random? random}) : _random = random ?? Random();

  static const spinCost = 50;
  static const dailyMajorRewardLimit = 3;
  static const buffTaskCount = 2;

  final Random _random;

  WheelAvailability availability(PlayerState state) {
    if (state.activeActivity?.type != ActivityType.work) {
      return const WheelAvailability(isAvailable: false, reason: 'Çarkı yalnızca aktif iş görevi sırasında çevirebilirsin.');
    }
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

    var reward = _drawReward();
    if (reward.isMajor && state.wheelMajorRewardsToday >= dailyMajorRewardLimit) {
      reward = EsnafWheelRewardCatalog.byType(EsnafWheelRewardType.tipRain);
    }
    var nextState = state.copyWith(
      money: state.money - spinCost,
      wheelCooldownSeconds: 0,
      wheelMajorRewardsToday: state.wheelMajorRewardsToday + (reward.isMajor ? 1 : 0),
    );
    nextState = _applyReward(nextState, reward.type);
    return WheelSpinOutcome(state: nextState, reward: reward);
  }

  PlayerState consumeWorkBuffs(PlayerState state) {
    return state.copyWith(
      wheelDurationBuffTasks: _remainingTasks(state.wheelDurationBuffTasks),
      wheelDurationBuffPercent: state.wheelDurationBuffTasks <= 1 ? 0 : state.wheelDurationBuffPercent,
      wheelEnergyBuffTasks: _remainingTasks(state.wheelEnergyBuffTasks),
      wheelEnergyBuffPercent: state.wheelEnergyBuffTasks <= 1 ? 0 : state.wheelEnergyBuffPercent,
    );
  }

  EsnafWheelReward _drawReward() {
    final sectorType = EsnafWheelRewardCatalog.sectorTypes[_random.nextInt(EsnafWheelRewardCatalog.sectorTypes.length)];
    return EsnafWheelRewardCatalog.byType(sectorType);
  }

  PlayerState _applyReward(PlayerState state, EsnafWheelRewardType type) {
    return switch (type) {
      EsnafWheelRewardType.luckyDay => state.copyWith(
          wheelDurationBuffPercent: max(state.wheelDurationBuffPercent, 50),
          wheelDurationBuffTasks: max(state.wheelDurationBuffTasks, buffTaskCount),
        ),
      EsnafWheelRewardType.esnafBlessing => state.copyWith(money: state.money + 30),
      EsnafWheelRewardType.customerPenalty => state.copyWith(money: state.money - 25),
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
      EsnafWheelRewardType.tipRain => state.copyWith(money: state.money + 60),
      EsnafWheelRewardType.bigTender => state.copyWith(money: state.money + 250),
    };
  }

  PlayerState _addWorkHour(PlayerState state) {
    final activity = state.activeActivity;
    if (activity == null || activity.type != ActivityType.work) {
      return state;
    }
    return state.copyWith(activeActivity: activity.copyWith(remainingHours: activity.remainingHours + 1, totalHours: activity.totalHours + 1));
  }

  int _remainingTasks(int tasks) => max(0, tasks - 1);
}
