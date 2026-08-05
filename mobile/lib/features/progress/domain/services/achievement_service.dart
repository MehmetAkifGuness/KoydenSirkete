import '../../../game/domain/entities/player_state.dart';
import '../entities/achievement.dart';

class AchievementService {
  static final achievements = <Achievement>[
    Achievement(id: 1, title: 'İlk kazanç', description: 'Toplam 100 ₺ kazan.', reward: 50, target: 100, measure: (state) => state.totalEarned),
    Achievement(id: 2, title: 'Çalışkan', description: '5 çalışma görevi tamamla.', reward: 150, target: 5, measure: (state) => state.totalWorkSessions),
    Achievement(id: 3, title: 'Öğrenmeye açık', description: '5 eğitim tamamla.', reward: 100, target: 5, measure: (state) => state.totalTrainingSessions),
    Achievement(id: 4, title: 'Girişimci', description: 'Kendi şirketini kur.', reward: 250, target: 1, measure: (state) => state.companyLevel > 0 ? 1 : 0),
    Achievement(id: 5, title: 'Proje yöneticisi', description: '3 şirket projesi tamamla.', reward: 300, target: 3, measure: (state) => state.completedProjects),
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
      state: state.copyWith(unlockedAchievementsMask: mask, money: state.money + reward),
      unlocked: unlocked,
    );
  }
}
