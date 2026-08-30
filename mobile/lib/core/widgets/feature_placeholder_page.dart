import 'package:flutter/material.dart';

import '../constants/app_features.dart';
import 'app_page.dart';
import 'app_state_view.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({required this.feature, super.key});

  final AppFeature feature;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: feature.title,
      subtitle: feature.subtitle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppStateView(
            state: feature.unlocked
                ? AppViewState.empty
                : AppViewState.locked,
            icon: feature.icon,
            title: feature.unlocked
                ? 'Bu alan hazırlanıyor'
                : 'Bu alan kilitli',
            message: feature.unlocked
                ? 'Bu özellik yeni kariyer akışının bir sonraki adımında açılacak.'
                : 'Kariyerindeki ilerleme bu alanın kilidini açacak.',
          ),
        ),
      ),
    );
  }
}
