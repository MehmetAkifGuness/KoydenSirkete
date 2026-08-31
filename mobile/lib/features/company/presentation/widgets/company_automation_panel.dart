import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/services/company_automation_service.dart';

class CompanyAutomationPanel extends StatelessWidget {
  const CompanyAutomationPanel({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) => AppInfoCard(
    accent: AppPalette.secondary,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YÖNETİM OTOMASYONU',
          style: TextStyle(
            color: AppPalette.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Tek işlemle proje ekibini, bayi yöneticilerini, yerel hedefleri, bütçeyi ve bekleyen zamları düzenle.',
          style: TextStyle(color: AppPalette.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 10),
        for (final preset in CompanyAutomationPreset.values) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: ValueKey('company-automation-${preset.name}'),
              onPressed: session.isBusy ? null : () => _apply(context, preset),
              icon: Icon(_iconFor(preset)),
              label: Text('${preset.label} · ${preset.description}'),
            ),
          ),
          const SizedBox(height: 7),
        ],
        const Divider(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            key: const ValueKey('advance-next-day'),
            onPressed: session.isBusy ? null : () => _nextDay(context),
            icon: const Icon(Icons.next_plan_outlined),
            label: const Text('Sonraki güne kadar ilerlet'),
          ),
        ),
      ],
    ),
  );

  Future<void> _apply(
    BuildContext context,
    CompanyAutomationPreset preset,
  ) async {
    final message = await session.applyCompanyAutomation(preset);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _nextDay(BuildContext context) async {
    final message = await session.tickToNextDay();
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  IconData _iconFor(CompanyAutomationPreset preset) => switch (preset) {
    CompanyAutomationPreset.balanced => Icons.balance_outlined,
    CompanyAutomationPreset.growth => Icons.trending_up_rounded,
    CompanyAutomationPreset.people => Icons.groups_outlined,
  };
}
