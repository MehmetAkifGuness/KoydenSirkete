import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.action, super.key});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(color: AppPalette.textMuted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6)),
        if (action != null)
          Text(action!, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
