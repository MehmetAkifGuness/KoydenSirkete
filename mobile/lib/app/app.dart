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
import '../features/company/domain/services/company_service.dart';
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
import '../features/onboarding/presentation/models/guided_tutorial_step.dart';
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
  final Set<String> _tutorialInteractions = <String>{};
  final Set<String> _tutorialFinanceSections = <String>{};
  final Set<String> _tutorialAssetSections = <String>{};
  final Set<String> _tutorialCompanySections = <String>{};

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
            OnboardingPage(session: _session, onStart: _enterGameWithTutorial),
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
                GameTopBar(
                  state: activeSession.state,
                  speed: _gameSpeed,
                  isRunning: tutorialStep == null
                      ? !_clockPaused && _clockTicker.isRunning
                      : !_clockPaused,
                  onSpeedChanged: (speed) {
                    _changeGameSpeed(speed);
                    if (tutorialStep != null) {
                      _markTutorialInteraction('topbar-speed');
                    }
                  },
                  onToggleRunning: () {
                    _toggleClock();
                    if (tutorialStep != null) {
                      _markTutorialInteraction('topbar-toggle');
                    }
                  },
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
                          totalSteps: guidedTutorialSteps.length,
                          title: guidedTutorialSteps[tutorialStep].title,
                          description:
                              guidedTutorialSteps[tutorialStep].description,
                          task: guidedTutorialSteps[tutorialStep].task,
                          taskCompleted: _tutorialTaskCompleted(tutorialStep),
                          canAcknowledge:
                              guidedTutorialSteps[tutorialStep].canAcknowledge,
                          onAcknowledge: () =>
                              _markTutorialInteraction('ack-$tutorialStep'),
                          collapsed: _tutorialCollapsed,
                          onNext: () => unawaited(_advanceTutorial()),
                          onBack: tutorialStep == 0 ? null : _backTutorial,
                          onToggleCollapsed: () => _update(
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

  void _update(VoidCallback action) => setState(action);
}

extension _AppShellActions on _AppShellState {
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
      onStartTutorial: _enterGameWithTutorial,
    ),
  };

  Widget _tutorialPage(int step) {
    final destination = guidedTutorialSteps[step].destination;
    return switch (destination) {
      GuidedTutorialDestination.dashboard => DashboardPage(
        session: _demoSession,
        onFeatureTap: (_) => _markTutorialInteraction('dashboard-shortcut'),
      ),
      GuidedTutorialDestination.earning => EarningPage(session: _demoSession),
      GuidedTutorialDestination.training => TrainingPage(session: _demoSession),
      GuidedTutorialDestination.skills => SkillsPage(session: _demoSession),
      GuidedTutorialDestination.sport => SportPage(session: _demoSession),
      GuidedTutorialDestination.jobs => JobsPage(session: _demoSession),
      GuidedTutorialDestination.employment => EmploymentPage(
        session: _demoSession,
      ),
      GuidedTutorialDestination.career => CareerPage(session: _demoSession),
      GuidedTutorialDestination.finance => FinancePage(
        session: _demoSession,
        onSectionOpened: (section) =>
            _markTutorialSection(_tutorialFinanceSections, section),
      ),
      GuidedTutorialDestination.cities => CitiesPage(session: _demoSession),
      GuidedTutorialDestination.assets => AssetsPage(
        session: _demoSession,
        onSectionOpened: (section) =>
            _markTutorialSection(_tutorialAssetSections, section),
      ),
      GuidedTutorialDestination.company => CompanyPage(
        session: _demoSession,
        establishmentCheckOverride: const CompanyCheck(
          isEligible: true,
          reason: 'Öğretici demosunda seviye ve sermaye koşulları hazır.',
        ),
        onEstablishCompany: _establishTutorialCompany,
        onSectionOpened: (section) =>
            _markTutorialSection(_tutorialCompanySections, section),
      ),
      GuidedTutorialDestination.profile => ProfilePage(session: _demoSession),
    };
  }

  int _tutorialNavigationIndex(int step) =>
      switch (guidedTutorialSteps[step].destination) {
        GuidedTutorialDestination.career => 1,
        GuidedTutorialDestination.jobs ||
        GuidedTutorialDestination.employment => 2,
        GuidedTutorialDestination.company => 3,
        GuidedTutorialDestination.profile => 4,
        _ => 0,
      };

  void _enterGameWithTutorial() {
    _startTutorialAt(0);
  }

  void _startTutorialAt(int step) {
    if (!mounted) return;
    _clockTicker.stop();
    _demoRepository.reset(_session.state.economyDifficulty);
    _demoRepository.prepareForStep(step);
    _tutorialInteractions.clear();
    _tutorialFinanceSections.clear();
    _tutorialAssetSections.clear();
    _tutorialCompanySections.clear();
    _gameSpeed = 1;
    _clockPaused = false;
    _navigation.select(0);
    _update(() {
      _showWelcome = false;
      _tutorialStep = step.clamp(0, guidedTutorialSteps.length - 1);
      _tutorialCollapsed = false;
    });
    unawaited(_demoSession.initialize());
  }

  Future<void> _advanceTutorial() async {
    final step = _tutorialStep;
    if (step == null || !_tutorialTaskCompleted(step)) return;
    if (step == guidedTutorialSteps.length - 1) {
      _finishTutorial();
      return;
    }
    await _demoSession.tick(hours: 3);
    if (guidedTutorialSteps[step].taskType ==
            GuidedTutorialTask.jobApplication &&
        _demoSession.state.employment == null) {
      _demoRepository.prepareEmployment();
    }
    final nextStep = step + 1;
    _demoRepository.prepareForStep(nextStep);
    await _demoSession.initialize();
    _update(() {
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
    _update(() {
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
    return switch (guidedTutorialSteps[step].taskType) {
      GuidedTutorialTask.topBar =>
        _tutorialInteractions.contains('topbar-speed') &&
            _tutorialInteractions.contains('topbar-toggle'),
      GuidedTutorialTask.dashboardShortcut => _tutorialInteractions.contains(
        'dashboard-shortcut',
      ),
      GuidedTutorialTask.earning =>
        state.totalEarned > 0 || hasActivity('earning'),
      GuidedTutorialTask.training =>
        state.totalTrainingSessions > 0 || hasActivity('training'),
      GuidedTutorialTask.acknowledge => _tutorialInteractions.contains(
        'ack-$step',
      ),
      GuidedTutorialTask.sport => hasActivity('sport'),
      GuidedTutorialTask.jobApplication =>
        state.employment != null || hasActivity('jobApplication'),
      GuidedTutorialTask.work =>
        state.totalWorkSessions > 0 || hasActivity('work'),
      GuidedTutorialTask.finance =>
        _tutorialFinanceSections.length == 3 &&
            (state.personalFinance.hasDebt ||
                state.personalFinance.hasInvestment),
      GuidedTutorialTask.cityMove => state.currentCityId != 1,
      GuidedTutorialTask.assets =>
        _tutorialAssetSections.length == 2 &&
            (state.ownedHomeIds.isNotEmpty || state.ownedCarId != null),
      GuidedTutorialTask.companyEstablishment => state.companyLevel > 0,
      GuidedTutorialTask.companySections =>
        _tutorialCompanySections.length == 4,
      GuidedTutorialTask.feedbackPreferences =>
        !state.soundEffectsEnabled && !state.hapticsEnabled,
      GuidedTutorialTask.finish => true,
    };
  }

  void _markTutorialInteraction(String key) {
    if (!mounted || !_tutorialInteractions.add(key)) return;
    _update(() {});
  }

  void _markTutorialSection(Set<String> sections, String section) {
    if (!mounted || !sections.add(section)) return;
    _update(() {});
  }

  Future<String?> _establishTutorialCompany() async {
    _demoRepository.establishTutorialCompany();
    await _demoSession.initialize();
    return 'Demo şirketin kuruldu.';
  }

  Future<void> _requestTutorialExit() async {
    final close = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sonra devam et'),
          ),
        ],
      ),
    );
    if (close == true && mounted) _closeTutorial();
  }

  void _finishTutorial() {
    if (!_session.state.tutorialCompleted) {
      unawaited(
        _session.setTutorialProgress(
          step: guidedTutorialSteps.length - 1,
          completed: true,
        ),
      );
    }
    _closeTutorial();
  }

  void _closeTutorial() {
    if (!mounted) return;
    _navigation.select(0);
    _update(() => _tutorialStep = null);
    if (!_clockPaused) unawaited(_resumeGame());
  }

  Future<void> _initializeSession() async {
    await _session.initialize();
    if (!mounted || !_session.isReady) return;
    if (!_session.state.isOnboarded) {
      _update(() => _showWelcome = true);
      return;
    }
    if (!_session.state.tutorialCompleted) {
      _startTutorialAt(_session.state.tutorialStep);
      return;
    }
    _update(() => _showWelcome = false);
    if (!_clockPaused) unawaited(_resumeGame());
  }

  void _changeGameSpeed(int speed) {
    if (_gameSpeed == speed) {
      return;
    }
    _update(() => _gameSpeed = speed);
    _clockTicker.updateInterval(GameClockService.intervalForSpeed(speed));
  }

  void _toggleClock() {
    if (_clockPaused) {
      _update(() => _clockPaused = false);
      if (_session.isReady &&
          _session.state.isOnboarded &&
          !_showWelcome &&
          _tutorialStep == null) {
        _clockTicker.start();
      }
      return;
    }
    _update(() => _clockPaused = true);
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
    _update(() {
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
