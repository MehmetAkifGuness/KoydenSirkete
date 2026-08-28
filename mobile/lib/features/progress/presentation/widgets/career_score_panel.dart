import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/career_score.dart';
import '../../domain/services/career_score_service.dart';

class CareerScorePanel extends StatelessWidget {
  const CareerScorePanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final summary = CareerScoreService().summarize(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Devam eden kariyer özeti',
          caption: 'Tek bir bitiş yok; her hedef yeni prestij basamağı açar.',
        ),
        const SizedBox(height: 12),
        _ScoreCard(summary: summary),
        const SizedBox(height: 18),
        const AppSectionHeader(
          title: 'Puan dağılımı',
          caption: 'Kariyerinin hangi alanlardan güçlendiğini gör.',
        ),
        const SizedBox(height: 10),
        AppInfoCard(
          accent: AppPalette.secondary,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (
                var index = 0;
                index < summary.categories.length;
                index++
              ) ...[
                _CategoryRow(
                  category: summary.categories[index],
                  color: _categoryColors[index % _categoryColors.length],
                ),
                if (index < summary.categories.length - 1)
                  const Divider(height: 18),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        const AppSectionHeader(
          title: 'Sıradaki puan hedefleri',
          caption: 'Tekrarlanabilir hedeflerle puanın büyümeye devam eder.',
        ),
        const SizedBox(height: 10),
        for (final goal in summary.goals) ...[
          _GoalCard(goal: goal),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  static const _categoryColors = <Color>[
    AppPalette.primary,
    AppPalette.tertiary,
    AppPalette.secondary,
    AppPalette.success,
  ];
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.summary});

  final CareerScoreSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      accent: AppPalette.primary,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppPalette.primary.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: AppPalette.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kariyer başarı puanı',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${summary.totalScore} puan',
                      key: const ValueKey('career-score-total'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              AppPill(
                label: summary.prestigeLevel > 0
                    ? 'Prestij ${summary.prestigeLevel}'
                    : 'Kariyer seviyesi',
                color: AppPalette.primary,
                icon: Icons.auto_awesome_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressLine(value: summary.progress, color: AppPalette.primary),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.title,
                  style: const TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${summary.remainingScore} puan sonra ${summary.nextTarget}',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const AppPill(
            label: 'Bitiş yok · Prestij devam eder',
            color: AppPalette.success,
            icon: Icons.all_inclusive_rounded,
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.color});

  final CareerScoreCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.description,
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${category.score}',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final CareerScoreGoal goal;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      accent: AppPalette.outline,
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppPill(
                label: '+${goal.scoreReward} puan',
                color: AppPalette.success,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            goal.description,
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 9),
          ),
          const SizedBox(height: 8),
          AppProgressLine(value: goal.progress, color: AppPalette.secondary),
          const SizedBox(height: 4),
          Text(
            '${goal.current}/${goal.target}',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
