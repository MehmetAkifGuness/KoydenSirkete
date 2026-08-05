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
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      final result = await _applicationService.earn(_state, performance: performance);
      _state = result.state;
      return '+₺${result.reward} kazandın. ${result.state.day}. gün, ${result.state.hour}:00';
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> train(Course course) async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      final nextState = await _applicationService.train(_state, course);
      _state = nextState;
      return '${course.name} tamamlandı. +${course.knowledge} bilgi';
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> rest() async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      final nextState = await _applicationService.rest(_state);
      _state = nextState;
      return 'Dinlendin. Enerjin yenilendi.';
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  JobApplicationCheck checkJob(Job job) => _applicationService.checkJob(_state, job);

  Future<String?> applyForJob(Job job) async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      _state = await _applicationService.applyForJob(_state, job);
      return '${job.title} başvurun kabul edildi.';
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> work(Job job, WorkTask task) async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      final result = await _applicationService.work(_state, job, task);
      _state = result.state;
      return '+₺${result.income} kazandın. Performansın: %${result.state.performance}';
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  PromotionCheck checkPromotion(Job currentJob, Job? nextJob) => _applicationService.checkPromotion(_state, currentJob, nextJob);

  Future<String?> promote(Job currentJob, Job nextJob) async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      _state = await _applicationService.promote(_state, currentJob, nextJob);
      return '${nextJob.title} seviyesine terfi ettin.';
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  CityMoveCheck checkCityMove(City city) => _applicationService.checkCityMove(_state, city);

  Future<String?> moveCity(City city) async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      _state = await _applicationService.moveCity(_state, city);
      return '${city.name} şehrine taşındın.';
    } on GameRuleException catch (exception) {
      return exception.message;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
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

  CompanyCheck checkCompanyEstablishment() => _applicationService.checkCompanyEstablishment(_state);

  Future<String?> establishCompany() async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      _state = await _applicationService.establishCompany(_state);
      return 'Şirketin kuruldu. Artık kendi işini büyütebilirsin.';
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> recruitEmployee() async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      _state = await _applicationService.recruitEmployee(_state);
      return 'Yeni çalışan ekibe katıldı.';
    } on GameRuleException catch (exception) {
      return exception.message;
    } catch (_) {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> advanceCompanyProject() async {
    if (!_canExecute()) {
      return 'Oyun henüz hazırlanıyor.';
    }
    _isBusy = true;
    notifyListeners();
    try {
      final result = await _applicationService.advanceCompanyProject(_state);
      _state = result.state;
      return result.message;
    } on GameRuleException catch (exception) {
      return exception.message;
    } on Exception {
      return 'İlerleme kaydedilemedi. Lütfen tekrar dene.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  bool _canExecute() => _isReady && !_isBusy;
}
