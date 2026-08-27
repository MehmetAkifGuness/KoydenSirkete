import '../../../game/domain/entities/player_state.dart';
import '../entities/bot_candidate.dart';
import '../entities/job_listing.dart';

class CompetitionResult {
  const CompetitionResult({
    required this.playerWon,
    required this.playerScore,
    required this.strongestBotScore,
    required this.botCount,
    required this.employerConnectionHired,
  });

  final bool playerWon;
  final int playerScore;
  final int strongestBotScore;
  final int botCount;
  final bool employerConnectionHired;

  bool get applicationSucceeded => playerWon && !employerConnectionHired;
}

class CompetitionService {
  static const employerConnectionChancePercent = 15;

  CompetitionResult resolve(
    PlayerState state,
    JobListing listing, {
    required int day,
  }) {
    final bots = generateBots(listing, day: day);
    final playerScore = _playerScore(state, listing);
    final strongestBot = bots
        .map((bot) => bot.score)
        .fold(0, (best, score) => score > best ? score : best);
    final playerWon = playerScore >= strongestBot;
    return CompetitionResult(
      playerWon: playerWon,
      playerScore: playerScore,
      strongestBotScore: strongestBot,
      botCount: bots.length,
      employerConnectionHired:
          playerWon &&
          _connectionRoll(listing, day) < employerConnectionChancePercent,
    );
  }

  List<BotCandidate> generateBots(JobListing listing, {required int day}) {
    final seed = _seed(listing.cityId, listing.job.id, day);
    final count = 12 + seed % 13;
    return List.generate(count, (index) {
      final value = _seed(seed, index + 1, listing.job.level);
      final tier = value % 100 < 55
          ? BotTier.easy
          : value % 100 < 85
          ? BotTier.medium
          : BotTier.advanced;
      final base = switch (tier) {
        BotTier.easy => 18,
        BotTier.medium => 38,
        BotTier.advanced => 62,
      };
      return BotCandidate(
        tier: tier,
        score: base + value % 31 + listing.job.level * 3,
      );
    }, growable: false);
  }

  int _playerScore(PlayerState state, JobListing listing) {
    final requirements = listing.job.scaledSkillRequirements.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false);
    final skillReadiness = requirements.isEmpty
        ? 1.0
        : requirements.fold<double>(
                0,
                (total, entry) =>
                    total +
                    (state.skills[entry.key] / entry.value).clamp(0, 1.5),
              ) /
              requirements.length;
    final knowledgeReadiness = _readiness(
      state.knowledge,
      listing.job.minimumKnowledge,
    );
    final experienceReadiness = _readiness(
      state.experience,
      listing.job.minimumExperience,
    );
    return (35 +
            listing.job.level * 3 +
            skillReadiness * 35 +
            knowledgeReadiness * 10 +
            experienceReadiness * 10 +
            state.performance * .1)
        .round();
  }

  double _readiness(int value, int requirement) {
    if (requirement <= 0) return 1;
    return (value / requirement).clamp(0, 1.5).toDouble();
  }

  int _connectionRoll(JobListing listing, int day) {
    final employerSeed = listing.company.codeUnits.fold<int>(
      17,
      (hash, codeUnit) => hash * 31 + codeUnit,
    );
    return (employerSeed +
                listing.job.id * 37 +
                listing.cityId * 19 +
                listing.opportunityIndex * 11 +
                day * 29)
            .abs() %
        100;
  }

  int _seed(int first, int second, int third) =>
      (first * 92821 + second * 68917 + third * 31337).abs();
}
