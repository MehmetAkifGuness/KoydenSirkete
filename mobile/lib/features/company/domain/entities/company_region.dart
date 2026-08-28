enum CompanyRegion {
  marmara,
  aegean,
  mediterranean,
  centralAnatolia,
  blackSea,
  easternAnatolia,
  southeasternAnatolia,
}

class CompanyRegionDefinition {
  const CompanyRegionDefinition({
    required this.region,
    required this.name,
    required this.advantage,
    required this.cityNames,
  });

  final CompanyRegion region;
  final String name;
  final String advantage;
  final Set<String> cityNames;
}

class CompanyRegionProgress {
  const CompanyRegionProgress({
    required this.definition,
    required this.branchCount,
    required this.influence,
  });

  static const controlTarget = 4;

  final CompanyRegionDefinition definition;
  final int branchCount;
  final int influence;

  bool get isControlled => influence >= controlTarget;
  double get ratio => (influence / controlTarget).clamp(0, 1);
}
