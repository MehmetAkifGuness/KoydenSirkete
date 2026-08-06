import 'package:flutter/material.dart';

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
  static const earning = AppFeature(
    title: 'Para kazan',
    subtitle: 'İlk sermayeni oluştur',
    icon: Icons.payments_outlined,
    color: Color(0xFFDDBA3E),
    unlocked: true,
  );
  static const training = AppFeature(
    title: 'Eğitim',
    subtitle: 'Bilgi ve becerilerini geliştir',
    icon: Icons.school_outlined,
    color: Color(0xFFDDBA3E),
    unlocked: true,
  );
  static const skills = AppFeature(
    title: 'Yetenekler',
    subtitle: 'Mesleki alanlarını geliştir',
    icon: Icons.auto_awesome_outlined,
    color: Color(0xFFDDBA3E),
    unlocked: true,
  );
  static const sport = AppFeature(
    title: 'Spor',
    subtitle: 'Maksimum enerjini artır',
    icon: Icons.fitness_center_outlined,
    color: Color(0xFFDDBA3E),
    unlocked: true,
  );
  static const jobs = AppFeature(
    title: 'İş ilanları',
    subtitle: 'İlk fırsatını bul',
    icon: Icons.work_outline,
    color: Color(0xFFDDBA3E),
    unlocked: true,
  );
  static const career = AppFeature(
    title: 'Kariyer',
    subtitle: 'İlerleme yolunu gör',
    icon: Icons.trending_up,
    color: Color(0xFFDDBA3E),
    unlocked: true,
  );
  static const cities = AppFeature(
    title: 'Şehirler',
    subtitle: 'Yeni yaşam alanları',
    icon: Icons.location_city_outlined,
    color: Color(0xFFDDBA3E),
    unlocked: true,
  );
  static const company = AppFeature(
    title: 'Şirket',
    subtitle: 'Geleceğin işini kur',
    icon: Icons.business_outlined,
    color: Color(0xFFDDBA3E),
    unlocked: true,
  );
}
