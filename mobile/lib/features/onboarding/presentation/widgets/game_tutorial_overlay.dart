import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';

class GameTutorialOverlay extends StatelessWidget {
  const GameTutorialOverlay({
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.description,
    required this.task,
    required this.taskCompleted,
    required this.collapsed,
    required this.onNext,
    required this.onBack,
    required this.onToggleCollapsed,
    required this.onExit,
    super.key,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String description;
  final String task;
  final bool taskCompleted;
  final bool collapsed;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback onToggleCollapsed;
  final VoidCallback onExit;

  bool get _isLast => step == totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 10,
      child: SafeArea(
        top: false,
        child: Semantics(
          liveRegion: true,
          label:
              'Uygulamalı tur, adım ${step + 1}/$totalSteps: $title. Görev: $task',
          child: AppInfoCard(
            accent: taskCompleted ? AppPalette.success : AppPalette.primary,
            padding: collapsed
                ? const EdgeInsets.fromLTRB(14, 6, 6, 6)
                : const EdgeInsets.fromLTRB(16, 12, 10, 12),
            child: collapsed ? _collapsedContent() : _expandedContent(context),
          ),
        ),
      ),
    );
  }

  Widget _collapsedContent() => Row(
    children: [
      Icon(
        taskCompleted ? Icons.check_circle_rounded : Icons.explore_rounded,
        color: taskCompleted ? AppPalette.success : AppPalette.primary,
        size: 19,
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          '${step + 1}/$totalSteps · $title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      IconButton(
        onPressed: onToggleCollapsed,
        tooltip: 'Rehberi büyüt',
        icon: const Icon(Icons.expand_less_rounded),
      ),
    ],
  );

  Widget _expandedContent(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .58,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'UYGULAMALI TUR · ${step + 1}/$totalSteps',
                  style: const TextStyle(
                    color: AppPalette.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleCollapsed,
                tooltip: 'Rehberi küçült',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.expand_more_rounded, size: 20),
              ),
              IconButton(
                onPressed: onExit,
                tooltip: 'Turdan çık',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (step + 1) / totalSteps,
              minHeight: 5,
              backgroundColor: AppPalette.track,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (taskCompleted ? AppPalette.success : AppPalette.primary)
                  .withValues(alpha: .09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  taskCompleted
                      ? Icons.check_circle_rounded
                      : Icons.touch_app_rounded,
                  color: taskCompleted
                      ? AppPalette.success
                      : AppPalette.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    taskCompleted ? 'Tamamlandı · $task' : 'Şimdi dene · $task',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
              final nextButton = FilledButton.icon(
                onPressed: onNext,
                icon: Icon(
                  _isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(
                  _isLast
                      ? 'Turu bitir'
                      : taskCompleted
                      ? 'Devam'
                      : 'Bu adımı geç',
                ),
              );
              if (largeText || constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (onBack != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Önceki adım'),
                        ),
                      ),
                    nextButton,
                  ],
                );
              }
              return Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      tooltip: 'Önceki adım',
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  const Spacer(),
                  nextButton,
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}
