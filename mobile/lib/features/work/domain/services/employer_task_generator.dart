import '../../../jobs/domain/entities/job.dart';
import '../../../skills/domain/entities/skill_profile.dart';
import '../entities/work_task.dart';

class EmployerTaskGenerator {
  List<WorkTask> generate({required Job job, required int cityId, required int day}) {
    final count = 3 + _seed(job.id, cityId, day) % 3;
    return List.generate(count, (index) {
      final template = _templates[(_seed(job.id, cityId, day) + index) % _templates.length];
      final id = job.id * 100000 + day * 10 + index;
      return WorkTask(
        id: id,
        jobId: job.id,
        title: '${template.title} · ${job.title}',
        description: template.description,
        energyCost: template.energyCost,
        durationHours: template.durationHours,
        salaryMultiplier: template.salaryMultiplier + job.level * .03,
        performanceGain: template.performanceGain,
        experienceGain: template.experienceGain,
        skillRequirements: {
          for (final entry in job.scaledSkillRequirements.entries) entry.key: (entry.value * template.requirementFactor).round().clamp(1, SkillProfile.maxValue),
        },
      );
    }, growable: false);
  }

  WorkTask? find({required Job job, required int cityId, required int day, required int taskId}) {
    for (final task in generate(job: job, cityId: cityId, day: day)) {
      if (task.id == taskId) return task;
    }
    return null;
  }

  int _seed(int first, int second, int third) => (first * 92821 + second * 68917 + third * 31337).abs();

  static const _templates = <_TaskTemplate>[
    _TaskTemplate('Günlük rapor', 'Günün verilerini düzenle ve işverene sun.', 10, 2, 1.0, 5, 5, .75),
    _TaskTemplate('Müşteri çözümü', 'Müşteri talebini analiz et ve çözüm üret.', 12, 3, 1.1, 6, 6, .9),
    _TaskTemplate('Süreç iyileştirme', 'İş akışındaki kaybı tespit edip iyileştirme öner.', 14, 4, 1.2, 7, 7, 1.0),
    _TaskTemplate('Ekip koordinasyonu', 'Günün görevlerini ekip üyeleriyle koordine et.', 16, 5, 1.15, 6, 8, .85),
    _TaskTemplate('Hedef çalışması', 'İşverenin günlük hedefini tamamla.', 18, 6, 1.3, 8, 9, 1.1),
    _TaskTemplate('Stratejik proje', 'Şirketin gelişim hedefi için stratejik bir proje tamamla.', 20, 7, 1.4, 9, 10, 1.15),
  ];
}

class _TaskTemplate {
  const _TaskTemplate(this.title, this.description, this.energyCost, this.durationHours, this.salaryMultiplier, this.performanceGain, this.experienceGain, this.requirementFactor);

  final String title;
  final String description;
  final int energyCost;
  final int durationHours;
  final double salaryMultiplier;
  final int performanceGain;
  final int experienceGain;
  final double requirementFactor;
}
