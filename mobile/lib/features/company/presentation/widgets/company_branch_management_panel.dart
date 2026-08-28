import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_branch.dart';
import '../../domain/entities/company_employee.dart';
import '../../domain/entities/company_specialty.dart';
import '../../domain/services/company_branch_management_service.dart';
import '../../domain/services/company_branch_service.dart';

class CompanyBranchManagementPanel extends StatelessWidget {
  const CompanyBranchManagementPanel({
    required this.branch,
    required this.session,
    super.key,
  });

  final CompanyBranch branch;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    const service = CompanyBranchManagementService();
    final manager = service.managerFor(branch);
    final specialty = service.effectiveSpecialty(branch);
    final city = CityCatalog.findById(branch.cityId);
    final preferred = city == null
        ? CompanySpecialty.operations
        : CompanyBranchManagementService.preferredSpecialty(city);
    return Container(
      key: ValueKey('branch-management-${branch.cityId}'),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppPalette.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.manage_accounts_outlined,
                color: AppPalette.secondary,
                size: 19,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Yerel yönetim',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
              AppPill(
                label: manager == null
                    ? 'Yönetici yok'
                    : 'Gelir +%${service.managerRevenueBonusPercent(branch)}',
                color: manager == null
                    ? AppPalette.textMuted
                    : AppPalette.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _SettingTitle(
            title: 'Bayi yöneticisi',
            caption:
                'Güçlü ve kıdemli çalışan daha yüksek gelir bonusu sağlar.',
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                key: ValueKey('branch-manager-${branch.cityId}-none'),
                label: const Text('Atanmadı'),
                selected: manager == null,
                onSelected: session.isBusy
                    ? null
                    : (_) => _setManager(context, null),
              ),
              for (final employee in branch.employees)
                ChoiceChip(
                  key: ValueKey(
                    'branch-manager-${branch.cityId}-${employee.id}',
                  ),
                  label: Text(employee.name),
                  selected: manager?.id == employee.id,
                  onSelected: session.isBusy
                      ? null
                      : (_) => _setManager(context, employee),
                ),
            ],
          ),
          const Divider(height: 24),
          const _SettingTitle(
            title: 'Yerel hedef',
            caption: 'Gelir, maliyet veya çalışan gelişimi arasında seçim yap.',
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final goal in CompanyBranchLocalGoal.values)
                ChoiceChip(
                  key: ValueKey('branch-goal-${branch.cityId}-${goal.name}'),
                  label: Text(goal.label),
                  selected: branch.localGoal == goal,
                  onSelected: session.isBusy
                      ? null
                      : (_) => _setGoal(context, goal),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            branch.localGoal.description,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 10,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AppPill(
                label: _percent('Gelir', branch.localGoal.revenuePercent),
              ),
              AppPill(label: _percent('Maaş', branch.localGoal.payrollPercent)),
              if (branch.localGoal.experienceGain > 0)
                AppPill(
                  label: 'Deneyim +${branch.localGoal.experienceGain}/gün',
                  color: AppPalette.success,
                ),
              if (branch.localGoal.burnoutDelta != 0)
                AppPill(
                  label:
                      'Tükenmişlik ${branch.localGoal.burnoutDelta > 0 ? '+' : ''}${branch.localGoal.burnoutDelta}/gün',
                  color: branch.localGoal.burnoutDelta < 0
                      ? AppPalette.success
                      : AppPalette.warning,
                ),
            ],
          ),
          const Divider(height: 24),
          _SettingTitle(
            title: 'Şube uzmanlığı',
            caption:
                '${preferred.label} bu şehrin önerilen odağı; eşleşen çalışan ek gelir üretir.',
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final option in CompanySpecialty.values)
                ChoiceChip(
                  key: ValueKey(
                    'branch-specialty-${branch.cityId}-${option.name}',
                  ),
                  avatar: option == preferred
                      ? const Icon(Icons.location_on_outlined, size: 15)
                      : null,
                  label: Text(option.label),
                  selected: specialty == option,
                  onSelected: session.isBusy
                      ? null
                      : (_) => _setSpecialty(context, option),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '${specialty.label} çalışanı başına günlük +₺${CompanyBranchService.specialistDailyRevenueBonus} uzmanlık geliri.',
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setManager(
    BuildContext context,
    CompanyEmployee? employee,
  ) async {
    final message = await session.setBranchManager(branch.cityId, employee);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _setGoal(
    BuildContext context,
    CompanyBranchLocalGoal goal,
  ) async {
    final message = await session.setBranchLocalGoal(branch.cityId, goal);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _setSpecialty(
    BuildContext context,
    CompanySpecialty specialty,
  ) async {
    final message = await session.setBranchSpecialty(branch.cityId, specialty);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  static String _percent(String label, int value) =>
      '$label ${value > 0 ? '+' : ''}%$value';
}

class _SettingTitle extends StatelessWidget {
  const _SettingTitle({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 2),
      Text(
        caption,
        style: const TextStyle(color: AppPalette.textMuted, fontSize: 9),
      ),
    ],
  );
}
