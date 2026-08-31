import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/app/theme/app_motion.dart';
import 'package:kariyerden_sirkete/app/theme/app_palette.dart';
import 'package:kariyerden_sirkete/app/theme/app_theme.dart';
import 'package:kariyerden_sirkete/core/accessibility/app_feedback_preferences.dart';
import 'package:kariyerden_sirkete/core/widgets/app_gradient_background.dart';
import 'package:kariyerden_sirkete/core/widgets/app_page.dart';
import 'package:kariyerden_sirkete/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kariyerden_sirkete/features/game/application/game_session_application_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/repositories/player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/presentation/state/game_session_controller.dart';
import 'package:kariyerden_sirkete/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:kariyerden_sirkete/features/onboarding/presentation/widgets/game_tutorial_overlay.dart';

void main() {
  test(
    'available sound and haptic feedback can be controlled independently',
    () {
      final preferences = AppFeedbackPreferences.instance;
      addTearDown(() {
        preferences
          ..setSoundEffects(true)
          ..setHaptics(true);
      });
      preferences
        ..setSoundEffects(false)
        ..setHaptics(false);
      expect(preferences.soundEffectsEnabled, isFalse);
      expect(preferences.hapticsEnabled, isFalse);
    },
  );

  test('semantic colors preserve WCAG AA contrast on supported surfaces', () {
    const surfaces = [
      AppPalette.background,
      AppPalette.surface,
      AppPalette.surfaceElevated,
      AppPalette.surfaceMuted,
    ];
    const textForegrounds = [
      AppPalette.textPrimary,
      AppPalette.textSecondary,
      AppPalette.textMuted,
    ];
    const accentForegrounds = [
      AppPalette.primary,
      AppPalette.secondary,
      AppPalette.tertiary,
      AppPalette.success,
      AppPalette.warning,
      AppPalette.error,
    ];
    for (final surface in surfaces) {
      for (final foreground in textForegrounds) {
        expect(
          _contrastRatio(foreground, surface),
          greaterThanOrEqualTo(4.5),
          reason: '$foreground on $surface',
        );
      }
    }
    for (final surface in const [AppPalette.background, AppPalette.surface]) {
      for (final foreground in accentForegrounds) {
        expect(
          _contrastRatio(foreground, surface),
          greaterThanOrEqualTo(4.5),
          reason: '$foreground on $surface',
        );
      }
    }
  });

  for (final viewport in const [
    (Size(320, 568), 2.0, 'small portrait with large text'),
    (Size(640, 360), 1.6, 'landscape with large text'),
  ]) {
    testWidgets('onboarding fits ${viewport.$3}', (tester) async {
      await tester.binding.setSurfaceSize(viewport.$1);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final session = await _readySession();
      addTearDown(session.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(viewport.$2)),
            child: child!,
          ),
          home: AppGradientBackground(child: OnboardingPage(session: session)),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Müdür uygulama logosu',
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('tutorial coach remains usable with large text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var collapsed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Stack(
              children: [
                const SizedBox.expand(),
                GameTutorialOverlay(
                  step: 1,
                  totalSteps: 8,
                  title: 'İlk sermayeni kazan',
                  description:
                      'Kazanç ekranındaki gerçek işlemi güvenle deneyebilirsin.',
                  task: 'Bir kazanç aktivitesi başlat.',
                  taskCompleted: false,
                  collapsed: collapsed,
                  onNext: () {},
                  onBack: () {},
                  onToggleCollapsed: () =>
                      setState(() => collapsed = !collapsed),
                  onExit: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Kazanç ekranındaki'), findsNothing);
    expect(
      tester.getSize(find.byType(AppInfoCard).last).height,
      lessThanOrEqualTo(240),
    );
    await tester.tap(find.byTooltip('Adım açıklamasını göster'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kazanç ekranındaki'), findsOneWidget);
    await tester.tap(find.byTooltip('Açıklamayı kapat'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Rehberi küçült'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Rehberi büyüt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard fits a compact landscape viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = await _readySession(
      PlayerState.initial.copyWith(isOnboarded: true),
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
        home: AppGradientBackground(
          child: DashboardPage(session: session, onFeatureTap: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion completes reveal effects immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const AppInfoCard(child: Text('Kart')),
        ),
      ),
    );
    expect(
      AppMotion.duration(tester.element(find.text('Kart')), AppMotion.slow),
      Duration.zero,
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

Future<GameSessionController> _readySession([PlayerState? initial]) async {
  final session = GameSessionController(
    applicationService: GameSessionApplicationService(
      repository: _MemoryRepository(initial),
    ),
  );
  await session.initialize();
  return session;
}

class _MemoryRepository implements PlayerStateRepository {
  _MemoryRepository(this.state);

  PlayerState? state;

  @override
  Future<PlayerState?> load() async => state;

  @override
  Future<void> save(PlayerState value) async => state = value;
}

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + .05) / (darker + .05);
}
