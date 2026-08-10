import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_project.dart';
import '../../domain/entities/company_employee.dart';
import '../../domain/services/company_service.dart';
import '../../domain/services/company_project_catalog.dart';
import 'company_branches_page.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şirketim')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          if (session.state.companyLevel == 0) {
            final check = session.checkCompanyEstablishment();
            return _EstablishmentView(session: session, check: check);
          }
          return _CompanyView(session: session);
        },
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
    return Center(
      child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: Text('Kendi şirketini kur', style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w700))),
                const SizedBox(height: 10),
                const Text('Kariyer yolunu tamamladıktan sonra kendi işini büyütmeye başlayabilirsin.'),
                const SizedBox(height: 14),
                Text(check.reason, style: TextStyle(color: check.isEligible ? AppPalette.success : AppPalette.warning)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: check.isEligible && !session.isBusy ? () => _establish(context) : null,
                    child: const Text('Şirket kur · ₺1000'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _establish(BuildContext context) async {
    final message = await session.establishCompany();
    if (!context.mounted || message == null) {
      return;
    }
    AppFeedback.show(context, message);
  }
}

class _CompanyView extends StatelessWidget {
  const _CompanyView({required this.session});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final companyService = CompanyService();
    final employees = CompanyService.employeesFor(state);
    final candidates = companyService.availableEmployees(state);
    final capacity = CompanyService.employeeCapacity(state.companyLevel);
    final project = CompanyProjectCatalog.byId(state.activeProjectId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Şirket seviyesi ${state.companyLevel}', style: const TextStyle(fontFamily: 'serif', fontSize: 21, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text('Kasa: ₺${state.companyFunds} · Çalışan: ${employees.length}/$capacity'),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: state.projectProgress / 100),
                const SizedBox(height: 6),
                Text('${project.name} · %${state.projectProgress}'),
                const SizedBox(height: 10),
                Text('Günlük gelir: +₺${companyService.dailyRevenue(state)} · Maaş gideri: -₺${companyService.dailyPayroll(state)}'),
                const SizedBox(height: 6),
                Text('Çalışan performansına göre günlük otomatik ilerleme: +${companyService.dailyProjectProgress(state)} puan'),
                const SizedBox(height: 6),
                Text('Tamamlanma geliri: ₺${project.reward} · Operasyon gideri: ₺${project.cost} · Net: ₺${project.reward - project.cost}'),
              ],
            ),
          ),
        ),
        if (state.companyLevel < CompanyService.maxCompanyLevel) ...[
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final check = session.checkCompanyUpgrade();
            return FilledButton.tonalIcon(
              onPressed: check.isEligible && !session.isBusy ? () => _upgrade(context) : null,
              icon: const Icon(Icons.trending_up),
              label: Text('Şirketi yükselt · ₺${CompanyService.upgradeCost(state.companyLevel)}'),
            );
          }),
        ],
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: session.isBusy ? null : () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CompanyBranchesPage(session: session))),
          icon: const Icon(Icons.storefront_outlined),
          label: const Text('Şehir bayilerini yönet'),
        ),
        const SizedBox(height: 18),
        const Text('Proje seçimi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        for (final project in CompanyProjectCatalog.projects)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ProjectTile(project: project, session: session),
          ),
        const SizedBox(height: 18),
        Text('Çalışanlar (${employees.length}/$capacity)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        for (final employee in employees)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _EmployeeTile(
              employee: employee,
              enabled: !session.isBusy,
              onDismiss: () => _dismiss(context, employee),
            ),
          ),
        if (employees.length < capacity) ...[
          const SizedBox(height: 8),
          Text('İşe alınabilir adaylar (${candidates.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final candidate in candidates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CandidateTile(
                employee: candidate,
                enabled: !session.isBusy,
                onHire: () => _recruit(context, candidate),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _recruit(BuildContext context, CompanyEmployee employee) async {
    final message = await session.recruitEmployee(employee);
    if (!context.mounted || message == null) {
      return;
    }
    AppFeedback.show(context, message);
  }

  Future<void> _dismiss(BuildContext context, CompanyEmployee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çalışanı işten çıkar'),
        content: Text('${employee.name} şirketten çıkarılacak. Günlük maaş gideri ve proje katkısı duracak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('İşten çıkar')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final message = await session.dismissEmployee(employee.id);
    if (!context.mounted || message == null) {
      return;
    }
    AppFeedback.show(context, message);
  }

  Future<void> _upgrade(BuildContext context) async {
    final message = await session.upgradeCompany();
    if (!context.mounted || message == null) {
      return;
    }
    AppFeedback.show(context, message);
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.enabled, required this.onDismiss});

  final CompanyEmployee employee;
  final bool enabled;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final performance = employee.performance;
    final salary = employee.dailySalary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text('%$performance', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text(employee.role, style: const TextStyle(color: AppPalette.textSecondary)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: performance / 100),
            const SizedBox(height: 6),
            Text('Günlük maaş: ₺$salary', style: const TextStyle(color: AppPalette.textMuted, fontSize: 12)),
            Text(
              'Günlük net katkı: ₺${CompanyService().dailyEmployeeNetContribution(employee)}',
              style: const TextStyle(color: AppPalette.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: enabled ? onDismiss : null,
                icon: const Icon(Icons.person_remove_outlined),
                label: const Text('İşten çıkar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({required this.employee, required this.enabled, required this.onHire});

  final CompanyEmployee employee;
  final bool enabled;
  final VoidCallback onHire;

  @override
  Widget build(BuildContext context) {
    final performance = employee.performance;
    final salary = employee.dailySalary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text('Performans %$performance', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(employee.role, style: const TextStyle(color: AppPalette.textSecondary)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: performance / 100),
            const SizedBox(height: 6),
            Text('Günlük maaş: ₺$salary', style: const TextStyle(color: AppPalette.textMuted, fontSize: 12)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: enabled ? onHire : null,
                child: const Text('İşe al · Ücretsiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project, required this.session});

  final CompanyProject project;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final selected = state.activeProjectId == project.id;
    final unlocked = project.id <= state.companyLevel;
    final selectable = unlocked && (selected || state.projectProgress == 0) && !session.isBusy;
    return Card(
      child: ListTile(
        leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? Theme.of(context).colorScheme.primary : null),
        title: Text(project.name),
        subtitle: Text(
          unlocked
              ? '${project.description} Tamamlanma gideri: ₺${project.cost} · Brüt ödül: ₺${project.reward}'
              : 'Seviye ${project.id} şirket gerekir.',
        ),
        trailing: selected ? const Icon(Icons.check) : null,
        enabled: selectable,
        onTap: selectable && !selected ? () => _select(context) : null,
      ),
    );
  }

  Future<void> _select(BuildContext context) async {
    final message = await session.selectCompanyProject(project);
    if (!context.mounted || message == null) {
      return;
    }
    AppFeedback.show(context, message);
  }
}
