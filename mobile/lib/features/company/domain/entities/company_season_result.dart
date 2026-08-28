import 'company_season_reward.dart';

class CompanySeasonResult {
  const CompanySeasonResult({
    required this.seasonNumber,
    required this.rank,
    required this.points,
    required this.wins,
    required this.losses,
    required this.cashReward,
    required this.reward,
  });

  final int seasonNumber;
  final int rank;
  final int points;
  final int wins;
  final int losses;
  final int cashReward;
  final CompanySeasonReward reward;

  int get matches => wins + losses;
}
