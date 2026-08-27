import '../../../skills/domain/entities/skill_id.dart';
import '../entities/course.dart';

abstract final class TrainingCatalog {
  static const version = 3;

  static const _generalCourses = <Course>[
    Course(
      id: 'free-practice',
      name: 'Ücretsiz pratik',
      description: 'Para harcamadan genel bilgini geliştir.',
      cost: 0,
      durationHours: 3,
      energyCost: 10,
      knowledge: 3,
      experience: 4,
    ),
    Course(
      id: 'standard-course',
      name: 'Standart kurs',
      description: 'Dengeli maliyet ve güçlü genel bilgi kazanımı.',
      cost: 80,
      durationHours: 4,
      energyCost: 15,
      knowledge: 12,
      experience: 2,
    ),
    Course(
      id: 'intensive-course',
      name: 'Yoğun eğitim',
      description: 'Daha hızlı genel gelişim için yüksek maliyetli eğitim.',
      cost: 150,
      durationHours: 6,
      energyCost: 25,
      knowledge: 20,
      experience: 4,
    ),
    Course(
      id: 'expert-course',
      name: 'Uzmanlık programı',
      description:
          'İleri kariyer seviyeleri için genel bilgi ve tecrübe kazan.',
      cost: 300,
      durationHours: 8,
      energyCost: 30,
      knowledge: 35,
      experience: 8,
    ),
    Course(
      id: 'commercial-negotiation',
      name: 'Ticari müzakere',
      description: 'Satış ve müzakereyi birlikte uygula.',
      cost: 220,
      durationHours: 6,
      energyCost: 22,
      knowledge: 14,
      experience: 6,
      skillDeltas: {SkillId.sales: 8, SkillId.negotiation: 8},
    ),
    Course(
      id: 'operations-leadership',
      name: 'Operasyon liderliği',
      description: 'Operasyon ve liderlik becerilerini birlikte geliştir.',
      cost: 240,
      durationHours: 6,
      energyCost: 23,
      knowledge: 15,
      experience: 7,
      skillDeltas: {SkillId.operations: 8, SkillId.leadership: 8},
    ),
  ];

  static const _levels = <_SkillLevel>[
    _SkillLevel('başlangıç', 90, 3, 12, 8),
    _SkillLevel('orta', 160, 5, 20, 14),
    _SkillLevel('ileri', 280, 7, 32, 22),
  ];

  static final courses = List<Course>.unmodifiable([
    ..._generalCourses,
    for (final skill in SkillId.values)
      for (final level in _levels)
        Course(
          id: '${skill.name}-${level.name}',
          name: '${skill.label} ${level.name}',
          description: '${skill.label} alanında ${level.name} seviye eğitim.',
          cost: level.cost,
          durationHours: level.durationHours,
          energyCost: level.energyCost,
          knowledge: level.skillGain + 4,
          experience: level.skillGain ~/ 2,
          skillDeltas: {skill: level.skillGain},
        ),
  ]);

  static Course? findById(String id) {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }
}

class _SkillLevel {
  const _SkillLevel(
    this.name,
    this.cost,
    this.durationHours,
    this.energyCost,
    this.skillGain,
  );

  final String name;
  final int cost;
  final int durationHours;
  final int energyCost;
  final int skillGain;
}
