enum BotTier { easy, medium, advanced }

class BotCandidate {
  const BotCandidate({required this.tier, required this.score});

  final BotTier tier;
  final int score;
}
