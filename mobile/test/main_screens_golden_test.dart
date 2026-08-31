import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/app/theme/app_theme.dart';
import 'package:kariyerden_sirkete/core/widgets/app_gradient_background.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/presentation/pages/company_page.dart';
import 'package:kariyerden_sirkete/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kariyerden_sirkete/features/finance/presentation/pages/finance_page.dart';
import 'package:kariyerden_sirkete/features/game/application/game_session_application_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/repositories/player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/presentation/state/game_session_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ana ekranların görsel regresyonu', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = await _readySession();
    addTearDown(session.dispose);

    await _expectGolden(
      tester,
      DashboardPage(session: session, onFeatureTap: (_) {}),
      'goldens/dashboard.png',
    );
    await _expectGolden(
      tester,
      FinancePage(session: session),
      'goldens/finance.png',
    );
    await _expectGolden(
      tester,
      CompanyPage(session: session),
      'goldens/company.png',
    );
  });
}

Future<void> _expectGolden(
  WidgetTester tester,
  Widget page,
  String path,
) async {
  const key = ValueKey('golden-boundary');
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: RepaintBoundary(
        key: key,
        child: AppGradientBackground(child: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(find.byKey(key), matchesGoldenFile(path));
}

Future<GameSessionController> _readySession() async {
  final employee = CompanyEmployeeCatalog.candidates.first;
  final session = GameSessionController(
    applicationService: GameSessionApplicationService(
      repository: _GoldenRepository(
        PlayerState.initial.copyWith(
          isOnboarded: true,
          day: 18,
          money: 12450,
          energy: 72,
          knowledge: 48,
          experience: 320,
          careerLevel: 3,
          companyLevel: 2,
          companyFunds: 28750,
          employeeCount: 1,
          employees: [employee],
          completedProjects: 4,
        ),
      ),
    ),
  );
  await session.initialize();
  return session;
}

class _GoldenRepository implements PlayerStateRepository {
  _GoldenRepository(this.state);

  PlayerState state;

  @override
  Future<PlayerState?> load() async => state;

  @override
  Future<void> save(PlayerState value) async => state = value;
}
