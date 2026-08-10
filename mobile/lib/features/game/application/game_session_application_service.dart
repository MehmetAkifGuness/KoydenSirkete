import '../../earning/domain/entities/earning_performance.dart';
import '../../training/domain/entities/course.dart';
import '../../jobs/domain/entities/job.dart';
import '../../jobs/domain/services/job_application_service.dart';
import '../../work/domain/entities/work_task.dart';
import '../../work/domain/services/work_service.dart';
import '../../career/domain/services/career_service.dart';
import '../../cities/domain/entities/city.dart';
import '../../cities/domain/services/city_service.dart';
import '../../cities/domain/services/living_cost_service.dart';
import '../../company/domain/services/company_service.dart';
import '../domain/entities/player_state.dart';
import '../domain/entities/debug_state_patch.dart';
import '../../skills/domain/entities/skill_profile.dart';
import '../domain/repositories/player_state_repository.dart';
import '../domain/entities/game_tick_outcome.dart';
import '../domain/services/activity_service.dart';
import '../domain/services/game_clock_service.dart';
import '../domain/services/energy_recovery_service.dart';
import '../../daily_goals/domain/entities/daily_goal.dart';
import '../../progress/domain/services/achievement_service.dart';
import '../../company/domain/entities/company_project.dart';
import '../../company/domain/entities/company_employee.dart';
import '../../company/domain/entities/company_branch.dart';
import '../../company/domain/services/company_branch_service.dart';
import '../../assets/domain/entities/home_asset.dart';
import '../../assets/domain/entities/car_asset.dart';
import '../../assets/domain/services/asset_service.dart';
import '../../jobs/domain/entities/job_listing.dart';
import '../../jobs/domain/services/job_listing_service.dart';
import '../../jobs/domain/services/job_catalog.dart';
import '../../employment/domain/entities/employment.dart';
import '../../employment/domain/services/employment_service.dart';
import '../../work/domain/services/employer_task_generator.dart';
import '../../wheel/domain/services/esnaf_wheel_service.dart';

class GameSessionApplicationService {
  GameSessionApplicationService({
    required PlayerStateRepository repository,
    JobApplicationService? jobApplicationService,
    WorkService? workService,
    CareerService? careerService,
    CityService? cityService,
    LivingCostService? livingCostService,
    CompanyService? companyService,
    CompanyBranchService? companyBranchService,
    AssetService? assetService,
    DailyGoalService? dailyGoalService,
    AchievementService? achievementService,
    GameClockService? gameClockService,
    EnergyRecoveryService? energyRecoveryService,
    ActivityService? activityService,
    JobListingService? jobListingService,
    EmploymentService? employmentService,
    EmployerTaskGenerator? employerTaskGenerator,
    EsnafWheelService? esnafWheelService,
  })  : _repository = repository,
        _jobApplicationService = jobApplicationService ?? JobApplicationService(),
        _workService = workService ?? WorkService(),
        _careerService = careerService ?? CareerService(),
        _cityService = cityService ?? CityService(),
        _livingCostService = livingCostService ?? LivingCostService(),
        _companyService = companyService ?? CompanyService(),
        _companyBranchService = companyBranchService ?? CompanyBranchService(),
        _assetService = assetService ?? AssetService(),
        _dailyGoalService = dailyGoalService ?? DailyGoalService(),
        _achievementService = achievementService ?? AchievementService(),
        _gameClockService = gameClockService ?? GameClockService(),
        _energyRecoveryService = energyRecoveryService ?? EnergyRecoveryService(),
        _activityService = activityService ?? ActivityService(),
        _jobListingService = jobListingService ?? JobListingService(),
        _employmentService = employmentService ?? EmploymentService(),
        _employerTaskGenerator = employerTaskGenerator ?? EmployerTaskGenerator(),
        _esnafWheelService = esnafWheelService ?? EsnafWheelService();

  final PlayerStateRepository _repository;
  final JobApplicationService _jobApplicationService;
  final WorkService _workService;
  final CareerService _careerService;
  final CityService _cityService;
  final LivingCostService _livingCostService;
  final CompanyService _companyService;
  final CompanyBranchService _companyBranchService;
  final AssetService _assetService;
  final DailyGoalService _dailyGoalService;
  final AchievementService _achievementService;
  final GameClockService _gameClockService;
  final EnergyRecoveryService _energyRecoveryService;
  final ActivityService _activityService;
  final JobListingService _jobListingService;
  final EmploymentService _employmentService;
  final EmployerTaskGenerator _employerTaskGenerator;
  final EsnafWheelService _esnafWheelService;

  Future<PlayerState> load() async {
    final loaded = await _repository.load() ?? PlayerState.initial;
    if (loaded.employment == null && loaded.currentJobId != null) {
      final job = JobCatalog.findById(loaded.currentJobId);
      if (job != null) {
        return _persist(loaded.copyWith(
          employment: Employment(
            jobId: job.id,
            cityId: loaded.currentCityId,
            salary: job.salary,
            company: job.company,
            startedDay: loaded.day,
          ),
          careerLevel: job.level,
        ));
      }
    }
    if (loaded.employment != null) {
      final employmentJob = JobCatalog.findById(loaded.employment!.jobId);
      if (employmentJob != null &&
          (loaded.currentJobId != employmentJob.id || loaded.careerLevel != employmentJob.level)) {
        return _persist(loaded.copyWith(currentJobId: employmentJob.id, careerLevel: employmentJob.level));
      }
    }
    return _persist(loaded);
  }

  Future<PlayerState> startEarning(PlayerState state, {EarningPerformance performance = EarningPerformance.none}) async {
    final activity = _activityService.startEarning(state, performance: performance);
    return _persist(_activityService.activate(state, activity));
  }

  Future<PlayerState> startTraining(PlayerState state, Course course) async {
    final activity = _activityService.startTraining(state, course);
    return _persist(_activityService.activate(state, activity));
  }

  Future<PlayerState> startSport(PlayerState state) async {
    final activity = _activityService.startSport(state);
    return _persist(_activityService.activate(state, activity));
  }

  List<JobListing> jobListings(PlayerState state) {
    return _jobListingService.forPlayer(state);
  }

  List<WorkTask> employerTasks(PlayerState state, Job job) {
    return _employerTaskGenerator.generate(job: job, cityId: state.currentCityId, day: state.day);
  }

  Future<PlayerState> startJobApplication(PlayerState state, JobListing listing) async {
    final activity = _activityService.startJobApplication(state, listing);
    return _persist(_activityService.activate(state, activity));
  }

  Future<PlayerState> startWork(PlayerState state, Job job, WorkTask task) async {
    final activity = _activityService.startWork(state, job, task);
    final activated = _activityService.activate(state, activity);
    final marked = _employmentService.markTaskStarted(activated);
    return _persist(_esnafWheelService.consumeWorkBuffs(marked));
  }

  WheelAvailability wheelAvailability(PlayerState state) => _esnafWheelService.availability(state);

  Future<WheelSpinOutcome> spinWheel(PlayerState state) async {
    final outcome = _esnafWheelService.spin(state);
    return WheelSpinOutcome(state: await _persist(outcome.state), reward: outcome.reward, sectorIndex: outcome.sectorIndex);
  }

  Future<PlayerState> leaveJob(PlayerState state) async {
    return _persist(_employmentService.leave(state));
  }

  Future<GameTickOutcome> tick(PlayerState state, {int hours = 1}) async {
    final clock = _gameClockService.tick(state, hours: hours);
    var nextState = clock.state;
    final messages = <String>[];
    for (final completed in clock.activities) {
      final result = _activityService.complete(nextState, completed);
      nextState = result.state;
      messages.add(result.message);
    }
    final elapsedDays = clock.state.day - state.day;
    if (elapsedDays > 0) {
      final operations = _companyService.processDailyOperations(nextState, days: elapsedDays);
      nextState = operations.state;
      messages.addAll(operations.messages);
      final branchOperations = _companyBranchService.processDailyOperations(nextState, days: elapsedDays);
      nextState = branchOperations.state;
      messages.addAll(branchOperations.messages);
    }
    if (clock.dayChanged) {
      nextState = _employmentService.checkAttendance(nextState);
      if (nextState.lastJobEvent != state.lastJobEvent && nextState.lastJobEvent != null) {
        messages.add(nextState.lastJobEvent!);
      }
    }
    final saved = await _persist(nextState);
    final settlementDelta = saved.money - nextState.money;
    if (settlementDelta != 0) {
      final settlementAmount = settlementDelta.abs();
      messages.add(
        settlementDelta > 0
            ? 'Para kazand\u0131n: +\u20BA$settlementDelta.'
            : 'Para gitti: -\u20BA$settlementAmount.',
      );
    }
    final companyFundsDelta = saved.companyFunds - state.companyFunds;
    if (companyFundsDelta != 0) {
      final companyFundsAmount = companyFundsDelta.abs();
      messages.add(
        companyFundsDelta > 0
            ? 'Şirket kasasına +$companyFundsDelta TL girdi.'
            : 'Şirket kasasından $companyFundsAmount TL çıktı.',
      );
    }
    final moneyDelta = saved.money - state.money;
    if (moneyDelta != 0 && messages.isEmpty) {
      final moneyAmount = moneyDelta.abs();
      messages.add(
        moneyDelta > 0
            ? 'Para kazand\u0131n: +\u20BA$moneyDelta.'
            : 'Para gitti: -\u20BA$moneyAmount.',
      );
    }
    return GameTickOutcome(
      state: saved,
      dayChanged: clock.dayChanged,
      message: messages.isEmpty ? null : messages.join(' · '),
    );
  }

  JobApplicationCheck checkJob(PlayerState state, Job job) => _jobApplicationService.check(state, job);

  Future<PlayerState> applyForJob(PlayerState state, Job job) async {
    final nextState = _jobApplicationService.apply(state, job);
    return _persist(nextState);
  }

  Future<WorkResult> work(PlayerState state, Job job, WorkTask task) async {
    final result = _workService.execute(state, job, task);
    final nextState = await _persist(result.state);
    return WorkResult(state: nextState, income: result.income);
  }

  PromotionCheck checkPromotion(PlayerState state, Job currentJob, Job? nextJob) => _careerService.check(state, currentJob, nextJob);

  Future<PlayerState> promote(PlayerState state, Job currentJob, Job nextJob) async {
    final nextState = _careerService.promote(state, currentJob, nextJob);
    return _persist(nextState);
  }

  CityMoveCheck checkCityMove(PlayerState state, City city) => _cityService.check(state, city);

  Future<PlayerState> moveCity(PlayerState state, City city) async {
    return _persist(_cityService.move(state, city));
  }

  Future<PlayerState> completeOnboarding(PlayerState state) async {
    return _persist(state.copyWith(isOnboarded: true));
  }

  Future<PlayerState> resetGame() async {
    return _persist(PlayerState.initial);
  }

  Future<PlayerState> selectThemePalette(PlayerState state, int paletteId) async {
    return _persist(state.copyWith(themePaletteId: paletteId));
  }

  Future<PlayerState> updateDebugState(PlayerState state, DebugStatePatch patch) async {
    int bounded(int value, int min, int max) => value.clamp(min, max).toInt();
    final money = patch.money ?? state.money;
    final maxEnergy = bounded(patch.maxEnergy ?? state.maxEnergy, 1, 1000);
    final skills = patch.skills == null ? null : SkillProfile({for (final entry in patch.skills!.entries) entry.key: bounded(entry.value, 0, SkillProfile.maxValue)});
    final next = state.copyWith(
      money: money,
      energy: bounded(patch.energy ?? state.energy, 0, maxEnergy),
      maxEnergy: maxEnergy,
      knowledge: bounded(patch.knowledge ?? state.knowledge, 0, 1000000),
      experience: bounded(patch.experience ?? state.experience, 0, 1000000),
      day: bounded(patch.day ?? state.day, 1, 1000000),
      hour: bounded(patch.hour ?? state.hour, 0, 23),
      careerLevel: bounded(patch.careerLevel ?? state.careerLevel, 1, 20),
      companyFunds: bounded(patch.companyFunds ?? state.companyFunds, 0, 1000000000),
      performance: bounded(patch.performance ?? state.performance, 0, 100),
      skills: skills,
      negativeMoneyHours: money >= 0 ? 0 : state.negativeMoneyHours,
    );
    await _repository.save(next);
    return next;
  }

  Future<PlayerState> recoverEnergy(PlayerState state) => _persist(state);

  DailyGoalStatus dailyGoalStatus(PlayerState state) => _dailyGoalService.status(state);

  Future<PlayerState> claimDailyGoal(PlayerState state) async {
    return _persist(_dailyGoalService.claim(state));
  }

  CompanyCheck checkCompanyEstablishment(PlayerState state) => _companyService.checkEstablishment(state);

  Future<PlayerState> establishCompany(PlayerState state) async {
    return _persist(_companyService.establish(state));
  }

  Future<PlayerState> recruitEmployee(PlayerState state, {CompanyEmployee? employee}) async {
    return _persist(_companyService.recruit(state, employee: employee));
  }

  Future<PlayerState> dismissEmployee(PlayerState state, {required int employeeId}) async {
    return _persist(_companyService.dismissEmployee(state, employeeId));
  }

  CompanyCheckResult checkBranchOpen(PlayerState state, City city) => _companyBranchService.checkOpen(state, city);

  List<CompanyEmployee> branchCandidates(PlayerState state, CompanyBranch branch) => _companyBranchService.availableEmployees(state, branch);

  Future<PlayerState> openBranch(PlayerState state, City city) async {
    return _persist(_companyBranchService.open(state, city));
  }

  Future<PlayerState> recruitBranchEmployee(PlayerState state, {required int cityId, required CompanyEmployee employee}) async {
    return _persist(_companyBranchService.recruit(state, cityId, employee));
  }

  Future<PlayerState> dismissBranchEmployee(PlayerState state, {required int cityId, required int employeeId}) async {
    return _persist(_companyBranchService.dismiss(state, cityId, employeeId));
  }

  AssetCheck checkHome(PlayerState state, HomeAsset home, City city) => _assetService.checkHome(state, home, city);

  Future<PlayerState> buyHome(PlayerState state, HomeAsset home, City city) async {
    return _persist(_assetService.buyHome(state, home, city));
  }

  AssetCheck checkCar(PlayerState state, CarAsset car) => _assetService.checkCar(state, car);

  Future<PlayerState> buyCar(PlayerState state, CarAsset car) async {
    return _persist(_assetService.buyCar(state, car));
  }

  CompanyCheck checkCompanyUpgrade(PlayerState state) => _companyService.checkUpgrade(state);

  Future<PlayerState> upgradeCompany(PlayerState state) async {
    return _persist(_companyService.upgrade(state));
  }

  Future<PlayerState> selectCompanyProject(PlayerState state, CompanyProject project) async {
    return _persist(_companyService.selectProject(state, project));
  }

  Future<CompanyActionResult> advanceCompanyProject(PlayerState state) async {
    final result = _companyService.advanceProject(state);
    final nextState = await _persist(result.state);
    return CompanyActionResult(state: nextState, message: result.message);
  }

  Future<PlayerState> _persist(PlayerState state) async {
    final recovered = _energyRecoveryService.recover(state);
    final settled = _livingCostService.settle(recovered);
    final normalized = settled.money >= 0 && !settled.isBankrupt ? settled.copyWith(negativeMoneyHours: 0) : settled;
    final evaluated = _achievementService.evaluate(normalized).state;
    await _repository.save(evaluated);
    return evaluated;
  }
}
