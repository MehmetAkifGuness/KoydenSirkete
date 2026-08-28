import 'company_stage.dart';

enum CompanyDealType { acquisition, merger, marketShareTransfer }

extension CompanyDealTypeLabel on CompanyDealType {
  String get label => switch (this) {
    CompanyDealType.acquisition => 'Şirket satın alma',
    CompanyDealType.merger => 'Birleşme',
    CompanyDealType.marketShareTransfer => 'Pazar payı devri',
  };
}

class CompanyDeal {
  const CompanyDeal({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.cost,
    required this.minimumStage,
    required this.valuationGain,
    required this.reputationGain,
    required this.marketShareGain,
    this.requiredControlledRegions = 0,
    this.requiredChampionships = 0,
  });

  final String id;
  final CompanyDealType type;
  final String title;
  final String description;
  final int cost;
  final CompanyStage minimumStage;
  final int requiredControlledRegions;
  final int requiredChampionships;
  final int valuationGain;
  final int reputationGain;
  final int marketShareGain;
}
