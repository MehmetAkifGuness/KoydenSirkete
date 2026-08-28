import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/app/theme/app_theme.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/presentation/widgets/company_competition_panel.dart';
import 'package:kariyerden_sirkete/features/company/presentation/widgets/company_market_panel.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  testWidgets('company panels explain the active season rule and modifiers', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = PlayerState.initial.copyWith(
      day: 7,
      companyLevel: 1,
      companyFunds: 10000,
      employeeCount: 1,
      employees: const [
        CompanyEmployee(
          id: 999,
          name: 'Test Çalışanı',
          role: 'Satış uzmanı',
          performance: 70,
          dailySalary: 40,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                CompanyMarketPanel(state: state),
                const SizedBox(height: 24),
                CompanyCompetitionPanel(state: state),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sezon · Talep patlaması'), findsOneWidget);
    expect(find.text('Sezon kuralı · Talep patlaması'), findsOneWidget);
    expect(find.text('Toplam gelir +%10'), findsOneWidget);
    expect(find.text('Toplam maaş +%2'), findsOneWidget);
    expect(find.text('Sezon: Sen +5 · Rakip +5'), findsOneWidget);
    expect(find.text('Satış uzmanlığı +5 güç'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
