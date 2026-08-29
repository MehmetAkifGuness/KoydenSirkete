import '../../../jobs/domain/entities/job.dart';
import '../../../skills/domain/entities/skill_id.dart';

class ContextualWorkTaskTemplate {
  const ContextualWorkTaskTemplate({
    required this.code,
    required this.title,
    required this.description,
    required this.energyCost,
    required this.durationHours,
    required this.salaryMultiplier,
    required this.performanceGain,
    required this.experienceGain,
    required this.requirementFactor,
    required this.contextLabel,
    this.focusSkill,
  });

  final int code;
  final String title;
  final String description;
  final int energyCost;
  final int durationHours;
  final double salaryMultiplier;
  final int performanceGain;
  final int experienceGain;
  final double requirementFactor;
  final String contextLabel;
  final SkillId? focusSkill;
}

abstract final class ContextualWorkTaskCatalog {
  static ContextualWorkTaskTemplate forSector(String careerTrack) =>
      _sector[careerTrack] ?? _sector['dijital ve operasyon']!;

  static ContextualWorkTaskTemplate forStage(CareerStage stage) =>
      _stage[stage]!;

  static ContextualWorkTaskTemplate forSkill(SkillId skill) => _skill[skill]!;

  static Iterable<ContextualWorkTaskTemplate> forJob(Job job) =>
      <ContextualWorkTaskTemplate>{
        forSector(job.careerTrack),
        forStage(job.careerStage),
        ..._skill.values,
      };

  static const _sector = <String, ContextualWorkTaskTemplate>{
    'satış ve perakende': ContextualWorkTaskTemplate(
      code: 101,
      title: 'Mağaza talep planı',
      description: 'Satış verisini inceleyip mağaza talep planını güncelle.',
      energyCost: 12,
      durationHours: 3,
      salaryMultiplier: 1.1,
      performanceGain: 6,
      experienceGain: 6,
      requirementFactor: .9,
      contextLabel: 'Sektör · Perakende',
    ),
    'finans': ContextualWorkTaskTemplate(
      code: 102,
      title: 'Finansal risk kontrolü',
      description: 'Nakit akışındaki sapmaları ve finansal riskleri raporla.',
      energyCost: 14,
      durationHours: 4,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 7,
      requirementFactor: 1,
      contextLabel: 'Sektör · Finans',
    ),
    'lojistik': ContextualWorkTaskTemplate(
      code: 103,
      title: 'Tedarik akışı kontrolü',
      description: 'Teslimat akışını denetleyip gecikme riskini azalt.',
      energyCost: 15,
      durationHours: 4,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 7,
      requirementFactor: 1,
      contextLabel: 'Sektör · Lojistik',
    ),
    'dijital ve operasyon': ContextualWorkTaskTemplate(
      code: 104,
      title: 'Dijital süreç denetimi',
      description: 'Ürün verisini inceleyip dijital iş akışını iyileştir.',
      energyCost: 14,
      durationHours: 4,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 7,
      requirementFactor: 1,
      contextLabel: 'Sektör · Teknoloji',
    ),
  };

  static const _stage = <CareerStage, ContextualWorkTaskTemplate>{
    CareerStage.entry: ContextualWorkTaskTemplate(
      code: 201,
      title: 'Görev desteği',
      description:
          'Ekibin günlük iş listesinden sorumluluğundaki adımı tamamla.',
      energyCost: 9,
      durationHours: 2,
      salaryMultiplier: .95,
      performanceGain: 5,
      experienceGain: 5,
      requirementFactor: .7,
      contextLabel: 'Pozisyon · Başlangıç',
    ),
    CareerStage.specialist: ContextualWorkTaskTemplate(
      code: 202,
      title: 'Uzmanlık incelemesi',
      description:
          'Alanındaki bir sorunu inceleyip uygulanabilir çözüm hazırla.',
      energyCost: 12,
      durationHours: 3,
      salaryMultiplier: 1.1,
      performanceGain: 6,
      experienceGain: 7,
      requirementFactor: .9,
      contextLabel: 'Pozisyon · Uzman',
    ),
    CareerStage.senior: ContextualWorkTaskTemplate(
      code: 203,
      title: 'Kıdemli değerlendirmesi',
      description:
          'Karmaşık bir işi değerlendirip ekibe çözüm standardı oluştur.',
      energyCost: 15,
      durationHours: 4,
      salaryMultiplier: 1.25,
      performanceGain: 7,
      experienceGain: 8,
      requirementFactor: 1,
      contextLabel: 'Pozisyon · Kıdemli',
    ),
    CareerStage.manager: ContextualWorkTaskTemplate(
      code: 204,
      title: 'Ekip hedefi yönetimi',
      description:
          'Ekip önceliklerini belirleyip günlük hedefleri koordine et.',
      energyCost: 17,
      durationHours: 5,
      salaryMultiplier: 1.35,
      performanceGain: 8,
      experienceGain: 9,
      requirementFactor: 1.1,
      contextLabel: 'Pozisyon · Yönetim',
    ),
    CareerStage.executive: ContextualWorkTaskTemplate(
      code: 205,
      title: 'Yönetim kurulu planı',
      description:
          'Birimler arası hedefleri şirket stratejisiyle uyumlu hâle getir.',
      energyCost: 19,
      durationHours: 6,
      salaryMultiplier: 1.5,
      performanceGain: 9,
      experienceGain: 10,
      requirementFactor: 1.2,
      contextLabel: 'Pozisyon · Üst yönetim',
    ),
  };

  static const _skill = <SkillId, ContextualWorkTaskTemplate>{
    SkillId.communication: ContextualWorkTaskTemplate(
      code: 301,
      title: 'Paydaş görüşmesi',
      description:
          'Paydaş beklentilerini netleştirip ortak bir eylem planı çıkar.',
      energyCost: 10,
      durationHours: 2,
      salaryMultiplier: 1.05,
      performanceGain: 6,
      experienceGain: 6,
      requirementFactor: .9,
      contextLabel: 'Yetenek · İletişim',
      focusSkill: SkillId.communication,
    ),
    SkillId.sales: ContextualWorkTaskTemplate(
      code: 302,
      title: 'Teklif geliştirme',
      description:
          'Müşteri ihtiyacına uygun, ikna edici bir ticari teklif hazırla.',
      energyCost: 12,
      durationHours: 3,
      salaryMultiplier: 1.15,
      performanceGain: 6,
      experienceGain: 7,
      requirementFactor: .95,
      contextLabel: 'Yetenek · Satış',
      focusSkill: SkillId.sales,
    ),
    SkillId.accounting: ContextualWorkTaskTemplate(
      code: 303,
      title: 'Bütçe mutabakatı',
      description: 'Kayıtlarla bütçe kalemlerini karşılaştırıp farkları gider.',
      energyCost: 12,
      durationHours: 3,
      salaryMultiplier: 1.15,
      performanceGain: 6,
      experienceGain: 7,
      requirementFactor: .95,
      contextLabel: 'Yetenek · Muhasebe',
      focusSkill: SkillId.accounting,
    ),
    SkillId.analysis: ContextualWorkTaskTemplate(
      code: 304,
      title: 'Veri analizi',
      description: 'Güncel veriden kararları destekleyecek içgörüler çıkar.',
      energyCost: 13,
      durationHours: 3,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 7,
      requirementFactor: 1,
      contextLabel: 'Yetenek · Analiz',
      focusSkill: SkillId.analysis,
    ),
    SkillId.logistics: ContextualWorkTaskTemplate(
      code: 305,
      title: 'Rota optimizasyonu',
      description:
          'Kaynak ve teslimat rotasını daha verimli olacak şekilde düzenle.',
      energyCost: 14,
      durationHours: 4,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 8,
      requirementFactor: 1,
      contextLabel: 'Yetenek · Lojistik',
      focusSkill: SkillId.logistics,
    ),
    SkillId.digital: ContextualWorkTaskTemplate(
      code: 306,
      title: 'Dijital araç kurulumu',
      description:
          'Tekrarlanan bir işi dijital araçlarla daha verimli hâle getir.',
      energyCost: 13,
      durationHours: 3,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 8,
      requirementFactor: 1,
      contextLabel: 'Yetenek · Dijital',
      focusSkill: SkillId.digital,
    ),
    SkillId.leadership: ContextualWorkTaskTemplate(
      code: 307,
      title: 'Ekip yönlendirmesi',
      description:
          'Ekibin önündeki engelleri kaldırıp sorumlulukları netleştir.',
      energyCost: 15,
      durationHours: 4,
      salaryMultiplier: 1.25,
      performanceGain: 8,
      experienceGain: 8,
      requirementFactor: 1.05,
      contextLabel: 'Yetenek · Liderlik',
      focusSkill: SkillId.leadership,
    ),
    SkillId.operations: ContextualWorkTaskTemplate(
      code: 308,
      title: 'Operasyon düzenleme',
      description: 'Günlük iş akışındaki darboğazı tespit edip gider.',
      energyCost: 14,
      durationHours: 4,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 8,
      requirementFactor: 1,
      contextLabel: 'Yetenek · Operasyon',
      focusSkill: SkillId.operations,
    ),
    SkillId.creativity: ContextualWorkTaskTemplate(
      code: 309,
      title: 'Yeni çözüm tasarımı',
      description:
          'Mevcut bir soruna farklı ve uygulanabilir bir çözüm tasarla.',
      energyCost: 13,
      durationHours: 3,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 8,
      requirementFactor: 1,
      contextLabel: 'Yetenek · Yaratıcılık',
      focusSkill: SkillId.creativity,
    ),
    SkillId.negotiation: ContextualWorkTaskTemplate(
      code: 310,
      title: 'Koşul müzakeresi',
      description:
          'Tarafların önceliklerini dengeleyen anlaşma koşulları oluştur.',
      energyCost: 14,
      durationHours: 4,
      salaryMultiplier: 1.25,
      performanceGain: 8,
      experienceGain: 8,
      requirementFactor: 1.05,
      contextLabel: 'Yetenek · Müzakere',
      focusSkill: SkillId.negotiation,
    ),
  };
}
