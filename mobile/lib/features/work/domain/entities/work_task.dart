class WorkTask {
  const WorkTask({
    required this.id,
    required this.jobId,
    required this.title,
    required this.description,
    required this.energyCost,
    required this.durationHours,
    required this.salaryMultiplier,
    required this.performanceGain,
    required this.experienceGain,
  });

  final int id;
  final int jobId;
  final String title;
  final String description;
  final int energyCost;
  final int durationHours;
  final double salaryMultiplier;
  final int performanceGain;
  final int experienceGain;
}
