import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_employee.dart';
import '../../domain/entities/company_project.dart';
import '../../domain/entities/company_specialty.dart';
import '../../domain/services/company_project_catalog.dart';
import '../../domain/services/company_service.dart';
import '../models/employee_candidate_filter.dart';
import '../widgets/employee_filter_bar.dart';
import '../widgets/company_growth_panel.dart';
import '../widgets/company_market_panel.dart';
import '../widgets/company_season_event_panel.dart';
import '../widgets/company_rival_profiles_panel.dart';
import '../widgets/company_strategy_panel.dart';
import '../widgets/company_season_reward_panel.dart';
import '../widgets/company_competition_panel.dart';
import '../widgets/company_stage_panel.dart';
import '../widgets/company_expansion_panel.dart';
import '../widgets/company_treasury_panel.dart';
import '../widgets/company_trophy_panel.dart';
import 'company_branches_page.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Şirketim',
      subtitle: 'Kendi işini kur, sistemini büyüt',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) => session.state.companyLevel == 0
            ? _EstablishmentView(
                session: session,
                check: session.checkCompanyEstablishment(),
              )
            : _CompanyView(session: session),
      ),
    );
  }
}

class _EstablishmentView extends StatelessWidget {
  const _EstablishmentView({required this.session, required this.check});

  final GameSessionController session;
  final CompanyCheck check;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        AppInfoCard(
          accent: AppPalette.tertiary,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppPalette.tertiary.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppPalette.tertiary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'İlk şirketini kur',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kariyer yolculuğunun bir sonraki aşaması kendi sistemini kurmak. Sermayeni ve tecrübeni doğru zamanda kullan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              const AppPill(
                label: 'Kişisel cüzdan · ₺${CompanyService.establishmentCost}',
                color: AppPalette.tertiary,
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 14),
              Text(
                check.reason,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: check.isEligible
                      ? AppPalette.success
                      : AppPalette.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: check.isEligible && !session.isBusy
                      ? () => _establish(context)
                      : null,
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Kişisel cüzdandan şirketimi kur'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const AppSectionHeader(
          title: 'Şirket yol haritası',
          caption: 'Kurulumdan bayilere uzanan büyüme planı.',
        ),
        const SizedBox(height: 12),
        const _RoadmapStep(
          number: '01',
          title: 'Şirketi kur',
          description: 'İlk sermayeni operasyon bütçesine dönüştür.',
        ),
        const _RoadmapStep(
          number: '02',
          title: 'Proje seç',
          description: 'Şirketinin odaklanacağı projeyi belirle.',
        ),
        const _RoadmapStep(
          number: '03',
          title: 'Ekip kur',
          description: 'Doğru çalışanlarla kapasiteni artır.',
        ),
      ],
    );
  }

  Future<void> _establish(BuildContext context) async {
    final message = await session.establishCompany();
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _RoadmapStep extends StatelessWidget {
  const _RoadmapStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppPalette.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppPalette.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyView extends StatefulWidget {
  const _CompanyView({required this.session});

  final GameSessionController session;

  @override
  State<_CompanyView> createState() => _CompanyViewState();
}

class _CompanyViewState extends State<_CompanyView> {
  EmployeeCandidateFilter _candidateFilter = EmployeeCandidateFilter.all;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final state = session.state;
    final service = CompanyService();
    final employees = CompanyService.employeesFor(state);
    final allCandidates = service.availableEmployees(state);
    final candidates = filterEmployeeCandidates(
      allCandidates,
      _candidateFilter,
    );
    final capacity = CompanyService.employeeCapacity(state.companyLevel);
    final project = CompanyProjectCatalog.byId(state.activeProjectId);
    final forecast = service.projectForecast(state, project);
    final lastOutcome = state.lastProjectOutcome;
    final lastProject = lastOutcome == null
        ? null
        : CompanyProjectCatalog.byId(lastOutcome.projectId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        AppInfoCard(
          accent: AppPalette.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppPalette.primary.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      color: AppPalette.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Operasyon merkezi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Seviye ${state.companyLevel} · ${employees.length}/$capacity çalışan',
                          style: const TextStyle(
                            color: AppPalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppPill(
                    label: 'Şirket kasası · ₺${state.companyFunds}',
                    color: AppPalette.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                project.name,
                style: const TextStyle(
                  color: AppPalette.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              AppProgressLine(
                value: state.projectProgress / 100,
                color: AppPalette.primary,
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    '%${state.projectProgress} tamamlandı',
                    style: const TextStyle(
                      color: AppPalette.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Şirket kasasına ₺${project.reward} ödül',
                    style: const TextStyle(
                      color: AppPalette.tertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppPill(
                    label: 'Kasaya +₺${service.dailyRevenue(state)}/gün gelir',
                    color: AppPalette.primary,
                  ),
                  AppPill(
                    label: 'Kasadan -₺${service.dailyPayroll(state)}/gün maaş',
                    color: AppPalette.warning,
                  ),
                  AppPill(
                    label: '+${service.dailyProjectProgress(state)} proje/gün',
                    color: AppPalette.secondary,
                  ),
                  AppPill(
                    label: '%${forecast.successChance} başarı',
                    color: forecast.successChance >= 70
                        ? AppPalette.success
                        : AppPalette.warning,
                  ),
                  AppPill(
                    label: forecast.estimatedDays == 0
                        ? 'Ekip gerekli'
                        : '~${forecast.estimatedDays} gün',
                  ),
                  AppPill(label: 'Müşteri · ${project.customerType.label}'),
                  AppPill(
                    label:
                        'Teslim · ${state.projectElapsedDays}/${project.deliveryDays} gün',
                    color: state.projectElapsedDays > project.deliveryDays
                        ? AppPalette.warning
                        : AppPalette.secondary,
                  ),
                  AppPill(
                    label: '%${forecast.delayChance} gecikme riski',
                    color: forecast.delayChance <= 25
                        ? AppPalette.success
                        : AppPalette.warning,
                  ),
                  AppPill(
                    label:
                        'Beklenen kalite · ${forecast.expectedQuality.label}',
                    color: AppPalette.tertiary,
                  ),
                ],
              ),
              if (lastOutcome != null && lastProject != null) ...[
                const SizedBox(height: 13),
                Text(
                  'Son sonuç · ${lastProject.name} · ${lastOutcome.quality.label} kalite · '
                  '${lastOutcome.delayed ? 'Gecikmeli' : 'Zamanında'}',
                  style: TextStyle(
                    color: lastOutcome.succeeded
                        ? AppPalette.success
                        : AppPalette.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        CompanyTreasuryPanel(session: session),
        const SizedBox(height: 12),
        Row(
          children: [
            if (state.companyLevel < CompanyService.maxCompanyLevel) ...[
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed:
                      session.checkCompanyUpgrade().isEligible &&
                          !session.isBusy
                      ? () => _upgrade(context)
                      : null,
                  icon: const Icon(Icons.trending_up_rounded, size: 18),
                  label: Text(
                    'Kasa · ₺${CompanyService.upgradeCost(state.companyLevel)}',
                  ),
                ),
              ),
              const SizedBox(width: 9),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: session.isBusy
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CompanyBranchesPage(session: session),
                        ),
                      ),
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text('Bayiler'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        CompanyStagePanel(state: state),
        const SizedBox(height: 25),
        CompanyExpansionPanel(session: session),
        const SizedBox(height: 25),
        const AppSectionHeader(
          title: 'Proje portföyü',
          caption: 'Şirketinin bir sonraki büyüme hamlesini seç.',
        ),
        const SizedBox(height: 12),
        for (final category in CompanyProjectCategory.values) ...[
          AppSectionHeader(
            title: category.label,
            caption:
                '${CompanyProjectCatalog.projects.where((item) => item.category == category).length} proje',
          ),
          const SizedBox(height: 8),
          for (final item in CompanyProjectCatalog.projects.where(
            (item) => item.category == category,
          )) ...[
            _ProjectCard(project: item, session: session),
            const SizedBox(height: 9),
          ],
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 17),
        CompanyGrowthPanel(state: state),
        const SizedBox(height: 25),
        CompanyMarketPanel(state: state),
        const SizedBox(height: 25),
        CompanySeasonEventPanel(state: state),
        const SizedBox(height: 25),
        CompanyRivalProfilesPanel(state: state),
        const SizedBox(height: 25),
        CompanyStrategyPanel(session: session),
        const SizedBox(height: 25),
        CompanyCompetitionPanel(state: state),
        const SizedBox(height: 25),
        CompanySeasonRewardPanel(state: state),
        const SizedBox(height: 25),
        CompanyTrophyPanel(state: state),
        const SizedBox(height: 25),
        AppSectionHeader(
          title: 'Ekip',
          caption: '${employees.length}/$capacity kapasite dolu',
        ),
        const SizedBox(height: 12),
        for (final employee in employees) ...[
          _EmployeeCard(employee: employee, session: session),
          const SizedBox(height: 9),
        ],
        if (employees.length < capacity && candidates.isNotEmpty) ...[
          const SizedBox(height: 10),
          const AppSectionHeader(
            title: 'Aday havuzu',
            caption: 'Ekibine katabileceğin kişiler',
          ),
          const SizedBox(height: 12),
          EmployeeFilterBar(
            value: _candidateFilter,
            onChanged: (filter) => setState(() => _candidateFilter = filter),
          ),
          const SizedBox(height: 9),
          Text(
            '${candidates.length}/${allCandidates.length} aday gösteriliyor',
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          for (final employee in candidates) ...[
            _CandidateCard(employee: employee, session: session),
            const SizedBox(height: 9),
          ],
        ],
      ],
    );
  }

  Future<void> _upgrade(BuildContext context) async {
    final message = await widget.session.upgradeCompany();
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.session});

  final CompanyProject project;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final service = CompanyService();
    final forecast = service.projectForecast(state, project);
    final check = service.checkProjectSelection(state, project);
    final selected = state.activeProjectId == project.id;
    final selectable = !selected && check.isEligible && !session.isBusy;
    final accent = selected
        ? AppPalette.primary
        : check.isEligible
        ? AppPalette.outline
        : AppPalette.warning;
    return AppInfoCard(
      accent: accent,
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: selectable ? () => _select(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                selected
                    ? Icons.check_rounded
                    : !check.isEligible
                    ? Icons.lock_outline_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppPalette.primary : AppPalette.textMuted,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${project.description} · Şirket kasası: -₺${project.cost} / +₺${project.reward}',
                    style: const TextStyle(
                      color: AppPalette.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      AppPill(label: project.category.label),
                      AppPill(label: project.customerType.label),
                      AppPill(label: '${project.specialty.label} uzmanlığı'),
                      AppPill(
                        label: '%${forecast.successChance} başarı',
                        color: forecast.successChance >= 70
                            ? AppPalette.success
                            : AppPalette.warning,
                      ),
                      AppPill(
                        label: forecast.estimatedDays == 0
                            ? 'Ekip gerekli'
                            : '~${forecast.estimatedDays} gün',
                      ),
                      AppPill(label: '${project.deliveryDays} gün teslim'),
                      AppPill(
                        label: '%${forecast.delayChance} gecikme riski',
                        color: forecast.delayChance <= 25
                            ? AppPalette.success
                            : AppPalette.warning,
                      ),
                      AppPill(
                        label: '${forecast.expectedQuality.label} kalite',
                        color: AppPalette.tertiary,
                      ),
                      AppPill(
                        label:
                            'Önerilen seviye ${project.recommendedCompanyLevel}',
                      ),
                      if (project.requiresSeasonInvitation)
                        AppPill(
                          label: check.isEligible
                              ? 'Davet hazır'
                              : 'Sezon daveti gerekli',
                          icon: Icons.mark_email_unread_outlined,
                          color: check.isEligible
                              ? AppPalette.secondary
                              : AppPalette.warning,
                        ),
                    ],
                  ),
                  if (!check.isEligible) ...[
                    const SizedBox(height: 7),
                    Text(
                      check.reason,
                      style: const TextStyle(
                        color: AppPalette.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(BuildContext context) async {
    if (session.state.projectProgress > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Projeyi değiştir'),
          content: const Text(
            'Mevcut proje ilerlemesi sıfırlanacak. Devam edilsin mi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Projeyi değiştir'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    final message = await session.selectCompanyProject(project);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee, required this.session});

  final CompanyEmployee employee;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final development = session.checkEmployeeDevelopment(employee.id);
    final promotion = session.checkEmployeePromotion(employee.id);
    final project = CompanyProjectCatalog.byId(session.state.activeProjectId);
    return _PersonCard(
      employee: employee,
      action: 'Çıkar',
      onAction: session.isBusy ? null : () => _dismiss(context),
      accent: AppPalette.primary,
      developmentCost: development.cost,
      developmentReason: development.reason,
      onDevelop: development.isEligible && !session.isBusy
          ? () => _develop(context)
          : null,
      jobFitPercent: employee.jobFitPercentFor(project.specialty),
      promotionCost: promotion.cost,
      promotionReason: promotion.reason,
      onPromote: promotion.isEligible && !session.isBusy
          ? () => _promote(context)
          : null,
      onRaiseAccept: employee.hasRaiseRequest && !session.isBusy
          ? () => _respondToRaise(context, accept: true)
          : null,
      onRaiseReject: employee.hasRaiseRequest && !session.isBusy
          ? () => _respondToRaise(context, accept: false)
          : null,
    );
  }

  Future<void> _develop(BuildContext context) async {
    final message = await session.developEmployee(employee.id);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _promote(BuildContext context) async {
    final message = await session.promoteEmployee(employee.id);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _respondToRaise(
    BuildContext context, {
    required bool accept,
  }) async {
    final message = await session.respondToEmployeeRaise(
      employee.id,
      accept: accept,
    );
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _dismiss(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çalışanı ekipten çıkar'),
        content: Text('${employee.name} şirketten çıkarılacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final message = await session.dismissEmployee(employee.id);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.employee, required this.session});

  final CompanyEmployee employee;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final project = CompanyProjectCatalog.byId(session.state.activeProjectId);
    return _PersonCard(
      employee: employee,
      action: 'İşe al',
      onAction: session.isBusy ? null : () => _hire(context),
      accent: AppPalette.secondary,
      jobFitPercent: employee.jobFitPercentFor(project.specialty),
    );
  }

  Future<void> _hire(BuildContext context) async {
    final message = await session.recruitEmployee(employee);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.employee,
    required this.action,
    required this.onAction,
    required this.accent,
    this.developmentCost,
    this.developmentReason,
    this.onDevelop,
    this.jobFitPercent,
    this.promotionCost,
    this.promotionReason,
    this.onPromote,
    this.onRaiseAccept,
    this.onRaiseReject,
  });

  final CompanyEmployee employee;
  final String action;
  final VoidCallback? onAction;
  final Color accent;
  final int? developmentCost;
  final String? developmentReason;
  final VoidCallback? onDevelop;
  final int? jobFitPercent;
  final int? promotionCost;
  final String? promotionReason;
  final VoidCallback? onPromote;
  final VoidCallback? onRaiseAccept;
  final VoidCallback? onRaiseReject;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      accent: accent,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person_rounded, color: accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${employee.role} · ${employee.specialty.label} · ₺${employee.dailySalary}/gün',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Moral %${employee.morale} · Sadakat %${employee.loyalty} · '
                  'Etkin güç %${employee.effectivePerformance}',
                  style: const TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${employee.seniority.label} · Deneyim ${employee.experience} · '
                  'Tükenmişlik %${employee.burnout}'
                  '${jobFitPercent == null ? '' : ' · Görev uyumu %$jobFitPercent'}',
                  style: TextStyle(
                    color: employee.burnout >= 80
                        ? AppPalette.warning
                        : AppPalette.textSecondary,
                    fontSize: 10,
                    fontWeight: employee.burnout >= 80
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 7),
                AppProgressLine(
                  value: employee.performance / 100,
                  color: accent,
                ),
                if (employee.requestedDailySalary case final requested?) ...[
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Zam talebi: ₺$requested/gün',
                        style: const TextStyle(
                          color: AppPalette.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: onRaiseAccept,
                        child: const Text('Kabul'),
                      ),
                      TextButton(
                        onPressed: onRaiseReject,
                        child: const Text('Reddet'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '%${employee.performance}',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              if (developmentCost != null)
                Tooltip(
                  message: developmentReason ?? '',
                  child: TextButton(
                    onPressed: onDevelop,
                    child: Text(
                      employee.isFullyDeveloped
                          ? 'Maksimum'
                          : 'Kasa ₺$developmentCost',
                    ),
                  ),
                ),
              if (promotionCost != null)
                Tooltip(
                  message: promotionReason ?? '',
                  child: TextButton(
                    onPressed: onPromote,
                    child: Text(
                      employee.seniority.next == null
                          ? 'Son kıdem'
                          : 'Terfi ₺$promotionCost',
                    ),
                  ),
                ),
              TextButton(onPressed: onAction, child: Text(action)),
            ],
          ),
        ],
      ),
    );
  }
}
