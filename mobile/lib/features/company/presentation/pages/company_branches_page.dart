import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feature_error_view.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_branch.dart';
import '../../domain/entities/company_employee.dart';
import '../../domain/services/company_branch_service.dart';
import '../models/employee_candidate_filter.dart';
import '../widgets/employee_filter_bar.dart';

class CompanyBranchesPage extends StatelessWidget {
  const CompanyBranchesPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Bayiler',
      subtitle: 'Şirketini şehir şehir büyüt',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          try {
            final branches = session.state.branches;
            final branchCities = branches
                .map((branch) => branch.cityId)
                .toSet();
            final availableCities = CityCatalog.cities
                .where((city) => !branchCities.contains(city.id))
                .toList(growable: false);
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _Header(
                  branches: branches.length,
                  funds: session.state.companyFunds,
                ),
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
    final cost = CompanyBranchService.openingCost(city);
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
                  'Nüfus ${city.population} · Pazar ${city.marketLevel} · ₺$cost',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
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
            child: const Text('Aç'),
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
            '${branch.employees.length}/$capacity çalışan · +₺${service.dailyRevenue(branch)} gelir · -₺${service.dailyPayroll(branch)} maaş',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 12,
            ),
          ),
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
                '${employee.role} · %${employee.performance} performans · ₺${employee.dailySalary}/gün',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: session.isBusy ? null : () => _dismiss(context),
          icon: const Icon(Icons.person_remove_outlined, size: 18),
          color: AppPalette.textMuted,
        ),
      ],
    );
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
                '${employee.role} · %${employee.performance} performans · ₺${employee.dailySalary}/gün',
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
