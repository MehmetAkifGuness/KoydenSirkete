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
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_budget_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_specialty.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_trophy.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_development_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_expansion_service.dart';
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
    var ledger = const FinanceLedger().record(
      day: 1,
      category: FinanceCategory.casualIncome,
      amount: 150,
    );
    ledger = ledger.record(
      day: 1,
      category: FinanceCategory.companyRevenue,
      amount: 500,
      account: FinanceAccount.company,
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
    await tester.scrollUntilVisible(
      find.text('Şirket hareketleri'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Şirket operasyon geliri'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Son 7 gün'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Son 7 gün'), findsOneWidget);
    session.dispose();
  });

  testWidgets('company treasury transfers money in both directions', (
    tester,
  ) async {
    final session = await _readySession(
      PlayerState.initial.copyWith(
        money: 5000,
        companyLevel: 1,
        companyFunds: 2000,
        unlockedAchievementsMask: (1 << 12) - 1,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HESAPLAR ARASI AKTARIM'), findsOneWidget);
    await tester.tap(find.text('Sermaye aktar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Aktar'));
    await tester.pumpAndSettle();
    expect(session.state.money, 4000);
    expect(session.state.companyFunds, 3000);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Kâr payı çek'));
    await tester.tap(find.text('Kâr payı çek'));
    await tester.pumpAndSettle();
    expect(find.text('Vergi ₺100 · Cüzdana net ₺900'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Aktar'));
    await tester.pumpAndSettle();
    expect(session.state.money, 4900);
    expect(session.state.companyFunds, 2000);
    session.dispose();
  });

  testWidgets('company budget choices respect the daily limit', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = await _readySession(
      PlayerState.initial.copyWith(
        money: 5000,
        companyLevel: 1,
        companyFunds: 2000,
        unlockedAchievementsMask: (1 << 12) - 1,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    final marketing = find.byKey(
      const ValueKey('company-budget-marketing-medium'),
    );
    await tester.ensureVisible(marketing);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Pazarlama bütçesi: Orta'), findsOneWidget);
    expect(find.text('Günlük ₺0 / ₺75'), findsOneWidget);
    await tester.tap(marketing);
    await tester.pumpAndSettle();

    expect(session.state.companyBudget.marketing, CompanyBudgetLevel.medium);
    expect(session.state.money, 5000);
    expect(session.state.companyFunds, 2000);
    expect(find.text('Günlük ₺40 / ₺75'), findsOneWidget);
    expect(find.text('Gelir +6%'), findsOneWidget);
    expect(find.text('İtibar +2'), findsOneWidget);

    final research = find.byKey(
      const ValueKey('company-budget-research-medium'),
    );
    await tester.ensureVisible(research);
    await tester.pumpAndSettle();
    await tester.tap(research);
    await tester.pumpAndSettle();

    expect(session.state.companyBudget.research, CompanyBudgetLevel.off);
    expect(find.textContaining('Günlük bütçe sınırı ₺75'), findsOneWidget);
    session.dispose();
  });

  testWidgets('company decision shows outcomes and locks after selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = await _readySession(
      PlayerState.initial.copyWith(
        day: 2,
        companyLevel: 1,
        companyFunds: 1000,
        unlockedAchievementsMask: (1 << 12) - 1,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    final choice = find.byKey(const ValueKey('company-decision-people'));
    await tester.ensureVisible(choice);
    await tester.pumpAndSettle();
    expect(find.text('Kasa -₺80'), findsOneWidget);
    expect(find.text('Moral +7'), findsOneWidget);
    await tester.tap(choice);
    await tester.pumpAndSettle();

    expect(session.state.companyFunds, 920);
    expect(session.state.companyCompetition.lastDecisionChoiceId, 'people');
    expect(choice, findsNothing);
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

    expect(find.text('Bölgesel hâkimiyet'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Yeni bayi aç'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Yeni bayi aç'), findsOneWidget);
    expect(find.text('Ankara'), findsOneWidget);
  });

  testWidgets('branch upgrade is visible and persists the new level', (
    tester,
  ) async {
    final city = CityCatalog.cities.first;
    final branch = CompanyBranch(
      id: city.id,
      cityId: city.id,
      employees: [CompanyEmployeeCatalog.candidates.first],
    );
    final cost = CompanyBranchService.upgradeCost(branch);
    final session = await _readySession(
      PlayerState.initial.copyWith(
        companyLevel: 3,
        companyFunds: cost + 100,
        branches: [branch],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(
          child: CompanyBranchesPage(session: session),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final action = find.text('Yükselt · Kasa ₺$cost');
    await tester.scrollUntilVisible(
      action,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    expect(find.textContaining('odağı'), findsWidgets);
    expect(find.textContaining('Başlangıç'), findsWidgets);
    expect(find.textContaining('Deneyim 0'), findsWidgets);
    expect(find.textContaining('Tükenmişlik %0'), findsWidgets);
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(session.state.branches.single.level, 2);
    expect(session.state.companyFunds, 100);
    session.dispose();
  });

  testWidgets('branch management choices persist from the branch panel', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final city = CityCatalog.cities.first;
    final employee = CompanyEmployeeCatalog.candidates.first;
    final branch = CompanyBranch(
      id: city.id,
      cityId: city.id,
      employees: [employee],
    );
    final session = await _readySession(
      PlayerState.initial.copyWith(
        companyLevel: 3,
        companyFunds: 10000,
        branches: [branch],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(
          child: CompanyBranchesPage(session: session),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final managerChip = find.byKey(
      ValueKey('branch-manager-${city.id}-${employee.id}'),
    );
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(managerChip);
    await tester.pumpAndSettle();
    expect(session.state.branches.single.managerEmployeeId, employee.id);

    await tester.pump(const Duration(seconds: 4));
    final goalChip = find.byKey(
      ValueKey(
        'branch-goal-${city.id}-${CompanyBranchLocalGoal.teamDevelopment.name}',
      ),
    );
    await tester.drag(scrollable, const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(goalChip);
    await tester.pumpAndSettle();
    expect(
      session.state.branches.single.localGoal,
      CompanyBranchLocalGoal.teamDevelopment,
    );

    await tester.pump(const Duration(seconds: 4));
    final specialtyChip = find.byKey(
      ValueKey(
        'branch-specialty-${city.id}-${CompanySpecialty.finance.name}',
      ),
    );
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(specialtyChip);
    await tester.pumpAndSettle();
    expect(
      session.state.branches.single.specialty,
      CompanySpecialty.finance,
    );
    session.dispose();
  });

  testWidgets('standard projects stay open while invited project stays locked', (
    tester,
  ) async {
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
      find.text('Şirket yol haritası'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Yerel girişim'), findsWidgets);
    expect(find.text('Bölgesel şirket'), findsOneWidget);
    expect(find.text('Ulusal marka'), findsOneWidget);
    expect(find.text('Holding'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Kurumsal çözüm'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Orta sözleşme'), findsWidgets);
    expect(find.text('Kurumsal şirket'), findsWidgets);
    expect(find.textContaining('gün teslim'), findsWidgets);
    expect(find.textContaining('gecikme riski'), findsWidgets);
    expect(find.textContaining('kalite'), findsWidgets);
    expect(find.textContaining('başarı'), findsWidgets);
    expect(find.textContaining('uzmanlığı'), findsWidgets);
    await tester.ensureVisible(find.text('Kurumsal çözüm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kurumsal çözüm'));
    await tester.pumpAndSettle();

    expect(session.state.activeProjectId, 3);
    await tester.scrollUntilVisible(
      find.text('Özel dönüşüm ortaklığı'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sezon daveti gerekli'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Piyasa ve rekabet'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Piyasa ve rekabet'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('30 günlük rekabet sezonu'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Senin şirketin'), findsOneWidget);
    expect(find.text('Atlas Global'), findsWidgets);
    session.dispose();
  });

  testWidgets('company project team assignment updates the active project', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final employee = CompanyEmployeeCatalog.candidates.first;
    final session = await _readySession(
      PlayerState.initial.copyWith(
        companyLevel: 1,
        companyFunds: 500,
        employeeCount: 1,
        employees: [employee],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    final checkbox = find.byKey(
      ValueKey('project-team-checkbox-${employee.id}'),
    );
    await tester.scrollUntilVisible(
      checkbox,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);

    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect(session.state.companyProjectTeams.isConfigured(1), isTrue);
    expect(session.state.companyProjectTeams.employeeIdsFor(1), isEmpty);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    expect(find.text('0 çalışan'), findsOneWidget);
    session.dispose();
  });

  testWidgets('company employee can be developed from the team card', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final employee = CompanyEmployeeCatalog.candidates.first.copyWith(
      requestedDailySalary: 35,
    );
    final cost = CompanyEmployeeDevelopmentService.developmentCost(employee);
    final session = await _readySession(
      PlayerState.initial.copyWith(
        companyLevel: 1,
        companyFunds: cost + 100,
        employeeCount: 1,
        employees: [employee],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();
    final action = find.text('Kasa ₺$cost');
    await tester.scrollUntilVisible(
      action,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    expect(find.textContaining('Moral %70'), findsWidgets);
    expect(find.textContaining('Başlangıç'), findsWidgets);
    expect(find.textContaining('Deneyim 0'), findsWidgets);
    expect(find.textContaining('Tükenmişlik %0'), findsWidgets);
    expect(find.textContaining('Görev uyumu'), findsWidgets);
    expect(find.textContaining('Zam talebi: ₺35/gün'), findsOneWidget);
    expect(find.text('Kabul'), findsOneWidget);
    expect(find.text('Reddet'), findsOneWidget);
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(
      session.state.employees.single.performance,
      employee.performance + CompanyEmployeeDevelopmentService.performanceGain,
    );
    expect(session.state.companyFunds, 100);
    session.dispose();
  });

  testWidgets('eligible company acquisition requires confirmation', (
    tester,
  ) async {
    final deal = CompanyExpansionService.deals.first;
    final session = await _readySession(
      PlayerState.initial.copyWith(
        companyLevel: 3,
        companyStageIndex: 1,
        companyFunds: deal.cost + 250,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    final action = find.byKey(ValueKey('complete-company-deal-${deal.id}'));
    await tester.scrollUntilVisible(
      action,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(find.textContaining('geri alınamaz'), findsOneWidget);
    await tester.tap(find.text('İşlemi tamamla'));
    await tester.pumpAndSettle();

    expect(session.state.companyFunds, 250);
    expect(session.state.companyExpansion.hasCompleted(deal.id), isTrue);
    expect(
      session.state.financeLedger.entries.last.category,
      FinanceCategory.companyExpansion,
    );
    session.dispose();
  });

  testWidgets('company page shows trophy history and unlocked benefits', (
    tester,
  ) async {
    final session = await _readySession(
      PlayerState.initial.copyWith(
        companyLevel: 3,
        companyCompetition: const CompanyCompetitionState(
          championships: 1,
          trophies: [
            CompanySeasonTrophy(seasonNumber: 1, points: 84, reward: 6000),
          ],
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('Kupa geçmişi ve avantajlar');
    await tester.scrollUntilVisible(
      title,
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(title);
    await tester.pumpAndSettle();

    expect(title, findsOneWidget);
    expect(find.text('Proje güvencesi'), findsOneWidget);
    expect(find.text('1. sezon şampiyonluğu'), findsOneWidget);
    expect(find.text('84 puan · +₺6000'), findsOneWidget);
    session.dispose();
  });

  testWidgets('company strategy selection is confirmed and season locked', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = await _readySession(
      PlayerState.initial.copyWith(
        day: 7,
        companyLevel: 1,
        companyFunds: 10000,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: CompanyPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    final section = find.text('Rekabet stratejisi');
    await tester.scrollUntilVisible(
      section,
      700,
      scrollable: find.byType(Scrollable).first,
    );
    final action = find.byKey(
      const ValueKey('select-company-strategy-price_leadership'),
    );
    await tester.scrollUntilVisible(
      action,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(find.text('Fiyat liderliği'), findsWidgets);
    expect(find.textContaining('değiştirilemez'), findsWidgets);
    await tester.tap(find.text('Stratejiyi seç'));
    await tester.pumpAndSettle();

    expect(session.state.companyCompetition.strategyId, 'price_leadership');
    expect(find.text('Seçildi · sezon sonuna kadar kilitli'), findsOneWidget);
    session.dispose();
  });

  testWidgets('progress page shows an open-ended career score target', (
    tester,
  ) async {
    final session = await _readySession(
      PlayerState.initial.copyWith(
        totalWorkSessions: 12,
        totalTrainingSessions: 4,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppGradientBackground(child: ProgressPage(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Devam eden kariyer özeti'), findsOneWidget);
    expect(find.byKey(const ValueKey('career-score-total')), findsOneWidget);
    expect(find.text('Bitiş yok · Prestij devam eder'), findsOneWidget);
    expect(find.text('Sıradaki puan hedefleri'), findsOneWidget);
    expect(find.text('Çalışma serisi'), findsOneWidget);
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
