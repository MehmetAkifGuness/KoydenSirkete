import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_competition_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_rival_progress_service.dart';

void main() {
  const progressService = CompanyRivalProgressService();

  test('rival season starts from a stable company baseline', () {
    const season = 1;
    final start = CompanyCompetitionState.startDay(season);

    for (final competitor in CompanyMarketService.competitors) {
      final progress = progressService.progressFor(
        competitor,
        seasonNumber: season,
        throughDay: start - 1,
      );

      expect(progress.elapsedDays, 0);
      expect(progress.branchGrowth, 0);
      expect(progress.employeeGrowth, 0);
      expect(progress.fundsGrowth, 0);
      expect(progress.completedProjectGrowth, 0);
      expect(progress.competitiveStrengthBonus, 0);
      expect(progress.projectProgress, inInclusiveRange(0, 99));
    }
  });

  test(
    'every rival develops visibly and deterministically during a season',
    () {
      const season = 1;
      final end = CompanyCompetitionState.endDay(season);
      final signatures = <String>{};

      for (final competitor in CompanyMarketService.competitors) {
        final progress = progressService.progressFor(
          competitor,
          seasonNumber: season,
          throughDay: end,
        );
        final repeated = progressService.progressFor(
          competitor,
          seasonNumber: season,
          throughDay: end,
        );

        expect(
          progress.elapsedDays,
          CompanyCompetitionState.seasonDurationDays,
        );
        expect(progress.branchGrowth, greaterThan(0));
        expect(progress.employeeGrowth, greaterThan(0));
        expect(progress.fundsGrowth, greaterThan(0));
        expect(progress.completedProjectGrowth, greaterThan(0));
        expect(progress.competitiveStrengthBonus, inInclusiveRange(1, 12));
        expect(repeated.branchCount, progress.branchCount);
        expect(repeated.employeeCount, progress.employeeCount);
        expect(repeated.companyFunds, progress.companyFunds);
        expect(repeated.projectProgress, progress.projectProgress);
        signatures.add(
          '${progress.branchCount}:${progress.employeeCount}:'
          '${progress.companyFunds}:${progress.projectProgress}',
        );
      }

      expect(signatures, hasLength(CompanyMarketService.competitors.length));
    },
  );

  test('rival progress clamps to season bounds and grows across seasons', () {
    final competitor = CompanyMarketService.competitors.first;
    final firstStart = CompanyCompetitionState.startDay(1);
    final firstEnd = CompanyCompetitionState.endDay(1);
    final before = progressService.progressFor(
      competitor,
      seasonNumber: 1,
      throughDay: firstStart - 500,
    );
    final end = progressService.progressFor(
      competitor,
      seasonNumber: 1,
      throughDay: firstEnd,
    );
    final after = progressService.progressFor(
      competitor,
      seasonNumber: 1,
      throughDay: firstEnd + 500,
    );
    final laterSeason = progressService.progressFor(
      competitor,
      seasonNumber: 3,
      throughDay: CompanyCompetitionState.startDay(3) - 1,
    );

    expect(before.elapsedDays, 0);
    expect(after.branchCount, end.branchCount);
    expect(after.employeeCount, end.employeeCount);
    expect(after.companyFunds, end.companyFunds);
    expect(laterSeason.startingBranchCount, greaterThan(before.branchCount));
    expect(
      laterSeason.startingEmployeeCount,
      greaterThan(before.employeeCount),
    );
    expect(laterSeason.startingCompanyFunds, greaterThan(before.companyFunds));
  });

  test('operational growth increases but caps rival season strength', () {
    final service = CompanyCompetitionService();
    const season = 1;
    final start = CompanyCompetitionState.startDay(season);
    final end = CompanyCompetitionState.endDay(season);

    for (final competitor in CompanyMarketService.competitors) {
      final initial = service.rivalStrength(competitor, season, start - 1);
      final developed = service.rivalStrength(competitor, season, end);

      expect(developed, greaterThan(initial));
      expect(developed - initial, lessThanOrEqualTo(12));
      expect(developed, lessThanOrEqualTo(95));
    }
  });
}
