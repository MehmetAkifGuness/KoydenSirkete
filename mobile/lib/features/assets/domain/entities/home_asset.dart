class HomeAsset {
  const HomeAsset({
    required this.id,
    required this.cityId,
    required this.name,
    required this.description,
    required this.price,
    required this.comfort,
    required this.energyRecoveryBonus,
    required this.requiredCareerLevel,
  });

  final int id;
  final int cityId;
  final String name;
  final String description;
  final int price;
  final int comfort;
  final int energyRecoveryBonus;
  final int requiredCareerLevel;
}
