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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}
