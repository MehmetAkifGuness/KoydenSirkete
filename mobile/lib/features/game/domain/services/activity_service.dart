import '../../../earning/domain/entities/earning_performance.dart';
import '../../../earning/domain/services/earning_service.dart';
import '../../../sport/domain/services/sport_service.dart';
import '../../../training/domain/entities/course.dart';
import '../../../training/domain/services/training_catalog.dart';
import '../../../training/domain/services/training_service.dart';
import '../../../../core/errors/game_rule_exception.dart';
import '../entities/active_activity.dart';
import '../entities/player_state.dart';
import '../../../jobs/domain/entities/job_listing.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/domain/services/job_application_service.dart';
import '../../../jobs/domain/services/job_catalog.dart';
import '../../../work/domain/entities/work_task.dart';
import '../../../work/domain/services/work_service.dart';
import '../../../work/domain/services/work_task_catalog.dart';
import '../../../work/domain/services/employer_task_generator.dart';

class ActivityCompletion {
  const ActivityCompletion({required this.state, required this.message});

  final PlayerState state;
  final String message;
}

class ActivityService {
  ActivityService({
    EarningService? earningService,
    TrainingService? trainingService,
    SportService? sportService,
    JobApplicationService? jobApplicationService,
    WorkService? workService,
    EmployerTaskGenerator? taskGenerator,
  }) : _earningService = earningService ?? EarningService(),
       _trainingService = trainingService ?? TrainingService(),
       _sportService = sportService ?? SportService(),
       _jobApplicationService =
           jobApplicationService ?? JobApplicationService(),
       _workService = workService ?? WorkService(),
       _taskGenerator = taskGenerator ?? EmployerTaskGenerator();

  final EarningService _earningService;
  final TrainingService _trainingService;
  final SportService _sportService;
  final JobApplicationService _jobApplicationService;
  final WorkService _workService;
  final EmployerTaskGenerator _taskGenerator;

  ActiveActivity startEarning(
    PlayerState state, {
    EarningPerformance performance = EarningPerformance.none,
  }) {
    return _earningService.start(state, performance: performance);
  }

  ActiveActivity startTraining(PlayerState state, Course course) {
    return _trainingService.start(state, course);
  }

  ActiveActivity startSport(PlayerState state) => _sportService.start(state);

  ActiveActivity startJobApplication(PlayerState state, JobListing listing) {
    return _jobApplicationService.start(state, listing);
  }

  ActiveActivity startWork(PlayerState state, Job job, WorkTask task) {
    final activity = _workService.start(state, job, task);
    return activity.copyWith(
      payload: {
        ...activity.payload,
        'city_id': '${state.currentCityId}',
        'task_day': '${state.day}',
      },
    );
  }

  PlayerState activate(PlayerState state, ActiveActivity activity) {
    if (!state.hasActivityCapacity) {
      throw const GameRuleException('R\u00FCtbe kapasitesi dolu.');
    }
    if (state.activities.any(
      (current) =>
          current.type == activity.type &&
          current.sourceId == activity.sourceId,
    )) {
      throw const GameRuleException('Ayn\u0131 aktivite zaten devam ediyor.');
    }
    return state.copyWith(
      energy: state.energy - activity.energyCost,
      activeActivity: null,
      activeActivities: <ActiveActivity>[...state.activities, activity],
    );
  }

  ActivityCompletion complete(PlayerState state, ActiveActivity activity) {
    switch (activity.type) {
      case ActivityType.earning:
        final result = _earningService.complete(
          state,
          performance: _performance(activity),
        );
        return ActivityCompletion(
          state: result.state,
          message: '+₺${result.reward} kazanç tamamlandı.',
        );
      case ActivityType.training:
        final course = TrainingCatalog.findById(activity.sourceId);
        if (course == null) {
          return ActivityCompletion(
            state: state,
            message: 'Eğitim kaydı bulunamadı.',
          );
        }
        return ActivityCompletion(
          state: _trainingService.complete(state, course),
          message:
              '${course.name} tamamlandı. +${course.knowledge} genel bilgi',
        );
      case ActivityType.sport:
        return ActivityCompletion(
          state: _sportService.complete(state),
          message: 'Spor tamamlandı. Maksimum enerjin arttı.',
        );
      case ActivityType.work:
        final resolvedJob = JobCatalog.findById(
          int.tryParse(activity.payload['job_id'] ?? ''),
        );
        if (resolvedJob == null) {
          return ActivityCompletion(
            state: state,
            message: 'Görev kaydı bulunamadı.',
          );
        }
        final taskId = int.tryParse(activity.payload['task_id'] ?? '') ?? -1;
        final task =
            _taskGenerator.find(
              job: resolvedJob,
              cityId:
                  int.tryParse(activity.payload['city_id'] ?? '') ??
                  state.currentCityId,
              day:
                  int.tryParse(activity.payload['task_day'] ?? '') ??
                  activity.startedDay,
              taskId: taskId,
            ) ??
            WorkTaskCatalog.findById(taskId);
        if (task == null) {
          return ActivityCompletion(
            state: state,
            message: 'Görev kaydı bulunamadı.',
          );
        }
        final result = _workService.complete(
          state,
          resolvedJob,
          task,
          salary: state.employment?.salary,
        );
        final employment = state.employment;
        final nextState = employment == null
            ? result.state
            : result.state.copyWith(
                employment: employment.copyWith(lastTaskDay: state.day),
              );
        return ActivityCompletion(
          state: nextState,
          message: '+₺${result.income} kazandın. Görev tamamlandı.',
        );
      case ActivityType.jobApplication:
        final job = JobCatalog.findById(int.tryParse(activity.sourceId));
        final cityId =
            int.tryParse(activity.payload['city_id'] ?? '') ??
            state.currentCityId;
        final salary =
            int.tryParse(activity.payload['salary'] ?? '') ?? job?.salary ?? 0;
        if (job == null) {
          return ActivityCompletion(
            state: state,
            message: 'Başvuru kaydı bulunamadı.',
          );
        }
        final listing = JobListing(
          job: job,
          cityId: cityId,
          salary: salary,
          opportunityIndex: 0,
          employer: activity.payload['employer'],
        );
        final nextState = _jobApplicationService.complete(
          state,
          listing,
          competitionDay: activity.startedDay,
        );
        return ActivityCompletion(
          state: nextState,
          message: nextState.lastJobEvent ?? 'Başvuru sonucu kaydedilemedi.',
        );
    }
  }

  EarningPerformance _performance(ActiveActivity activity) {
    return EarningPerformance(
      hits: int.tryParse(activity.payload['hits'] ?? '') ?? 0,
    );
  }
}
