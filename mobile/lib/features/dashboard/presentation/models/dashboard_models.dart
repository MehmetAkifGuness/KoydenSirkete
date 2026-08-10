import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../game/domain/entities/player_state.dart';

class DashboardMetric {
  const DashboardMetric({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class DashboardDesignState {
  const DashboardDesignState({required this.greeting, required this.goal, required this.metrics});

  final String greeting;
  final String goal;
  final List<DashboardMetric> metrics;

  factory DashboardDesignState.fromPlayer(PlayerState state) {
    return DashboardDesignState(
      greeting: 'Yeni başlangıç',
      goal: state.knowledge < 12 ? 'İlk eğitimine ulaş' : 'İlk iş ilanını bul',
      metrics: [
        DashboardMetric(label: 'Para', value: '₺${state.money}', icon: Icons.payments_outlined, color: AppPalette.primary),
        DashboardMetric(label: 'Enerji', value: '${state.energy} / ${state.maxEnergy}', icon: Icons.bolt, color: AppPalette.tertiary),
        DashboardMetric(label: 'Bilgi', value: '${state.knowledge}', icon: Icons.menu_book_outlined, color: AppPalette.secondary),
        DashboardMetric(label: 'Tecrübe', value: '${state.experience}', icon: Icons.workspace_premium_outlined, color: AppPalette.success),
      ],
    );
  }

  static DashboardDesignState get initial => DashboardDesignState(
    greeting: 'Yeni başlangıç',
    goal: 'İlk eğitimine ulaş',
    metrics: [
      DashboardMetric(label: 'Para', value: '₺240', icon: Icons.payments_outlined, color: AppPalette.primary),
      DashboardMetric(label: 'Enerji', value: '100 / 100', icon: Icons.bolt, color: AppPalette.tertiary),
      DashboardMetric(label: 'Bilgi', value: '12', icon: Icons.menu_book_outlined, color: AppPalette.secondary),
      DashboardMetric(label: 'Tecrübe', value: '4', icon: Icons.workspace_premium_outlined, color: AppPalette.success),
    ],
  );
}
