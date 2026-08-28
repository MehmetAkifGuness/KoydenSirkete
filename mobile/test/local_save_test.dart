import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/database/player_state_store.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/player_state_mapper.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/company_employee_codec.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/finance_ledger_codec.dart';
import 'package:kariyerden_sirkete/features/game/data/repositories/local_player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/active_activity.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_expansion_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_trophy.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_reward.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_season_result.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_project_outcome.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';

void main() {
  test('player state repository persists the latest state', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(
      database: store,
      mapper: PlayerStateMapper(),
    );
    final expected = PlayerState.initial.copyWith(
      money: 340,
      energy: 85,
      energyRecoveryAt: DateTime(2026, 1, 1, 12),
      day: 1,
      hour: 10,
      currentJobId: 1,
      performance: 55,
      careerLevel: 2,
      currentCityId: 2,
      companyLevel: 1,
      companyFunds: 300,
      employeeCount: 2,
      projectProgress: 40,
      projectElapsedDays: 6,
      lastProjectOutcome: const CompanyProjectOutcome(
        projectId: 3,
        completedDay: 7,
        elapsedDays: 14,
        delayed: false,
        succeeded: true,
        quality: CompanyProjectQuality.high,
        netIncome: 1400,
      ),
      negativeMoneyHours: 12,
      wheelMajorRewardsToday: 2,
      wheelDurationBuffPercent: 50,
      wheelDurationBuffTasks: 2,
      wheelEnergyBuffPercent: 20,
      wheelEnergyBuffTasks: 1,
      wheelRewardBuffPercent: 100,
      wheelRewardBuffTasks: 2,
      companyCompetition: const CompanyCompetitionState(
        seasonNumber: 4,
        points: 24,
        wins: 8,
        losses: 3,
        championships: 2,
        bestRank: 1,
        lastRank: 1,
        lastReward: 6000,
        strategyId: 'quality_advantage',
        trophies: [
          CompanySeasonTrophy(seasonNumber: 3, points: 81, reward: 6000),
          CompanySeasonTrophy(seasonNumber: 4, points: 87, reward: 6000),
        ],
        seasonRewards: [
          CompanySeasonReward(
            seasonNumber: 2,
            rank: 3,
            type: CompanySeasonRewardType.projectInvitation,
            value: 1,
            consumed: true,
          ),
          CompanySeasonReward(
            seasonNumber: 3,
            rank: 2,
            type: CompanySeasonRewardType.sponsorship,
            value: 8,
          ),
        ],
        seasonHistory: [
          CompanySeasonResult(
            seasonNumber: 2,
            rank: 3,
            points: 72,
            wins: 24,
            losses: 6,
            cashReward: 1500,
            reward: CompanySeasonReward(
              seasonNumber: 2,
              rank: 3,
              type: CompanySeasonRewardType.projectInvitation,
              value: 1,
            ),
          ),
          CompanySeasonResult(
            seasonNumber: 3,
            rank: 2,
            points: 78,
            wins: 26,
            losses: 4,
            cashReward: 3000,
            reward: CompanySeasonReward(
              seasonNumber: 3,
              rank: 2,
              type: CompanySeasonRewardType.sponsorship,
              value: 8,
            ),
          ),
        ],
      ),
      companyStageIndex: 2,
      companyExpansion: const CompanyExpansionState(
        completedDealIds: ['rota_logistics', 'mavi_software'],
      ),
      isOnboarded: true,
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.money, expected.money);
    expect(actual?.energy, expected.energy);
    expect(actual?.energyRecoveryAt, expected.energyRecoveryAt);
    expect(actual?.hour, expected.hour);
    expect(actual?.currentJobId, expected.currentJobId);
    expect(actual?.performance, expected.performance);
    expect(actual?.careerLevel, expected.careerLevel);
    expect(actual?.currentCityId, expected.currentCityId);
    expect(actual?.companyLevel, expected.companyLevel);
    expect(actual?.companyFunds, expected.companyFunds);
    expect(actual?.employeeCount, expected.employeeCount);
    expect(actual?.projectProgress, expected.projectProgress);
    expect(actual?.projectElapsedDays, expected.projectElapsedDays);
    expect(actual?.lastProjectOutcome?.projectId, 3);
    expect(actual?.lastProjectOutcome?.quality, CompanyProjectQuality.high);
    expect(actual?.lastProjectOutcome?.netIncome, 1400);
    expect(actual?.negativeMoneyHours, expected.negativeMoneyHours);
    expect(actual?.wheelMajorRewardsToday, expected.wheelMajorRewardsToday);
    expect(actual?.wheelDurationBuffPercent, expected.wheelDurationBuffPercent);
    expect(actual?.wheelDurationBuffTasks, expected.wheelDurationBuffTasks);
    expect(actual?.wheelEnergyBuffPercent, expected.wheelEnergyBuffPercent);
    expect(actual?.wheelEnergyBuffTasks, expected.wheelEnergyBuffTasks);
    expect(actual?.wheelRewardBuffPercent, expected.wheelRewardBuffPercent);
    expect(actual?.wheelRewardBuffTasks, expected.wheelRewardBuffTasks);
    expect(actual?.companyCompetition.seasonNumber, 4);
    expect(actual?.companyCompetition.points, 24);
    expect(actual?.companyCompetition.championships, 2);
    expect(actual?.companyCompetition.bestRank, 1);
    expect(actual?.companyCompetition.lastReward, 6000);
    expect(actual?.companyCompetition.strategyId, 'quality_advantage');
    expect(actual?.companyCompetition.trophies, hasLength(2));
    expect(actual?.companyCompetition.trophies.last.seasonNumber, 4);
    expect(actual?.companyCompetition.trophies.last.points, 87);
    expect(actual?.companyCompetition.seasonRewards, hasLength(2));
    expect(actual?.companyCompetition.seasonRewards.first.consumed, isTrue);
    expect(
      actual?.companyCompetition.seasonRewards.last.type,
      CompanySeasonRewardType.sponsorship,
    );
    expect(actual?.companyCompetition.seasonHistory, hasLength(2));
    expect(actual?.companyCompetition.seasonHistory.first.points, 72);
    expect(actual?.companyCompetition.seasonHistory.last.rank, 2);
    expect(actual?.companyCompetition.seasonHistory.last.cashReward, 3000);
    expect(actual?.companyStageIndex, 2);
    expect(actual?.companyExpansion.completedDealIds, [
      'rota_logistics',
      'mavi_software',
    ]);
    expect(actual?.isOnboarded, expected.isOnboarded);
  });

  test('player state repository persists concurrent activities', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(
      database: store,
      mapper: PlayerStateMapper(),
    );
    const earning = ActiveActivity(
      type: ActivityType.earning,
      sourceId: 'earning',
      remainingHours: 2,
      totalHours: 2,
      energyCost: 20,
      startedDay: 1,
      startedHour: 8,
    );
    const sport = ActiveActivity(
      type: ActivityType.sport,
      sourceId: 'sport',
      remainingHours: 1,
      totalHours: 1,
      energyCost: 20,
      startedDay: 1,
      startedHour: 8,
    );
    final expected = PlayerState.initial.copyWith(
      careerLevel: 2,
      activeActivities: const [earning, sport],
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.activeActivities, hasLength(2));
    expect(actual?.activities.map((activity) => activity.sourceId), [
      'earning',
      'sport',
    ]);
  });

  test('player state repository persists selected company employees', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(
      database: store,
      mapper: PlayerStateMapper(),
    );
    const employee = CompanyEmployee(
      id: 3,
      name: 'Zeynep Yılmaz',
      role: 'Dijital uzmanı',
      performance: 86,
      dailySalary: 55,
      morale: 64,
      loyalty: 81,
      experience: 145,
      seniority: CompanyEmployeeSeniority.specialist,
      burnout: 38,
      requestedDailySalary: 64,
    );
    final expected = PlayerState.initial.copyWith(
      companyLevel: 1,
      employeeCount: 1,
      employees: const [employee],
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.employees.single.id, employee.id);
    expect(actual?.employees.single.performance, employee.performance);
    expect(actual?.employees.single.dailySalary, employee.dailySalary);
    expect(actual?.employees.single.morale, employee.morale);
    expect(actual?.employees.single.loyalty, employee.loyalty);
    expect(actual?.employees.single.experience, employee.experience);
    expect(actual?.employees.single.seniority, employee.seniority);
    expect(actual?.employees.single.burnout, employee.burnout);
    expect(
      actual?.employees.single.requestedDailySalary,
      employee.requestedDailySalary,
    );
  });

  test('legacy employee records receive safe wellbeing defaults', () {
    const legacy =
        '[{"id":3,"name":"Zeynep Yılmaz","role":"Dijital uzmanı",'
        '"performance":86,"daily_salary":55}]';
    final employee = CompanyEmployeeCodec().decodeList(legacy).single;

    expect(employee.morale, 70);
    expect(employee.loyalty, 70);
    expect(employee.experience, 0);
    expect(employee.seniority, CompanyEmployeeSeniority.junior);
    expect(employee.burnout, 0);
    expect(employee.requestedDailySalary, isNull);
  });

  test('legacy finance records default to the personal account', () {
    const legacy = '[{"day":1,"category":"casualIncome","amount":150}]';
    final entry = FinanceLedgerCodec().decode(legacy).entries.single;

    expect(entry.account, FinanceAccount.personal);
  });

  test('finance codec persists company account movements', () {
    final expected = const FinanceLedger().record(
      day: 4,
      category: FinanceCategory.companyRevenue,
      amount: 750,
      account: FinanceAccount.company,
    );
    final codec = FinanceLedgerCodec();
    final actual = codec.decode(codec.encode(expected)).entries.single;

    expect(actual.account, FinanceAccount.company);
    expect(actual.category, FinanceCategory.companyRevenue);
    expect(actual.amount, 750);
  });

  test('player state repository persists branches and owned assets', () async {
    final store = _MemoryPlayerStateStore();
    final repository = LocalPlayerStateRepository(
      database: store,
      mapper: PlayerStateMapper(),
    );
    const branch = CompanyBranch(id: 2, cityId: 2, level: 2);
    final expected = PlayerState.initial.copyWith(
      companyLevel: 1,
      branches: const [branch],
      ownedHomeIds: const [201, 202],
      rentedHomeIds: const [202],
      financeLedger: const FinanceLedger(
        entries: [
          FinanceEntry(
            day: 2,
            category: FinanceCategory.rentalIncome,
            amount: 67,
          ),
        ],
      ),
      ownedCarId: 2,
    );

    await repository.save(expected);

    final actual = await repository.load();
    expect(actual?.branches.single.cityId, 2);
    expect(actual?.branches.single.level, 2);
    expect(actual?.ownedHomeIds, [201, 202]);
    expect(actual?.rentedHomeIds, [202]);
    expect(
      actual?.financeLedger.entries.single.category,
      FinanceCategory.rentalIncome,
    );
    expect(actual?.financeLedger.entries.single.amount, 67);
    expect(actual?.ownedCarId, 2);
  });
}

class _MemoryPlayerStateStore implements PlayerStateStore {
  PlayerStateRecord? _record;

  @override
  Future<PlayerStateRecord?> readPlayerState() async => _record;

  @override
  Future<void> savePlayerState(PlayerStateRecord record) async {
    _record = record;
  }

  @override
  Future<void> close() async {}
}
