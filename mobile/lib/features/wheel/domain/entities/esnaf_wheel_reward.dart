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
    EsnafWheelReward(type: EsnafWheelRewardType.luckyDay, title: 'Şanslı Gün', description: 'Sonraki 2 iş görevinin süresi %50 kısalır.', isMajor: true),
    EsnafWheelReward(type: EsnafWheelRewardType.esnafBlessing, title: 'Esnaf Hayır Duası', description: '+30 TL bahşiş aldın.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.customerPenalty, title: 'Müşteri Kazığı', description: '-25 TL kaybettin.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.supplierDiscount, title: 'Tedarikçi İndirimi', description: 'Sonraki 2 iş görevinin enerji maliyeti %20 azalır.', isMajor: true),
    EsnafWheelReward(type: EsnafWheelRewardType.empty, title: 'Esnaf Çayı', description: 'Bugün sadece çay çıktı; ne kazandın ne kaybettin.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.apprenticeMistake, title: 'Çırak Hatası', description: 'Devam eden işine 1 oyun saati eklendi.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.fastService, title: 'Hızlı Servis', description: 'Sonraki 2 iş görevinin süresi %25 kısalır.', isMajor: true),
    EsnafWheelReward(type: EsnafWheelRewardType.tipRain, title: 'Bahşiş Yağmuru', description: '+60 TL anlık bahşiş aldın.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.staleDoner, title: 'Bayat Döner', description: 'Bugün şansın da dönerin de nötr kaldı.', isMajor: false),
    EsnafWheelReward(type: EsnafWheelRewardType.bigTender, title: 'Büyük İhale Fırsatı', description: '+250 TL sermaye kazandın.', isMajor: true),
  ];

  static const sectorTypes = <EsnafWheelRewardType>[
    EsnafWheelRewardType.bigTender,
    EsnafWheelRewardType.luckyDay,
    EsnafWheelRewardType.tipRain,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.staleDoner,
    EsnafWheelRewardType.apprenticeMistake,
    EsnafWheelRewardType.tipRain,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.staleDoner,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.apprenticeMistake,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.staleDoner,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.customerPenalty,
    EsnafWheelRewardType.empty,
    EsnafWheelRewardType.customerPenalty,
  ];

  static EsnafWheelReward byType(EsnafWheelRewardType type) => rewards.firstWhere((reward) => reward.type == type);
}
