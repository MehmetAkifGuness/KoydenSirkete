enum EsnafWheelRewardType {
  empty,
  bigTender,
  luckyDay,
  tipRain,
  smallTip,
  customerPenalty,
  majorPenalty,
}

class EsnafWheelReward {
  const EsnafWheelReward({
    required this.type,
    required this.title,
    required this.description,
    required this.isMajor,
  });

  final EsnafWheelRewardType type;
  final String title;
  final String description;
  final bool isMajor;
}

abstract final class EsnafWheelRewardCatalog {
  static const rewards = <EsnafWheelReward>[
    EsnafWheelReward(
      type: EsnafWheelRewardType.empty,
      title: 'Boş',
      description: 'Bu tur ödül veya ceza yok.',
      isMajor: false,
    ),
    EsnafWheelReward(
      type: EsnafWheelRewardType.bigTender,
      title: 'İhale',
      description: '₺1.000 kazandın.',
      isMajor: true,
    ),
    EsnafWheelReward(
      type: EsnafWheelRewardType.luckyDay,
      title: 'Şans',
      description:
          'Sonraki 2 işte süre ve enerji maliyeti yarıya iner; kazanç 2 katına çıkar.',
      isMajor: true,
    ),
    EsnafWheelReward(
      type: EsnafWheelRewardType.tipRain,
      title: '₺100',
      description: '₺100 kazandın.',
      isMajor: false,
    ),
    EsnafWheelReward(
      type: EsnafWheelRewardType.smallTip,
      title: '₺50',
      description: '₺50 kazandın.',
      isMajor: false,
    ),
    EsnafWheelReward(
      type: EsnafWheelRewardType.customerPenalty,
      title: '-₺50',
      description: '₺50 kaybettin.',
      isMajor: false,
    ),
    EsnafWheelReward(
      type: EsnafWheelRewardType.majorPenalty,
      title: '-₺100',
      description: '₺100 kaybettin.',
      isMajor: false,
    ),
  ];

  static const sectorTypes = <EsnafWheelRewardType>[
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.majorPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.luckyDay,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.bigTender,
    EsnafWheelRewardType.majorPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.smallTip,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.tipRain,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.majorPenalty,
    EsnafWheelRewardType.smallTip,
  ];

  static EsnafWheelReward byType(EsnafWheelRewardType type) =>
      rewards.firstWhere((reward) => reward.type == type);

  static int chancePercent(EsnafWheelRewardType type) =>
      sectorTypes.where((sector) => sector == type).length *
      100 ~/
      sectorTypes.length;
}
