import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feature_error_view.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../economy/domain/services/investment_return_service.dart';
import '../../domain/entities/company_branch.dart';
import '../../domain/entities/company_employee.dart';
import '../../domain/entities/company_specialty.dart';
import '../../domain/entities/company_region.dart';
import '../../domain/services/company_branch_service.dart';
import '../../domain/services/company_region_service.dart';
import '../models/employee_candidate_filter.dart';
import '../widgets/employee_filter_bar.dart';
import '../widgets/company_region_panel.dart';
import '../widgets/company_branch_management_panel.dart';

class CompanyBranchesPage extends StatelessWidget {
  const CompanyBranchesPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Bayiler',
      subtitle: 'Stratejik bölgelerde hâkimiyet kur',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          try {
            final branches = session.state.branches;
            final branchCities = branches
                .map((branch) => branch.cityId)
                .toSet();
            final regionService = CompanyRegionService();
            final regionProgress = {
              for (final progress in regionService.allProgress(session.state))
                progress.definition.region: progress,
            };
            final availableCities = CityCatalog.cities
                .where((city) => !branchCities.contains(city.id))
                .toList();
            availableCities.sort((left, right) {
              final leftRegion = regionService.definitionForCity(left)!;
              final rightRegion = regionService.definitionForCity(right)!;
              final leftProgress = regionProgress[leftRegion.region]!;
              final rightProgress = regionProgress[rightRegion.region]!;
              final leftPriority = leftProgress.isControlled
                  ? -1
                  : leftProgress.influence;
              final rightPriority = rightProgress.isControlled
                  ? -1
                  : rightProgress.influence;
              final influenceOrder = rightPriority.compareTo(leftPriority);
              return influenceOrder != 0
                  ? influenceOrder
                  : right.marketLevel.compareTo(left.marketLevel);
            });
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _Header(
                  branches: branches.length,
                  funds: session.state.companyFunds,
                ),
                const SizedBox(height: 25),
                CompanyRegionPanel(state: session.state),
                const SizedBox(height: 25),
                if (branches.isNotEmpty) ...[
                  const AppSectionHeader(
                    title: 'Aktif bayiler',
                    caption: 'Gelir ve ekip durumunu takip et.',
                  ),
                  const SizedBox(height: 12),
                  for (final branch in branches) ...[
                    _BranchCard(branch: branch, session: session),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 17),
                ],
                const AppSectionHeader(
                  title: 'Yeni bayi aç',
                  caption: 'Şirketini yeni bir şehre taşı.',
                ),
                const SizedBox(height: 12),
                for (final city in availableCities) ...[
                  _CityBranchCard(city: city, session: session),
                  const SizedBox(height: 10),
                ],
              ],
            );
          } on Object {
            return const FeatureErrorView(title: 'Bayi bilgileri okunamadı.');
          }
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.branches, required this.funds});

  final int branches;
  final int funds;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      accent: AppPalette.primary,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppPalette.primary.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppPalette.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Şirket kasası',
                  style: TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '₺$funds',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$branches aktif bayi · Her biri ayrı bir pazar',
                  style: const TextStyle(
                    color: AppPalette.textSecondary,
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

class _CityBranchCard extends StatelessWidget {
  const _CityBranchCard({required this.city, required this.session});

  final City city;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final check = session.checkBranchOpen(city);
    final branchService = CompanyBranchService();
    final cost = branchService.openingCostFor(session.state, city);
    final regionService = CompanyRegionService();
    final region = regionService.definitionForCity(city)!;
    final regionProgress = regionService.progress(session.state, region);
    return AppInfoCard(
      accent: check.isEligible ? AppPalette.secondary : AppPalette.outline,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppPalette.secondary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_city_rounded,
              color: AppPalette.secondary,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nüfus ${city.population} · Pazar ${city.marketLevel} · Şirket kasası ₺$cost\n'
                  'Hedef geri dönüş · ${InvestmentReturnService.target(InvestmentType.branch).label}',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${region.name} · Etki ${regionProgress.influence}/${CompanyRegionProgress.controlTarget} · ${region.advantage}',
                  style: const TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  check.reason,
                  style: TextStyle(
                    color: check.isEligible
                        ? AppPalette.success
                        : AppPalette.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: check.isEligible && !session.isBusy
                ? () => _open(context)
                : null,
            child: Text('Aç · ₺$cost'),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final message = await session.openBranch(city);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _BranchCard extends StatefulWidget {
  const _BranchCard({required this.branch, required this.session});

  final CompanyBranch branch;
  final GameSessionController session;

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  EmployeeCandidateFilter _candidateFilter = EmployeeCandidateFilter.all;

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
    final session = widget.session;
    final city = CityCatalog.findById(branch.cityId);
    final allCandidates = session.branchCandidates(branch);
    final candidates = filterEmployeeCandidates(
      allCandidates,
      _candidateFilter,
    );
    final capacity = CompanyBranchService.employeeCapacity(branch);
    final service = CompanyBranchService();
    final upgradeCheck = session.checkBranchUpgrade(branch.cityId);
    final upgradeCost = service.upgradeCostFor(session.state, branch);
    final specialty = city == null
        ? CompanySpecialty.operations
        : branch.specialty ?? CompanyBranchService.preferredSpecialty(city);
    return AppInfoCard(
      accent: AppPalette.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  city?.name ?? 'Bilinmeyen şehir',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppPill(
                label: 'Seviye ${branch.level}',
                color: AppPalette.primary,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${branch.employees.length}/$capacity çalışan · +₺${service.dailyRevenueFor(session.state, branch)} gelir · -₺${service.dailyPayrollFor(session.state, branch)} maaş',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppPill(
                label:
                    '${specialty.label} odağı · uzman +₺${CompanyBranchService.specialistDailyRevenueBonus}',
                color: AppPalette.secondary,
              ),
              if (branch.level < CompanyBranchService.maxBranchLevel)
                OutlinedButton.icon(
                  onPressed: upgradeCheck.isEligible && !session.isBusy
                      ? () => _upgrade(context)
                      : null,
                  icon: const Icon(Icons.upgrade_rounded, size: 17),
                  label: Text('Yükselt · Kasa ₺$upgradeCost'),
                ),
              if (branch.level < CompanyBranchService.maxBranchLevel)
                AppPill(
                  label:
                      'Hedef ${InvestmentReturnService.target(InvestmentType.branch).label}',
                  color: AppPalette.success,
                  icon: Icons.savings_outlined,
                ),
            ],
          ),
          if (!upgradeCheck.isEligible &&
              branch.level < CompanyBranchService.maxBranchLevel) ...[
            const SizedBox(height: 5),
            Text(
              upgradeCheck.reason,
              style: const TextStyle(color: AppPalette.textMuted, fontSize: 10),
            ),
          ],
          const SizedBox(height: 14),
          CompanyBranchManagementPanel(branch: branch, session: session),
          const Divider(height: 22),
          for (final employee in branch.employees) ...[
            _BranchEmployeeTile(
              employee: employee,
              cityId: branch.cityId,
              session: session,
            ),
            const SizedBox(height: 8),
          ],
          if (branch.employees.length < capacity && candidates.isNotEmpty) ...[
            const SizedBox(height: 7),
            const Text(
              'Bayi adayları',
              style: TextStyle(
                color: AppPalette.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 6),
            EmployeeFilterBar(
              value: _candidateFilter,
              onChanged: (filter) => setState(() => _candidateFilter = filter),
            ),
            const SizedBox(height: 8),
            Text(
              '${candidates.length}/${allCandidates.length} aday gösteriliyor',
              style: const TextStyle(color: AppPalette.textMuted, fontSize: 10),
            ),
            const SizedBox(height: 5),
            for (final candidate in candidates)
              _BranchCandidateTile(
                employee: candidate,
                cityId: branch.cityId,
                session: session,
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _upgrade(BuildContext context) async {
    final message = await widget.session.upgradeBranch(widget.branch.cityId);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _BranchEmployeeTile extends StatelessWidget {
  const _BranchEmployeeTile({
    required this.employee,
    required this.cityId,
    required this.session,
  });

  final CompanyEmployee employee;
  final int cityId;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final development = session.checkBranchEmployeeDevelopment(
      cityId,
      employee.id,
    );
    final promotion = session.checkBranchEmployeePromotion(cityId, employee.id);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppPalette.primary.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppPalette.primary,
            size: 17,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${employee.role} · ${employee.specialty.label} · %${employee.performance} · ₺${employee.dailySalary}/gün',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 3),
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
                'Tükenmişlik %${employee.burnout}',
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
              if (employee.requestedDailySalary case final requested?) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Zam: ₺$requested/gün',
                      style: const TextStyle(
                        color: AppPalette.warning,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: session.isBusy
                          ? null
                          : () => _respondToRaise(context, accept: true),
                      child: const Text('Kabul'),
                    ),
                    TextButton(
                      onPressed: session.isBusy
                          ? null
                          : () => _respondToRaise(context, accept: false),
                      child: const Text('Reddet'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: development.reason,
          onPressed: development.isEligible && !session.isBusy
              ? () => _develop(context)
              : null,
          icon: const Icon(Icons.school_outlined, size: 18),
          color: AppPalette.secondary,
        ),
        IconButton(
          tooltip: promotion.reason,
          onPressed: promotion.isEligible && !session.isBusy
              ? () => _promote(context)
              : null,
          icon: const Icon(Icons.workspace_premium_outlined, size: 18),
          color: AppPalette.tertiary,
        ),
        IconButton(
          onPressed: session.isBusy ? null : () => _dismiss(context),
          icon: const Icon(Icons.person_remove_outlined, size: 18),
          color: AppPalette.textMuted,
        ),
      ],
    );
  }

  Future<void> _develop(BuildContext context) async {
    final message = await session.developBranchEmployee(cityId, employee.id);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _promote(BuildContext context) async {
    final message = await session.promoteBranchEmployee(cityId, employee.id);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _respondToRaise(
    BuildContext context, {
    required bool accept,
  }) async {
    final message = await session.respondToBranchEmployeeRaise(
      cityId,
      employee.id,
      accept: accept,
    );
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _dismiss(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bayi çalışanını çıkar'),
        content: Text('${employee.name} bu bayiden çıkarılacak.'),
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
    final message = await session.dismissBranchEmployee(cityId, employee.id);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _BranchCandidateTile extends StatelessWidget {
  const _BranchCandidateTile({
    required this.employee,
    required this.cityId,
    required this.session,
  });

  final CompanyEmployee employee;
  final int cityId;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppPalette.secondary.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: AppPalette.secondary,
            size: 17,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${employee.role} · ${employee.specialty.label} · %${employee.performance} · ₺${employee.dailySalary}/gün',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: session.isBusy ? null : () => _hire(context),
          child: const Text('İşe al'),
        ),
      ],
    );
  }

  Future<void> _hire(BuildContext context) async {
    final message = await session.recruitBranchEmployee(cityId, employee);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}
