import 'package:flutter/material.dart';

import 'app_palette.dart';

class ThemePalettePicker extends StatelessWidget {
  const ThemePalettePicker({required this.selectedId, required this.enabled, required this.onSelected, super.key});

  final int selectedId;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.palette_outlined), title: Text('Renk paleti', style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700)), subtitle: Text('10 farklı tema arasından seçim yap.')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final scheme in AppPalette.schemes)
                ChoiceChip(
                  selected: scheme.id == selectedId,
                  onSelected: enabled ? (_) => onSelected(scheme.id) : null,
                  selectedColor: scheme.primary,
                  labelStyle: TextStyle(color: scheme.id == selectedId ? scheme.background : scheme.primary, fontSize: 11, fontWeight: FontWeight.w700),
                  avatar: CircleAvatar(backgroundColor: scheme.primary, radius: 8),
                  label: Text(scheme.name),
                ),
            ],
          ),
        ]),
      ),
    );
  }
}
