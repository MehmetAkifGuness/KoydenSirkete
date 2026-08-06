import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';

class EmploymentService {
  PlayerState markTaskStarted(PlayerState state) {
    final employment = state.employment;
    if (employment == null) return state;
    return state.copyWith(employment: employment.copyWith(lastTaskDay: state.day));
  }

  PlayerState checkAttendance(PlayerState state) {
    final employment = state.employment;
    if (employment == null || state.day - employment.lastTaskDay < 2) return state;
    return state.copyWith(
      currentJobId: null,
      employment: null,
      performance: 0,
      dismissedDay: state.day,
      lastJobEvent: '${employment.company} iki oyun günü görev yapılmadığı için iş akdini sonlandırdı.',
    );
  }

  PlayerState leave(PlayerState state) {
    if (state.employment == null && state.currentJobId == null) {
      throw const GameRuleException('Aktif bir işin yok.');
    }
    return state.copyWith(
      currentJobId: null,
      employment: null,
      performance: 0,
      lastJobEvent: 'Aktif işinden ayrıldın.',
    );
  }
}
