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
import '../../cities/domain/services/city_salary_service.dart';
import '../../company/domain/services/company_service.dart';
import '../../company/domain/services/company_employee_development_service.dart';
import '../../company/domain/services/company_employee_management_service.dart';
import '../../company/domain/services/company_employee_wellbeing_service.dart';
import '../../company/domain/services/company_market_service.dart';
import '../../company/domain/services/company_competition_service.dart';
import '../../company/domain/services/company_stage_service.dart';
import '../../company/domain/services/company_treasury_service.dart';
import '../../company/domain/entities/company_deal.dart';
import '../../company/domain/entities/company_competition_strategy.dart';
import '../../company/domain/services/company_expansion_service.dart';
import '../../company/domain/services/company_competition_strategy_service.dart';
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

part 'game_session_feature_application.dart';

class GameSessionApplicationService {
  GameSessionApplicationService({
    required PlayerStateRepository repository,
    JobApplicationService? jobApplicationService,
    WorkService? workService,
    CareerService? careerService,
    CityService? cityService,
    LivingCostService? livingCostService,
    CompanyService? companyService,
    CompanyEmployeeDevelopmentService? employeeDevelopmentService,
    CompanyEmployeeManagementService? employeeManagementService,
    CompanyEmployeeWellbeingService? employeeWellbeingService,
    CompanyMarketService? companyMarketService,
    CompanyCompetitionService? companyCompetitionService,
    CompanyStageService? companyStageService,
    CompanyTreasuryService? companyTreasuryService,
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
    CitySalaryService? citySalaryService,
  }) : _repository = repository,
       _jobApplicationService =
           jobApplicationService ?? JobApplicationService(),
       _workService = workService ?? WorkService(),
       _careerService = careerService ?? CareerService(),
       _cityService = cityService ?? CityService(),
       _livingCostService = livingCostService ?? LivingCostService(),
       _companyService = companyService ?? CompanyService(),
       _employeeDevelopmentService =
           employeeDevelopmentService ?? CompanyEmployeeDevelopmentService(),
       _employeeManagementService =
           employeeManagementService ?? CompanyEmployeeManagementService(),
       _employeeWellbeingService =
           employeeWellbeingService ?? CompanyEmployeeWellbeingService(),
       _companyMarketService = companyMarketService ?? CompanyMarketService(),
       _companyCompetitionService =
           companyCompetitionService ?? CompanyCompetitionService(),
       _companyStageService = companyStageService ?? CompanyStageService(),
       _companyTreasuryService =
           companyTreasuryService ?? CompanyTreasuryService(),
       _companyBranchService = companyBranchService ?? CompanyBranchService(),
       _assetService = assetService ?? AssetService(),
       _dailyGoalService = dailyGoalService ?? DailyGoalService(),
       _achievementService = achievementService ?? AchievementService(),
       _gameClockService = gameClockService ?? GameClockService(),
       _energyRecoveryService =
           energyRecoveryService ?? EnergyRecoveryService(),
       _activityService = activityService ?? ActivityService(),
       _jobListingService = jobListingService ?? JobListingService(),
       _employmentService = employmentService ?? EmploymentService(),
       _employerTaskGenerator =
           employerTaskGenerator ?? EmployerTaskGenerator(),
       _esnafWheelService = esnafWheelService ?? EsnafWheelService(),
       _citySalaryService = citySalaryService ?? CitySalaryService();

  final PlayerStateRepository _repository;
  final JobApplicationService _jobApplicationService;
  final WorkService _workService;
  final CareerService _careerService;
  final CityService _cityService;
  final LivingCostService _livingCostService;
  final CompanyService _companyService;
  final CompanyEmployeeDevelopmentService _employeeDevelopmentService;
  final CompanyEmployeeManagementService _employeeManagementService;
  final CompanyEmployeeWellbeingService _employeeWellbeingService;
  final CompanyMarketService _companyMarketService;
  final CompanyCompetitionService _companyCompetitionService;
  final CompanyStageService _companyStageService;
  final CompanyTreasuryService _companyTreasuryService;
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
  final CitySalaryService _citySalaryService;

  Future<PlayerState> load() async {
    final loaded = await _repository.load() ?? PlayerState.initial;
    if (loaded.employment == null && loaded.currentJobId != null) {
      final job = JobCatalog.findById(loaded.currentJobId);
      if (job != null) {
        return _persist(
          loaded.copyWith(
            employment: Employment(
              jobId: job.id,
              cityId: loaded.currentCityId,
              salary: _citySalaryService.calculate(job, loaded.currentCityId),
              company: job.company,
              startedDay: loaded.day,
            ),
            careerLevel: job.level,
          ),
        );
      }
    }
    if (loaded.employment != null) {
      final employmentJob = JobCatalog.findById(loaded.employment!.jobId);
      if (employmentJob != null) {
        final salary = _citySalaryService.calculate(
          employmentJob,
          loaded.currentCityId,
        );
        if (loaded.currentJobId != employmentJob.id ||
            loaded.careerLevel != employmentJob.level ||
            loaded.employment!.cityId != loaded.currentCityId ||
            loaded.employment!.salary != salary) {
          return _persist(
            loaded.copyWith(
              currentJobId: employmentJob.id,
              careerLevel: employmentJob.level,
              employment: loaded.employment!.copyWith(
                cityId: loaded.currentCityId,
                salary: salary,
              ),
            ),
          );
        }
      }
    }
    return _persist(loaded);
  }

  Future<PlayerState> startEarning(
    PlayerState state, {
    EarningPerformance performance = EarningPerformance.none,
  }) async {
    final activity = _activityService.startEarning(
      state,
      performance: performance,
    );
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
    return _employerTaskGenerator.generate(
      job: job,
      cityId: state.currentCityId,
      day: state.day,
    );
  }

  Future<PlayerState> startJobApplication(
    PlayerState state,
    JobListing listing,
  ) async {
    final activity = _activityService.startJobApplication(state, listing);
    return _persist(_activityService.activate(state, activity));
  }

  Future<PlayerState> startWork(
    PlayerState state,
    Job job,
    WorkTask task,
  ) async {
    final activity = _activityService.startWork(state, job, task);
    final activated = _activityService.activate(state, activity);
    final marked = _employmentService.markTaskStarted(activated);
    return _persist(_esnafWheelService.consumeWorkBuffs(marked));
  }

  WheelAvailability wheelAvailability(PlayerState state) =>
      _esnafWheelService.availability(state);

  Future<WheelSpinOutcome> spinWheel(PlayerState state) async {
    final outcome = _esnafWheelService.spin(state);
    return WheelSpinOutcome(
      state: await _persist(outcome.state),
      reward: outcome.reward,
      sectorIndex: outcome.sectorIndex,
    );
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
      final operations = _companyService.processDailyOperations(
        nextState,
        days: elapsedDays,
      );
      nextState = operations.state;
      messages.addAll(operations.messages);
      final branchOperations = _companyBranchService.processDailyOperations(
        nextState,
        days: elapsedDays,
      );
      nextState = branchOperations.state;
      messages.addAll(branchOperations.messages);
      final market = _companyMarketService.process(
        nextState,
        days: elapsedDays,
      );
      nextState = market.state;
      messages.addAll(market.messages);
      final wellbeing = _employeeWellbeingService.process(
        nextState,
        market.outcomes,
      );
      nextState = wellbeing.state;
      messages.addAll(wellbeing.messages);
      final competition = _companyCompetitionService.process(
        nextState,
        market.outcomes,
      );
      nextState = competition.state;
      messages.addAll(competition.messages);
    }
    if (clock.dayChanged) {
      nextState = _employmentService.checkAttendance(nextState);
      if (nextState.lastJobEvent != state.lastJobEvent &&
          nextState.lastJobEvent != null) {
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

  Future<PlayerState> _persist(PlayerState state) async {
    final recovered = _energyRecoveryService.recover(state);
    final settled = _livingCostService.settle(recovered);
    final normalized = settled.money >= 0 && !settled.isBankrupt
        ? settled.copyWith(negativeMoneyHours: 0)
        : settled;
    final progressed = _companyStageService.evaluate(normalized);
    final evaluated = _achievementService.evaluate(progressed).state;
    await _repository.save(evaluated);
    return evaluated;
  }
}
