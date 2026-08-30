import '../entities/player_state.dart';

class PlayerGuidanceService {
  const PlayerGuidanceService();

  String nextAction(PlayerState state) {
    if (state.activeActivities.isNotEmpty) {
      final soonest = state.activeActivities
          .map((activity) => activity.remainingHours)
          .reduce((left, right) => left < right ? left : right);
      return 'Devam eden ${state.activeActivities.length} işlemi takip et; en yakını $soonest oyun saati içinde tamamlanacak.';
    }
    if (state.energy < 25) {
      return 'Enerjin düşük. Yeni işlem başlatmadan önce dinlen veya uygun bir spor etkinliği seç.';
    }
    if (state.money < 1000) {
      return 'Kazanç ekranından ilk sermayeni büyüt; harcama gerektiren eğitimleri sonra planla.';
    }
    if (state.knowledge < 40) {
      return 'Eğitim ekranından hedeflediğin işe uygun bilgi ve yetenek kazan.';
    }
    if (state.employment == null) {
      return 'İş fırsatlarını karşılaştır ve koşullarını karşıladığın bir ilana başvur.';
    }
    if (state.careerLevel < 3) {
      return 'İş görevleriyle tecrübe ve performans kazanarak kariyer seviyeni yükselt.';
    }
    if (state.companyLevel == 0) {
      return 'Şirket ekranında kuruluş koşullarını kontrol et ve başlangıç sermayeni hazırla.';
    }
    if (state.companyFunds == 0) {
      return 'Kişisel cüzdandan şirket kasasına operasyon sermayesi aktar.';
    }
    return 'Şirket projesini, ekibini ve günlük bütçeni birlikte kontrol et.';
  }
}
