import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';

class CompanyCheck {
  const CompanyCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class CompanyActionResult {
  const CompanyActionResult({required this.state, required this.message});

  final PlayerState state;
  final String message;
}

class CompanyService {
  static const establishmentCost = 1000;
  static const recruitmentCost = 200;
  static const projectCost = 100;

  CompanyCheck checkEstablishment(PlayerState state) {
    if (state.companyLevel > 0) {
      return const CompanyCheck(isEligible: false, reason: 'Zaten bir şirketin var.');
    }
    if (state.careerLevel < 3) {
      return const CompanyCheck(isEligible: false, reason: 'Şirket kurmak için kariyer seviyesi 3 olmalı.');
    }
    if (state.money < establishmentCost) {
      return const CompanyCheck(isEligible: false, reason: 'Şirket kurmak için yeterli sermayen yok.');
    }
    return const CompanyCheck(isEligible: true, reason: 'Şirket kurmaya hazırsın.');
  }

  PlayerState establish(PlayerState state) {
    final check = checkEstablishment(state);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    return state.copyWith(
      currentJobId: null,
      money: state.money - establishmentCost,
      companyLevel: 1,
      companyFunds: 500,
      employeeCount: 0,
      projectProgress: 0,
    );
  }

  PlayerState recruit(PlayerState state) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    if (state.companyFunds < recruitmentCost) {
      throw const GameRuleException('Çalışan almak için şirket kasasında yeterli para yok.');
    }
    return state.copyWith(
      companyFunds: state.companyFunds - recruitmentCost,
      employeeCount: state.employeeCount + 1,
    );
  }

  CompanyActionResult advanceProject(PlayerState state) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    if (state.employeeCount == 0) {
      throw const GameRuleException('Proje için en az bir çalışan almalısın.');
    }
    if (state.companyFunds < projectCost) {
      throw const GameRuleException('Proje için şirket kasasında yeterli para yok.');
    }
    final completed = state.projectProgress + state.employeeCount * 10 >= 100;
    final nextProgress = completed ? 0 : state.projectProgress + state.employeeCount * 10;
    final nextState = state.copyWith(
      companyFunds: state.companyFunds - projectCost,
      projectProgress: nextProgress,
      money: completed ? state.money + 500 : state.money,
      experience: state.experience + 5,
    );
    return CompanyActionResult(
      state: nextState,
      message: completed ? 'Proje tamamlandı. Şirketin ₺500 gelir elde etti.' : 'Proje ilerlemesi %$nextProgress oldu.',
    );
  }
}
