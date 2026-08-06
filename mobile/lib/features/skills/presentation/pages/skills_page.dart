import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/skill_id.dart';

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
          padding: const EdgeInsets.all(20),
          itemCount: SkillId.values.length,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final skill = SkillId.values[index];
            final value = session.state.skills[skill];
            return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(skill.label, style: const TextStyle(fontWeight: FontWeight.w800))), Text('$value / 100')]),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: value / 100),
            ])));
          },
        ),
      ),
    );
  }
}
