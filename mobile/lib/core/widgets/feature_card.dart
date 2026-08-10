import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: feature.color.withValues(alpha: .65))),
                child: Icon(feature.unlocked ? feature.icon : Icons.lock_outline, color: feature.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feature.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppPalette.outlineMuted),
            ],
          ),
        ),
      ),
    );
  }
}
