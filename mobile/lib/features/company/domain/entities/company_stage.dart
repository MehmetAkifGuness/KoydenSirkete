enum CompanyStage { localEnterprise, regionalCompany, nationalBrand, holding }

class CompanyStageRequirement {
  const CompanyStageRequirement({
    required this.label,
    required this.current,
    required this.target,
    required this.valueLabel,
  });

  final String label;
  final int current;
  final int target;
  final String valueLabel;

  bool get isMet => current >= target;
  double get ratio => target == 0 ? 1 : (current / target).clamp(0, 1);
}

class CompanyStageMilestone {
  const CompanyStageMilestone({
    required this.stage,
    required this.title,
    required this.description,
    required this.requirements,
  });

  final CompanyStage stage;
  final String title;
  final String description;
  final List<CompanyStageRequirement> requirements;

  bool get isUnlocked => requirements.every((requirement) => requirement.isMet);
  double get ratio => requirements.isEmpty
      ? 1
      : requirements.fold<double>(0, (sum, item) => sum + item.ratio) /
            requirements.length;
}
