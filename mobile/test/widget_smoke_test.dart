import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:kariyerden_sirkete/app/app.dart';
import 'package:kariyerden_sirkete/app/theme/app_theme.dart';
import 'package:kariyerden_sirkete/core/database/player_state_store.dart';
import 'package:kariyerden_sirkete/core/widgets/app_gradient_background.dart';
import 'package:kariyerden_sirkete/features/assets/presentation/pages/assets_page.dart';
import 'package:kariyerden_sirkete/features/career/presentation/pages/career_page.dart';
import 'package:kariyerden_sirkete/features/company/presentation/pages/company_branches_page.dart';
import 'package:kariyerden_sirkete/features/company/presentation/pages/company_page.dart';
import 'package:kariyerden_sirkete/features/cities/presentation/pages/cities_page.dart';
import 'package:kariyerden_sirkete/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kariyerden_sirkete/features/earning/presentation/pages/earning_page.dart';
import 'package:kariyerden_sirkete/features/employment/presentation/pages/employment_page.dart';
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
  testWidgets('offline onboarding opens the playable dashboard', (tester) async {
    await tester.pumpWidget(CareerToCompanyApp(playerStateStore: _MemoryPlayerStateStore()));
    await tester.pumpAndSettle();

    expect(find.text('Oyuna başla'), findsOneWidget);

    await tester.tap(find.text('Oyuna başla'));
    await tester.pumpAndSettle();

    expect(find.text('Panel'), findsOneWidget);
  });

  testWidgets('assets page renders home and car sections', (tester) async {
    final session = await _readySession();
    await tester.pumpWidget(MaterialApp(theme: AppTheme.dark(), home: AppGradientBackground(child: AssetsPage(session: session))));
    await tester.pumpAndSettle();

    expect(find.text('Evler'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Arabalar'), findsOneWidget);
  });

  testWidgets('company branches page renders city opening options', (tester) async {
    final session = await _readySession();
    await tester.pumpWidget(MaterialApp(theme: AppTheme.dark(), home: AppGradientBackground(child: CompanyBranchesPage(session: session))));
    await tester.pumpAndSettle();

    expect(find.text('Yeni bayi aç'), findsOneWidget);
    expect(find.text('Ankara'), findsOneWidget);
  });

  testWidgets('all feature pages render under the shared theme', (tester) async {
    final session = await _readySession();
    final pages = <Widget>[
      DashboardPage(session: session, onFeatureTap: (_) {}),
      CareerPage(session: session),
      EmploymentPage(session: session),
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
      await tester.pumpWidget(MaterialApp(theme: AppTheme.dark(), home: AppGradientBackground(child: page)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: page.runtimeType.toString());
    }
    session.dispose();
  });
}

Future<GameSessionController> _readySession() async {
  final session = GameSessionController(
    applicationService: GameSessionApplicationService(repository: _MemoryPlayerStateStoreRepository()),
  );
  await session.initialize();
  return session;
}

class _MemoryPlayerStateStoreRepository implements PlayerStateRepository {
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
