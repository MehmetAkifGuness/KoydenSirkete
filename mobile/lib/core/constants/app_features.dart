import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

class AppFeature {
  const AppFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.unlocked,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool unlocked;
}

abstract final class AppFeatures {
  static AppFeature get earning => AppFeature(
    title: 'Para kazan',
    subtitle: 'İlk sermayeni oluştur',
    icon: Icons.payments_outlined,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get training => AppFeature(
    title: 'Eğitim',
    subtitle: 'Bilgi ve becerilerini geliştir',
    icon: Icons.school_outlined,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get skills => AppFeature(
    title: 'Yetenekler',
    subtitle: 'Mesleki alanlarını geliştir',
    icon: Icons.auto_awesome_outlined,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get sport => AppFeature(
    title: 'Spor',
    subtitle: 'Maksimum enerjini artır',
    icon: Icons.fitness_center_outlined,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get jobs => AppFeature(
    title: 'İş ilanları',
    subtitle: 'İlk fırsatını bul',
    icon: Icons.work_outline,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get career => AppFeature(
    title: 'Kariyer',
    subtitle: 'İlerleme yolunu gör',
    icon: Icons.trending_up,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get cities => AppFeature(
    title: 'Şehirler',
    subtitle: 'Yeni yaşam alanları',
    icon: Icons.location_city_outlined,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get finance => AppFeature(
    title: 'Finans',
    subtitle: 'Gelir ve giderlerini izle',
    icon: Icons.account_balance_wallet_outlined,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get assets => AppFeature(
    title: 'Varlıklar',
    subtitle: 'Ev ve araçlarını yönet',
    icon: Icons.real_estate_agent_outlined,
    color: AppPalette.primary,
    unlocked: true,
  );
  static AppFeature get company => AppFeature(
    title: 'Şirket',
    subtitle: 'Geleceğin işini kur',
    icon: Icons.business_outlined,
    color: AppPalette.primary,
    unlocked: true,
  );
}
