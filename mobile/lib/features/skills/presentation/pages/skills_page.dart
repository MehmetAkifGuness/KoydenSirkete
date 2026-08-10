import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/skill_id.dart';
import '../../domain/entities/skill_profile.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yetenekler')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: SkillId.values.length,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final skill = SkillId.values[index];
            final value = session.state.skills[skill];
            return Card(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(skill.label, style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700))), Text('$value / ${SkillProfile.maxValue}', style: TextStyle(color: value > 0 ? Theme.of(context).colorScheme.primary : AppPalette.textSecondary, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: value / SkillProfile.maxValue, minHeight: 5, borderRadius: BorderRadius.circular(8)),
            ])));
          },
        ),
      ),
    );
  }
}
