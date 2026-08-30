import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import 'app_page.dart';

class AppTransactionPreview extends StatelessWidget {
  const AppTransactionPreview({
    required this.cost,
    required this.returnSummary,
    required this.duration,
    required this.risk,
    required this.account,
    super.key,
  });

  final String cost;
  final String returnSummary;
  final String duration;
  final String risk;
  final String account;

  @override
  Widget build(BuildContext context) => AppInfoCard(
    accent: AppPalette.tertiary,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$account · $cost',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Tahmini getiri: $returnSummary\nSüre: $duration · Risk: $risk',
          style: const TextStyle(
            color: AppPalette.textSecondary,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

Future<bool> showAppConfirmation(
  BuildContext context, {
  required String title,
  required Widget summary,
  String confirmLabel = 'Onayla',
  String? irreversibleWarning,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summary,
              if (irreversibleWarning != null) ...[
                const SizedBox(height: 12),
                Text(
                  irreversibleWarning,
                  style: const TextStyle(
                    color: AppPalette.warning,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ) ??
    false;
