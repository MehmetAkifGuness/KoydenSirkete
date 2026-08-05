import '../../earning/domain/services/earning_service.dart';
import '../../earning/domain/entities/earning_performance.dart';
import '../../training/domain/entities/course.dart';
import '../../training/domain/services/training_service.dart';
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
import '../domain/services/rest_service.dart';
import '../../daily_goals/domain/entities/daily_goal.dart';
import '../../progress/domain/services/achievement_service.dart';
import '../../company/domain/entities/company_project.dart';

class GameSessionApplicationService {
  GameSessionApplicationService({
    required PlayerStateRepository repository,
    required EarningService earningService,
    required TrainingService trainingService,
    required RestService restService,
    JobApplicationService? jobApplicationService,
    WorkService? workService,
    CareerService? careerService,
    CityService? cityService,
    LivingCostService? livingCostService,
    CompanyService? companyService,
    DailyGoalService? dailyGoalService,
    AchievementService? achievementService,
  })  : _repository = repository,
        _earningService = earningService,
        _trainingService = trainingService,
        _restService = restService,
        _jobApplicationService = jobApplicationService ?? JobApplicationService(),
        _workService = workService ?? WorkService(),
        _careerService = careerService ?? CareerService(),
        _cityService = cityService ?? CityService(),
        _livingCostService = livingCostService ?? LivingCostService(),
        _companyService = companyService ?? CompanyService(),
        _dailyGoalService = dailyGoalService ?? DailyGoalService(),
        _achievementService = achievementService ?? AchievementService();

  final PlayerStateRepository _repository;
  final EarningService _earningService;
  final TrainingService _trainingService;
  final RestService _restService;
  final JobApplicationService _jobApplicationService;
  final WorkService _workService;
  final CareerService _careerService;
  final CityService _cityService;
  final LivingCostService _livingCostService;
  final CompanyService _companyService;
  final DailyGoalService _dailyGoalService;
  final AchievementService _achievementService;

  Future<PlayerState> load() async {
    return _persist(await _repository.load() ?? PlayerState.initial);
  }

  Future<EarningResult> earn(PlayerState state, {EarningPerformance performance = EarningPerformance.none}) async {
    final result = _earningService.execute(state, performance: performance);
    final nextState = await _persist(result.state);
    return EarningResult(state: nextState, reward: result.reward, bonusPercent: result.bonusPercent);
  }

  Future<PlayerState> train(PlayerState state, Course course) async {
    final nextState = _trainingService.execute(state, course);
    return _persist(nextState);
  }

  Future<PlayerState> rest(PlayerState state) async {
    final nextState = _restService.execute(state);
    return _persist(nextState);
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
