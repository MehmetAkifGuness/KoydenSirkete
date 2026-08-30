import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/app_features.dart';
import '../core/accessibility/app_feedback_preferences.dart';
import '../core/database/app_database.dart';
import '../core/database/player_state_store.dart';
import '../core/widgets/app_feedback.dart';
import '../core/widgets/app_gradient_background.dart';
import '../core/widgets/game_bottom_nav.dart';
import '../core/widgets/game_account_bar.dart';
import '../core/widgets/game_top_bar.dart';
import '../core/widgets/storage_error_page.dart';
import '../core/widgets/app_state_view.dart';
import '../features/career/presentation/pages/career_page.dart';
import '../features/assets/presentation/pages/assets_page.dart';
import '../features/cities/presentation/pages/cities_page.dart';
import '../features/company/presentation/pages/company_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/earning/presentation/pages/earning_page.dart';
import '../features/employment/presentation/pages/employment_page.dart';
import '../features/finance/presentation/pages/finance_page.dart';
import '../features/game/application/game_session_application_service.dart';
import '../features/game/data/mappers/player_state_mapper.dart';
import '../features/game/data/repositories/local_player_state_repository.dart';
import '../features/game/domain/services/game_clock_service.dart';
import '../features/game/presentation/pages/bankruptcy_page.dart';
import '../features/game/presentation/state/foreground_clock_ticker.dart';
import '../features/game/presentation/state/game_session_controller.dart';
import '../features/jobs/presentation/pages/jobs_page.dart';
import '../features/onboarding/data/onboarding_demo_repository.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/widgets/game_tutorial_overlay.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/skills/presentation/pages/skills_page.dart';
import '../features/sport/presentation/pages/sport_page.dart';
import '../features/training/presentation/pages/training_page.dart';
import 'router/app_navigation_state.dart';
import 'router/app_router.dart';
import 'theme/app_motion.dart';
import 'theme/app_theme.dart';

class CareerToCompanyApp extends StatelessWidget {
  const CareerToCompanyApp({this.playerStateStore, super.key});

  final PlayerStateStore? playerStateStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Müdür',
      theme: AppTheme.dark(),
      builder: (context, child) =>
          AppGradientBackground(child: child ?? const SizedBox.shrink()),
      home: AppShell(playerStateStore: playerStateStore),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({this.playerStateStore, super.key});

  final PlayerStateStore? playerStateStore;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  final AppNavigationState _navigation = AppNavigationState();
  late final ForegroundClockTicker _clockTicker;
  late final PlayerStateStore _playerStateStore;
  late final GameSessionController _session;
  late final OnboardingDemoRepository _demoRepository;
  late final GameSessionController _demoSession;
  bool _showWelcome = false;
  int _gameSpeed = 1;
  bool _clockPaused = false;
  int? _tutorialStep;
  bool _tutorialCollapsed = false;

  static const _tutorialSteps = <({String title, String description, String task})>[
    (
      title: 'Panelini tanı',
      description:
          'Para, enerji, bilgi ve devam eden işlemler burada özetlenir. Hızlı erişim kartları diğer oyun alanlarına götürür.',
      task: 'Günlük özetini ve hızlı erişim kartlarını incele.',
    ),
    (
      title: 'İlk sermayeni kazan',
      description:
          'Kazanç ekranındaki refleks oyununu deneyebilirsin. Sonuç demo cüzdanına ve enerji değerine gerçek kurallarla uygulanır.',
      task: 'Refleks oyununu tamamlayıp bir kazanç aktivitesi başlat.',
    ),
    (
      title: 'Bilgine yatırım yap',
      description:
          'Bir eğitimi başlatmayı dene. Süre, enerji, ücret ve kazanacağın bilgi kartın üzerinde birlikte gösterilir.',
      task: 'Listeden hedeflerine uygun bir eğitim başlat.',
    ),
    (
      title: 'Kariyer yolunu izle',
      description:
          'Seviye koşullarını, bir sonraki hedefini ve şirket kurmaya uzanan ilerleme yolunu bu ekrandan takip edersin.',
      task: 'Bir sonraki kariyer seviyesinin koşullarını incele.',
    ),
    (
      title: 'İş fırsatını seç',
      description:
          'İlanları koşullarına göre karşılaştır ve uygun bir role başvur. Başvurunun sonucu gerçek oyun kurallarıyla demo kaydına işlenir.',
      task: 'Koşullarını karşıladığın bir iş ilanına başvur.',
    ),
    (
      title: 'Paranın akışını planla',
      description:
          'Gelir-gider dengesi, hareket geçmişi ve gelecek tahminleri Finans ekranında karar vermene yardım eder.',
      task: 'Hesap hareketlerini ve yaklaşan gider tahminini incele.',
    ),
    (
      title: 'Kendi şirketini kur',
      description:
          'Demo hesabında şirket kurmaya yetecek sermaye ve kariyer seviyesi hazır. Kuruluş akışını gerçek ekran üzerinden deneyebilirsin.',
      task: 'Demo sermayesiyle şirket kuruluş akışını tamamla.',
    ),
    (
      title: 'Artık sıra sende',
      description:
          'Tur boyunca ayrı bir demo kaydı kullandın. Turu bitirdiğinde seçtiğin zorluktaki gerçek kariyerin Panel ekranından başlayacak.',
      task: 'Turu bitirip gerçek kariyerine dön.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playerStateStore = widget.playerStateStore ?? AppDatabase();
    _session = GameSessionController(
      applicationService: GameSessionApplicationService(
        repository: LocalPlayerStateRepository(
          database: _playerStateStore,
          mapper: PlayerStateMapper(),
        ),
      ),
    );
    _demoRepository = OnboardingDemoRepository();
    _demoSession = GameSessionController(
      applicationService: GameSessionApplicationService(
        repository: _demoRepository,
      ),
    );
    _clockTicker = ForegroundClockTicker(
      onTick: _tickClock,
      interval: GameClockService.intervalForSpeed(_gameSpeed),
    );
    unawaited(_initializeSession());
  }

  @override
  void dispose() {
    _navigation.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _clockTicker.dispose();
    _demoSession.dispose();
    _session.dispose();
    unawaited(_playerStateStore.close());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_clockPaused &&
          !_showWelcome &&
          _tutorialStep == null &&
          _session.state.isOnboarded &&
          _session.isReady) {
        unawaited(_resumeGame());
      }
    } else {
      _clockTicker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_navigation, _session, _demoSession]),
      builder: (context, _) {
        AppFeedbackPreferences.instance.configure(
          soundEffects: _session.state.soundEffectsEnabled,
          haptics: _session.state.hapticsEnabled,
        );
        if (!_session.isReady) {
          return _shellTransition(
            context,
            'loading',
            const Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: AppStateView(
                    state: AppViewState.loading,
                    title: 'Oyun yükleniyor',
                    message: 'Kayıt ve ekonomi bilgileri hazırlanıyor.',
                  ),
                ),
              ),
            ),
          );
        }
        if (_session.errorMessage != null) {
          return _shellTransition(
            context,
            'error',
            StorageErrorPage(
              message: _session.errorMessage!,
              onRetry: _session.retryInitialization,
            ),
          );
        }
        if (_session.state.isBankrupt) {
          return _shellTransition(
            context,
            'bankruptcy',
            BankruptcyPage(onRestart: _restartAfterBankruptcy),
          );
        }
        if (_showWelcome || !_session.state.isOnboarded) {
          return _shellTransition(
            context,
            'welcome',
            OnboardingPage(
              session: _session,
              onStart: _enterGameWithTutorial,
              onSkip: _skipTutorial,
            ),
          );
        }
        final tutorialStep = _tutorialStep;
        final activeSession = tutorialStep == null ? _session : _demoSession;
        final selectedIndex = tutorialStep == null
            ? _navigation.currentIndex
            : _tutorialNavigationIndex(tutorialStep);
        return _shellTransition(
          context,
          'game',
          Scaffold(
            body: Column(
              children: [
                IgnorePointer(
                  ignoring: tutorialStep != null,
                  child: GameTopBar(
                    state: activeSession.state,
                    speed: _gameSpeed,
                    isRunning:
                        tutorialStep == null &&
                        !_clockPaused &&
                        _clockTicker.isRunning,
                    onSpeedChanged: _changeGameSpeed,
                    onToggleRunning: _toggleClock,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: AnimatedSwitcher(
                            duration: _motionDuration(
                              context,
                              AppMotion.standard,
                            ),
                            switchInCurve: AppMotion.enterCurve,
                            switchOutCurve: AppMotion.exitCurve,
                            transitionBuilder: (child, animation) =>
                                AppMotion.fadeSlide(
                                  child,
                                  animation,
                                  begin: const Offset(.035, 0),
                                ),
                            child: KeyedSubtree(
                              key: ValueKey(
                                tutorialStep == null
                                    ? 'game-${_navigation.currentIndex}'
                                    : 'tutorial-$tutorialStep',
                              ),
                              child: tutorialStep == null
                                  ? _currentPage()
                                  : _tutorialPage(tutorialStep),
                            ),
                          ),
                        ),
                      ),
                      if (tutorialStep != null)
                        GameTutorialOverlay(
                          step: tutorialStep,
                          totalSteps: _tutorialSteps.length,
                          title: _tutorialSteps[tutorialStep].title,
                          description: _tutorialSteps[tutorialStep].description,
                          task: _tutorialSteps[tutorialStep].task,
                          taskCompleted: _tutorialTaskCompleted(tutorialStep),
                          collapsed: _tutorialCollapsed,
                          onNext: _advanceTutorial,
                          onBack: tutorialStep == 0 ? null : _backTutorial,
                          onToggleCollapsed: () => setState(
                            () => _tutorialCollapsed = !_tutorialCollapsed,
                          ),
                          onExit: _requestTutorialExit,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: GameBottomNav(
              selectedIndex: selectedIndex,
              onSelected: tutorialStep == null ? _navigation.select : (_) {},
            ),
          ),
        );
      },
    );
  }

  Widget _shellTransition(BuildContext context, String key, Widget child) {
    return AnimatedSwitcher(
      duration: _motionDuration(context, AppMotion.slow),
      switchInCurve: AppMotion.enterCurve,
      switchOutCurve: AppMotion.exitCurve,
      transitionBuilder: AppMotion.fadeSlide,
      child: KeyedSubtree(key: ValueKey(key), child: child),
    );
  }

  Duration _motionDuration(BuildContext context, Duration duration) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false
      ? Duration.zero
      : duration;

  Widget _currentPage() => switch (_navigation.currentIndex) {
    0 => DashboardPage(session: _session, onFeatureTap: _openFeature),
    1 => CareerPage(session: _session),
    2 => EmploymentPage(session: _session, onFindJob: _openJobs),
    3 => CompanyPage(session: _session),
    _ => ProfilePage(
      session: _session,
      saveSlotStore: _playerStateStore is SaveSlotStore
          ? _playerStateStore
          : null,
      onSlotSelected: _reloadSelectedSlot,
      onStartTutorial: _enterGameWithTutorial,
    ),
  };

  Future<void> _reloadSelectedSlot(int _) async {
    _clockTicker.stop();
    await _session.initialize();
    final error = _session.errorMessage;
    if (error != null) throw SaveDataException(error);
    if (!_clockPaused && _session.isReady && _session.state.isOnboarded) {
      _clockTicker.start();
    }
  }

  Widget _tutorialPage(int step) => switch (step) {
    0 || 7 => DashboardPage(session: _demoSession, onFeatureTap: (_) {}),
    1 => EarningPage(session: _demoSession),
    2 => TrainingPage(session: _demoSession),
    3 => CareerPage(session: _demoSession),
    4 => JobsPage(session: _demoSession),
    5 => FinancePage(session: _demoSession),
    _ => CompanyPage(session: _demoSession),
  };

  int _tutorialNavigationIndex(int step) => switch (step) {
    3 => 1,
    4 => 2,
    6 => 3,
    _ => 0,
  };

  void _enterGame() {
    if (!mounted) return;
    setState(() => _showWelcome = false);
    unawaited(_resumeGame());
  }

  void _enterGameWithTutorial() {
    _startTutorialAt(0);
  }

  void _startTutorialAt(int step) {
    if (!mounted) return;
    _clockTicker.stop();
    _demoRepository.reset(_session.state.economyDifficulty);
    _navigation.select(0);
    setState(() {
      _showWelcome = false;
      _tutorialStep = step.clamp(0, _tutorialSteps.length - 1);
      _tutorialCollapsed = false;
    });
    unawaited(_demoSession.initialize());
  }

  void _advanceTutorial() {
    final step = _tutorialStep;
    if (step == null) return;
    if (step == _tutorialSteps.length - 1) {
      _finishTutorial();
      return;
    }
    unawaited(_demoSession.tick(hours: 3));
    final nextStep = step + 1;
    setState(() {
      _tutorialStep = nextStep;
      _tutorialCollapsed = false;
    });
    if (!_session.state.tutorialCompleted) {
      unawaited(_session.setTutorialProgress(step: nextStep, completed: false));
    }
  }

  void _backTutorial() {
    final step = _tutorialStep;
    if (step == null || step == 0) return;
    final previousStep = step - 1;
    setState(() {
      _tutorialStep = previousStep;
      _tutorialCollapsed = false;
    });
    if (!_session.state.tutorialCompleted) {
      unawaited(
        _session.setTutorialProgress(step: previousStep, completed: false),
      );
    }
  }

  bool _tutorialTaskCompleted(int step) {
    final state = _demoSession.state;
    bool hasActivity(String type) =>
        state.activeActivities.any((activity) => activity.type.name == type);
    return switch (step) {
      1 => state.totalEarned > 0 || hasActivity('earning'),
      2 => state.totalTrainingSessions > 0 || hasActivity('training'),
      4 => state.employment != null || hasActivity('jobApplication'),
      6 => state.companyLevel > 0,
      _ => true,
    };
  }

  Future<void> _requestTutorialExit() async {
    final skip = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Uygulamalı turdan çıkılsın mı?'),
        content: const Text(
          'İlerlemen kaydedildi. Daha sonra kaldığın adımdan devam edebilir veya öğreticiyi tamamen atlayabilirsin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tura dön'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Sonra devam et'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Öğreticiyi atla'),
          ),
        ],
      ),
    );
    if (skip == null || !mounted) return;
    if (skip && !_session.state.tutorialCompleted) {
      await _session.setTutorialProgress(
        step: _tutorialStep ?? 0,
        completed: true,
      );
    }
    _closeTutorial();
  }

  void _finishTutorial() {
    if (!_session.state.tutorialCompleted) {
      unawaited(
        _session.setTutorialProgress(
          step: _tutorialSteps.length - 1,
          completed: true,
        ),
      );
    }
    _closeTutorial();
  }

  void _closeTutorial() {
    if (!mounted) return;
    _navigation.select(0);
    setState(() => _tutorialStep = null);
    if (!_clockPaused) unawaited(_resumeGame());
  }

  void _skipTutorial() {
    unawaited(_completeTutorialSkip());
  }

  Future<void> _completeTutorialSkip() async {
    await _session.setTutorialProgress(step: 0, completed: true);
    _enterGame();
  }

  Future<void> _initializeSession() async {
    await _session.initialize();
    if (!mounted || !_session.isReady) return;
    if (!_session.state.isOnboarded) {
      setState(() => _showWelcome = true);
      return;
    }
    if (!_session.state.tutorialCompleted) {
      _startTutorialAt(_session.state.tutorialStep);
      return;
    }
    setState(() => _showWelcome = false);
    if (!_clockPaused) unawaited(_resumeGame());
  }

  void _changeGameSpeed(int speed) {
    if (_gameSpeed == speed) {
      return;
    }
    setState(() => _gameSpeed = speed);
    _clockTicker.updateInterval(GameClockService.intervalForSpeed(speed));
  }

  void _toggleClock() {
    if (_clockPaused) {
      setState(() => _clockPaused = false);
      if (_session.isReady &&
          _session.state.isOnboarded &&
          !_showWelcome &&
          _tutorialStep == null) {
        _clockTicker.start();
      }
      return;
    }
    setState(() => _clockPaused = true);
    _clockTicker.stop();
  }

  Future<void> _tickClock() async {
    final message = await _session.tick(
      hours: GameClockService.gameHoursPerRealTick,
    );
    if (mounted && message != null && message.isNotEmpty) {
      AppFeedback.show(context, message);
    }
    if (mounted && _session.state.isBankrupt) _clockTicker.stop();
  }

  Future<void> _resumeGame() async {
    await _session.recoverEnergy();
    if (mounted &&
        !_showWelcome &&
        _tutorialStep == null &&
        _session.state.isOnboarded) {
      _clockTicker.start();
    }
  }

  Future<void> _restartAfterBankruptcy() async {
    _clockTicker.stop();
    await _session.resetGame();
    if (!mounted) return;
    setState(() {
      _showWelcome = true;
      _clockPaused = false;
      _gameSpeed = 1;
    });
  }

  void _openFeature(AppFeature feature) {
    final route = switch (feature.title) {
      _ when feature.title == AppFeatures.earning.title => _gameRoute(
        EarningPage(session: _session),
      ),
      _ when feature.title == AppFeatures.training.title => _gameRoute(
        TrainingPage(session: _session),
      ),
      _ when feature.title == AppFeatures.finance.title => _gameRoute(
        FinancePage(session: _session),
      ),
      _ when feature.title == AppFeatures.assets.title => _gameRoute(
        AssetsPage(session: _session),
      ),
      _ when feature.title == AppFeatures.skills.title => _gameRoute(
        SkillsPage(session: _session),
      ),
      _ when feature.title == AppFeatures.sport.title => _gameRoute(
        SportPage(session: _session),
      ),
      _ when feature.title == AppFeatures.jobs.title => _gameRoute(
        JobsPage(session: _session),
      ),
      _ when feature.title == AppFeatures.cities.title => _gameRoute(
        CitiesPage(session: _session),
      ),
      _ => _gameRoute(AppRouter.placeholder(feature)),
    };
    Navigator.of(context).push(route);
  }

  void _openJobs() {
    Navigator.of(context).push(_gameRoute(JobsPage(session: _session)));
  }

  MaterialPageRoute<void> _gameRoute(Widget page) => MaterialPageRoute<void>(
    builder: (_) => GameAccountRoute(session: _session, child: page),
  );
}
