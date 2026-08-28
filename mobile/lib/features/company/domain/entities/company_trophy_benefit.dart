enum CompanyTrophyBenefitType {
  projectAssurance,
  branchRevenue,
  branchPayroll,
  marketAuthority,
}

class CompanyTrophyBenefit {
  const CompanyTrophyBenefit({
    required this.type,
    required this.requiredTrophies,
    required this.title,
    required this.description,
  });

  final CompanyTrophyBenefitType type;
  final int requiredTrophies;
  final String title;
  final String description;
}
