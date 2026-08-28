import 'dart:convert';

import '../../../company/domain/entities/company_competition_state.dart';
import '../../../company/domain/entities/company_season_reward.dart';
import '../../../company/domain/entities/company_season_trophy.dart';
import '../../../company/domain/services/company_competition_strategy_service.dart';

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
      final seasonRewards = _decodeSeasonRewards(data['seasonRewards']);
      return CompanyCompetitionState(
        seasonNumber: read(
          'seasonNumber',
          fallback.seasonNumber,
        ).clamp(1, 1 << 20),
        points: read('points'),
        wins: read('wins'),
        losses: read('losses'),
        championships: targetCount,
        bestRank: read('bestRank', lastRank).clamp(0, 5),
        lastRank: lastRank,
        lastReward: read('lastReward'),
        strategyId: strategyId,
        trophies: normalizedTrophies,
        seasonRewards: seasonRewards,
      );
    } on FormatException {
      return fallback;
    }
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
      final safeValue = switch (type) {
        CompanySeasonRewardType.trophy ||
        CompanySeasonRewardType.projectInvitation => rewardValue.clamp(0, 1),
        CompanySeasonRewardType.sponsorship => rewardValue.clamp(0, 25),
        CompanySeasonRewardType.reputation => rewardValue.clamp(0, 100),
        CompanySeasonRewardType.none => 0,
      };
      rewards.add(
        CompanySeasonReward(
          seasonNumber: season.clamp(1, 1 << 20).toInt(),
          rank: rank,
          type: type,
          value: safeValue.toInt(),
          consumed: item['consumed'] == true,
        ),
      );
      if (rewards.length == maxStoredTrophies) break;
    }
    return List<CompanySeasonReward>.unmodifiable(rewards);
  }
}
