class City {
  const City({
    required this.id,
    required this.name,
    required this.description,
    required this.dailyCost,
    required this.moveCost,
    required this.minimumCareerLevel,
  });

  final int id;
  final String name;
  final String description;
  final int dailyCost;
  final int moveCost;
  final int minimumCareerLevel;
}
