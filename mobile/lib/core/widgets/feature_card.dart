import 'package:flutter/material.dart';

import '../constants/app_features.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({required this.feature, required this.onTap, super.key});

  final AppFeature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: feature.color.withValues(alpha: .15),
                child: Icon(feature.unlocked ? feature.icon : Icons.lock_outline, color: feature.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feature.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(feature.unlocked ? feature.subtitle : 'Yakında açılacak', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: .4)),
            ],
          ),
        ),
      ),
    );
  }
}
