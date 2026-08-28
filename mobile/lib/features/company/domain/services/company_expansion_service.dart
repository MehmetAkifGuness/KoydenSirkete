import '../../../../core/errors/game_rule_exception.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_deal.dart';
import '../entities/company_stage.dart';
import 'company_finance_recorder.dart';
import 'company_region_service.dart';

class CompanyDealCheck {
  const CompanyDealCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class CompanyExpansionService {
  CompanyExpansionService({CompanyRegionService? regionService})
    : _regionService = regionService ?? CompanyRegionService();

  final CompanyRegionService _regionService;

  static const deals = <CompanyDeal>[
    CompanyDeal(
      id: 'rota_logistics',
      type: CompanyDealType.acquisition,
      title: 'Rota Lojistik',
      description: 'Yerel teslimat ağını ve müşteri sözleşmelerini devral.',
      cost: 90000,
      minimumStage: CompanyStage.regionalCompany,
      valuationGain: 140000,
      reputationGain: 2,
      marketShareGain: 2,
    ),
    CompanyDeal(
      id: 'mavi_software',
      type: CompanyDealType.acquisition,
      title: 'Mavi Yazılım',
      description: 'Teknoloji ekibini ve kurumsal müşteri portföyünü satın al.',
      cost: 180000,
      minimumStage: CompanyStage.regionalCompany,
      requiredControlledRegions: 1,
      valuationGain: 300000,
      reputationGain: 4,
      marketShareGain: 3,
    ),
    CompanyDeal(
      id: 'anatolian_production',
      type: CompanyDealType.merger,
      title: 'Anadolu Üretim Birliği',
      description: 'Üretim kapasitesini ortak marka altında şirketine kat.',
      cost: 350000,
      minimumStage: CompanyStage.nationalBrand,
      requiredControlledRegions: 2,
      requiredChampionships: 1,
      valuationGain: 600000,
      reputationGain: 7,
      marketShareGain: 5,
    ),
    CompanyDeal(
      id: 'nova_retail_group',
      type: CompanyDealType.merger,
      title: 'Nova Perakende Grubu',
      description: 'Ulusal satış ağını holding yapına dahil et.',
      cost: 800000,
      minimumStage: CompanyStage.holding,
      requiredControlledRegions: 4,
      requiredChampionships: 3,
      valuationGain: 1400000,
      reputationGain: 12,
      marketShareGain: 8,
    ),
    CompanyDeal(
      id: 'city_services_portfolio',
      type: CompanyDealType.marketShareTransfer,
      title: 'Kent Hizmetleri Portföyü',
      description: 'Rakibin yerel sözleşmelerini ve müşteri payını devral.',
      cost: 120000,
      minimumStage: CompanyStage.regionalCompany,
      requiredControlledRegions: 1,
      valuationGain: 70000,
      reputationGain: 2,
      marketShareGain: 3,
    ),
    CompanyDeal(
      id: 'national_distribution_network',
      type: CompanyDealType.marketShareTransfer,
      title: 'Ulusal Dağıtım Ağı',
      description: 'Rakibin iki bölgedeki dağıtım haklarını şirketine geçir.',
      cost: 300000,
      minimumStage: CompanyStage.nationalBrand,
      requiredControlledRegions: 2,
      requiredChampionships: 1,
      valuationGain: 180000,
      reputationGain: 4,
      marketShareGain: 5,
    ),
  ];

  CompanyDealCheck check(PlayerState state, CompanyDeal deal) {
    if (state.companyLevel == 0) {
      return const CompanyDealCheck(
        isEligible: false,
        reason: 'Önce şirketini kurmalısın.',
      );
    }
    if (state.companyExpansion.hasCompleted(deal.id)) {
      return const CompanyDealCheck(
        isEligible: false,
        reason: 'Bu işlem tamamlandı ve kazanımları şirkete işlendi.',
      );
    }
    if (state.companyStageIndex < deal.minimumStage.index) {
      return CompanyDealCheck(
        isEligible: false,
        reason: '${_stageName(deal.minimumStage)} aşaması gerekli.',
      );
    }
    final controlledRegions = _regionService.controlledCount(state);
    if (controlledRegions < deal.requiredControlledRegions) {
      return CompanyDealCheck(
        isEligible: false,
        reason:
            '${deal.requiredControlledRegions} bölge hâkimiyeti gerekli '
            '($controlledRegions/${deal.requiredControlledRegions}).',
      );
    }
    final championships = state.companyCompetition.championships;
    if (championships < deal.requiredChampionships) {
      return CompanyDealCheck(
        isEligible: false,
        reason:
            '${deal.requiredChampionships} sezon şampiyonluğu gerekli '
            '($championships/${deal.requiredChampionships}).',
      );
    }
    if (state.companyFunds < deal.cost) {
      return CompanyDealCheck(
        isEligible: false,
        reason: 'Şirket kasasında ₺${deal.cost} olmalı.',
      );
    }
    return const CompanyDealCheck(
      isEligible: true,
      reason: 'İşlem şirket kasasından finanse edilmeye hazır.',
    );
  }

  PlayerState execute(PlayerState state, CompanyDeal deal) {
    final checkResult = check(state, deal);
    if (!checkResult.isEligible) throw GameRuleException(checkResult.reason);
    return state.copyWith(
      companyFunds: state.companyFunds - deal.cost,
      companyExpansion: state.companyExpansion.complete(deal.id),
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companyExpansion,
        -deal.cost,
      ),
    );
  }

  List<CompanyDeal> completedDeals(PlayerState state) => deals
      .where((deal) => state.companyExpansion.hasCompleted(deal.id))
      .toList(growable: false);

  int valuationGain(PlayerState state) => completedDeals(
    state,
  ).fold(0, (total, deal) => total + deal.valuationGain);

  int reputationGain(PlayerState state) => completedDeals(
    state,
  ).fold(0, (total, deal) => total + deal.reputationGain);

  int marketShareGain(PlayerState state) => completedDeals(
    state,
  ).fold(0, (total, deal) => total + deal.marketShareGain);

  String _stageName(CompanyStage stage) => switch (stage) {
    CompanyStage.localEnterprise => 'Yerel girişim',
    CompanyStage.regionalCompany => 'Bölgesel şirket',
    CompanyStage.nationalBrand => 'Ulusal marka',
    CompanyStage.holding => 'Holding',
  };
}
