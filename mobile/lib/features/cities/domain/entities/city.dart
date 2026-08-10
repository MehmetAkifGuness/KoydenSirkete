enum CityEconomicLevel { regional, developing, metropolis, economicCenter }

class City {
  const City({
    required this.id,
    required this.name,
    required this.description,
    required this.dailyCost,
    required this.moveCost,
    required this.minimumCareerLevel,
    this.salaryMultiplier = 1,
    this.opportunityCount = 3,
    this.maximumJobLevel = 2,
    this.economicLevel = CityEconomicLevel.regional,
    this.population = 0,
    this.technologyLevel = 0,
    this.marketLevel = 0,
  });

  final int id;
  final String name;
  final String description;
  final int dailyCost;
  final int moveCost;
  final int minimumCareerLevel;
  final double salaryMultiplier;
  final int opportunityCount;
  final int maximumJobLevel;
  final CityEconomicLevel economicLevel;
  final int population;
  final int technologyLevel;
  final int marketLevel;
}
