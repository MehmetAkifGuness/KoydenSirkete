import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_market_event.dart';
import '../../domain/services/company_season_event_service.dart';

class CompanySeasonEventPanel extends StatelessWidget {
  const CompanySeasonEventPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    const service = CompanySeasonEventService();
    final competition = state.companyCompetition;
    final slots = service.slotsForSeason(competition.seasonNumber);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Sezon olay takvimi',
          caption:
              'Her sezon dört etki türü ve bir değişken olay dengeli seçilir.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${competition.seasonNumber}. sezon · ${slots.length} olay',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const AppPill(
                    label: 'Deterministik',
                    icon: Icons.shuffle_rounded,
                    color: AppPalette.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Takvim kayıt değişmeden aynı kalır; aynı olay iki dönem üst üste gelemez.',
                style: TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
              const Divider(height: 22),
              for (var index = 0; index < slots.length; index++) ...[
                _EventSlotRow(slot: slots[index], day: state.day),
                if (index < slots.length - 1) const SizedBox(height: 9),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EventSlotRow extends StatelessWidget {
  const _EventSlotRow({required this.slot, required this.day});

  final CompanySeasonEventSlot slot;
  final int day;

  @override
  Widget build(BuildContext context) {
    final active =
        slot.contains(day) || (slot.index == 0 && day < slot.startDay);
    final color = _colorFor(slot.event.category);
    return Container(
      key: ValueKey('season-event-${slot.index}-${slot.event.id}'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: .09) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? color.withValues(alpha: .45) : AppPalette.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(_iconFor(slot.event.category), color: color, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        slot.event.title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (active) AppPill(label: 'Aktif', color: color),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${slot.startDay}–${slot.endDay}. gün · '
                  '${slot.event.category.label} · '
                  '${_effect('Gelir', slot.event.revenuePercent)} · '
                  '${_effect('Maaş', slot.event.payrollPercent)}',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _effect(String title, int value) =>
      '$title ${value >= 0 ? '+' : '-'}%${value.abs()}';

  static IconData _iconFor(CompanyMarketEventCategory category) =>
      switch (category) {
        CompanyMarketEventCategory.opportunity => Icons.trending_up_rounded,
        CompanyMarketEventCategory.threat => Icons.warning_amber_rounded,
        CompanyMarketEventCategory.workforce => Icons.groups_2_outlined,
        CompanyMarketEventCategory.stable => Icons.balance_rounded,
      };

  static Color _colorFor(CompanyMarketEventCategory category) =>
      switch (category) {
        CompanyMarketEventCategory.opportunity => AppPalette.success,
        CompanyMarketEventCategory.threat => AppPalette.warning,
        CompanyMarketEventCategory.workforce => AppPalette.tertiary,
        CompanyMarketEventCategory.stable => AppPalette.secondary,
      };
}
