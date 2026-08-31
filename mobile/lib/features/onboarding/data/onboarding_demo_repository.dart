import '../../economy/domain/entities/economy_difficulty.dart';
import '../../employment/domain/entities/employment.dart';
import '../../company/domain/services/company_service.dart';
import '../../game/domain/entities/player_state.dart';
import '../../game/domain/repositories/player_state_repository.dart';

class OnboardingDemoRepository implements PlayerStateRepository {
  PlayerState _state = PlayerState.initial;

  void reset(EconomyDifficulty difficulty) {
    _state = PlayerState.initial.copyWith(
      isOnboarded: true,
      economyDifficulty: difficulty,
      money: 1000000,
      knowledge: 50,
      experience: 500,
      careerLevel: 3,
      performance: 100,
    );
  }

  void prepareEmployment() {
    if (_state.employment != null) return;
    _state = _state.copyWith(
      currentJobId: 1,
      employment: Employment(
        jobId: 1,
        cityId: _state.currentCityId,
        salary: 120,
        company: 'Bereket Market',
        startedDay: _state.day,
      ),
      lastJobEvent: 'Demo görevi için başlangıç işi hazırlandı.',
    );
  }

  void prepareForStep(int step) {
    _state = _state.copyWith(
      money: _state.money < 1000000 ? 1000000 : _state.money,
      energy: _state.maxEnergy,
      careerLevel: _state.careerLevel < 3 ? 3 : _state.careerLevel,
    );
    if (step >= 7) prepareEmployment();
    if (step >= 13) {
      _state = _state.copyWith(
        companyLevel: 1,
        companyFunds: 500,
        currentJobId: null,
        employment: null,
      );
    }
  }

  void establishTutorialCompany() {
    if (_state.companyLevel > 0) return;
    _state = _state.copyWith(
      money: _state.money - CompanyService.establishmentCost,
      companyLevel: 1,
      companyFunds: 500,
      currentJobId: null,
      employment: null,
      firstCompanyDay: _state.day,
    );
  }

  @override
  Future<PlayerState?> load() async => _state;

  @override
  Future<void> save(PlayerState state) async => _state = state;
}
