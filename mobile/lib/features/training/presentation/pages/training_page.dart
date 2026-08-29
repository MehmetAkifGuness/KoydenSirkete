import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../economy/domain/services/investment_return_service.dart';
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
    return courses
        .where(
          (course) =>
              course.skillDeltas.keys.any((skill) => skill.label == _filter),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Eğitim',
      subtitle: 'Bilgini fırsata dönüştür',
      child: AnimatedBuilder(
        animation: widget.session,
        builder: (context, _) {
          final courses = _filteredCourses;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.secondary,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppPalette.secondary.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppPalette.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Öğrenme merkezi',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${courses.length} eğitim · Bilgi, tecrübe ve yetenek kazan',
                            style: const TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppPill(
                      label: '${courses.length} kurs',
                      color: AppPalette.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _FilterBar(
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 23),
              AppSectionHeader(
                title: 'Kurs kataloğu',
                caption: 'Enerji ve zamanını doğru alana yatır.',
              ),
              const SizedBox(height: 12),
              for (final course in courses) ...[
                _CourseCard(
                  course: course,
                  enabled:
                      !widget.session.isBusy &&
                      widget.session.state.hasActivityCapacity,
                  onTap: () => _train(context, course),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _train(BuildContext context, Course course) async {
    final message = await widget.session.train(course);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = [
      'Tümü',
      'Genel',
      'Çoklu yetenek',
      ...SkillId.values.map((skill) => skill.label),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, index) => const SizedBox(width: 7),
        itemBuilder: (_, index) {
          final filter = filters[index];
          return ChoiceChip(
            label: Text(filter),
            selected: filter == selected,
            onSelected: (_) => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.enabled,
    required this.onTap,
  });

  final Course course;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      accent: AppPalette.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AppPill(
                label: course.cost == 0 ? 'Ücretsiz' : '₺${course.cost}',
                color: course.cost == 0
                    ? AppPalette.primary
                    : AppPalette.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            course.description,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              AppPill(
                label: '${course.durationHours} saat',
                color: AppPalette.secondary,
                icon: Icons.schedule_rounded,
              ),
              AppPill(
                label: '-${course.energyCost} enerji',
                color: AppPalette.tertiary,
                icon: Icons.bolt_rounded,
              ),
              AppPill(
                label: '+${course.knowledge} bilgi',
                color: AppPalette.primary,
                icon: Icons.menu_book_rounded,
              ),
              AppPill(
                label: '+${course.experience} tecrübe',
                color: AppPalette.textSecondary,
                icon: Icons.trending_up_rounded,
              ),
              if (course.cost > 0)
                AppPill(
                  label: InvestmentReturnService.summary(
                    InvestmentType.training,
                    InvestmentReturnService.trainingDays(course),
                  ),
                  color: AppPalette.success,
                  icon: Icons.savings_outlined,
                ),
            ],
          ),
          if (course.skillDeltas.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final entry in course.skillDeltas.entries)
                  AppPill(
                    label: '+${entry.value} ${entry.key.label}',
                    color: AppPalette.secondary,
                    icon: Icons.auto_awesome_rounded,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: enabled ? onTap : null,
              child: const Text('Eğitime başla'),
            ),
          ),
        ],
      ),
    );
  }
}
