enum CompanyBudgetLevel {
  off('Kapalı', 0),
  low('Düşük', 1),
  medium('Orta', 2),
  high('Yüksek', 3);

  const CompanyBudgetLevel(this.label, this.factor);

  final String label;
  final int factor;
}

enum CompanyBudgetCategory {
  office('Ofis'),
  marketing('Pazarlama'),
  research('Ar-Ge'),
  maintenance('Bakım');

  const CompanyBudgetCategory(this.label);

  final String label;
}

class CompanyBudgetState {
  const CompanyBudgetState({
    this.office = CompanyBudgetLevel.off,
    this.marketing = CompanyBudgetLevel.off,
    this.research = CompanyBudgetLevel.off,
    this.maintenance = CompanyBudgetLevel.off,
  });

  final CompanyBudgetLevel office;
  final CompanyBudgetLevel marketing;
  final CompanyBudgetLevel research;
  final CompanyBudgetLevel maintenance;

  CompanyBudgetLevel levelFor(CompanyBudgetCategory category) =>
      switch (category) {
        CompanyBudgetCategory.office => office,
        CompanyBudgetCategory.marketing => marketing,
        CompanyBudgetCategory.research => research,
        CompanyBudgetCategory.maintenance => maintenance,
      };

  CompanyBudgetState withLevel(
    CompanyBudgetCategory category,
    CompanyBudgetLevel level,
  ) => switch (category) {
    CompanyBudgetCategory.office => CompanyBudgetState(
      office: level,
      marketing: marketing,
      research: research,
      maintenance: maintenance,
    ),
    CompanyBudgetCategory.marketing => CompanyBudgetState(
      office: office,
      marketing: level,
      research: research,
      maintenance: maintenance,
    ),
    CompanyBudgetCategory.research => CompanyBudgetState(
      office: office,
      marketing: marketing,
      research: level,
      maintenance: maintenance,
    ),
    CompanyBudgetCategory.maintenance => CompanyBudgetState(
      office: office,
      marketing: marketing,
      research: research,
      maintenance: level,
    ),
  };

  bool get isDisabled => CompanyBudgetCategory.values.every(
    (category) => levelFor(category) == CompanyBudgetLevel.off,
  );
}
