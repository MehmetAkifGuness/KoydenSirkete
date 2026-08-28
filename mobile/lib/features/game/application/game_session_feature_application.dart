part of 'game_session_application_service.dart';

extension GameSessionFeatureApplication on GameSessionApplicationService {
  JobApplicationCheck checkJob(PlayerState state, Job job) =>
      _jobApplicationService.check(state, job);

  Future<PlayerState> applyForJob(PlayerState state, Job job) async {
    return _persist(_jobApplicationService.apply(state, job));
  }

  Future<WorkResult> work(PlayerState state, Job job, WorkTask task) async {
    final result = _workService.execute(state, job, task);
    return WorkResult(
      state: await _persist(result.state),
      income: result.income,
    );
  }

  PromotionCheck checkPromotion(
    PlayerState state,
    Job currentJob,
    Job? nextJob,
  ) => _careerService.check(state, currentJob, nextJob);

  Future<PlayerState> promote(PlayerState state, Job currentJob, Job nextJob) =>
      _persist(_careerService.promote(state, currentJob, nextJob));

  CityMoveCheck checkCityMove(PlayerState state, City city) =>
      _cityService.check(state, city);

  Future<PlayerState> moveCity(PlayerState state, City city) =>
      _persist(_cityService.move(state, city));

  Future<PlayerState> completeOnboarding(PlayerState state) =>
      _persist(state.copyWith(isOnboarded: true));

  Future<PlayerState> resetGame() => _persist(PlayerState.initial);

  Future<PlayerState> updateDebugState(
    PlayerState state,
    DebugStatePatch patch,
  ) async {
    int bounded(int value, int min, int max) => value.clamp(min, max).toInt();
    final money = patch.money ?? state.money;
    final maxEnergy = bounded(patch.maxEnergy ?? state.maxEnergy, 1, 1000);
    final skills = patch.skills == null
        ? null
        : SkillProfile({
            for (final entry in patch.skills!.entries)
              entry.key: bounded(entry.value, 0, SkillProfile.maxValue),
          });
    final next = state.copyWith(
      money: money,
      energy: bounded(patch.energy ?? state.energy, 0, maxEnergy),
      maxEnergy: maxEnergy,
      knowledge: bounded(patch.knowledge ?? state.knowledge, 0, 1000000),
      experience: bounded(patch.experience ?? state.experience, 0, 1000000),
      day: bounded(patch.day ?? state.day, 1, 1000000),
      hour: bounded(patch.hour ?? state.hour, 0, 23),
      careerLevel: bounded(patch.careerLevel ?? state.careerLevel, 1, 20),
      companyFunds: bounded(
        patch.companyFunds ?? state.companyFunds,
        0,
        1000000000,
      ),
      performance: bounded(patch.performance ?? state.performance, 0, 100),
      skills: skills,
      negativeMoneyHours: money >= 0 ? 0 : state.negativeMoneyHours,
    );
    await _repository.save(next);
    return next;
  }

  Future<PlayerState> recoverEnergy(PlayerState state) => _persist(state);

  DailyGoalStatus dailyGoalStatus(PlayerState state) =>
      _dailyGoalService.status(state);

  Future<PlayerState> claimDailyGoal(PlayerState state) =>
      _persist(_dailyGoalService.claim(state));

  CompanyCheck checkCompanyEstablishment(PlayerState state) =>
      _companyService.checkEstablishment(state);

  Future<PlayerState> establishCompany(PlayerState state) {
    final established = _companyService.establish(state);
    return _persist(_companyCompetitionService.initialize(established));
  }

  Future<PlayerState> addCompanyCapital(PlayerState state, int amount) =>
      _persist(_companyTreasuryService.addCapital(state, amount));

  Future<PlayerState> withdrawCompanyDividend(
    PlayerState state,
    int grossAmount,
  ) => _persist(_companyTreasuryService.withdrawDividend(state, grossAmount));

  Future<PlayerState> recruitEmployee(
    PlayerState state, {
    CompanyEmployee? employee,
  }) => _persist(_companyService.recruit(state, employee: employee));

  Future<PlayerState> dismissEmployee(
    PlayerState state, {
    required int employeeId,
  }) => _persist(_companyService.dismissEmployee(state, employeeId));

  EmployeeDevelopmentCheck checkEmployeeDevelopment(
    PlayerState state,
    int employeeId,
  ) => _employeeDevelopmentService.checkHeadquarters(state, employeeId);

  Future<PlayerState> developEmployee(PlayerState state, int employeeId) =>
      _persist(
        _employeeDevelopmentService.developHeadquarters(state, employeeId),
      );

  EmployeePromotionCheck checkEmployeePromotion(
    PlayerState state,
    int employeeId,
  ) => _employeeManagementService.checkHeadquarters(state, employeeId);

  Future<PlayerState> promoteEmployee(PlayerState state, int employeeId) =>
      _persist(
        _employeeManagementService.promoteHeadquarters(state, employeeId),
      );

  Future<PlayerState> respondToEmployeeRaise(
    PlayerState state,
    int employeeId, {
    required bool accept,
  }) => _persist(
    _employeeManagementService.respondToHeadquartersRaise(
      state,
      employeeId,
      accept: accept,
    ),
  );

  CompanyCheckResult checkBranchOpen(PlayerState state, City city) =>
      _companyBranchService.checkOpen(state, city);

  List<CompanyEmployee> branchCandidates(
    PlayerState state,
    CompanyBranch branch,
  ) => _companyBranchService.availableEmployees(state, branch);

  Future<PlayerState> openBranch(PlayerState state, City city) =>
      _persist(_companyBranchService.open(state, city));

  Future<PlayerState> recruitBranchEmployee(
    PlayerState state, {
    required int cityId,
    required CompanyEmployee employee,
  }) => _persist(_companyBranchService.recruit(state, cityId, employee));

  Future<PlayerState> dismissBranchEmployee(
    PlayerState state, {
    required int cityId,
    required int employeeId,
  }) => _persist(_companyBranchService.dismiss(state, cityId, employeeId));

  EmployeeDevelopmentCheck checkBranchEmployeeDevelopment(
    PlayerState state,
    int cityId,
    int employeeId,
  ) => _employeeDevelopmentService.checkBranch(state, cityId, employeeId);

  Future<PlayerState> developBranchEmployee(
    PlayerState state,
    int cityId,
    int employeeId,
  ) => _persist(
    _employeeDevelopmentService.developBranch(state, cityId, employeeId),
  );

  EmployeePromotionCheck checkBranchEmployeePromotion(
    PlayerState state,
    int cityId,
    int employeeId,
  ) => _employeeManagementService.checkBranch(state, cityId, employeeId);

  Future<PlayerState> promoteBranchEmployee(
    PlayerState state,
    int cityId,
    int employeeId,
  ) => _persist(
    _employeeManagementService.promoteBranch(state, cityId, employeeId),
  );

  Future<PlayerState> respondToBranchEmployeeRaise(
    PlayerState state,
    int cityId,
    int employeeId, {
    required bool accept,
  }) => _persist(
    _employeeManagementService.respondToBranchRaise(
      state,
      cityId,
      employeeId,
      accept: accept,
    ),
  );

  CompanyCheckResult checkBranchUpgrade(PlayerState state, int cityId) =>
      _companyBranchService.checkUpgrade(state, cityId);

  Future<PlayerState> upgradeBranch(PlayerState state, int cityId) =>
      _persist(_companyBranchService.upgrade(state, cityId));

  AssetCheck checkHome(PlayerState state, HomeAsset home, City city) =>
      _assetService.checkHome(state, home, city);

  Future<PlayerState> buyHome(PlayerState state, HomeAsset home, City city) =>
      _persist(_assetService.buyHome(state, home, city));

  Future<PlayerState> sellHome(PlayerState state, HomeAsset home) =>
      _persist(_assetService.sellHome(state, home));

  Future<PlayerState> rentOutHome(PlayerState state, HomeAsset home) =>
      _persist(_assetService.rentOutHome(state, home));

  Future<PlayerState> stopRentingHome(PlayerState state, HomeAsset home) =>
      _persist(_assetService.stopRentingHome(state, home));

  AssetCheck checkCar(PlayerState state, CarAsset car) =>
      _assetService.checkCar(state, car);

  Future<PlayerState> buyCar(PlayerState state, CarAsset car) =>
      _persist(_assetService.buyCar(state, car));

  Future<PlayerState> sellCar(PlayerState state, CarAsset car) =>
      _persist(_assetService.sellCar(state, car));

  CompanyCheck checkCompanyUpgrade(PlayerState state) =>
      _companyService.checkUpgrade(state);

  Future<PlayerState> upgradeCompany(PlayerState state) =>
      _persist(_companyService.upgrade(state));

  Future<PlayerState> selectCompanyProject(
    PlayerState state,
    CompanyProject project,
  ) => _persist(_companyService.selectProject(state, project));

  Future<PlayerState> setCompanyProjectEmployeeAssignment(
    PlayerState state, {
    required CompanyProject project,
    required int employeeId,
    required bool assigned,
  }) => _persist(
    _companyProjectTeamService.setAssignment(
      state,
      project: project,
      employeeId: employeeId,
      assigned: assigned,
    ),
  );

  Future<PlayerState> selectCompanyCompetitionStrategy(
    PlayerState state,
    CompanyCompetitionStrategy strategy,
  ) => _persist(
    const CompanyCompetitionStrategyService().select(state, strategy),
  );

  Future<CompanyActionResult> advanceCompanyProject(PlayerState state) async {
    final result = _companyService.advanceProject(state);
    return CompanyActionResult(
      state: await _persist(result.state),
      message: result.message,
      succeeded: result.succeeded,
      projectOutcome: result.projectOutcome,
    );
  }

  CompanyDealCheck checkCompanyDeal(PlayerState state, CompanyDeal deal) =>
      CompanyExpansionService().check(state, deal);

  Future<PlayerState> completeCompanyDeal(
    PlayerState state,
    CompanyDeal deal,
  ) => _persist(CompanyExpansionService().execute(state, deal));
}
