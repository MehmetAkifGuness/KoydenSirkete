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
import '../domain/repositories/player_state_repository.dart';
import '../domain/entities/game_tick_outcome.dart';
import '../domain/services/activity_service.dart';
import '../domain/services/game_clock_service.dart';
import '../../daily_goals/domain/entities/daily_goal.dart';
import '../../progress/domain/services/achievement_service.dart';
import '../../company/domain/entities/company_project.dart';
import '../../jobs/domain/entities/job_listing.dart';
import '../../jobs/domain/services/job_listing_service.dart';
import '../../jobs/domain/services/job_catalog.dart';
import '../../employment/domain/entities/employment.dart';
import '../../employment/domain/services/employment_service.dart';
import '../../work/domain/services/employer_task_generator.dart';

class GameSessionApplicationService {
  GameSessionApplicationService({
    required PlayerStateRepository repository,
    JobApplicationService? jobApplicationService,
    WorkService? workService,
    CareerService? careerService,
    CityService? cityService,
    LivingCostService? livingCostService,
    CompanyService? companyService,
    DailyGoalService? dailyGoalService,
    AchievementService? achievementService,
    GameClockService? gameClockService,
    ActivityService? activityService,
    JobListingService? jobListingService,
    EmploymentService? employmentService,
    EmployerTaskGenerator? employerTaskGenerator,
  })  : _repository = repository,
        _jobApplicationService = jobApplicationService ?? JobApplicationService(),
        _workService = workService ?? WorkService(),
        _careerService = careerService ?? CareerService(),
        _cityService = cityService ?? CityService(),
        _livingCostService = livingCostService ?? LivingCostService(),
        _companyService = companyService ?? CompanyService(),
        _dailyGoalService = dailyGoalService ?? DailyGoalService(),
        _achievementService = achievementService ?? AchievementService(),
        _gameClockService = gameClockService ?? GameClockService(),
        _activityService = activityService ?? ActivityService(),
        _jobListingService = jobListingService ?? JobListingService(),
        _employmentService = employmentService ?? EmploymentService(),
        _employerTaskGenerator = employerTaskGenerator ?? EmployerTaskGenerator();

  final PlayerStateRepository _repository;
  final JobApplicationService _jobApplicationService;
  final WorkService _workService;
  final CareerService _careerService;
  final CityService _cityService;
  final LivingCostService _livingCostService;
  final CompanyService _companyService;
  final DailyGoalService _dailyGoalService;
  final AchievementService _achievementService;
  final GameClockService _gameClockService;
  final ActivityService _activityService;
  final JobListingService _jobListingService;
  final EmploymentService _employmentService;
  final EmployerTaskGenerator _employerTaskGenerator;

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
        ));
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
    return _persist(_employmentService.markTaskStarted(activated));
  }

  Future<PlayerState> leaveJob(PlayerState state) async {
    return _persist(_employmentService.leave(state));
  }

  Future<GameTickOutcome> tick(PlayerState state, {int hours = 1}) async {
    final clock = _gameClockService.tick(state, hours: hours);
    var nextState = clock.state;
    String? message;
    final completed = clock.completedActivity;
    if (completed != null) {
      final result = _activityService.complete(nextState, completed);
      nextState = result.state;
      message = result.message;
    }
    if (clock.dayChanged) {
      nextState = _employmentService.checkAttendance(nextState);
    }
    return GameTickOutcome(state: await _persist(nextState), dayChanged: clock.dayChanged, message: message);
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

  DailyGoalStatus dailyGoalStatus(PlayerState state) => _dailyGoalService.status(state);

  Future<PlayerState> claimDailyGoal(PlayerState state) async {
    return _persist(_dailyGoalService.claim(state));
  }

  CompanyCheck checkCompanyEstablishment(PlayerState state) => _companyService.checkEstablishment(state);

  Future<PlayerState> establishCompany(PlayerState state) async {
    return _persist(_companyService.establish(state));
  }

  Future<PlayerState> recruitEmployee(PlayerState state) async {
    return _persist(_companyService.recruit(state));
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
    final settled = _livingCostService.settle(state);
    final evaluated = _achievementService.evaluate(settled).state;
    await _repository.save(evaluated);
    return evaluated;
  }
}
