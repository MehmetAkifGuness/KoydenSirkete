import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/app_features.dart';
import '../core/database/app_database.dart';
import '../core/database/player_state_store.dart';
import '../core/widgets/app_feedback.dart';
import '../core/widgets/app_gradient_background.dart';
import '../core/widgets/game_bottom_nav.dart';
import '../core/widgets/game_top_bar.dart';
import '../core/widgets/storage_error_page.dart';
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
import '../features/onboarding/presentation/pages/onboarding_page.dart';
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
  bool _showWelcome = true;
  int _gameSpeed = 1;
  bool _clockPaused = false;

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
    _clockTicker = ForegroundClockTicker(
      onTick: _tickClock,
      interval: GameClockService.intervalForSpeed(_gameSpeed),
    );
    _session.initialize();
  }

  @override
  void dispose() {
    _navigation.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _clockTicker.dispose();
    _session.dispose();
    unawaited(_playerStateStore.close());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_clockPaused &&
          !_showWelcome &&
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
      animation: Listenable.merge([_navigation, _session]),
      builder: (context, _) {
        if (!_session.isReady) {
          return _shellTransition(
            context,
            'loading',
            const Scaffold(body: Center(child: CircularProgressIndicator())),
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
            OnboardingPage(session: _session, onStart: _enterGame),
          );
        }
        return _shellTransition(
          context,
          'game',
          Scaffold(
            body: Column(
              children: [
                GameTopBar(
                  state: _session.state,
                  speed: _gameSpeed,
                  isRunning: !_clockPaused && _clockTicker.isRunning,
                  onSpeedChanged: _changeGameSpeed,
                  onToggleRunning: _toggleClock,
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: AnimatedSwitcher(
                      duration: _motionDuration(context, AppMotion.standard),
                      switchInCurve: AppMotion.enterCurve,
                      switchOutCurve: AppMotion.exitCurve,
                      transitionBuilder: (child, animation) =>
                          AppMotion.fadeSlide(
                            child,
                            animation,
                            begin: const Offset(.035, 0),
                          ),
                      child: KeyedSubtree(
                        key: ValueKey(_navigation.currentIndex),
                        child: _currentPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: GameBottomNav(
              selectedIndex: _navigation.currentIndex,
              onSelected: _navigation.select,
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
    2 => EmploymentPage(session: _session),
    3 => CompanyPage(session: _session),
    _ => ProfilePage(session: _session),
  };

  void _enterGame() {
    if (!mounted) return;
    setState(() => _showWelcome = false);
    unawaited(_resumeGame());
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
      if (_session.isReady && _session.state.isOnboarded && !_showWelcome) {
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
    if (mounted && !_showWelcome && _session.state.isOnboarded) {
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
      _ when feature.title == AppFeatures.earning.title =>
        MaterialPageRoute<void>(builder: (_) => EarningPage(session: _session)),
      _ when feature.title == AppFeatures.training.title =>
        MaterialPageRoute<void>(
          builder: (_) => TrainingPage(session: _session),
        ),
      _ when feature.title == AppFeatures.finance.title =>
        MaterialPageRoute<void>(builder: (_) => FinancePage(session: _session)),
      _ when feature.title == AppFeatures.assets.title =>
        MaterialPageRoute<void>(builder: (_) => AssetsPage(session: _session)),
      _ when feature.title == AppFeatures.skills.title =>
        MaterialPageRoute<void>(builder: (_) => SkillsPage(session: _session)),
      _ when feature.title == AppFeatures.sport.title =>
        MaterialPageRoute<void>(builder: (_) => SportPage(session: _session)),
      _ when feature.title == AppFeatures.jobs.title => MaterialPageRoute<void>(
        builder: (_) => JobsPage(session: _session),
      ),
      _ when feature.title == AppFeatures.cities.title =>
        MaterialPageRoute<void>(builder: (_) => CitiesPage(session: _session)),
      _ => AppRouter.placeholderRoute(feature),
    };
    Navigator.of(context).push(route);
  }
}
