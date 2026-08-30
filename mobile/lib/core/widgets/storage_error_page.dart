import 'package:flutter/material.dart';

import 'app_page.dart';
import 'app_state_view.dart';

class StorageErrorPage extends StatelessWidget {
  const StorageErrorPage({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Müdür',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: AppStateView(
            state: AppViewState.error,
            icon: Icons.storage_rounded,
            title: 'Yerel kayıt açılamadı',
            message: message,
            action: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar dene'),
            ),
          ),
        ),
      ),
    );
  }
}
