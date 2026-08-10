enum EsnafWheelRewardType {
  luckyDay,
  esnafBlessing,
  customerPenalty,
  supplierDiscount,
  empty,
  apprenticeMistake,
  fastService,
  tipRain,
  staleDoner,
  bigTender,
}

class EsnafWheelReward {
  const EsnafWheelReward({required this.type, required this.title, required this.description, required this.isMajor});

  final EsnafWheelRewardType type;
  final String title;
  final String description;
  final bool isMajor;
}

abstract final class EsnafWheelRewardCatalog {
  static const rewards = <EsnafWheelReward>[
    EsnafWheelReward(type: EsnafWheelRewardType.luckyDay, title: 'Şans', description: 'Sonraki 2 işte süre ve enerji maliyeti yarıya iner; kazanç 2 katına çıkar.', isMajor: true),
    EsnafWheelReward(type: EsnafWheelRewardType.customerPenalty, title: 'Kötü İş', description: 'İş maaşından 50 TL düştü.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.empty, title: 'Boş', description: 'Hayat normal gidiyor.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.tipRain, title: '100 TL', description: '100 TL kazandın.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.bigTender, title: 'İhale', description: '1.000 TL kazandın.', isMajor: true),
  ];

  static const sectorTypes = <EsnafWheelRewardType>[
    EsnafWheelRewardType.bigTender,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.luckyDay,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.tipRain,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.tipRain,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.empty,
  ];

  static EsnafWheelReward byType(EsnafWheelRewardType type) => rewards.firstWhere((reward) => reward.type == type);
}
