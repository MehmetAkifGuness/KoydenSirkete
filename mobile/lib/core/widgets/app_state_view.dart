import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

enum AppViewState { empty, loading, error, locked, completed }

class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.state,
    required this.title,
    required this.message,
    this.action,
    this.icon,
    super.key,
  });

  final AppViewState state;
  final String title;
  final String message;
  final Widget? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (defaultIcon, color) = switch (state) {
      AppViewState.empty => (Icons.inbox_outlined, AppPalette.primary),
      AppViewState.loading => (Icons.hourglass_top_rounded, AppPalette.secondary),
      AppViewState.error => (Icons.error_outline_rounded, AppPalette.warning),
      AppViewState.locked => (Icons.lock_outline_rounded, AppPalette.warning),
      AppViewState.completed => (Icons.check_circle_outline, AppPalette.success),
    };
    return Semantics(
      liveRegion: state == AppViewState.loading || state == AppViewState.error,
      label: '$title. $message',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          border: Border.all(color: color.withValues(alpha: .22)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state == AppViewState.loading)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Icon(icon ?? defaultIcon, color: color, size: 28),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 7),
            Text(
              message,
              style: const TextStyle(
                color: AppPalette.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 17), action!],
          ],
        ),
      ),
    );
  }
}
