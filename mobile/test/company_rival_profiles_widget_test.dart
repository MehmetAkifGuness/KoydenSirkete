import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/app/theme/app_theme.dart';
import 'package:kariyerden_sirkete/features/company/presentation/widgets/company_rival_profiles_panel.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  testWidgets('rival panel exposes every leader and strategic trait', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: CompanyRivalProfilesPanel(
              state: PlayerState.initial.copyWith(day: 31, companyLevel: 1),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rakip şirket takibi'), findsOneWidget);
    for (final leader in [
      'Ece Yalın',
      'Mert Özkan',
      'Selin Karaca',
      'Arda Vural',
    ]) {
      expect(find.textContaining(leader), findsOneWidget);
    }
    expect(
      find.textContaining('Hızlı yenilik', findRichText: true),
      findsWidgets,
    );
    expect(
      find.textContaining('Kriz dayanıklılığı', findRichText: true),
      findsWidgets,
    );
    expect(
      find.textContaining('Maliyet disiplini', findRichText: true),
      findsWidgets,
    );
    expect(
      find.textContaining('Küresel satış ağı', findRichText: true),
      findsWidgets,
    );
    expect(find.textContaining('Bayi '), findsNWidgets(4));
    expect(find.textContaining('Çalışan '), findsNWidgets(4));
    expect(find.textContaining('Kasa ₺'), findsNWidgets(4));
    expect(find.textContaining('Aktif proje %'), findsNWidgets(4));
    expect(find.textContaining('Operasyon gücü +'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
