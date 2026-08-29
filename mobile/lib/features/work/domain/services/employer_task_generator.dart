import '../../../jobs/domain/entities/job.dart';
import '../../../skills/domain/entities/skill_id.dart';
import '../../../skills/domain/entities/skill_profile.dart';
import '../entities/work_task.dart';
import 'contextual_work_task_catalog.dart';

class EmployerTaskGenerator {
  List<WorkTask> generate({
    required Job job,
    required int cityId,
    required int day,
    SkillProfile skills = SkillProfile.empty,
  }) {
    final count = 4 + _seed(job.id, cityId, day) % 3;
    final seed = _seed(job.id, cityId, day);
    final contextual = <ContextualWorkTaskTemplate>[
      ContextualWorkTaskCatalog.forSector(job.careerTrack),
      ContextualWorkTaskCatalog.forStage(job.careerStage),
      ContextualWorkTaskCatalog.forSkill(_strongestSkill(skills, seed)),
    ];
    return List.generate(count, (index) {
      if (index < contextual.length) {
        return _buildContextual(job, day, contextual[index]);
      }
      final template =
          _templates[(seed + index - contextual.length) % _templates.length];
      final id = _taskId(job.id, day, template.code);
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
          for (final entry in job.scaledSkillRequirements.entries)
            entry.key: (entry.value * template.requirementFactor).round().clamp(
              1,
              SkillProfile.maxValue,
            ),
        },
      );
    }, growable: false);
  }

  WorkTask? find({
    required Job job,
    required int cityId,
    required int day,
    required int taskId,
  }) {
    for (final template in ContextualWorkTaskCatalog.forJob(job)) {
      if (_taskId(job.id, day, template.code) == taskId) {
        return _buildContextual(job, day, template);
      }
    }
    for (final template in _templates) {
      if (_taskId(job.id, day, template.code) == taskId) {
        return _buildGeneral(job, day, template);
      }
    }
    return null;
  }

  WorkTask _buildGeneral(Job job, int day, _TaskTemplate template) => WorkTask(
    id: _taskId(job.id, day, template.code),
    jobId: job.id,
    title: '${template.title} · ${job.title}',
    description: template.description,
    energyCost: template.energyCost,
    durationHours: template.durationHours,
    salaryMultiplier: template.salaryMultiplier + job.level * .03,
    performanceGain: template.performanceGain,
    experienceGain: template.experienceGain,
    skillRequirements: _requirements(job, template.requirementFactor),
  );

  WorkTask _buildContextual(
    Job job,
    int day,
    ContextualWorkTaskTemplate template,
  ) => WorkTask(
    id: _taskId(job.id, day, template.code),
    jobId: job.id,
    title: '${template.title} · ${job.title}',
    description: template.description,
    energyCost: template.energyCost,
    durationHours: template.durationHours,
    salaryMultiplier: template.salaryMultiplier + job.level * .03,
    performanceGain: template.performanceGain,
    experienceGain: template.experienceGain,
    skillRequirements: template.focusSkill == null
        ? _requirements(job, template.requirementFactor)
        : {
            template.focusSkill!:
                ((80 + job.level * 70) * template.requirementFactor)
                    .round()
                    .clamp(1, SkillProfile.maxValue),
          },
    contextLabel: template.contextLabel,
  );

  Map<SkillId, int> _requirements(Job job, double factor) => {
    for (final entry in job.scaledSkillRequirements.entries)
      entry.key: (entry.value * factor).round().clamp(1, SkillProfile.maxValue),
  };

  SkillId _strongestSkill(SkillProfile skills, int seed) {
    final ordered = [...SkillId.values]
      ..sort((left, right) {
        final score = skills[right].compareTo(skills[left]);
        return score != 0 ? score : left.index.compareTo(right.index);
      });
    final bestScore = skills[ordered.first];
    final tied = ordered.where((skill) => skills[skill] == bestScore).toList();
    return tied[seed % tied.length];
  }

  int _taskId(int jobId, int day, int templateCode) =>
      jobId * 10000000 + day * 1000 + templateCode;

  int _seed(int first, int second, int third) =>
      (first * 92821 + second * 68917 + third * 31337).abs();

  static const _templates = <_TaskTemplate>[
    _TaskTemplate(
      1,
      'Günlük rapor',
      'Günün verilerini düzenle ve işverene sun.',
      8,
      1,
      .9,
      4,
      4,
      .75,
    ),
    _TaskTemplate(
      2,
      'Müşteri çözümü',
      'Müşteri talebini analiz et ve çözüm üret.',
      10,
      2,
      1.0,
      5,
      5,
      .9,
    ),
    _TaskTemplate(
      3,
      'Süreç iyileştirme',
      'İş akışındaki kaybı tespit edip iyileştirme öner.',
      12,
      3,
      1.1,
      6,
      6,
      1.0,
    ),
    _TaskTemplate(
      4,
      'Ekip koordinasyonu',
      'Günün görevlerini ekip üyeleriyle koordine et.',
      14,
      4,
      1.2,
      7,
      7,
      .85,
    ),
    _TaskTemplate(
      5,
      'Hedef çalışması',
      'İşverenin günlük hedefini tamamla.',
      16,
      5,
      1.3,
      8,
      8,
      1.1,
    ),
    _TaskTemplate(
      6,
      'Stratejik proje',
      'Şirketin gelişim hedefi için stratejik bir proje tamamla.',
      18,
      6,
      1.4,
      9,
      9,
      1.15,
    ),
    _TaskTemplate(
      7,
      'Stok ve kaynak kontrolü',
      'Günlük kaynak kullanımını inceleyip eksikleri raporla.',
      9,
      2,
      .95,
      4,
      4,
      .8,
    ),
    _TaskTemplate(
      8,
      'Acil sorun çözümü',
      'Beklenmedik operasyon sorununu süre dolmadan çöz.',
      15,
      3,
      1.25,
      7,
      7,
      1.05,
    ),
    _TaskTemplate(
      9,
      'Kalite kontrolü',
      'Teslimatları standartlara göre denetle ve hataları azalt.',
      11,
      2,
      1.05,
      5,
      5,
      .9,
    ),
    _TaskTemplate(
      10,
      'Ekip desteği',
      'Ekibin iş akışındaki darboğazları gider.',
      13,
      4,
      1.15,
      6,
      6,
      .85,
    ),
    _TaskTemplate(
      11,
      'Müşteri sunumu',
      'Kritik müşteriye sonuçları ve yeni önerileri sun.',
      17,
      5,
      1.35,
      8,
      8,
      1.1,
    ),
    _TaskTemplate(
      12,
      'İnovasyon çalışması',
      'Yeni bir iş fikrini uygulanabilir plana dönüştür.',
      19,
      6,
      1.5,
      9,
      10,
      1.2,
    ),
  ];
}

class _TaskTemplate {
  const _TaskTemplate(
    this.code,
    this.title,
    this.description,
    this.energyCost,
    this.durationHours,
    this.salaryMultiplier,
    this.performanceGain,
    this.experienceGain,
    this.requirementFactor,
  );

  final int code;
  final String title;
  final String description;
  final int energyCost;
  final int durationHours;
  final double salaryMultiplier;
  final int performanceGain;
  final int experienceGain;
  final double requirementFactor;
}
