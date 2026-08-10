import '../entities/work_task.dart';
import '../../../skills/domain/entities/skill_id.dart';

abstract final class WorkTaskCatalog {
  static const tasks = <WorkTask>[
    WorkTask(
      id: 1,
      jobId: 1,
      title: 'Müşteri desteği',
      description: 'Müşterilere yardımcı ol ve iletişim becerini geliştir.',
      energyCost: 10,
      durationHours: 2,
      salaryMultiplier: 1,
      performanceGain: 5,
      experienceGain: 5,
      skillRequirements: {SkillId.communication: 200, SkillId.sales: 100},
    ),
    WorkTask(
      id: 2,
      jobId: 1,
      title: 'Satış hedefi',
      description: 'Günün satış hedefini tamamla ve daha yüksek gelir kazan.',
      energyCost: 12,
      durationHours: 3,
      salaryMultiplier: 1.2,
      performanceGain: 7,
      experienceGain: 6,
      skillRequirements: {SkillId.sales: 250, SkillId.negotiation: 150},
    ),
    WorkTask(
      id: 3,
      jobId: 2,
      title: 'Vardiya planı',
      description: 'Ekibin vardiya planını hazırla ve operasyonu düzenle.',
      energyCost: 14,
      durationHours: 4,
      salaryMultiplier: 1,
      performanceGain: 5,
      experienceGain: 7,
      skillRequirements: {SkillId.leadership: 200, SkillId.operations: 200},
    ),
    WorkTask(
      id: 4,
      jobId: 3,
      title: 'Bölge raporu',
      description: 'Mağaza sonuçlarını analiz et ve büyüme önerisi hazırla.',
      energyCost: 16,
      durationHours: 5,
      salaryMultiplier: 1,
      performanceGain: 4,
      experienceGain: 8,
      skillRequirements: {SkillId.analysis: 250, SkillId.leadership: 150},
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
      experienceGain: 9,
      skillRequirements: {SkillId.accounting: 200, SkillId.analysis: 150},
    ),
    WorkTask(
      id: 6,
      jobId: 5,
      title: 'Bütçe analizi',
      description: 'Bütçe sapmalarını incele ve iyileştirme önerisi geliştir.',
      energyCost: 20,
      durationHours: 7,
      salaryMultiplier: 1,
      performanceGain: 5,
      experienceGain: 10,
      skillRequirements: {SkillId.accounting: 300, SkillId.analysis: 250},
    ),
    WorkTask(
      id: 7,
      jobId: 6,
      title: 'Rota planı',
      description: 'Sevkiyat rotalarını planla ve teslimat verimliliğini artır.',
      energyCost: 20,
      durationHours: 7,
      salaryMultiplier: 1.1,
      performanceGain: 5,
      experienceGain: 10,
      skillRequirements: {SkillId.logistics: 250, SkillId.operations: 200},
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
