import 'package:flutter/material.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/feature_error_view.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_branch.dart';
import '../../domain/entities/company_employee.dart';
import '../../domain/services/company_branch_service.dart';

class CompanyBranchesPage extends StatelessWidget {
  const CompanyBranchesPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şehir bayileri')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            try {
              final branches = session.state.branches;
              final branchCities = branches.map((branch) => branch.cityId).toSet();
              final availableCities = CityCatalog.cities.where((city) => !branchCities.contains(city.id)).toList(growable: false);
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(child: _BranchHeader(session: session)),
                  ),
                  if (branches.isNotEmpty) ...[
                    const SliverPadding(padding: EdgeInsets.only(top: 20), sliver: SliverToBoxAdapter(child: _SectionTitle('Aktif bayiler'))),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _BranchCard(branch: branches[index], session: session), childCount: branches.length)),
                    ),
                  ],
                  const SliverPadding(padding: EdgeInsets.only(top: 20), sliver: SliverToBoxAdapter(child: _SectionTitle('Yeni bayi aç'))),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _CityBranchCard(city: availableCities[index], session: session), childCount: availableCities.length)),
                  ),
                ],
              );
            } on Object {
              return const FeatureErrorView(title: 'Bayi bilgileri okunamadı.');
            }
          },
        ),
      ),
    );
  }
}

class _BranchHeader extends StatelessWidget {
  const _BranchHeader({required this.session});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Şirket kasası: ₺${session.state.companyFunds}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Bayiler şehir pazarından gelir üretir; çalışan maaşları şirket kasasından ödenir.'),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      );
}

class _CityBranchCard extends StatelessWidget {
  const _CityBranchCard({required this.city, required this.session});

  final City city;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final check = session.checkBranchOpen(city);
    final cost = CompanyBranchService.openingCost(city);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(city.name),
        subtitle: Text('Nüfus: ${city.population} · Pazar: ${city.marketLevel} · Açılış: ₺$cost\n${check.reason}'),
        isThreeLine: true,
        trailing: SizedBox(
          width: 68,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44), padding: const EdgeInsets.symmetric(horizontal: 6)),
            onPressed: check.isEligible && !session.isBusy ? () => _open(context) : null,
            child: const Text('Aç'),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final message = await session.openBranch(city);
    if (!context.mounted || message == null) return;
    AppFeedback.show(context, message);
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.session});

  final CompanyBranch branch;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final city = CityCatalog.findById(branch.cityId);
    final candidates = session.branchCandidates(branch);
    final capacity = CompanyBranchService.employeeCapacity(branch);
    final service = CompanyBranchService();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city?.name ?? 'Bilinmeyen şehir', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            Text('Seviye ${branch.level} · Çalışan ${branch.employees.length}/$capacity'),
            const SizedBox(height: 6),
            Text('Günlük gelir: ₺${service.dailyRevenue(branch)} · Maaş: ₺${service.dailyPayroll(branch)}'),
            const Divider(height: 20),
            for (final employee in branch.employees) _BranchEmployeeTile(employee: employee, cityId: branch.cityId, session: session),
            if (branch.employees.length < capacity && candidates.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text('Bayi adayları', style: TextStyle(fontWeight: FontWeight.w800)),
              for (final candidate in candidates.take(6)) _BranchCandidateTile(employee: candidate, cityId: branch.cityId, session: session),
            ],
          ],
        ),
      ),
    );
  }
}

class _BranchEmployeeTile extends StatelessWidget {
  const _BranchEmployeeTile({required this.employee, required this.cityId, required this.session});

  final CompanyEmployee employee;
  final int cityId;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.badge_outlined),
        title: Text(employee.name),
        subtitle: Text('${employee.role} · Performans %${employee.performance} · ₺${employee.dailySalary}/gün'),
        trailing: IconButton(
          tooltip: 'İşten çıkar',
          onPressed: session.isBusy ? null : () => _dismiss(context),
          icon: const Icon(Icons.person_remove_outlined),
        ),
      );

  Future<void> _dismiss(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bayi çalışanını çıkar'),
        content: Text('${employee.name} bu bayiden çıkarılacak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Çıkar')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final message = await session.dismissBranchEmployee(cityId, employee.id);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _BranchCandidateTile extends StatelessWidget {
  const _BranchCandidateTile({required this.employee, required this.cityId, required this.session});

  final CompanyEmployee employee;
  final int cityId;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person_add_alt_1),
        title: Text(employee.name),
        subtitle: Text('${employee.role} · Performans %${employee.performance} · ₺${employee.dailySalary}/gün'),
        trailing: TextButton(
          onPressed: session.isBusy ? null : () => _hire(context),
          child: const Text('İşe al'),
        ),
      );

  Future<void> _hire(BuildContext context) async {
    final message = await session.recruitBranchEmployee(cityId, employee);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}
