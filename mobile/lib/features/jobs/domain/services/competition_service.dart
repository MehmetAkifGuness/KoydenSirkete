import '../../../game/domain/entities/player_state.dart';
import '../entities/bot_candidate.dart';
import '../entities/job_listing.dart';

class CompetitionResult {
  const CompetitionResult({required this.playerWon, required this.playerScore, required this.botCount});

  final bool playerWon;
  final int playerScore;
  final int botCount;
}

class CompetitionService {
  CompetitionResult resolve(PlayerState state, JobListing listing, {required int day}) {
    final bots = generateBots(listing, day: day);
    final playerScore = _playerScore(state, listing);
    final strongestBot = bots.map((bot) => bot.score).fold(0, (best, score) => score > best ? score : best);
    return CompetitionResult(playerWon: playerScore >= strongestBot, playerScore: playerScore, botCount: bots.length);
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
      return BotCandidate(tier: tier, score: base + value % 31 + listing.job.level * 3);
    }, growable: false);
  }

  int _playerScore(PlayerState state, JobListing listing) {
    final skillScore = listing.job.skillRequirements.entries.fold<double>(0, (total, entry) {
      if (entry.value <= 0) return total;
      final ratio = state.skills[entry.key] / entry.value;
      return total + ratio.clamp(0, 1.5) * 35;
    });
    return (30 + skillScore + state.knowledge * .25 + state.experience * .2 + state.performance * .2).round();
  }

  int _seed(int first, int second, int third) => (first * 92821 + second * 68917 + third * 31337).abs();
}
