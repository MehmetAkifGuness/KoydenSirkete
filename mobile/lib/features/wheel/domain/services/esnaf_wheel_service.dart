import 'dart:math';

import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/esnaf_wheel_reward.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class WheelAvailability {
  const WheelAvailability({required this.isAvailable, required this.reason});

  final bool isAvailable;
  final String reason;
}

class WheelSpinOutcome {
  const WheelSpinOutcome({
    required this.state,
    required this.reward,
    required this.sectorIndex,
  });

  final PlayerState state;
  final EsnafWheelReward reward;
  final int sectorIndex;

  String get message => '${reward.title}: ${reward.description}';
}

class EsnafWheelService {
  EsnafWheelService({Random? random}) : _random = random;

  static const spinCost = 50;
  static const dailyMajorRewardLimit = 3;
  static const buffTaskCount = 2;

  final Random? _random;

  WheelAvailability availability(PlayerState state) {
    if (state.money < spinCost) {
      return const WheelAvailability(
        isAvailable: false,
        reason: 'Çarkı çevirmek için ₺50 gerekir.',
      );
    }
    return const WheelAvailability(
      isAvailable: true,
      reason: 'Çark çevirmeye hazırsın.',
    );
  }

  WheelSpinOutcome spin(PlayerState state) {
    final availability = this.availability(state);
    if (!availability.isAvailable) {
      throw GameRuleException(availability.reason);
    }

    final random = _random ?? Random(state.randomSeed);
    final drawn = _drawReward(random);
    var reward = drawn.reward;
    var sectorIndex = drawn.index;
    if (reward.isMajor &&
        state.wheelMajorRewardsToday >= dailyMajorRewardLimit) {
      reward = EsnafWheelRewardCatalog.byType(EsnafWheelRewardType.tipRain);
      final tipSectors = [
        for (
          var index = 0;
          index < EsnafWheelRewardCatalog.sectorTypes.length;
          index++
        )
          if (EsnafWheelRewardCatalog.sectorTypes[index] ==
              EsnafWheelRewardType.tipRain)
            index,
      ];
      sectorIndex = tipSectors[random.nextInt(tipSectors.length)];
    }
    var nextState = state.copyWith(
      money: state.money - spinCost,
      wheelMajorRewardsToday:
          state.wheelMajorRewardsToday + (reward.isMajor ? 1 : 0),
      randomSeed: _nextSeed(state.randomSeed),
    );
    nextState = _applyReward(nextState, reward.type);
    nextState = nextState.copyWith(
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.wheel,
        amount: nextState.money - state.money,
      ),
    );
    return WheelSpinOutcome(
      state: nextState,
      reward: reward,
      sectorIndex: sectorIndex,
    );
  }

  PlayerState consumeWorkBuffs(PlayerState state) {
    return state.copyWith(
      wheelDurationBuffTasks: _remainingTasks(state.wheelDurationBuffTasks),
      wheelDurationBuffPercent: state.wheelDurationBuffTasks <= 1
          ? 0
          : state.wheelDurationBuffPercent,
      wheelEnergyBuffTasks: _remainingTasks(state.wheelEnergyBuffTasks),
      wheelEnergyBuffPercent: state.wheelEnergyBuffTasks <= 1
          ? 0
          : state.wheelEnergyBuffPercent,
    );
  }

  _DrawnReward _drawReward(Random random) {
    final index = random.nextInt(EsnafWheelRewardCatalog.sectorTypes.length);
    return _DrawnReward(
      index: index,
      reward: EsnafWheelRewardCatalog.byType(
        EsnafWheelRewardCatalog.sectorTypes[index],
      ),
    );
  }

  PlayerState _applyReward(PlayerState state, EsnafWheelRewardType type) {
    return switch (type) {
      EsnafWheelRewardType.luckyDay => state.copyWith(
        wheelDurationBuffPercent: max(state.wheelDurationBuffPercent, 50),
        wheelDurationBuffTasks: max(
          state.wheelDurationBuffTasks,
          buffTaskCount,
        ),
        wheelEnergyBuffPercent: max(state.wheelEnergyBuffPercent, 50),
        wheelEnergyBuffTasks: max(state.wheelEnergyBuffTasks, buffTaskCount),
        wheelRewardBuffPercent: max(state.wheelRewardBuffPercent, 100),
        wheelRewardBuffTasks: max(state.wheelRewardBuffTasks, buffTaskCount),
      ),
      EsnafWheelRewardType.empty => state,
      EsnafWheelRewardType.bigTender => state.copyWith(
        money: state.money + 1000,
      ),
      EsnafWheelRewardType.tipRain => state.copyWith(money: state.money + 100),
      EsnafWheelRewardType.smallTip => state.copyWith(money: state.money + 50),
      EsnafWheelRewardType.customerPenalty => state.copyWith(
        money: state.money - 50,
      ),
      EsnafWheelRewardType.majorPenalty => state.copyWith(
        money: state.money - 100,
      ),
    };
  }

  int _remainingTasks(int tasks) => max(0, tasks - 1);

  int _nextSeed(int seed) => (seed * 1103515245 + 12345) & 0x7fffffff;
}

class _DrawnReward {
  const _DrawnReward({required this.index, required this.reward});

  final int index;
  final EsnafWheelReward reward;
}
