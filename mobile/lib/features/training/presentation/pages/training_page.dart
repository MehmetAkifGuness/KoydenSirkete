import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../../skills/domain/entities/skill_id.dart';
import '../../domain/entities/course.dart';
import '../../domain/services/training_catalog.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({required this.session, super.key});

  final GameSessionController session;

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  String _filter = 'Tümü';

  List<Course> get _filteredCourses {
    final courses = TrainingCatalog.courses;
    if (_filter == 'Tümü') {
      return courses;
    }
    if (_filter == 'Genel') {
      return courses.where((course) => course.skillDeltas.isEmpty).toList();
    }
    if (_filter == 'Çoklu yetenek') {
      return courses.where((course) => course.skillDeltas.length > 1).toList();
    }
    return courses.where((course) => course.skillDeltas.keys.any((skill) => skill.label == _filter)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eğitim')),
      body: AnimatedBuilder(
        animation: widget.session,
        builder: (context, _) {
          final courses = _filteredCourses;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _FilterBar(selected: _filter, onSelected: (value) => setState(() => _filter = value)),
              const SizedBox(height: 16),
              Text('${courses.length} eğitim', style: const TextStyle(color: Color(0xFF9F988B), fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              for (final course in courses) ...[
                _CourseCard(
                  course: course,
                  enabled: !widget.session.isBusy && widget.session.state.activeActivity == null,
                  onTap: () => _train(context, course),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _train(BuildContext context, Course course) async {
    final message = await widget.session.train(course);
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  static const _fixedFilters = ['Tümü', 'Genel', 'Çoklu yetenek'];

  @override
  Widget build(BuildContext context) {
    final filters = [
      ..._fixedFilters,
      ...SkillId.values.map((skill) => skill.label),
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          return InkWell(
            onTap: () => onSelected(filter),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDDBA3E) : const Color(0xFF090909),
                border: Border.all(color: const Color(0xFFDDBA3E)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(filter, style: TextStyle(color: isSelected ? Colors.black : const Color(0xFFDDBA3E), fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          );
        },
      ),
    );
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
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Padding(padding: const EdgeInsets.only(top: 24), child: Text(course.name, style: const TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w700, fontSize: 18)))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: const BoxDecoration(color: Color(0xFFDDBA3E), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10))), child: Text(course.cost == 0 ? 'Ücretsiz' : '₺${course.cost}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 8),
            Text(course.description, style: const TextStyle(color: Color(0xFFD1C9B8))),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF8C741A)), borderRadius: BorderRadius.circular(8)), child: Wrap(spacing: 12, runSpacing: 8, children: [
              _Tag(icon: Icons.schedule_outlined, text: '${course.durationHours} saat'),
              _Tag(icon: Icons.bolt, text: '-${course.energyCost}'),
              _Tag(icon: Icons.menu_book_outlined, text: '+${course.knowledge}'),
            ])),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final entry in course.skillDeltas.entries) _Tag(icon: Icons.auto_awesome_outlined, text: '+${entry.value} ${entry.key.label}'),
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
