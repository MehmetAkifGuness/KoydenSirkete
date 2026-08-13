import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/skill_id.dart';
import '../../domain/entities/skill_profile.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Yetenekler',
      subtitle: 'Kariyer gücünü oluşturan alanlar',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final total = session.state.skills.values.values.fold<int>(
            0,
            (sum, value) => sum + value,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.secondary,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppPalette.secondary.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: AppPalette.secondary,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uzmanlık portföyü',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$total / ${SkillProfile.maxValue * SkillId.values.length} toplam puan',
                            style: const TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppPill(
                      label: '${SkillId.values.length} alan',
                      color: AppPalette.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const AppSectionHeader(
                title: 'Uzmanlık alanların',
                caption: 'Her seviye yeni fırsatların kilidini açar.',
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: SkillId.values.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 124,
                  crossAxisSpacing: 11,
                  mainAxisSpacing: 11,
                ),
                itemBuilder: (_, index) => _SkillCard(
                  skill: SkillId.values[index],
                  value: session.state.skills[SkillId.values[index]],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.skill, required this.value});

  final SkillId skill;
  final int value;

  @override
  Widget build(BuildContext context) {
    final ratio = value / SkillProfile.maxValue;
    return AppInfoCard(
      accent: ratio > 0 ? AppPalette.primary : AppPalette.outline,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$value',
                style: TextStyle(
                  color: ratio > 0 ? AppPalette.primary : AppPalette.textMuted,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          AppProgressLine(value: ratio),
          const SizedBox(height: 6),
          Text(
            '${(ratio * 100).round()}% uzmanlık',
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
}
