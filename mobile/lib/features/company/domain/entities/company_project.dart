class CompanyProject {
  const CompanyProject({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.reward,
    required this.progressPerEmployee,
    required this.experienceReward,
  });

  final int id;
  final String name;
  final String description;
  final int cost;
  final int reward;
  final int progressPerEmployee;
  final int experienceReward;
}
