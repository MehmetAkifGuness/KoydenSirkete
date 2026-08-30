import '../entities/player_state.dart';

class PlaytestMetricsService {
  const PlaytestMetricsService();

  int? firstCompanyDays(PlayerState state) =>
      state.firstCompanyDay > 0 ? state.firstCompanyDay : null;

  int? lateGameDays(PlayerState state) =>
      state.lateGameReachedDay > 0 ? state.lateGameReachedDay : null;

  int? companyToLateGameDays(PlayerState state) =>
      state.firstCompanyDay > 0 && state.lateGameReachedDay > 0
      ? state.lateGameReachedDay - state.firstCompanyDay
      : null;

  String report(PlayerState state, {required String testerProfile}) => <String>[
    'Oynanış testi ölçümü v1',
    'Test oyuncusu: $testerProfile',
    'Zorluk: ${state.economyDifficulty.name}',
    'Mevcut oyun günü: ${state.day}',
    'İlk şirketi kurma: ${firstCompanyDays(state) ?? "tamamlanmadı"}',
    'Geç oyuna ulaşma: ${lateGameDays(state) ?? "tamamlanmadı"}',
    'İlk şirketten geç oyuna: ${companyToLateGameDays(state) ?? "tamamlanmadı"}',
    'Geç oyun ölçütü: ulusal marka',
  ].join('\n');
}
