import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Gizlilik politikası',
    subtitle: 'Verilerin nasıl işlendiğine ilişkin açık bilgilendirme',
    child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: const [
        AppInfoCard(
          accent: AppPalette.success,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TAMAMEN ÇEVRİMDIŞI',
                style: TextStyle(
                  color: AppPalette.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Müdür hesap oluşturmaz, reklam göstermez ve Android INTERNET iznini istemez.',
                style: TextStyle(height: 1.45),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        _PolicySection(
          title: 'Toplanan ve paylaşılan veriler',
          body:
              'Geliştirici; kişisel veri, cihaz tanımlayıcısı, konum, kişi listesi, reklam kimliği, kullanım analitiği veya çökme raporu toplamaz. Veriler geliştiriciye ya da üçüncü taraflara gönderilmez.',
        ),
        _PolicySection(
          title: 'Cihazda saklanan veriler',
          body:
              'Oyun ilerlemesi, tercihler ve şirket verileri yalnızca uygulamanın Android tarafından korunan yerel alanındaki SQLite veritabanında tutulur. Uygulama bu kayıtları bir sunucuya yüklemez.',
        ),
        _PolicySection(
          title: 'Saklama ve silme',
          body:
              'Yerel kayıt, kullanıcı uygulama içinden “Yeni oyuna başla” seçeneğini uygulayana, Android ayarlarından uygulama verilerini temizleyene veya uygulamayı kaldırana kadar cihazda kalır.',
        ),
        _PolicySection(
          title: 'Çocukların gizliliği',
          body:
              'Uygulama hiçbir kullanıcıdan kişisel veri toplamaz ve çocuklardan bilerek veri istemez.',
        ),
        _PolicySection(
          title: 'Geliştirici ve iletişim',
          body:
              'Geliştirici: Mehmet Akif Güneş\nSorular ve gizlilik talepleri: github.com/MehmetAkifGuness/KoydenSirkete/issues',
        ),
        SizedBox(height: 4),
        Text(
          'Son güncelleme: 31 Ağustos 2026',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppPalette.textMuted, fontSize: 11),
        ),
      ],
    ),
  );
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    ),
  );
}
