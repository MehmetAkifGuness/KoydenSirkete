import '../entities/course.dart';

abstract final class TrainingCatalog {
  static const version = 2;

  static const courses = [
    Course(
      id: 'free-practice',
      name: 'Ücretsiz pratik',
      description: 'Para harcamadan temel bilgini geliştir.',
      cost: 0,
      durationHours: 3,
      energyCost: 10,
      knowledge: 3,
      experience: 4,
    ),
    Course(
      id: 'standard-course',
      name: 'Standart kurs',
      description: 'Dengeli maliyet ve güçlü bilgi kazanımı.',
      cost: 80,
      durationHours: 4,
      energyCost: 15,
      knowledge: 12,
      experience: 2,
    ),
    Course(
      id: 'intensive-course',
      name: 'Yoğun eğitim',
      description: 'Daha hızlı gelişim için yüksek maliyetli eğitim.',
      cost: 150,
      durationHours: 6,
      energyCost: 25,
      knowledge: 20,
      experience: 4,
    ),
    Course(
      id: 'expert-course',
      name: 'Uzmanlık programı',
      description: 'İleri kariyer seviyeleri için kapsamlı bilgi ve tecrübe kazan.',
      cost: 300,
      durationHours: 8,
      energyCost: 30,
      knowledge: 35,
      experience: 8,
    ),
  ];
}
