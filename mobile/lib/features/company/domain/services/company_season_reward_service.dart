import '../../../game/domain/entities/player_state.dart';
import '../entities/company_season_reward.dart';

class CompanySeasonRewardService {
  const CompanySeasonRewardService();

  static const sponsorshipRevenuePercent = 8;
  static const reputationPoints = 5;

  CompanySeasonReward rewardFor({
    required int seasonNumber,
    required int rank,
  }) => switch (rank) {
    1 => CompanySeasonReward(
      seasonNumber: seasonNumber,
      rank: rank,
      type: CompanySeasonRewardType.trophy,
      value: 1,
    ),
    2 => CompanySeasonReward(
      seasonNumber: seasonNumber,
      rank: rank,
      type: CompanySeasonRewardType.sponsorship,
      value: sponsorshipRevenuePercent,
    ),
    3 => CompanySeasonReward(
      seasonNumber: seasonNumber,
      rank: rank,
      type: CompanySeasonRewardType.projectInvitation,
      value: 1,
    ),
    4 => CompanySeasonReward(
      seasonNumber: seasonNumber,
      rank: rank,
      type: CompanySeasonRewardType.reputation,
      value: reputationPoints,
    ),
    _ => CompanySeasonReward(
      seasonNumber: seasonNumber,
      rank: rank.clamp(1, 5).toInt(),
      type: CompanySeasonRewardType.none,
      value: 0,
    ),
  };

  int sponsorshipRevenueBonus(PlayerState state) => state
      .companyCompetition
      .seasonRewards
      .where(
        (reward) =>
            reward.type == CompanySeasonRewardType.sponsorship &&
            reward.seasonNumber + 1 == state.companyCompetition.seasonNumber,
      )
      .fold(0, (total, reward) => total + reward.value);

  int reputationBonus(PlayerState state) => state
      .companyCompetition
      .seasonRewards
      .where((reward) => reward.type == CompanySeasonRewardType.reputation)
      .fold(0, (total, reward) => total + reward.value);

  int availableProjectInvitations(PlayerState state) => state
      .companyCompetition
      .seasonRewards
      .where(
        (reward) =>
            reward.type == CompanySeasonRewardType.projectInvitation &&
            !reward.consumed,
      )
      .fold(0, (total, reward) => total + reward.value);

  bool hasProjectInvitation(PlayerState state) =>
      availableProjectInvitations(state) > 0;

  PlayerState consumeProjectInvitation(PlayerState state) {
    var consumed = false;
    final rewards = <CompanySeasonReward>[];
    for (final reward in state.companyCompetition.seasonRewards) {
      if (!consumed &&
          reward.type == CompanySeasonRewardType.projectInvitation &&
          !reward.consumed) {
        rewards.add(reward.copyWith(consumed: true));
        consumed = true;
      } else {
        rewards.add(reward);
      }
    }
    if (!consumed) return state;
    return state.copyWith(
      companyCompetition: state.companyCompetition.copyWith(
        seasonRewards: List<CompanySeasonReward>.unmodifiable(rewards),
      ),
    );
  }
}
