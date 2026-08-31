import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_competition_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/economy/domain/entities/economy_difficulty.dart';
import 'package:kariyerden_sirkete/features/economy/domain/services/economy_index_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  test('ekonomi endeksi 10.000 tohumlu girdide taşmaz ve monoton kalır', () {
    const service = EconomyIndexService();
    final random = Random(0x2f9a41);
    for (var index = 0; index < 10000; index++) {
      final amount = random.nextInt(1000000000);
      final day = random.nextInt(1000000) + 1;
      final difficulty = EconomyDifficulty.values[random.nextInt(3)];
      final current = service.applyIncome(amount, day, difficulty: difficulty);
      final later = service.applyIncome(
        amount,
        day + 30,
        difficulty: difficulty,
      );
      expect(current, greaterThanOrEqualTo(0));
      expect(later, greaterThanOrEqualTo(current));
      expect(current, lessThanOrEqualTo(0x7fffffff));
    }
  });

  test('rekabet simülasyonu 500 tohumda deterministik ve sınırlıdır', () {
    for (var seed = 0; seed < 500; seed++) {
      final first = _simulate(seed);
      final second = _simulate(seed);
      expect(first.companyFunds, second.companyFunds);
      expect(first.companyCompetition.points, second.companyCompetition.points);
      expect(first.companyCompetition.wins, second.companyCompetition.wins);
      expect(first.companyFunds, greaterThanOrEqualTo(0));
      expect(first.companyCompetition.points, greaterThanOrEqualTo(0));
      expect(
        first.companyCompetition.seasonHistory.length,
        lessThanOrEqualTo(CompanyCompetitionState.maxStoredSeasonResults),
      );
    }
  });
}

PlayerState _simulate(int seed) {
  final random = Random(seed);
  final market = CompanyMarketService();
  final competition = CompanyCompetitionService();
  var state = PlayerState.initial.copyWith(
    companyLevel: random.nextInt(3) + 1,
    companyFunds: random.nextInt(100000) + 10000,
    employeeCount: 1,
    employees: [CompanyEmployeeCatalog.candidates[seed % 5]],
    companyCompetition: const CompanyCompetitionState(),
  );
  for (var day = 2; day <= 122; day++) {
    state = state.copyWith(day: day);
    final result = market.process(state);
    state = competition.process(result.state, result.outcomes).state;
  }
  return state;
}
