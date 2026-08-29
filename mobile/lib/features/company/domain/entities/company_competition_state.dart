import 'company_season_reward.dart';
import 'company_season_result.dart';
import 'company_season_trophy.dart';

class CompanyCompetitionState {
  const CompanyCompetitionState({
    this.seasonNumber = 1,
    this.points = 0,
    this.wins = 0,
    this.losses = 0,
    this.championships = 0,
    this.bestRank = 0,
    this.lastRank = 0,
    this.lastReward = 0,
    this.strategyId = '',
    this.resolvedDecisionKeys = const <String>[],
    this.lastDecisionChoiceId = '',
    this.decisionReputation = 0,
    this.trophies = const <CompanySeasonTrophy>[],
    this.seasonRewards = const <CompanySeasonReward>[],
    this.seasonHistory = const <CompanySeasonResult>[],
  });

  static const seasonDurationDays = 30;
  static const maxStoredSeasonResults = 1000;

  final int seasonNumber;
  final int points;
  final int wins;
  final int losses;
  final int championships;
  final int bestRank;
  final int lastRank;
  final int lastReward;
  final String strategyId;
  final List<String> resolvedDecisionKeys;
  final String lastDecisionChoiceId;
  final int decisionReputation;
  final List<CompanySeasonTrophy> trophies;
  final List<CompanySeasonReward> seasonRewards;
  final List<CompanySeasonResult> seasonHistory;

  int get matches => wins + losses;
  int get daysRemaining => seasonDurationDays - matches;

  static int seasonForDay(int day) =>
      day <= 1 ? 1 : (day - 2) ~/ seasonDurationDays + 1;

  static int startDay(int seasonNumber) =>
      2 + (seasonNumber - 1) * seasonDurationDays;

  static int endDay(int seasonNumber) =>
      startDay(seasonNumber) + seasonDurationDays - 1;

  factory CompanyCompetitionState.forDay(int day) =>
      CompanyCompetitionState(seasonNumber: seasonForDay(day));

  CompanyCompetitionState copyWith({
    int? seasonNumber,
    int? points,
    int? wins,
    int? losses,
    int? championships,
    int? bestRank,
    int? lastRank,
    int? lastReward,
    String? strategyId,
    List<String>? resolvedDecisionKeys,
    String? lastDecisionChoiceId,
    int? decisionReputation,
    List<CompanySeasonTrophy>? trophies,
    List<CompanySeasonReward>? seasonRewards,
    List<CompanySeasonResult>? seasonHistory,
  }) => CompanyCompetitionState(
    seasonNumber: seasonNumber ?? this.seasonNumber,
    points: points ?? this.points,
    wins: wins ?? this.wins,
    losses: losses ?? this.losses,
    championships: championships ?? this.championships,
    bestRank: bestRank ?? this.bestRank,
    lastRank: lastRank ?? this.lastRank,
    lastReward: lastReward ?? this.lastReward,
    strategyId: strategyId ?? this.strategyId,
    resolvedDecisionKeys: resolvedDecisionKeys ?? this.resolvedDecisionKeys,
    lastDecisionChoiceId: lastDecisionChoiceId ?? this.lastDecisionChoiceId,
    decisionReputation: decisionReputation ?? this.decisionReputation,
    trophies: trophies ?? this.trophies,
    seasonRewards: seasonRewards ?? this.seasonRewards,
    seasonHistory: seasonHistory ?? this.seasonHistory,
  );
}
