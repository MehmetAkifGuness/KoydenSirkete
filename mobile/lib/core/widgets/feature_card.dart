import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../constants/app_features.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({required this.feature, required this.onTap, super.key});

  final AppFeature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = feature.unlocked;
    final color = active ? feature.color : AppPalette.textMuted;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: active ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      active ? feature.icon : Icons.lock_outline,
                      color: color,
                      size: 19,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppPalette.textMuted,
                    size: 18,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                feature.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? AppPalette.textPrimary : AppPalette.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                feature.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
