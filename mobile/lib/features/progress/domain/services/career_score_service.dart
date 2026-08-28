import 'dart:math' as math;

import '../../../company/domain/services/company_expansion_service.dart';
import '../../../company/domain/services/company_growth_service.dart';
import '../../../company/domain/services/company_region_service.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/career_score.dart';
import 'achievement_service.dart';

class CareerScoreService {
  CareerScoreService({
    CompanyGrowthService? growthService,
    CompanyRegionService? regionService,
    CompanyExpansionService? expansionService,
  }) : _growthService = growthService ?? CompanyGrowthService(),
       _regionService = regionService ?? CompanyRegionService(),
       _expansionService = expansionService ?? CompanyExpansionService();

  static const prestigeStart = 20000;
  static const prestigeStep = 5000;
  static const _titles = <({int threshold, String title})>[
    (threshold: 0, title: 'Yeni başlangıç'),
    (threshold: 800, title: 'Yükselen profesyonel'),
    (threshold: 2000, title: 'Deneyimli yönetici'),
    (threshold: 4500, title: 'Girişimci'),
    (threshold: 8000, title: 'Bölgesel lider'),
    (threshold: 13000, title: 'Ulusal marka'),
    (threshold: prestigeStart, title: 'Holding mimarı'),
  ];

  final CompanyGrowthService _growthService;
  final CompanyRegionService _regionService;
  final CompanyExpansionService _expansionService;

  CareerScoreSummary summarize(PlayerState state) {
    final categories = <CareerScoreCategory>[
      _personalCareer(state),
      _companyPower(state),
      _strategicLegacy(state),
      _assets(state),
    ];
    final total = categories.fold<int>(0, (sum, item) => sum + item.score);
    final rank = _rank(total);
    return CareerScoreSummary(
      totalScore: total,
      title: rank.title,
      currentThreshold: rank.currentThreshold,
      nextTarget: rank.nextTarget,
      prestigeLevel: rank.prestigeLevel,
      categories: List<CareerScoreCategory>.unmodifiable(categories),
      goals: List<CareerScoreGoal>.unmodifiable(_goals(state)),
    );
  }

  CareerScoreCategory _personalCareer(PlayerState state) {
    final score =
        state.careerLevel * 150 +
        _sqrtScore(state.experience, 12) +
        state.skills.weightedScore() ~/ 4 +
        state.totalWorkSessions * 15 +
        state.totalTrainingSessions * 20 +
        _sqrtScore(state.totalEarned, 3) +
        state.day * 2;
    return CareerScoreCategory(
      title: 'Kişisel kariyer',
      description: 'Tecrübe, yetenek, çalışma, eğitim ve geçen günler',
      score: score,
    );
  }

  CareerScoreCategory _companyPower(PlayerState state) {
    final score =
        state.companyLevel * 250 +
        state.companyStageIndex * 600 +
        state.completedProjects * 50 +
        CompanyGrowthService.totalEmployees(state) * 70 +
        state.branches.length * 120 +
        _sqrtScore(_growthService.valuation(state), 3);
    return CareerScoreCategory(
      title: 'Şirket gücü',
      description: 'Aşama, değerleme, ekip, bayi ve tamamlanan projeler',
      score: score,
    );
  }

  CareerScoreCategory _strategicLegacy(PlayerState state) {
    final achievements = AchievementService.achievements
        .where((achievement) => achievement.isUnlocked(state))
        .length;
    final score =
        _regionService.controlledCount(state) * 300 +
        _expansionService.completedDeals(state).length * 350 +
        state.companyCompetition.championships * 500 +
        achievements * 150;
    return CareerScoreCategory(
      title: 'Stratejik miras',
      description: 'Bölgeler, anlaşmalar, kupalar ve başarılar',
      score: score,
    );
  }

  CareerScoreCategory _assets(PlayerState state) {
    final score =
        state.ownedHomeIds.length * 400 +
        state.rentedHomeIds.length * 200 +
        (state.ownedCarId == null ? 0 : 250) +
        _sqrtScore(state.money, 2);
    return CareerScoreCategory(
      title: 'Varlıklar',
      description: 'Evler, kiralık mülkler, araç ve kişisel birikim',
      score: score,
    );
  }

  List<CareerScoreGoal> _goals(PlayerState state) {
    final goals = <CareerScoreGoal>[
      _cyclicGoal(
        title: 'Çalışma serisi',
        description: 'Her görev kariyer puanını kalıcı artırır.',
        current: state.totalWorkSessions,
        step: 5,
        scoreReward: 75,
      ),
      _cyclicGoal(
        title: 'Eğitim serisi',
        description: 'Yeni eğitimlerle kişisel kariyerini büyüt.',
        current: state.totalTrainingSessions,
        step: 3,
        scoreReward: 60,
      ),
    ];
    if (state.companyLevel == 0) {
      goals.add(
        const CareerScoreGoal(
          title: 'İlk şirket',
          description: 'Şirketini kurarak yeni puan kaynaklarını aç.',
          current: 0,
          target: 1,
          scoreReward: 250,
        ),
      );
    } else {
      goals.add(
        _cyclicGoal(
          title: 'Proje portföyü',
          description: 'Her beş proje şirket gücüne +250 puan katar.',
          current: state.completedProjects,
          step: 5,
          scoreReward: 250,
        ),
      );
      goals.add(_strategicGoal(state));
    }
    return goals;
  }

  CareerScoreGoal _strategicGoal(PlayerState state) {
    final regions = _regionService.controlledCount(state);
    if (regions < CompanyRegionService.definitions.length) {
      return CareerScoreGoal(
        title: 'Yeni bölge hâkimiyeti',
        description: 'Bir bölge daha kontrol ederek stratejik mirasını büyüt.',
        current: regions,
        target: regions + 1,
        scoreReward: 300,
      );
    }
    final deals = _expansionService.completedDeals(state).length;
    if (deals < CompanyExpansionService.deals.length) {
      return CareerScoreGoal(
        title: 'Stratejik şirket işlemi',
        description: 'Yeni satın alma, birleşme veya pazar payı devri tamamla.',
        current: deals,
        target: deals + 1,
        scoreReward: 350,
      );
    }
    final trophies = state.companyCompetition.championships;
    return CareerScoreGoal(
      title: 'Yeni sezon kupası',
      description: 'Şampiyonluk sayısı arttıkça prestij yolculuğu sürer.',
      current: trophies,
      target: trophies + 1,
      scoreReward: 500,
    );
  }

  CareerScoreGoal _cyclicGoal({
    required String title,
    required String description,
    required int current,
    required int step,
    required int scoreReward,
  }) {
    final start = current ~/ step * step;
    return CareerScoreGoal(
      title: title,
      description: description,
      current: current - start,
      target: step,
      scoreReward: scoreReward,
    );
  }

  ({String title, int currentThreshold, int nextTarget, int prestigeLevel})
  _rank(int score) {
    if (score >= prestigeStart) {
      final completed = (score - prestigeStart) ~/ prestigeStep;
      final prestigeLevel = completed;
      return (
        title: prestigeLevel == 0
            ? _titles.last.title
            : 'Kariyer efsanesi · Prestij $prestigeLevel',
        currentThreshold: prestigeStart + completed * prestigeStep,
        nextTarget: prestigeStart + (completed + 1) * prestigeStep,
        prestigeLevel: prestigeLevel,
      );
    }
    for (var index = _titles.length - 2; index >= 0; index--) {
      final current = _titles[index];
      if (score >= current.threshold) {
        return (
          title: current.title,
          currentThreshold: current.threshold,
          nextTarget: _titles[index + 1].threshold,
          prestigeLevel: 0,
        );
      }
    }
    return (
      title: _titles.first.title,
      currentThreshold: 0,
      nextTarget: _titles[1].threshold,
      prestigeLevel: 0,
    );
  }

  int _sqrtScore(int value, int multiplier) =>
      (math.sqrt(value.clamp(0, 1 << 62).toInt()) * multiplier).round();
}
