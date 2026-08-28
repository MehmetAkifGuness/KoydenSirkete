import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_region.dart';

class CompanyRegionService {
  static const branchRevenueBonusPercent = 8;
  static const projectSuccessBonusPercent = 5;
  static const positiveMarketBonusPercent = 10;
  static const branchPayrollDiscountPercent = 8;
  static const moraleLossReduction = 1;
  static const branchInvestmentDiscountPercent = 10;
  static const projectProgressBonus = 1;

  static const definitions = <CompanyRegionDefinition>[
    CompanyRegionDefinition(
      region: CompanyRegion.marmara,
      name: 'Marmara',
      advantage: 'Tüm bayi gelirleri +%8',
      cityNames: {
        'Balıkesir',
        'Bilecik',
        'Bursa',
        'Çanakkale',
        'Edirne',
        'İstanbul',
        'Kırklareli',
        'Kocaeli',
        'Sakarya',
        'Tekirdağ',
        'Yalova',
      },
    ),
    CompanyRegionDefinition(
      region: CompanyRegion.aegean,
      name: 'Ege',
      advantage: 'Proje başarı ihtimali +%5',
      cityNames: {
        'Afyonkarahisar',
        'Aydın',
        'Denizli',
        'İzmir',
        'Kütahya',
        'Manisa',
        'Muğla',
        'Uşak',
      },
    ),
    CompanyRegionDefinition(
      region: CompanyRegion.mediterranean,
      name: 'Akdeniz',
      advantage: 'Olumlu piyasa kazancı +%10',
      cityNames: {
        'Adana',
        'Antalya',
        'Burdur',
        'Hatay',
        'Isparta',
        'Kahramanmaraş',
        'Mersin',
        'Osmaniye',
      },
    ),
    CompanyRegionDefinition(
      region: CompanyRegion.centralAnatolia,
      name: 'İç Anadolu',
      advantage: 'Tüm bayi maaşları -%8',
      cityNames: {
        'Ankara',
        'Aksaray',
        'Çankırı',
        'Eskişehir',
        'Karaman',
        'Kayseri',
        'Kırıkkale',
        'Kırşehir',
        'Konya',
        'Nevşehir',
        'Niğde',
        'Sivas',
        'Yozgat',
      },
    ),
    CompanyRegionDefinition(
      region: CompanyRegion.blackSea,
      name: 'Karadeniz',
      advantage: 'Olumsuz moral kaybı 1 azalır',
      cityNames: {
        'Amasya',
        'Artvin',
        'Bartın',
        'Bayburt',
        'Bolu',
        'Çorum',
        'Düzce',
        'Giresun',
        'Gümüşhane',
        'Karabük',
        'Kastamonu',
        'Ordu',
        'Rize',
        'Samsun',
        'Sinop',
        'Tokat',
        'Trabzon',
        'Zonguldak',
      },
    ),
    CompanyRegionDefinition(
      region: CompanyRegion.easternAnatolia,
      name: 'Doğu Anadolu',
      advantage: 'Bayi yatırımları -%10',
      cityNames: {
        'Ağrı',
        'Ardahan',
        'Bingöl',
        'Bitlis',
        'Elazığ',
        'Erzincan',
        'Erzurum',
        'Hakkari',
        'Iğdır',
        'Kars',
        'Malatya',
        'Muş',
        'Tunceli',
        'Van',
      },
    ),
    CompanyRegionDefinition(
      region: CompanyRegion.southeasternAnatolia,
      name: 'Güneydoğu Anadolu',
      advantage: 'Günlük proje ilerlemesi +1',
      cityNames: {
        'Adıyaman',
        'Batman',
        'Diyarbakır',
        'Gaziantep',
        'Kilis',
        'Mardin',
        'Siirt',
        'Şanlıurfa',
        'Şırnak',
      },
    ),
  ];

  static final _definitionByCityId = <int, CompanyRegionDefinition>{
    for (final city in CityCatalog.cities)
      city.id: definitions.firstWhere(
        (definition) => definition.cityNames.contains(city.name),
      ),
  };

  CompanyRegionDefinition? definitionForCity(City city) =>
      _definitionByCityId[city.id];

  CompanyRegionProgress progress(
    PlayerState state,
    CompanyRegionDefinition definition,
  ) {
    var branches = 0;
    var influence = 0;
    for (final branch in state.branches) {
      if (_definitionByCityId[branch.cityId] == definition) {
        branches++;
        influence += branch.level;
      }
    }
    return CompanyRegionProgress(
      definition: definition,
      branchCount: branches,
      influence: influence,
    );
  }

  List<CompanyRegionProgress> allProgress(PlayerState state) => [
    for (final definition in definitions) progress(state, definition),
  ];

  bool controls(PlayerState state, CompanyRegion region) {
    final definition = definitions.firstWhere((item) => item.region == region);
    return progress(state, definition).isControlled;
  }

  int controlledCount(PlayerState state) =>
      allProgress(state).where((item) => item.isControlled).length;

  int revenueBonus(PlayerState state) =>
      controls(state, CompanyRegion.marmara) ? branchRevenueBonusPercent : 0;

  int projectSuccessBonusFor(PlayerState state) =>
      controls(state, CompanyRegion.aegean) ? projectSuccessBonusPercent : 0;

  int marketBonus(PlayerState state) =>
      controls(state, CompanyRegion.mediterranean)
      ? positiveMarketBonusPercent
      : 0;

  int payrollDiscount(PlayerState state) =>
      controls(state, CompanyRegion.centralAnatolia)
      ? branchPayrollDiscountPercent
      : 0;

  int moraleProtection(PlayerState state) =>
      controls(state, CompanyRegion.blackSea) ? moraleLossReduction : 0;

  int investmentDiscount(PlayerState state) =>
      controls(state, CompanyRegion.easternAnatolia)
      ? branchInvestmentDiscountPercent
      : 0;

  int projectProgressBonusFor(PlayerState state) =>
      controls(state, CompanyRegion.southeasternAnatolia)
      ? projectProgressBonus
      : 0;
}
