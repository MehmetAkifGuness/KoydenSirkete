import 'dart:convert';

import '../../../company/domain/entities/company_competition_state.dart';
import '../../../company/domain/entities/company_season_reward.dart';
import '../../../company/domain/entities/company_season_result.dart';
import '../../../company/domain/entities/company_season_trophy.dart';
import '../../../company/domain/services/company_competition_strategy_service.dart';
import '../../../company/domain/services/company_decision_service.dart';

class CompanyCompetitionCodec {
  static const maxStoredTrophies = 1000;

  String encode(CompanyCompetitionState value) => jsonEncode({
    'seasonNumber': value.seasonNumber,
    'points': value.points,
    'wins': value.wins,
    'losses': value.losses,
    'championships': value.championships,
    'bestRank': value.bestRank,
    'lastRank': value.lastRank,
    'lastReward': value.lastReward,
    'strategyId': value.strategyId,
    'resolvedDecisionKeys': value.resolvedDecisionKeys,
    'lastDecisionChoiceId': value.lastDecisionChoiceId,
    'decisionReputation': value.decisionReputation,
    'seasonRewards': [
      for (final reward in value.seasonRewards)
        {
          'seasonNumber': reward.seasonNumber,
          'rank': reward.rank,
          'type': reward.type.name,
          'value': reward.value,
          'consumed': reward.consumed,
        },
    ],
    'seasonHistory': [
      for (final result in value.seasonHistory)
        {
          'seasonNumber': result.seasonNumber,
          'rank': result.rank,
          'points': result.points,
          'wins': result.wins,
          'losses': result.losses,
          'cashReward': result.cashReward,
          'rewardType': result.reward.type.name,
          'rewardValue': result.reward.value,
        },
    ],
    'trophies': [
      for (final trophy in value.trophies)
        {
          'seasonNumber': trophy.seasonNumber,
          'points': trophy.points,
          'reward': trophy.reward,
        },
    ],
  });

  CompanyCompetitionState decode(String? value, {required int day}) {
    final fallback = CompanyCompetitionState.forDay(day);
    if (value == null || value.isEmpty) return fallback;
    try {
      final data = jsonDecode(value);
      if (data is! Map<String, dynamic>) return fallback;
      int read(String key, [int fallbackValue = 0]) {
        final parsed = data[key];
        return parsed is int ? parsed.clamp(0, 1 << 31).toInt() : fallbackValue;
      }

      final lastRank = read('lastRank').clamp(0, 5);
      final trophies = _decodeTrophies(data['trophies']);
      final recordedChampionships = read(
        'championships',
      ).clamp(0, maxStoredTrophies).toInt();
      final targetCount = recordedChampionships > trophies.length
          ? recordedChampionships
          : trophies.length;
      final normalizedTrophies = List<CompanySeasonTrophy>.unmodifiable([
        ...trophies,
        for (var index = trophies.length; index < targetCount; index++)
          const CompanySeasonTrophy.imported(),
      ]);
      final strategyValue = data['strategyId'];
      final strategyId =
          strategyValue is String &&
              const CompanyCompetitionStrategyService().byId(strategyValue) !=
                  null
          ? strategyValue
          : '';
      final resolvedDecisionKeys = _decodeDecisionKeys(
        data['resolvedDecisionKeys'],
      );
      final choiceValue = data['lastDecisionChoiceId'];
      final lastDecisionChoiceId = choiceValue is String ? choiceValue : '';
      final seasonRewards = _decodeSeasonRewards(data['seasonRewards']);
      final seasonNumber = read(
        'seasonNumber',
        fallback.seasonNumber,
      ).clamp(1, 1 << 20).toInt();
      final seasonHistory = _decodeSeasonHistory(
        data['seasonHistory'],
        beforeSeason: seasonNumber,
      );
      return CompanyCompetitionState(
        seasonNumber: seasonNumber,
        points: read('points'),
        wins: read('wins'),
        losses: read('losses'),
        championships: targetCount,
        bestRank: read('bestRank', lastRank).clamp(0, 5),
        lastRank: lastRank,
        lastReward: read('lastReward'),
        strategyId: strategyId,
        resolvedDecisionKeys: resolvedDecisionKeys,
        lastDecisionChoiceId: lastDecisionChoiceId,
        decisionReputation: read('decisionReputation').clamp(0, 100),
        trophies: normalizedTrophies,
        seasonRewards: seasonRewards,
        seasonHistory: seasonHistory,
      );
    } on FormatException {
      return fallback;
    }
  }

  List<String> _decodeDecisionKeys(Object? value) {
    if (value is! List<dynamic>) return const <String>[];
    final keys = value.whereType<String>().where((key) => key.isNotEmpty);
    return List<String>.unmodifiable(
      keys.length <= CompanyDecisionService.maxResolvedDecisions
          ? keys
          : keys.skip(
              keys.length - CompanyDecisionService.maxResolvedDecisions,
            ),
    );
  }

  List<CompanySeasonTrophy> _decodeTrophies(Object? value) {
    if (value is! List<dynamic>) return const <CompanySeasonTrophy>[];
    final trophies = <CompanySeasonTrophy>[];
    final seasons = <int>{};
    for (final item in value) {
      if (item is! Map<dynamic, dynamic>) continue;
      final season = item['seasonNumber'];
      final points = item['points'];
      final reward = item['reward'];
      if (season is! int || points is! int || reward is! int || season < 0) {
        continue;
      }
      final safeSeason = season.clamp(0, 1 << 20).toInt();
      if (safeSeason > 0 && !seasons.add(safeSeason)) continue;
      trophies.add(
        CompanySeasonTrophy(
          seasonNumber: safeSeason,
          points: points.clamp(0, 1 << 20).toInt(),
          reward: reward.clamp(0, 1 << 31).toInt(),
        ),
      );
      if (trophies.length == maxStoredTrophies) break;
    }
    return trophies;
  }

  List<CompanySeasonReward> _decodeSeasonRewards(Object? value) {
    if (value is! List<dynamic>) return const <CompanySeasonReward>[];
    final rewards = <CompanySeasonReward>[];
    final seasons = <int>{};
    final types = CompanySeasonRewardType.values.asNameMap();
    for (final item in value) {
      if (item is! Map<dynamic, dynamic>) continue;
      final season = item['seasonNumber'];
      final rank = item['rank'];
      final type = types[item['type']];
      final rewardValue = item['value'];
      if (season is! int ||
          season < 1 ||
          rank is! int ||
          rank < 1 ||
          rank > 5 ||
          type == null ||
          rewardValue is! int ||
          !seasons.add(season)) {
        continue;
      }
      rewards.add(
        CompanySeasonReward(
          seasonNumber: season.clamp(1, 1 << 20).toInt(),
          rank: rank,
          type: type,
          value: _safeRewardValue(type, rewardValue),
          consumed: item['consumed'] == true,
        ),
      );
      if (rewards.length == maxStoredTrophies) break;
    }
    return List<CompanySeasonReward>.unmodifiable(rewards);
  }

  List<CompanySeasonResult> _decodeSeasonHistory(
    Object? value, {
    required int beforeSeason,
  }) {
    if (value is! List<dynamic>) return const <CompanySeasonResult>[];
    final results = <CompanySeasonResult>[];
    final seasons = <int>{};
    final types = CompanySeasonRewardType.values.asNameMap();
    for (final item in value) {
      if (item is! Map<dynamic, dynamic>) continue;
      final season = item['seasonNumber'];
      final rank = item['rank'];
      final points = item['points'];
      final wins = item['wins'];
      final losses = item['losses'];
      final cashReward = item['cashReward'];
      final rewardType = types[item['rewardType']];
      final rewardValue = item['rewardValue'];
      if (season is! int ||
          season < 1 ||
          season >= beforeSeason ||
          rank is! int ||
          rank < 1 ||
          rank > 5 ||
          points is! int ||
          wins is! int ||
          losses is! int ||
          cashReward is! int ||
          rewardType == null ||
          rewardValue is! int ||
          !seasons.add(season)) {
        continue;
      }
      final safeWins = wins.clamp(
        0,
        CompanyCompetitionState.seasonDurationDays,
      );
      final safeLosses = losses.clamp(
        0,
        CompanyCompetitionState.seasonDurationDays - safeWins,
      );
      results.add(
        CompanySeasonResult(
          seasonNumber: season,
          rank: rank,
          points: points.clamp(0, 1 << 20).toInt(),
          wins: safeWins.toInt(),
          losses: safeLosses.toInt(),
          cashReward: cashReward.clamp(0, 1 << 31).toInt(),
          reward: CompanySeasonReward(
            seasonNumber: season,
            rank: rank,
            type: rewardType,
            value: _safeRewardValue(rewardType, rewardValue),
          ),
        ),
      );
      if (results.length == CompanyCompetitionState.maxStoredSeasonResults) {
        break;
      }
    }
    results.sort(
      (left, right) => left.seasonNumber.compareTo(right.seasonNumber),
    );
    return List<CompanySeasonResult>.unmodifiable(results);
  }

  int _safeRewardValue(CompanySeasonRewardType type, int value) =>
      switch (type) {
        CompanySeasonRewardType.trophy ||
        CompanySeasonRewardType.projectInvitation => value.clamp(0, 1).toInt(),
        CompanySeasonRewardType.sponsorship => value.clamp(0, 25).toInt(),
        CompanySeasonRewardType.reputation => value.clamp(0, 100).toInt(),
        CompanySeasonRewardType.none => 0,
      };
}
