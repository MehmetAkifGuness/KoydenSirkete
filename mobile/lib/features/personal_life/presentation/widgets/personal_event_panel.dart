import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/personal_event.dart';

class PersonalEventPanel extends StatelessWidget {
  const PersonalEventPanel({
    required this.event,
    required this.session,
    super.key,
  });

  final PersonalEvent event;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      accent: AppPalette.tertiary,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppPalette.tertiary, size: 20),
              SizedBox(width: 8),
              Text(
                'BEKLENMEDİK OLAY',
                style: TextStyle(
                  color: AppPalette.tertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(event.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            event.description,
            style: const TextStyle(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final choice in event.choices) ...[
            _ChoiceButton(
              choice: choice,
              enabled:
                  !session.isBusy &&
                  session.state.money + choice.moneyDelta >= 0,
              onPressed: () => _resolve(context, choice),
            ),
            if (choice != event.choices.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Future<void> _resolve(
    BuildContext context,
    PersonalEventChoice choice,
  ) async {
    final message = await session.resolvePersonalEvent(choice);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.choice,
    required this.enabled,
    required this.onPressed,
  });

  final PersonalEventChoice choice;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        key: ValueKey('personal-event-choice-${choice.id}'),
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(choice.title),
            const SizedBox(height: 3),
            Text(
              enabled ? choice.effects : '${choice.effects} · Yetersiz para',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
