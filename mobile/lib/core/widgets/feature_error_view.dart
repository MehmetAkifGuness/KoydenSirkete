import 'package:flutter/material.dart';

class FeatureErrorView extends StatelessWidget {
  const FeatureErrorView({this.title = 'Ekran yüklenemedi', super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Geri dön'),
              ),
            ],
          ),
        ),
      );
}
