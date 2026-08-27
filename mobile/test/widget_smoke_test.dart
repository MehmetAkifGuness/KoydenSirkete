import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:kariyerden_sirkete/app/app.dart';
import 'package:kariyerden_sirkete/app/theme/app_palette.dart';
import 'package:kariyerden_sirkete/app/theme/app_theme.dart';
import 'package:kariyerden_sirkete/core/database/player_state_store.dart';
import 'package:kariyerden_sirkete/core/widgets/app_gradient_background.dart';
import 'package:kariyerden_sirkete/core/widgets/game_top_bar.dart';
import 'package:kariyerden_sirkete/features/assets/presentation/pages/assets_page.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/asset_service.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/car_catalog.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/home_catalog.dart';
import 'package:kariyerden_sirkete/features/career/presentation/pages/career_page.dart';
import 'package:kariyerden_sirkete/features/company/presentation/pages/company_branches_page.dart';
import 'package:kariyerden_sirkete/features/company/presentation/pages/company_page.dart';
import 'package:kariyerden_sirkete/features/cities/presentation/pages/cities_page.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kariyerden_sirkete/features/earning/presentation/pages/earning_page.dart';
import 'package:kariyerden_sirkete/features/employment/presentation/pages/employment_page.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/finance/presentation/pages/finance_page.dart';
import 'package:kariyerden_sirkete/features/game/presentation/pages/bankruptcy_page.dart';
import 'package:kariyerden_sirkete/features/game/presentation/pages/developer_data_page.dart';
import 'package:kariyerden_sirkete/features/game/application/game_session_application_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/repositories/player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/presentation/state/game_session_controller.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_catalog.dart';
import 'package:kariyerden_sirkete/features/jobs/presentation/pages/jobs_page.dart';
import 'package:kariyerden_sirkete/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:kariyerden_sirkete/features/profile/presentation/pages/profile_page.dart';
import 'package:kariyerden_sirkete/features/progress/presentation/pages/progress_page.dart';
import 'package:kariyerden_sirkete/features/skills/presentation/pages/skills_page.dart';
import 'package:kariyerden_sirkete/features/sport/presentation/pages/sport_page.dart';
import 'package:kariyerden_sirkete/features/training/presentation/pages/training_page.dart';
import 'package:kariyerden_sirkete/features/work/presentation/pages/work_page.dart';

void main() {
  testWidgets('offline onboarding opens the playable dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      CareerToCompanyApp(playerStateStore: _MemoryPlayerStateStore()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Oyuna başla'), findsOneWidget);

    await tester.tap(find.text('Oyuna başla'));
    await tester.pumpAndSettle();

    expect(find.text('Panel'), findsOneWidget);

    await tester.tap(find.text('Kariyer'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.byType(FadeTransition), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Bir sonraki seviyene giden yol'), findsOneWidget);
  });

  test('palette keeps small text readable on every surface', () {
    const surfaces = [
      AppPalette.background,
      AppPalette.surface,
      AppPalette.surfaceElevated,
      AppPalette.surfaceMuted,
    ];
    const foregrounds = [
      AppPalette.textPrimary,
      AppPalette.textSecondary,
      AppPalette.textMuted,
    ];

    for (final surface in surfaces) {
      for (final foreground in foregrounds) {
        expect(
          _contrastRatio(foreground, surface),
          greaterThanOrEqualTo(4.5),
          reason: '$foreground metni $surface üzerinde düşük kontrastlı.',
        );
      }
    }
    expect(
      _contrastRatio(AppPalette.secondary, AppPalette.surface),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('theme animates pushed routes with fade and slide', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Hedef sayfa')),
                    ),
                  ),
                ),
                child: const Text('Sayfayı aç'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sayfayı aç'));
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(SlideTransition), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Hedef sayfa'), findsOneWidget);
  });

  testWidgets('assets page renders home and car sections', (tester) async {
    final session = await _readySession();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: AssetsPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Evler'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Arabalar'), findsOneWidget);
  });

  testWidgets('owned assets expose a confirmed sale action', (tester) async {
    final city = CityCatalog.cities.first;
    final home = HomeCatalog.forCity(city).first;
    final car = CarCatalog.cars.first;
    final session = await _readySession(
      PlayerState.initial.copyWith(
        money: 0,
        ownedHomeIds: [home.id],
        ownedCarId: car.id,
        unlockedAchievementsMask: 1 << 5,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: AssetsPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sat').first);
    await tester.pumpAndSettle();
    expect(find.text('${home.name} satılsın mı?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sat'));
    await tester.pumpAndSettle();

    expect(session.state.ownedHomeIds, isEmpty);
    expect(session.state.money, AssetService().homeSaleValue(home));
    session.dispose();
  });

  testWidgets('owned homes can enter and leave rental status', (tester) async {
    final home = HomeCatalog.forCity(CityCatalog.cities.first).first;
    final session = await _readySession(
      PlayerState.initial.copyWith(money: 0, ownedHomeIds: [home.id]),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: AssetsPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Kiraya ver'));
    await tester.pumpAndSettle();
    expect(session.state.rentedHomeIds, contains(home.id));

    await tester.tap(find.widgetWithText(FilledButton, 'Kiradan çıkar'));
    await tester.pumpAndSettle();
    expect(session.state.rentedHomeIds, isEmpty);
    session.dispose();
  });

  testWidgets('finance page renders projections and recorded movements', (
    tester,
  ) async {
    final ledger = const FinanceLedger().record(
      day: 1,
      category: FinanceCategory.casualIncome,
      amount: 150,
    );
    final session = await _readySession(
      PlayerState.initial.copyWith(financeLedger: ledger),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: FinancePage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GÜNLÜK SABİT BÜTÇE'), findsOneWidget);
    expect(find.text('Ek kazanç'), findsOneWidget);
    expect(find.text('Son 7 gün'), findsOneWidget);
    session.dispose();
  });

  testWidgets('company branches page renders city opening options', (
    tester,
  ) async {
    final session = await _readySession();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(
          child: CompanyBranchesPage(session: session),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yeni bayi aç'), findsOneWidget);
    expect(find.text('Ankara'), findsOneWidget);
  });

  testWidgets('level one company can select every project', (tester) async {
    final session = await _readySession(
      PlayerState.initial.copyWith(
        companyLevel: 1,
        companyFunds: 500,
        activeProjectId: 1,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Kurumsal çözüm'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kurumsal çözüm'));
    await tester.pumpAndSettle();

    expect(session.state.activeProjectId, 3);
    session.dispose();
  });

  testWidgets('all feature pages render under the shared theme', (
    tester,
  ) async {
    final session = await _readySession();
    final pages = <Widget>[
      DashboardPage(session: session, onFeatureTap: (_) {}),
      CareerPage(session: session),
      EmploymentPage(session: session),
      FinancePage(session: session),
      CompanyPage(session: session),
      ProfilePage(session: session),
      EarningPage(session: session),
      TrainingPage(session: session),
      SkillsPage(session: session),
      SportPage(session: session),
      JobsPage(session: session),
      CitiesPage(session: session),
      AssetsPage(session: session),
      CompanyBranchesPage(session: session),
      ProgressPage(session: session),
      WorkPage(session: session, job: JobCatalog.jobs.first),
      DeveloperDataPage(session: session),
      OnboardingPage(session: session),
      BankruptcyPage(onRestart: () async {}),
    ];

    for (final page in pages) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: AppGradientBackground(child: page),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: page.runtimeType.toString(),
      );
    }
    session.dispose();
  });

  testWidgets('profile keeps reset under account and removes app metadata', (
    tester,
  ) async {
    final session = await _readySession();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: ProfilePage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hesabım'), findsOneWidget);
    expect(find.text('Yeni oyuna başla'), findsOneWidget);
    expect(find.text('Uygulama'), findsNothing);
    expect(find.text('Operasyon görünümü'), findsNothing);
    expect(find.text('Çevrimdışı mod'), findsNothing);
    expect(find.text('Offline · SQLite'), findsNothing);
    session.dispose();
  });

  testWidgets('clock speed controls expose 2x, 4x and pause', (tester) async {
    var selectedSpeed = 1;
    var running = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(
          child: Scaffold(
            body: GameTopBar(
              state: PlayerState.initial,
              speed: selectedSpeed,
              isRunning: running,
              onSpeedChanged: (speed) => selectedSpeed = speed,
              onToggleRunning: () => running = !running,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2x'), findsOneWidget);
    expect(find.text('4x'), findsOneWidget);
    expect(find.byTooltip('Durdur'), findsOneWidget);
    await tester.tap(find.text('4x'));
    expect(selectedSpeed, 4);
  });
}

Future<GameSessionController> _readySession([PlayerState? initial]) async {
  final session = GameSessionController(
    applicationService: GameSessionApplicationService(
      repository: _MemoryPlayerStateStoreRepository(initial),
    ),
  );
  await session.initialize();
  return session;
}

class _MemoryPlayerStateStoreRepository implements PlayerStateRepository {
  _MemoryPlayerStateStoreRepository([this.state]);

  PlayerState? state;

  @override
  Future<PlayerState?> load() async => state;

  @override
  Future<void> save(PlayerState value) async => state = value;
}

class _MemoryPlayerStateStore implements PlayerStateStore {
  PlayerStateRecord? _record;

  @override
  Future<PlayerStateRecord?> readPlayerState() async => _record;

  @override
  Future<void> savePlayerState(PlayerStateRecord record) async {
    _record = record;
  }

  @override
  Future<void> close() async {}
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + .05) / (darker + .05);
}
