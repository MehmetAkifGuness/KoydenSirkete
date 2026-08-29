import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../features/cities/domain/services/city_catalog.dart';
import '../../features/game/domain/entities/player_state.dart';
import '../../features/game/domain/services/game_clock_service.dart';
import 'game_account_bar.dart';

class GameTopBar extends StatelessWidget {
  const GameTopBar({
    required this.state,
    this.speed = 1,
    this.isRunning = true,
    this.onSpeedChanged,
    this.onToggleRunning,
    super.key,
  });

  final PlayerState state;
  final int speed;
  final bool isRunning;
  final ValueChanged<int>? onSpeedChanged;
  final VoidCallback? onToggleRunning;

  @override
  Widget build(BuildContext context) {
    final city = CityCatalog.findById(state.currentCityId)?.name ?? 'Köy';
    final hour = state.hour.toString().padLeft(2, '0');
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppPalette.background,
          border: Border(bottom: BorderSide(color: AppPalette.outlineMuted)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 10),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppPalette.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: AppPalette.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -5,
                      bottom: -5,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppPalette.primary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppPalette.background,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${state.careerLevel}',
                            style: const TextStyle(
                              color: AppPalette.background,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yerel oyuncu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Kariyer seviyesi ${state.careerLevel}',
                        style: const TextStyle(
                          color: AppPalette.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppPalette.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          city,
                          style: const TextStyle(
                            color: AppPalette.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.schedule_outlined,
                          size: 12,
                          color: AppPalette.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Gün ${state.day} · $hour:00',
                          style: const TextStyle(
                            color: AppPalette.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: GameAccountSummary(state: state),
            ),
            if (onSpeedChanged != null && onToggleRunning != null) ...[
              const SizedBox(height: 9),
              Row(
                children: [
                  const Text(
                    'Saat hızı',
                    style: TextStyle(
                      color: AppPalette.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  for (final value in [1, 2, 4]) ...[
                    ChoiceChip(
                      label: Text('${value}x'),
                      selected: speed == value,
                      onSelected: (_) => onSpeedChanged!(value),
                      labelStyle: TextStyle(
                        color: speed == value
                            ? AppPalette.background
                            : AppPalette.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    if (value != 4) const SizedBox(width: 2),
                  ],
                  const Spacer(),
                  IconButton(
                    tooltip: isRunning ? 'Durdur' : 'Devam et',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    onPressed: onToggleRunning,
                    icon: Icon(
                      isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                ],
              ),
              Text(
                '${_secondsForSpeed(speed)} saniyede 1 oyun saati',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _secondsForSpeed(int value) =>
      GameClockService.intervalForSpeed(value).inSeconds;
}
