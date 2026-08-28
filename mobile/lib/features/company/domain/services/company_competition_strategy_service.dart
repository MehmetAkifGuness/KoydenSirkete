import 'dart:math' as math;

import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_competition_strategy.dart';
import '../entities/company_competitor.dart';
import '../entities/company_specialty.dart';
import 'company_service.dart';

class CompanyCompetitionStrategyService {
  const CompanyCompetitionStrategyService();

  static const strategies = <CompanyCompetitionStrategy>[
    CompanyCompetitionStrategy(
      id: 'project_offensive',
      title: 'Proje atağı',
      description:
          'Kaynakları hızlı teslimata ayırarak yenilikçi rakiplere baskı kurar.',
      counteredSpecialty: CompanySpecialty.technology,
      baseStrengthBonus: 2,
      counterStrengthBonus: 4,
      revenuePercent: -3,
      payrollPercent: 0,
    ),
    CompanyCompetitionStrategy(
      id: 'price_leadership',
      title: 'Fiyat liderliği',
      description:
          'Pazar payı için marjdan vazgeçerek satış odaklı rakipleri zorlar.',
      counteredSpecialty: CompanySpecialty.sales,
      baseStrengthBonus: 3,
      counterStrengthBonus: 4,
      revenuePercent: -8,
      payrollPercent: 0,
    ),
    CompanyCompetitionStrategy(
      id: 'quality_advantage',
      title: 'Kalite üstünlüğü',
      description:
          'Denetim ve uzmanlığa yatırım yaparak operasyon rakiplerini geride bırakır.',
      counteredSpecialty: CompanySpecialty.operations,
      baseStrengthBonus: 3,
      counterStrengthBonus: 4,
      revenuePercent: -2,
      payrollPercent: 4,
    ),
    CompanyCompetitionStrategy(
      id: 'growth_push',
      title: 'Büyüme hamlesi',
      description:
          'Bayi ağını öne çıkararak lojistik üstünlüğüne doğrudan karşılık verir.',
      counteredSpecialty: CompanySpecialty.logistics,
      baseStrengthBonus: 2,
      counterStrengthBonus: 4,
      revenuePercent: -4,
      payrollPercent: 3,
    ),
  ];

  CompanyCompetitionStrategy? byId(String id) {
    for (final strategy in strategies) {
      if (strategy.id == id) return strategy;
    }
    return null;
  }

  CompanyCompetitionStrategy selectedFor(PlayerState state) =>
      byId(state.companyCompetition.strategyId) ??
      const CompanyCompetitionStrategy.neutral();

  PlayerState select(PlayerState state, CompanyCompetitionStrategy strategy) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    if (state.companyCompetition.strategyId.isNotEmpty) {
      throw const GameRuleException(
        'Sezon stratejisi yeni sezon başlayana kadar değiştirilemez.',
      );
    }
    final selected = byId(strategy.id);
    if (selected == null) {
      throw const GameRuleException('Geçersiz rekabet stratejisi.');
    }
    return state.copyWith(
      companyCompetition: state.companyCompetition.copyWith(
        strategyId: selected.id,
      ),
    );
  }

  CompanyStrategyEffect effectFor(
    PlayerState state,
    CompanyCompetitionStrategy strategy,
    CompanyCompetitor competitor,
  ) {
    if (!strategy.isSelected) {
      return const CompanyStrategyEffect(
        strategy: CompanyCompetitionStrategy.neutral(),
        strengthModifier: 0,
        reason: 'Bu sezon için strateji avantajı yok.',
      );
    }
    final readiness = _readinessBonus(state, strategy.id);
    final counters = competitor.specialty == strategy.counteredSpecialty;
    final counterBonus = counters ? strategy.counterStrengthBonus : 0;
    final modifier = (strategy.baseStrengthBonus + readiness + counterBonus)
        .clamp(0, 10)
        .toInt();
    final reasons = <String>[
      'Temel +${strategy.baseStrengthBonus}',
      if (readiness > 0) 'Hazırlık +$readiness',
      if (counters)
        '${strategy.counteredSpecialty.label} rakibe karşı +$counterBonus',
    ];
    return CompanyStrategyEffect(
      strategy: strategy,
      strengthModifier: modifier,
      reason: reasons.join(' · '),
    );
  }

  int _readinessBonus(PlayerState state, String strategyId) =>
      switch (strategyId) {
        'project_offensive' => math.min(
          2,
          state.projectProgress ~/ 34 + (state.completedProjects > 0 ? 1 : 0),
        ),
        'price_leadership' => state.companyFunds >= 5000 ? 1 : 0,
        'quality_advantage' => _qualityReadiness(state),
        'growth_push' => state.branches.length.clamp(0, 2).toInt(),
        _ => 0,
      };

  int _qualityReadiness(PlayerState state) {
    final employees = [
      ...CompanyService.employeesFor(state),
      for (final branch in state.branches) ...branch.employees,
    ];
    if (employees.isEmpty) return 0;
    final average =
        employees.fold<int>(
          0,
          (total, employee) => total + employee.effectivePerformance,
        ) ~/
        employees.length;
    return average >= 80
        ? 2
        : average >= 65
        ? 1
        : 0;
  }
}
