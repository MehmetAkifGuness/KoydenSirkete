import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_motion.dart';

class GameBottomNav extends StatelessWidget {
  const GameBottomNav({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Panel'),
    (Icons.trending_up_outlined, Icons.trending_up_rounded, 'Kariyer'),
    (Icons.work_outline_rounded, Icons.work_rounded, 'İşim'),
    (Icons.business_outlined, Icons.business_rounded, 'Şirketim'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.background,
        border: Border(top: BorderSide(color: AppPalette.outlineMuted)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _NavItem(
                  icon: _items[index].$1,
                  selectedIcon: _items[index].$2,
                  label: _items[index].$3,
                  selected: selectedIndex == index,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppPalette.primary : AppPalette.textMuted;
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.enterCurve,
          height: 60,
          decoration: BoxDecoration(
            color: selected
                ? AppPalette.primary.withValues(alpha: .11)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppPalette.primary.withValues(alpha: .25)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: AppMotion.fast,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: .72, end: 1).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: AppMotion.enterCurve,
                      ),
                    ),
                    child: child,
                  ),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  key: ValueKey(selected),
                  size: 21,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                curve: AppMotion.enterCurve,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
