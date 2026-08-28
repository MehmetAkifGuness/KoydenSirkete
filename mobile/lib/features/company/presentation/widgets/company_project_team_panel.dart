import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_employee.dart';
import '../../domain/entities/company_project.dart';
import '../../domain/entities/company_specialty.dart';
import '../../domain/services/company_project_team_service.dart';
import '../../domain/services/company_service.dart';

class CompanyProjectTeamPanel extends StatelessWidget {
  const CompanyProjectTeamPanel({
    required this.session,
    required this.project,
    super.key,
  });

  final GameSessionController session;
  final CompanyProject project;

  @override
  Widget build(BuildContext context) {
    const teamService = CompanyProjectTeamService();
    final state = session.state;
    final employees = CompanyService.employeesFor(state);
    final team = teamService.teamFor(state, project);
    final summary = teamService.summaryFor(state, project);
    final assignedIds = team.map((employee) => employee.id).toSet();
    return Column(
      key: const ValueKey('project-team-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Proje ekibi',
          caption: '${project.name} için uzman çalışanlarını seç.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: team.isEmpty ? AppPalette.warning : AppPalette.secondary,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppPill(
                    label: '${summary.employeeCount} çalışan',
                    color: AppPalette.secondary,
                    icon: Icons.groups_2_outlined,
                  ),
                  AppPill(
                    label: '${summary.specialistCount} uzman',
                    color: AppPalette.tertiary,
                    icon: Icons.workspace_premium_outlined,
                  ),
                  AppPill(
                    label: '%${summary.averageJobFit} görev uyumu',
                    color: summary.averageJobFit >= 75
                        ? AppPalette.success
                        : AppPalette.warning,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                team.isEmpty
                    ? 'Proje ilerlemesi için en az bir merkez çalışanı ata.'
                    : '${project.specialty.label} uzmanlığı ilerleme, süre ve kaliteyi güçlendirir.',
                style: TextStyle(
                  color: team.isEmpty
                      ? AppPalette.warning
                      : AppPalette.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (employees.isEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Atama yapabilmek için önce şirket merkezine çalışan al.',
                  style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
                ),
              ] else ...[
                const SizedBox(height: 7),
                for (final employee in employees)
                  _EmployeeAssignmentRow(
                    employee: employee,
                    project: project,
                    assigned: assignedIds.contains(employee.id),
                    enabled: !session.isBusy,
                    onChanged: (assigned) =>
                        _setAssignment(context, employee, assigned: assigned),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _setAssignment(
    BuildContext context,
    CompanyEmployee employee, {
    required bool assigned,
  }) async {
    final message = await session.setCompanyProjectEmployeeAssignment(
      project,
      employee,
      assigned: assigned,
    );
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _EmployeeAssignmentRow extends StatelessWidget {
  const _EmployeeAssignmentRow({
    required this.employee,
    required this.project,
    required this.assigned,
    required this.enabled,
    required this.onChanged,
  });

  final CompanyEmployee employee;
  final CompanyProject project;
  final bool assigned;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final fit = employee.jobFitPercentFor(project.specialty);
    return Padding(
      key: ValueKey('project-team-employee-${employee.id}'),
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Checkbox(
            key: ValueKey('project-team-checkbox-${employee.id}'),
            value: assigned,
            onChanged: enabled ? (value) => onChanged(value ?? false) : null,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${employee.role} · ${employee.specialty.label} · %$fit uyum',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            assigned ? 'Atandı' : 'Boşta',
            style: TextStyle(
              color: assigned ? AppPalette.success : AppPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
