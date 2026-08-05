import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/course.dart';
import '../../domain/services/training_catalog.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eğitim')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: TrainingCatalog.courses.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _CourseCard(
            course: TrainingCatalog.courses[index],
            enabled: !session.isBusy,
            onTap: () => _train(context, TrainingCatalog.courses[index]),
          ),
        ),
      ),
    );
  }

  Future<void> _train(BuildContext context, Course course) async {
    final message = await session.train(course);
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.enabled, required this.onTap});

  final Course course;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
              Text(course.cost == 0 ? 'Ücretsiz' : '₺${course.cost}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            Text(course.description, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Tag(icon: Icons.schedule_outlined, text: '${course.durationHours} saat'),
              _Tag(icon: Icons.bolt, text: '-${course.energyCost} enerji'),
              _Tag(icon: Icons.menu_book_outlined, text: '+${course.knowledge} bilgi'),
            ]),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: enabled ? onTap : null, child: const Text('Eğitime başla'))),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 15), label: Text(text, style: const TextStyle(fontSize: 11)));
  }
}
