import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_project.dart';
import 'company_project_catalog.dart';

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
  static const maxCompanyLevel = 3;

  static int upgradeCost(int level) => level * 600;
  static int employeeCapacity(int level) => level * 2;

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
      activeProjectId: CompanyProjectCatalog.projects.first.id,
      completedProjects: 0,
    );
  }

  PlayerState recruit(PlayerState state) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    if (state.companyFunds < recruitmentCost) {
      throw const GameRuleException('Çalışan almak için şirket kasasında yeterli para yok.');
    }
    if (state.employeeCount >= employeeCapacity(state.companyLevel)) {
      throw const GameRuleException('Bu şirket seviyesi için çalışan kapasitesi dolu.');
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
    final project = CompanyProjectCatalog.byId(state.activeProjectId);
    if (state.companyFunds < project.cost) {
      throw const GameRuleException('Proje için şirket kasasında yeterli para yok.');
    }
    final completed = state.projectProgress + state.employeeCount * project.progressPerEmployee >= 100;
    final nextProgress = completed ? 0 : state.projectProgress + state.employeeCount * project.progressPerEmployee;
    final nextState = state.copyWith(
      companyFunds: state.companyFunds - project.cost,
      projectProgress: nextProgress,
      money: completed ? state.money + project.reward : state.money,
      experience: state.experience + project.experienceReward,
      completedProjects: completed ? state.completedProjects + 1 : state.completedProjects,
    );
    return CompanyActionResult(
      state: nextState,
      message: completed ? 'Proje tamamlandı. Şirketin ₺${project.reward} gelir elde etti.' : 'Proje ilerlemesi %$nextProgress oldu.',
    );
  }

  CompanyCheck checkUpgrade(PlayerState state) {
    if (state.companyLevel == 0) {
      return const CompanyCheck(isEligible: false, reason: 'Önce şirketini kurmalısın.');
    }
    if (state.companyLevel >= maxCompanyLevel) {
      return const CompanyCheck(isEligible: false, reason: 'Şirketin en yüksek seviyede.');
    }
    final cost = upgradeCost(state.companyLevel);
    if (state.companyFunds < cost) {
      return CompanyCheck(isEligible: false, reason: 'Seviye yükseltmek için şirket kasasında ₺$cost olmalı.');
    }
    return CompanyCheck(isEligible: true, reason: 'Yeni seviye ve çalışan kapasitesi açılacak.');
  }

  PlayerState upgrade(PlayerState state) {
    final check = checkUpgrade(state);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    return state.copyWith(
      companyLevel: state.companyLevel + 1,
      companyFunds: state.companyFunds - upgradeCost(state.companyLevel),
    );
  }

  CompanyCheck checkProjectSelection(PlayerState state, CompanyProject project) {
    if (state.companyLevel == 0) {
      return const CompanyCheck(isEligible: false, reason: 'Önce şirketini kurmalısın.');
    }
    if (project.id > state.companyLevel) {
      return CompanyCheck(isEligible: false, reason: 'Bu proje için şirket seviyesi ${project.id} olmalı.');
    }
    if (state.projectProgress > 0) {
      return const CompanyCheck(isEligible: false, reason: 'Devam eden proje bitmeden proje değiştirilemez.');
    }
    return const CompanyCheck(isEligible: true, reason: 'Proje seçilebilir.');
  }

  PlayerState selectProject(PlayerState state, CompanyProject project) {
    final check = checkProjectSelection(state, project);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    return state.copyWith(activeProjectId: project.id);
  }
}
