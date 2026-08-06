import 'package:flutter/material.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({required this.label, required this.value, required this.icon, required this.color, super.key});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Expanded(child: Text(label, style: const TextStyle(color: Color(0xFFACA493), fontSize: 12, fontWeight: FontWeight.w600)))]),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
            if (label == 'Enerji') ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _energyRatio(value), minHeight: 5, borderRadius: BorderRadius.circular(8)),
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
