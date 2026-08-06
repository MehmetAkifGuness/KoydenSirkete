import '../entities/work_task.dart';
import '../../../skills/domain/entities/skill_id.dart';

abstract final class WorkTaskCatalog {
  static const tasks = <WorkTask>[
    WorkTask(
      id: 1,
      jobId: 1,
      title: 'Müşteri desteği',
      description: 'Müşterilere yardımcı ol ve iletişim becerini geliştir.',
      energyCost: 20,
      durationHours: 8,
      salaryMultiplier: 1,
      performanceGain: 5,
      experienceGain: 4,
      skillRequirements: {SkillId.communication: 20, SkillId.sales: 10},
    ),
    WorkTask(
      id: 2,
      jobId: 1,
      title: 'Satış hedefi',
      description: 'Günün satış hedefini tamamla ve daha yüksek gelir kazan.',
      energyCost: 25,
      durationHours: 6,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 5,
      skillRequirements: {SkillId.sales: 25, SkillId.negotiation: 15},
    ),
    WorkTask(
      id: 3,
      jobId: 2,
      title: 'Vardiya planı',
      description: 'Ekibin vardiya planını hazırla ve operasyonu düzenle.',
      energyCost: 24,
      durationHours: 8,
      salaryMultiplier: 1,
      performanceGain: 5,
      experienceGain: 7,
      skillRequirements: {SkillId.leadership: 20, SkillId.operations: 20},
    ),
    WorkTask(
      id: 4,
      jobId: 3,
      title: 'Bölge raporu',
      description: 'Mağaza sonuçlarını analiz et ve büyüme önerisi hazırla.',
      energyCost: 28,
      durationHours: 8,
      salaryMultiplier: 1,
      performanceGain: 4,
      experienceGain: 9,
      skillRequirements: {SkillId.analysis: 25, SkillId.leadership: 15},
    ),
    WorkTask(
      id: 5,
      jobId: 4,
      title: 'Finans kaydı',
      description: 'Günlük finans hareketlerini kaydet ve raporlamaya hazırla.',
      energyCost: 18,
      durationHours: 6,
      salaryMultiplier: 1,
      performanceGain: 6,
      experienceGain: 5,
      skillRequirements: {SkillId.accounting: 20, SkillId.analysis: 15},
    ),
    WorkTask(
      id: 6,
      jobId: 5,
      title: 'Bütçe analizi',
      description: 'Bütçe sapmalarını incele ve iyileştirme önerisi geliştir.',
      energyCost: 25,
      durationHours: 8,
      salaryMultiplier: 1,
      performanceGain: 5,
      experienceGain: 8,
      skillRequirements: {SkillId.accounting: 30, SkillId.analysis: 25},
    ),
    WorkTask(
      id: 7,
      jobId: 6,
      title: 'Rota planı',
      description: 'Sevkiyat rotalarını planla ve teslimat verimliliğini artır.',
      energyCost: 24,
      durationHours: 8,
      salaryMultiplier: 1.1,
      performanceGain: 5,
      experienceGain: 7,
      skillRequirements: {SkillId.logistics: 25, SkillId.operations: 20},
    ),
  ];

  static List<WorkTask> forJob(int jobId) => tasks.where((task) => task.jobId == jobId).toList(growable: false);

  static WorkTask? findById(int id) {
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }
}
