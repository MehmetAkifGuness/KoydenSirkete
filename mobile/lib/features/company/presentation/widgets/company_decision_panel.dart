import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_decision.dart';
import '../../domain/services/company_decision_service.dart';

class CompanyDecisionPanel extends StatelessWidget {
  const CompanyDecisionPanel({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    const service = CompanyDecisionService();
    final state = session.state;
    final decision = service.current(state);
    final resolved = service.isResolved(state);
    final selected = resolved
        ? CompanyDecisionService.choices
              .where(
                (choice) =>
                    choice.id == state.companyCompetition.lastDecisionChoiceId,
              )
              .firstOrNull
        : null;
    return AppInfoCard(
      accent: AppPalette.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DÖNEM KARARI',
            style: TextStyle(
              color: AppPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            decision.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${decision.event.title} · ${decision.description}',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (resolved)
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppPalette.success,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu dönem “${selected?.title ?? 'Karar verildi'}” seçildi. Yeni olayda tekrar karar verebilirsin.',
                    style: const TextStyle(
                      color: AppPalette.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            )
          else
            for (final choice in decision.choices) ...[
              _ChoiceCard(
                choice: choice,
                cost: service.cost(state, choice),
                hardReward: service.hardModeRewardPreview(state, choice),
                enabled: !session.isBusy,
                onPressed: () => _resolve(context, choice),
              ),
              if (choice != decision.choices.last) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  Future<void> _resolve(
    BuildContext context,
    CompanyDecisionChoice choice,
  ) async {
    final message = await session.resolveCompanyDecision(choice);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.choice,
    required this.cost,
    required this.hardReward,
    required this.enabled,
    required this.onPressed,
  });

  final CompanyDecisionChoice choice;
  final int cost;
  final String? hardReward;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppPalette.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppPalette.outlineMuted),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                choice.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            FilledButton.tonal(
              key: ValueKey('company-decision-${choice.id}'),
              onPressed: enabled ? onPressed : null,
              child: const Text('Seç'),
            ),
          ],
        ),
        Text(
          choice.description,
          style: const TextStyle(color: AppPalette.textMuted, fontSize: 11),
        ),
        if (hardReward != null) ...[
          const SizedBox(height: 7),
          Text(
            hardReward!,
            style: const TextStyle(
              color: AppPalette.success,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
        const SizedBox(height: 7),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AppPill(label: cost == 0 ? 'Kasa etkisi yok' : 'Kasa -₺$cost'),
            AppPill(label: _signed('Proje', choice.projectProgress)),
            AppPill(label: _signed('İtibar', choice.reputation)),
            AppPill(label: _signed('Moral', choice.morale)),
            AppPill(label: _signed('Tükenmişlik', choice.burnout)),
          ],
        ),
      ],
    ),
  );

  static String _signed(String label, int value) =>
      value == 0 ? '$label etkisi yok' : '$label ${value > 0 ? '+' : ''}$value';
}
