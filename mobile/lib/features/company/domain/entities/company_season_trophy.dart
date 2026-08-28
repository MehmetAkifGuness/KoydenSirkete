class CompanySeasonTrophy {
  const CompanySeasonTrophy({
    required this.seasonNumber,
    required this.points,
    required this.reward,
  });

  const CompanySeasonTrophy.imported()
    : seasonNumber = 0,
      points = 0,
      reward = 0;

  final int seasonNumber;
  final int points;
  final int reward;

  bool get isImported => seasonNumber == 0;
}
