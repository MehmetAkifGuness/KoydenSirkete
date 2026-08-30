import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

class AppPageGuidance extends StatelessWidget {
  const AppPageGuidance({
    required this.purpose,
    required this.nextAction,
    super.key,
  });

  final String purpose;
  final String nextAction;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Ekranın amacı: $purpose. Önerilen hamle: $nextAction',
    child: Padding(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          const Icon(
            Icons.assistant_direction_rounded,
            size: 13,
            color: AppPalette.primary,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              'Sonraki hamle · $nextAction',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

String appNextAction(String title) => switch (title) {
  'Kontrol' => 'Enerjine uygun bir günlük faaliyet seç.',
  'Kariyer' => 'Bir sonraki kariyer koşulunu tamamla.',
  'İşim' => 'Günlük görevini yap veya yeni fırsat ara.',
  'Şirketim' => 'Aktif projeyi ve şirket kasasını kontrol et.',
  'Profil' => 'İlerlemeni incele veya oyun ayarını yönet.',
  'Kazanç' => 'İlk sermayen için uygun kazancı seç.',
  'Eğitim' => 'Hedeflediğin işin eksik yeteneğini geliştir.',
  'Finans' => 'Hesap hareketlerini ve yaklaşan giderleri kontrol et.',
  'Varlıklarım' => 'Getiri süresi bütçene uygun bir varlığı karşılaştır.',
  'Yetenekler' => 'En düşük yeteneğini geliştirecek eğitimi seç.',
  'Spor' => 'Enerji ve zamanına uygun etkinliği seç.',
  'İş fırsatları' => 'Koşullarını karşıladığın ilanları filtrele.',
  'Şehirler' => 'Maliyet ve fırsat avantajlarını karşılaştır.',
  'Günün görevleri' => 'Enerjine uygun görevi tamamla.',
  'Bayiler' => 'Bölge hedefin için uygun bayiyi değerlendir.',
  'Sezon geçmişi' => 'Sonuçlarını karşılaştırıp yeni sezon planını belirle.',
  'İlerleme' => 'En yakın kısa vadeli hedefe odaklan.',
  'Kariyer durdu' => 'Yeni ve dengeli bir kariyer başlat.',
  _ => 'Durumu inceleyip kullanılabilir ana işlemi seç.',
};
