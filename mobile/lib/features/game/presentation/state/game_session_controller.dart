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
import '../../../company/domain/services/company_employee_development_service.dart';
import '../../../company/domain/services/company_employee_management_service.dart';
import '../../../company/domain/services/company_treasury_service.dart';
import '../../../company/domain/entities/company_deal.dart';
import '../../../company/domain/entities/company_competition_strategy.dart';
import '../../../company/domain/services/company_expansion_service.dart';
import '../../application/game_session_application_service.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/entities/debug_state_patch.dart';
import '../../../daily_goals/domain/entities/daily_goal.dart';
import '../../../company/domain/entities/company_project.dart';
import '../../../company/domain/entities/company_employee.dart';
import '../../../company/domain/entities/company_branch.dart';
import '../../../company/domain/entities/company_specialty.dart';
import '../../../company/domain/entities/company_budget_state.dart';
import '../../../company/domain/entities/company_decision.dart';
import '../../../company/domain/services/company_branch_service.dart';
import '../../../assets/domain/entities/home_asset.dart';
import '../../../assets/domain/entities/car_asset.dart';
import '../../../assets/domain/services/asset_service.dart';
import '../../../jobs/domain/entities/job_listing.dart';
import '../../../wheel/domain/services/esnaf_wheel_service.dart';
import '../../../personal_life/domain/entities/personal_event.dart';
import '../../../finance/domain/entities/personal_finance_state.dart';

part 'game_session_feature_controller.dart';

class GameSessionController extends ChangeNotifier {
  GameSessionController({
    required GameSessionApplicationService applicationService,
  }) : _applicationService = applicationService;
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
      _errorMessage =
          'Cihazdaki ilerleme verisi okunamadı. Verilerin korunması için tekrar deneyin.';
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> retryInitialization() => initialize();
  Future<String?> earnMoney({
    EarningPerformance performance = EarningPerformance.none,
  }) async {
    return _execute(
      action: (state) =>
          _applicationService.startEarning(state, performance: performance),
      stateOf: (result) => result,
      message: (_) =>
          'Para kazanma aktivitesi başladı. 2 oyun saati sonra tamamlanacak.',
    );
  }

  Future<String?> train(Course course) async {
    return _execute(
      action: (state) => _applicationService.startTraining(state, course),
      stateOf: (result) => result,
      message: (_) =>
          '${course.name} başladı. Aktivite tamamlanınca bilgi kazanacaksın.',
    );
  }

  Future<String?> startSport() async {
    return _execute(
      action: _applicationService.startSport,
      stateOf: (result) => result,
      message: (_) =>
          'Spor başladı. 1 oyun saati sonra maksimum enerjin artacak.',
    );
  }

  Future<String?> tick({int hours = 1}) async {
    if (!_canExecute()) {
      return null;
    }
    _isBusy = true;
    notifyListeners();
    try {
      final result = await _applicationService.tick(_state, hours: hours);
      _state = result.state;
      return result.message;
    } catch (_) {
      return 'Oyun saati kaydedilemedi.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> recoverEnergy() async {
    if (!_canExecute()) {
      return;
    }
    _isBusy = true;
    notifyListeners();
    try {
      _state = await _applicationService.recoverEnergy(_state);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  JobApplicationCheck checkJob(Job job) =>
      _applicationService.checkJob(_state, job);

  Future<String?> applyForJob(Job job) async {
    return _execute(
      action: (state) => _applicationService.applyForJob(state, job),
      stateOf: (result) => result,
      message: (_) => '${job.title} başvurun kabul edildi.',
    );
  }

  List<JobListing> get jobListings => _applicationService.jobListings(_state);

  List<WorkTask> employerTasks(Job job) =>
      _applicationService.employerTasks(_state, job);

  Future<String?> applyForListing(JobListing listing) async {
    return _execute(
      action: (state) =>
          _applicationService.startJobApplication(state, listing),
      stateOf: (result) => result,
      message: (_) =>
          'Başvuru karşılaşması başladı. 1 oyun saati sonra sonuçlanacak.',
    );
  }

  Future<String?> work(Job job, WorkTask task) async {
    return _execute(
      action: (state) => _applicationService.work(state, job, task),
      stateOf: (result) => result.state,
      message: (result) =>
          '+₺${result.income} kazandın. Performansın: %${result.state.performance}',
    );
  }

  Future<String?> startWork(Job job, WorkTask task) async {
    return _execute(
      action: (state) => _applicationService.startWork(state, job, task),
      stateOf: (result) => result,
      message: (_) =>
          'Görev başladı. Süre dolunca maaş ve performans işlenecek.',
    );
  }

  WheelAvailability get wheelAvailability =>
      _applicationService.wheelAvailability(_state);

  Future<WheelSpinOutcome?> spinWheel() async {
    if (!_canExecute()) {
      return null;
    }
    _isBusy = true;
    notifyListeners();
    try {
      final outcome = await _applicationService.spinWheel(_state);
      _state = outcome.state;
      return outcome;
    } on GameRuleException {
      return null;
    } catch (_) {
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> leaveJob() async {
    return _execute(
      action: _applicationService.leaveJob,
      stateOf: (result) => result,
      message: (_) => 'İşinden ayrıldın.',
    );
  }

  PromotionCheck checkPromotion(Job currentJob, Job? nextJob) =>
      _applicationService.checkPromotion(_state, currentJob, nextJob);

  Future<String?> promote(Job currentJob, Job nextJob) async {
    return _execute(
      action: (state) =>
          _applicationService.promote(state, currentJob, nextJob),
      stateOf: (result) => result,
      message: (_) => '${nextJob.title} seviyesine terfi ettin.',
    );
  }

  CityMoveCheck checkCityMove(City city) =>
      _applicationService.checkCityMove(_state, city);

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

  Future<String?> updateDebugState(DebugStatePatch patch) async {
    return _execute(
      action: (state) => _applicationService.updateDebugState(state, patch),
      stateOf: (result) => result,
      message: (_) => 'Geliştirici verileri kaydedildi.',
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
