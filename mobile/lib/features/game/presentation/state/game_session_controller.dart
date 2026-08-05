import 'package:flutter/foundation.dart';

import '../../../../core/errors/game_rule_exception.dart';
import '../../../earning/domain/entities/earning_performance.dart';
import '../../../training/domain/entities/course.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/domain/services/job_application_service.dart';
import '../../../work/domain/entities/work_task.dart';
import '../../../career/domain/services/career_service.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_service.dart';
import '../../../company/domain/services/company_service.dart';
import '../../application/game_session_application_service.dart';
import '../../domain/entities/player_state.dart';
import '../../../daily_goals/domain/entities/daily_goal.dart';
import '../../../company/domain/entities/company_project.dart';

class GameSessionController extends ChangeNotifier {
  GameSessionController({required GameSessionApplicationService applicationService})
      : _applicationService = applicationService;

  final GameSessionApplicationService _applicationService;
  PlayerState _state = PlayerState.initial;
  bool _isReady = false;
  bool _isBusy = false;
  String? _errorMessage;

  PlayerState get state => _state;
  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isReady = false;
    _errorMessage = null;
    notifyListeners();
    try {
      _state = await _applicationService.load();
    } catch (_) {
      _state = PlayerState.initial;
      _errorMessage = 'Cihazdaki ilerleme verisi okunamadı. Verilerin korunması için tekrar deneyin.';
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> retryInitialization() => initialize();

  Future<String?> earnMoney({EarningPerformance performance = EarningPerformance.none}) async {
    return _execute(
      action: (state) => _applicationService.earn(state, performance: performance),
      stateOf: (result) => result.state,
      message: (result) => '+₺${result.reward} kazandın. ${result.state.day}. gün, ${result.state.hour}:00',
    );
  }

  Future<String?> train(Course course) async {
    return _execute(
      action: (state) => _applicationService.train(state, course),
      stateOf: (result) => result,
      message: (_) => '${course.name} tamamlandı. +${course.knowledge} bilgi',
    );
  }

  Future<String?> rest() async {
    return _execute(
      action: _applicationService.rest,
      stateOf: (result) => result,
      message: (_) => 'Dinlendin. Enerjin yenilendi.',
    );
  }

  JobApplicationCheck checkJob(Job job) => _applicationService.checkJob(_state, job);

  Future<String?> applyForJob(Job job) async {
    return _execute(
      action: (state) => _applicationService.applyForJob(state, job),
      stateOf: (result) => result,
      message: (_) => '${job.title} başvurun kabul edildi.',
    );
  }

  Future<String?> work(Job job, WorkTask task) async {
    return _execute(
      action: (state) => _applicationService.work(state, job, task),
      stateOf: (result) => result.state,
      message: (result) => '+₺${result.income} kazandın. Performansın: %${result.state.performance}',
    );
  }

  PromotionCheck checkPromotion(Job currentJob, Job? nextJob) => _applicationService.checkPromotion(_state, currentJob, nextJob);

  Future<String?> promote(Job currentJob, Job nextJob) async {
    return _execute(
      action: (state) => _applicationService.promote(state, currentJob, nextJob),
      stateOf: (result) => result,
      message: (_) => '${nextJob.title} seviyesine terfi ettin.',
    );
  }

  CityMoveCheck checkCityMove(City city) => _applicationService.checkCityMove(_state, city);

  Future<String?> moveCity(City city) async {
    return _execute(
      action: (state) => _applicationService.moveCity(state, city),
      stateOf: (result) => result,
      message: (_) => '${city.name} şehrine taşındın.',
    );
  }

  Future<void> completeOnboarding() async {
    if (_isBusy) {
      return;
    }
    _isBusy = true;
    notifyListeners();
    try {
      _state = await _applicationService.completeOnboarding(_state);
    } catch (_) {
      _errorMessage = 'Onboarding bilgisi kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> resetGame() async {
    if (_isBusy) {
      return;
    }
    _isBusy = true;
    notifyListeners();
    try {
      _state = await _applicationService.resetGame();
    } catch (_) {
      _errorMessage = 'Oyun sıfırlanamadı. Mevcut kayıt korunuyor.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  DailyGoalStatus get dailyGoalStatus => _applicationService.dailyGoalStatus(_state);

  Future<String?> claimDailyGoal() async {
    return _execute(
      action: _applicationService.claimDailyGoal,
      stateOf: (result) => result,
      message: (_) => 'Günlük hedef ödülünü aldın: +₺${dailyGoalStatus.reward}.',
    );
  }

  CompanyCheck checkCompanyEstablishment() => _applicationService.checkCompanyEstablishment(_state);

  Future<String?> establishCompany() async {
    return _execute(
      action: _applicationService.establishCompany,
      stateOf: (result) => result,
      message: (_) => 'Şirketin kuruldu. Artık kendi işini büyütebilirsin.',
    );
  }

  Future<String?> recruitEmployee() async {
    return _execute(
      action: _applicationService.recruitEmployee,
      stateOf: (result) => result,
      message: (_) => 'Yeni çalışan ekibe katıldı.',
    );
  }

  CompanyCheck checkCompanyUpgrade() => _applicationService.checkCompanyUpgrade(_state);

  Future<String?> upgradeCompany() async {
    return _execute(
      action: _applicationService.upgradeCompany,
      stateOf: (result) => result,
      message: (result) => 'Şirketin seviye ${result.companyLevel} oldu.',
    );
  }

  Future<String?> selectCompanyProject(CompanyProject project) async {
    return _execute(
      action: (state) => _applicationService.selectCompanyProject(state, project),
      stateOf: (result) => result,
      message: (_) => '${project.name} projesi seçildi.',
    );
  }

  Future<String?> advanceCompanyProject() async {
    return _execute(
      action: _applicationService.advanceCompanyProject,
      stateOf: (result) => result.state,
      message: (result) => result.message,
    );
  }

  Future<String?> _execute<T>({
    required Future<T> Function(PlayerState state) action,
    required PlayerState Function(T result) stateOf,
    required String Function(T result) message,
  }) async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      final result = await action(_state);
      _state = stateOf(result);
      return message(result);
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  bool _canExecute() => _isReady && !_isBusy;
}
