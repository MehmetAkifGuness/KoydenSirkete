import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/playtest_metrics_service.dart';

void main() {
  test('playtest report measures company and late-game durations', () {
    const service = PlaytestMetricsService();
    final state = PlayerState.initial.copyWith(
      day: 210,
      firstCompanyDay: 30,
      lateGameReachedDay: 180,
    );

    expect(service.firstCompanyDays(state), 30);
    expect(service.lateGameDays(state), 180);
    expect(service.companyToLateGameDays(state), 150);
    final report = service.report(state, testerProfile: 'Deneyimli oyuncu');
    expect(report, contains('Test oyuncusu: Deneyimli oyuncu'));
    expect(report, contains('İlk şirketi kurma: 30'));
    expect(report, contains('Geç oyuna ulaşma: 180'));
  });
}
