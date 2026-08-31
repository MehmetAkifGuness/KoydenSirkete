import '../../../game/domain/entities/player_state.dart';
import '../entities/achievement.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../company/domain/services/company_growth_service.dart';
import '../../../economy/domain/entities/economy_difficulty.dart';

class AchievementService {
  static final achievements = <Achievement>[
    Achievement(
      id: 1,
      title: 'İlk kazanç',
      description: 'Toplam 100 ₺ kazan.',
      reward: 50,
      target: 100,
      measure: (state) => state.totalEarned,
    ),
    Achievement(
      id: 2,
      title: 'Çalışkan',
      description: '5 çalışma görevi tamamla.',
      reward: 150,
      target: 5,
      measure: (state) => state.totalWorkSessions,
    ),
    Achievement(
      id: 3,
      title: 'Öğrenmeye açık',
      description: '5 eğitim tamamla.',
      reward: 100,
      target: 5,
      measure: (state) => state.totalTrainingSessions,
    ),
    Achievement(
      id: 4,
      title: 'Girişimci',
      description: 'Kendi şirketini kur.',
      reward: 250,
      target: 1,
      measure: (state) => state.companyLevel > 0 ? 1 : 0,
    ),
    Achievement(
      id: 5,
      title: 'Proje yöneticisi',
      description: '3 şirket projesi tamamla.',
      reward: 300,
      target: 3,
      measure: (state) => state.completedProjects,
    ),
    Achievement(
      id: 6,
      title: 'Ev sahibi',
      description: 'İlk evini satın al.',
      reward: 500,
      target: 1,
      measure: (state) => state.ownedHomeIds.length,
    ),
    Achievement(
      id: 7,
      title: 'Gayrimenkul yatırımcısı',
      description: 'Bir evini kiraya ver.',
      reward: 750,
      target: 1,
      measure: (state) => state.rentedHomeIds.length,
    ),
    Achievement(
      id: 8,
      title: 'Bölgesel şirket',
      description: '3 farklı şehirde bayi aç.',
      reward: 2500,
      target: 3,
      measure: (state) => state.branches.length,
    ),
    Achievement(
      id: 9,
      title: 'Büyük ekip',
      description: 'Merkez ve bayilerde toplam 10 çalışana ulaş.',
      reward: 3000,
      target: 10,
      measure: CompanyGrowthService.totalEmployees,
    ),
    Achievement(
      id: 10,
      title: 'Üretim merkezi',
      description: '25 şirket projesi tamamla.',
      reward: 5000,
      target: 25,
      measure: (state) => state.completedProjects,
    ),
    Achievement(
      id: 11,
      title: 'Değerli marka',
      description: '₺250.000 şirket değerlemesine ulaş.',
      reward: 10000,
      target: 250000,
      measure: CompanyGrowthService.valuationFor,
    ),
    Achievement(
      id: 12,
      title: 'Pazar lideri',
      description: 'Ulusal pazar payını %30 seviyesine çıkar.',
      reward: 12000,
      target: 30,
      measure: CompanyGrowthService.marketShareFor,
    ),
    Achievement(
      id: 13,
      title: 'Zor girişimci',
      description: 'Zor ekonomide kendi şirketini kur.',
      reward: 5000,
      target: 1,
      measure: (state) =>
          state.economyDifficulty == EconomyDifficulty.hard &&
              state.companyLevel > 0
          ? 1
          : 0,
    ),
    Achievement(
      id: 14,
      title: 'Zor mod şampiyonu',
      description: 'Zor ekonomide bir şirket sezonunu şampiyon bitir.',
      reward: 12000,
      target: 1,
      measure: (state) => state.economyDifficulty == EconomyDifficulty.hard
          ? state.companyCompetition.championships
          : 0,
    ),
  ];

  AchievementEvaluation evaluate(PlayerState state) {
    var mask = state.unlockedAchievementsMask;
    var reward = 0;
    final unlocked = <Achievement>[];
    for (final achievement in achievements) {
      final bit = 1 << (achievement.id - 1);
      if (mask & bit != 0 || achievement.progress(state) < achievement.target) {
        continue;
      }
      mask |= bit;
      reward += achievement.reward;
      unlocked.add(achievement);
    }
    return AchievementEvaluation(
      state: state.copyWith(
        unlockedAchievementsMask: mask,
        money: state.money + reward,
        financeLedger: state.financeLedger.record(
          day: state.day,
          category: FinanceCategory.rewards,
          amount: reward,
        ),
      ),
      unlocked: unlocked,
    );
  }
}
