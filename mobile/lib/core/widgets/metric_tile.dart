import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppPalette.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            if (label == 'Enerji') ...[
              const SizedBox(height: 9),
              LinearProgressIndicator(
                value: _energyRatio(value),
                minHeight: 6,
                color: color,
                backgroundColor: AppPalette.track,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _energyRatio(String value) {
    final parts = value.split('/');
    if (parts.length != 2) return 0;
    final current = double.tryParse(parts.first.trim()) ?? 0;
    final max = double.tryParse(parts.last.trim()) ?? 1;
    return (current / max).clamp(0, 1);
  }
}
