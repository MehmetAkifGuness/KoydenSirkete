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
    this.canAcknowledge = false,
    this.onAcknowledge,
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
  final bool canAcknowledge;
  final VoidCallback? onAcknowledge;

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
          style: const TextStyle(fontWeight: FontWeight.w800),
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
      maxHeight: (MediaQuery.sizeOf(context).height * .34).clamp(150.0, 200.0),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showDetails(context),
                tooltip: 'Adım açıklamasını göster',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.info_outline_rounded, size: 20),
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
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
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
          if (canAcknowledge && !taskCompleted) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAcknowledge,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('İnceledim ve anladım'),
              ),
            ),
          ],
          const SizedBox(height: 7),
          LayoutBuilder(
            builder: (context, constraints) {
              final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
              final nextButton = FilledButton.icon(
                onPressed: taskCompleted ? onNext : null,
                icon: Icon(
                  _isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(
                  _isLast
                      ? 'Turu bitir'
                      : taskCompleted
                      ? 'Devam'
                      : 'Önce görevi tamamla',
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

  Future<void> _showDetails(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPalette.surface,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${step + 1}/$totalSteps · $title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Açıklamayı kapat',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Görev · $task',
              style: const TextStyle(fontWeight: FontWeight.w800, height: 1.4),
            ),
          ],
        ),
      ),
    ),
  );
}
