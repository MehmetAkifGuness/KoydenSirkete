import 'dart:async';

import 'package:flutter/material.dart';

import '../core/database/app_database.dart';
import '../core/database/player_state_store.dart';
import '../core/constants/app_features.dart';
import '../core/widgets/app_gradient_background.dart';
import '../core/widgets/storage_error_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/earning/presentation/pages/earning_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/game/data/mappers/player_state_mapper.dart';
import '../features/game/data/repositories/local_player_state_repository.dart';
import '../features/game/application/game_session_application_service.dart';
import '../features/game/domain/services/game_clock_service.dart';
import '../features/game/presentation/state/game_session_controller.dart';
import '../features/game/presentation/state/foreground_clock_ticker.dart';
import '../features/training/presentation/pages/training_page.dart';
import '../features/skills/presentation/pages/skills_page.dart';
import '../features/sport/presentation/pages/sport_page.dart';
import '../features/jobs/presentation/pages/jobs_page.dart';
import '../features/career/presentation/pages/career_page.dart';
import '../features/cities/presentation/pages/cities_page.dart';
import '../features/company/presentation/pages/company_page.dart';
import '../features/employment/presentation/pages/employment_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import 'router/app_navigation_state.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class CareerToCompanyApp extends StatelessWidget {
  const CareerToCompanyApp({this.playerStateStore, super.key});

  final PlayerStateStore? playerStateStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Müdürüm',
      theme: AppTheme.dark(),
      builder: (context, child) => AppGradientBackground(child: child ?? const SizedBox.shrink()),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playerStateStore = widget.playerStateStore ?? AppDatabase();
    _session = GameSessionController(
      applicationService: GameSessionApplicationService(
        repository: LocalPlayerStateRepository(database: _playerStateStore, mapper: PlayerStateMapper()),
      ),
    );
    _clockTicker = ForegroundClockTicker(
      onTick: () => _session.tick(hours: GameClockService.gameHoursPerRealTick),
    );
    _session.initialize();
    _clockTicker.start();
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
      _clockTicker.start();
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (_session.errorMessage != null) {
          return StorageErrorPage(message: _session.errorMessage!, onRetry: _session.retryInitialization);
        }
        if (!_session.state.isOnboarded) {
          return OnboardingPage(session: _session);
        }
        return Scaffold(
          body: IndexedStack(
            index: _navigation.currentIndex,
            children: [
              DashboardPage(session: _session, onFeatureTap: _openFeature),
              CareerPage(session: _session),
              EmploymentPage(session: _session),
              CompanyPage(session: _session),
              ProfilePage(session: _session),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _navigation.currentIndex,
            onDestinationSelected: _navigation.select,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Panel'),
              NavigationDestination(icon: Icon(Icons.trending_up), label: 'Kariyer'),
              NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'İşim'),
              NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'Şirketim'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        );
      },
    );
  }

  void _openFeature(AppFeature feature) {
    if (feature.title == AppFeatures.earning.title) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EarningPage(session: _session)));
      return;
    }
    if (feature.title == AppFeatures.training.title) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TrainingPage(session: _session)));
      return;
    }
    if (feature.title == AppFeatures.skills.title) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SkillsPage(session: _session)));
      return;
    }
    if (feature.title == AppFeatures.sport.title) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SportPage(session: _session)));
      return;
    }
    if (feature.title == AppFeatures.jobs.title) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => JobsPage(session: _session)));
      return;
    }
    if (feature.title == AppFeatures.cities.title) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CitiesPage(session: _session)));
      return;
    }
    Navigator.of(context).push(AppRouter.placeholderRoute(feature));
  }
}
