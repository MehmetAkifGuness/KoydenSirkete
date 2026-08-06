import '../../../jobs/domain/entities/job.dart';
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
        energyCost: (template.energyCost + job.level * 2).clamp(5, 100),
        durationHours: (template.durationHours + job.level % 3).clamp(1, 24),
        salaryMultiplier: template.salaryMultiplier + job.level * .03,
        performanceGain: template.performanceGain,
        experienceGain: template.experienceGain + job.level,
        skillRequirements: {
          for (final entry in job.skillRequirements.entries) entry.key: (entry.value * template.requirementFactor).round().clamp(1, 100),
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
    _TaskTemplate('Günlük rapor', 'Günün verilerini düzenle ve işverene sun.', 18, 4, 1.0, 5, 4, .75),
    _TaskTemplate('Müşteri çözümü', 'Müşteri talebini analiz et ve çözüm üret.', 22, 5, 1.1, 6, 5, .9),
    _TaskTemplate('Süreç iyileştirme', 'İş akışındaki kaybı tespit edip iyileştirme öner.', 26, 6, 1.2, 7, 6, 1.0),
    _TaskTemplate('Ekip koordinasyonu', 'Günün görevlerini ekip üyeleriyle koordine et.', 24, 5, 1.15, 6, 6, .85),
    _TaskTemplate('Hedef çalışması', 'İşverenin günlük hedefini tamamla.', 30, 7, 1.3, 8, 7, 1.1),
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
