import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/city.dart';
import '../../../assets/domain/services/asset_service.dart';
import '../../../jobs/domain/services/job_catalog.dart';
import 'city_salary_service.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class CityMoveCheck {
  const CityMoveCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class CityService {
  CityService({AssetService? assetService, CitySalaryService? salaryService})
    : _assetService = assetService ?? AssetService(),
      _salaryService = salaryService ?? CitySalaryService();

  final AssetService _assetService;
  final CitySalaryService _salaryService;

  CityMoveCheck check(PlayerState state, City city) {
    if (state.currentCityId == city.id) {
      return const CityMoveCheck(
        isEligible: false,
        reason: 'Zaten bu şehirde yaşıyorsun.',
      );
    }
    if (state.careerLevel < city.minimumCareerLevel) {
      return CityMoveCheck(
        isEligible: false,
        reason: 'En az kariyer seviyesi ${city.minimumCareerLevel} gerekiyor.',
      );
    }
    if (state.money < moveCost(state, city)) {
      return CityMoveCheck(
        isEligible: false,
        reason: 'Taşınmak için yeterli paran yok.',
      );
    }
    return const CityMoveCheck(isEligible: true, reason: 'Taşınmaya hazırsın.');
  }

  PlayerState move(PlayerState state, City city) {
    final result = check(state, city);
    if (!result.isEligible) {
      throw GameRuleException(result.reason);
    }
    final employment = state.employment;
    final job = JobCatalog.findById(employment?.jobId ?? state.currentJobId);
    final cost = moveCost(state, city);
    return state.copyWith(
      currentCityId: city.id,
      money: state.money - cost,
      lastLivingCostDay: state.day,
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.relocation,
        amount: -cost,
      ),
      employment: employment == null || job == null
          ? employment
          : employment.copyWith(
              cityId: city.id,
              salary: _salaryService.calculateForCity(
                job,
                city,
                day: state.day,
              ),
            ),
    );
  }

  int moveCost(PlayerState state, City city) =>
      _assetService.moveCost(state, city.moveCost);
}
