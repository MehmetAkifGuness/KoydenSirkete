import 'package:flutter/material.dart';

import 'app_page.dart';

class FeatureErrorView extends StatelessWidget {
  const FeatureErrorView({this.title = 'Ekran yüklenemedi', super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: title,
        message: 'Bu veriyi şu anda görüntüleyemiyoruz.',
        action: FilledButton.tonalIcon(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Geri dön'),
        ),
      ),
    ),
  );
}
