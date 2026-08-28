enum CompanySeasonRewardType {
  trophy,
  sponsorship,
  projectInvitation,
  reputation,
  none,
}

class CompanySeasonReward {
  const CompanySeasonReward({
    required this.seasonNumber,
    required this.rank,
    required this.type,
    required this.value,
    this.consumed = false,
  });

  final int seasonNumber;
  final int rank;
  final CompanySeasonRewardType type;
  final int value;
  final bool consumed;

  String get title => switch (type) {
    CompanySeasonRewardType.trophy => 'Şampiyonluk kupası',
    CompanySeasonRewardType.sponsorship => 'Gelir sponsorluğu',
    CompanySeasonRewardType.projectInvitation => 'Özel proje daveti',
    CompanySeasonRewardType.reputation => 'Sektör itibarı',
    CompanySeasonRewardType.none => 'Derece ödülü yok',
  };

  String get description => switch (type) {
    CompanySeasonRewardType.trophy => 'Kalıcı kupa avantajlarına ilerleme',
    CompanySeasonRewardType.sponsorship =>
      'Sonraki sezon şirket gelirlerine +%$value',
    CompanySeasonRewardType.projectInvitation =>
      consumed
          ? 'Özel proje daveti kullanıldı'
          : '$value adet tek kullanımlık özel proje hakkı',
    CompanySeasonRewardType.reputation => 'Kalıcı +$value itibar',
    CompanySeasonRewardType.none => 'Bu sezon ek ödül kazanılmadı',
  };

  CompanySeasonReward copyWith({bool? consumed}) => CompanySeasonReward(
    seasonNumber: seasonNumber,
    rank: rank,
    type: type,
    value: value,
    consumed: consumed ?? this.consumed,
  );
}
