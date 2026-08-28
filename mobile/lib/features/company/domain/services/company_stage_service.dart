import '../../../game/domain/entities/player_state.dart';
import '../entities/company_stage.dart';
import 'company_growth_service.dart';

class CompanyStageService {
  CompanyStageService({CompanyGrowthService? growthService})
    : _growthService = growthService ?? CompanyGrowthService();

  final CompanyGrowthService _growthService;

  CompanyStage current(PlayerState state) =>
      CompanyStage.values[state.companyStageIndex.clamp(
        0,
        CompanyStage.values.length - 1,
      )];

  List<CompanyStageMilestone> roadmap(PlayerState state) => [
    _local(),
    _regional(state),
    _national(state),
    _holding(state),
  ];

  CompanyStageMilestone milestone(PlayerState state, CompanyStage stage) =>
      roadmap(state)[stage.index];

  PlayerState evaluate(PlayerState state) {
    if (state.companyLevel == 0) {
      return state.companyStageIndex == 0
          ? state
          : state.copyWith(companyStageIndex: 0);
    }
    var highest = current(state).index;
    final milestones = roadmap(state);
    while (highest + 1 < milestones.length &&
        milestones[highest + 1].isUnlocked) {
      highest++;
    }
    return highest == state.companyStageIndex
        ? state
        : state.copyWith(companyStageIndex: highest);
  }

  CompanyStageMilestone _local() => const CompanyStageMilestone(
    stage: CompanyStage.localEnterprise,
    title: 'Yerel girişim',
    description: 'Temel ekibini kur ve ilk düzenli gelirini oluştur.',
    requirements: [],
  );

  CompanyStageMilestone _regional(PlayerState state) => CompanyStageMilestone(
    stage: CompanyStage.regionalCompany,
    title: 'Bölgesel şirket',
    description: 'Birden fazla şehirde güçlü ve istikrarlı bir yapı kur.',
    requirements: [
      _requirement('Şirket seviyesi', state.companyLevel, 2),
      _requirement('İtibar', _growthService.reputation(state), 30),
      _requirement('Pazar payı', _marketShare(state), 12, suffix: '%'),
      _requirement(
        'Toplam çalışan',
        CompanyGrowthService.totalEmployees(state),
        6,
      ),
      _requirement('Ekip kalitesi', _employeeQuality(state), 60),
      _requirement('Bayi', state.branches.length, 2),
      _seasonRank(state, 3),
    ],
  );

  CompanyStageMilestone _national(PlayerState state) => CompanyStageMilestone(
    stage: CompanyStage.nationalBrand,
    title: 'Ulusal marka',
    description: 'Yüksek itibarlı ve ülke çapında tanınan bir marka ol.',
    requirements: [
      _requirement('Şirket seviyesi', state.companyLevel, 3),
      _requirement(
        'Şirket değeri',
        _growthService.valuation(state),
        400000,
        suffix: '₺',
      ),
      _requirement('İtibar', _growthService.reputation(state), 60),
      _requirement('Pazar payı', _marketShare(state), 25, suffix: '%'),
      _requirement(
        'Toplam çalışan',
        CompanyGrowthService.totalEmployees(state),
        15,
      ),
      _requirement('Ekip kalitesi', _employeeQuality(state), 70),
      _requirement('Bayi', state.branches.length, 5),
      _requirement('Şampiyonluk', state.companyCompetition.championships, 1),
    ],
  );

  CompanyStageMilestone _holding(PlayerState state) => CompanyStageMilestone(
    stage: CompanyStage.holding,
    title: 'Holding',
    description: 'Kalıcı pazar liderliği kuran çok şehirli bir yapıya dönüş.',
    requirements: [
      _requirement(
        'Şirket değeri',
        _growthService.valuation(state),
        1500000,
        suffix: '₺',
      ),
      _requirement('İtibar', _growthService.reputation(state), 85),
      _requirement('Pazar payı', _marketShare(state), 40, suffix: '%'),
      _requirement(
        'Toplam çalışan',
        CompanyGrowthService.totalEmployees(state),
        25,
      ),
      _requirement('Ekip kalitesi', _employeeQuality(state), 80),
      _requirement('Bayi', state.branches.length, 10),
      _requirement('Şampiyonluk', state.companyCompetition.championships, 3),
    ],
  );

  CompanyStageRequirement _requirement(
    String label,
    int current,
    int target, {
    String suffix = '',
  }) => CompanyStageRequirement(
    label: label,
    current: current,
    target: target,
    valueLabel: suffix == '₺'
        ? '₺$current / ₺$target'
        : '$current$suffix / $target$suffix',
  );

  CompanyStageRequirement _seasonRank(PlayerState state, int targetRank) {
    final rank = state.companyCompetition.bestRank;
    final met = rank > 0 && rank <= targetRank;
    return CompanyStageRequirement(
      label: 'En iyi sezon derecesi',
      current: met ? 1 : 0,
      target: 1,
      valueLabel: rank == 0 ? 'İlk $targetRank gerekli' : '$rank. sıra',
    );
  }

  int _marketShare(PlayerState state) =>
      _growthService.marketShare(state).floor();

  int _employeeQuality(PlayerState state) {
    final employees = [
      ...state.employees,
      for (final branch in state.branches) ...branch.employees,
    ];
    if (employees.isEmpty) return 0;
    return employees.fold<int>(
          0,
          (total, item) => total + item.effectivePerformance,
        ) ~/
        employees.length;
  }
}
