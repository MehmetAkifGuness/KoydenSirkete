import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/app/theme/app_theme.dart';
import 'package:kariyerden_sirkete/features/company/presentation/widgets/company_season_event_panel.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  testWidgets('season event panel exposes five balanced deterministic slots', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = PlayerState.initial.copyWith(day: 9, companyLevel: 1);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanySeasonEventPanel(state: state),
          ),
        ),
      ),
    );

    expect(find.text('Sezon olay takvimi'), findsOneWidget);
    expect(find.text('Deterministik'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('season-event-0-balanced_market')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('season-event-4-talent_shortage')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
