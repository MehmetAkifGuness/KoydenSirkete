import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../constants/app_features.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({required this.feature, super.key});

  final AppFeature feature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(feature.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 42, backgroundColor: feature.color.withValues(alpha: .15), child: Icon(feature.icon, size: 40, color: feature.color)),
              const SizedBox(height: 24),
              Text(feature.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(
                feature.unlocked ? 'Bu ekran tasarım taslağıdır.' : 'Bu özellik sonraki sürüm planında açılacak.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppPalette.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
