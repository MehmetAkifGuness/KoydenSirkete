class CarAsset {
  const CarAsset({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.moveDiscountPercent,
    required this.opportunityBonus,
  });

  final int id;
  final String name;
  final String description;
  final int price;
  final int moveDiscountPercent;
  final int opportunityBonus;
}
