import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_reward.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_competition_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_growth_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_season_reward_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const rewards = CompanySeasonRewardService();
  const employee = CompanyEmployee(
    id: 1,
    name: 'Lider',
    role: 'Takım lideri',
    performance: 100,
    dailySalary: 100,
  );

  test('five ranks map to bounded and distinct season rewards', () {
    expect([
      for (var rank = 1; rank <= 5; rank++)
        rewards.rewardFor(seasonNumber: 4, rank: rank).type,
    ], CompanySeasonRewardType.values);
    expect(
      rewards.rewardFor(seasonNumber: 4, rank: 2).value,
      CompanySeasonRewardService.sponsorshipRevenuePercent,
    );
    expect(
      rewards.rewardFor(seasonNumber: 4, rank: 4).value,
      CompanySeasonRewardService.reputationPoints,
    );
  });

  test('season settlement records the matching reward exactly once', () {
    final competition = CompanyCompetitionService();
    for (var targetRank = 1; targetRank <= 5; targetRank++) {
      PlayerState? candidate;
      for (var points = 0; points <= 100; points++) {
        final current = _state(seasonNumber: 1).copyWith(
          day: 32,
          companyCompetition: CompanyCompetitionState(points: points),
        );
        final rank = competition
            .standings(current)
            .singleWhere((standing) => standing.isPlayer)
            .rank;
        if (rank == targetRank) {
          candidate = current;
          break;
        }
      }
      expect(candidate, isNotNull, reason: '$targetRank. sıra üretilemedi');

      final settled = competition.process(candidate!, const []);
      final repeated = competition.process(settled.state, const []);

      expect(
        settled.state.companyCompetition.seasonRewards.single.type,
        CompanySeasonRewardType.values[targetRank - 1],
      );
      expect(repeated.state.companyCompetition.seasonRewards, hasLength(1));
    }
  });

  test('sponsorship increases central and branch revenue for one season', () {
    const branch = CompanyBranch(id: 1, cityId: 1, employees: [employee]);
    final base = _state(seasonNumber: 2).copyWith(
      employees: const [employee],
      employeeCount: 1,
      branches: const [branch],
    );
    final sponsored =
        _state(
          seasonNumber: 2,
          seasonRewards: const [
            CompanySeasonReward(
              seasonNumber: 1,
              rank: 2,
              type: CompanySeasonRewardType.sponsorship,
              value: CompanySeasonRewardService.sponsorshipRevenuePercent,
            ),
          ],
        ).copyWith(
          employees: const [employee],
          employeeCount: 1,
          branches: const [branch],
        );
    final expired = sponsored.copyWith(
      companyCompetition: sponsored.companyCompetition.copyWith(
        seasonNumber: 3,
      ),
    );

    expect(
      CompanyService().dailyRevenue(sponsored),
      (CompanyService().dailyRevenue(base) * 1.08).round(),
    );
    expect(
      CompanyBranchService().dailyRevenueFor(sponsored, branch),
      (CompanyBranchService().dailyRevenueFor(base, branch) * 1.08).round(),
    );
    expect(
      CompanyService().dailyRevenue(expired),
      CompanyService().dailyRevenue(base),
    );
  });

  test('reputation rewards remain permanent and stack safely', () {
    final base = _state(seasonNumber: 4);
    final awarded = _state(
      seasonNumber: 4,
      seasonRewards: const [
        CompanySeasonReward(
          seasonNumber: 1,
          rank: 4,
          type: CompanySeasonRewardType.reputation,
          value: 5,
        ),
        CompanySeasonReward(
          seasonNumber: 3,
          rank: 4,
          type: CompanySeasonRewardType.reputation,
          value: 5,
        ),
      ],
    );

    expect(
      CompanyGrowthService().reputation(awarded),
      CompanyGrowthService().reputation(base) + 10,
    );
  });

  test('special project requires and consumes exactly one invitation', () {
    final project = CompanyProjectCatalog.projects.singleWhere(
      (item) => item.requiresSeasonInvitation,
    );
    final base = _state(
      seasonNumber: 3,
    ).copyWith(employees: const [employee], employeeCount: 1);
    final invited = _state(
      seasonNumber: 3,
      seasonRewards: const [
        CompanySeasonReward(
          seasonNumber: 1,
          rank: 3,
          type: CompanySeasonRewardType.projectInvitation,
          value: 1,
        ),
        CompanySeasonReward(
          seasonNumber: 2,
          rank: 3,
          type: CompanySeasonRewardType.projectInvitation,
          value: 1,
        ),
      ],
    ).copyWith(employees: const [employee], employeeCount: 1);
    final company = CompanyService();

    expect(company.checkProjectSelection(base, project).isEligible, isFalse);
    expect(company.checkProjectSelection(invited, project).isEligible, isTrue);

    final selected = company
        .selectProject(invited, project)
        .copyWith(projectProgress: 99);
    final completed = company.advanceProject(selected);

    expect(rewards.availableProjectInvitations(completed.state), 1);
    expect(
      completed.state.activeProjectId,
      CompanyProjectCatalog.projects.first.id,
    );
    expect(
      completed.state.companyCompetition.seasonRewards.where(
        (reward) => reward.consumed,
      ),
      hasLength(1),
    );
  });
}

PlayerState _state({
  required int seasonNumber,
  List<CompanySeasonReward> seasonRewards = const [],
}) => PlayerState.initial.copyWith(
  companyLevel: 3,
  companyFunds: 100000,
  companyCompetition: CompanyCompetitionState(
    seasonNumber: seasonNumber,
    seasonRewards: seasonRewards,
  ),
);
