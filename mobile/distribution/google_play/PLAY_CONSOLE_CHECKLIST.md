# Müdür — Google Play Console yayın kontrolü

Bu dosya `2.55.0+58` sürümü için hazırlanmıştır. Play Console beyanları, yüklenen AAB'nin gerçek davranışıyla aynı kalmalıdır.

## Mağaza ve sürüm

- Uygulama türü: Oyun
- Kategori: Simülasyon
- Varsayılan dil: Türkçe (`tr-TR`)
- Paket adı: `com.koydensirkete`
- Sürüm: `2.55.0` (`versionCode 58`)
- Yüklenecek dosya: upload anahtarıyla imzalanmış release `.aab`
- Play App Signing: Etkinleştir
- İletişim e-postası: Play Console'da doğrulanmış geliştirici e-postasını gir
- Gizlilik politikası: `privacy_policy_url.txt` içindeki herkese açık adres

## Uygulama içeriği beyanları

- Reklamlar: **Hayır** — reklam ve reklam SDK'sı yok.
- Uygulama erişimi: **Tüm işlevler kısıtlama olmadan kullanılabilir** — hesap/giriş yok.
- Veri Güvenliği:
  - Veri toplanıyor mu: **Hayır**
  - Veri paylaşılıyor mu: **Hayır**
  - Hesap oluşturma: **Yok**
  - Oyun kaydı yalnızca cihazdaki uygulama alanında işlenir; geliştiriciye iletilmez.
- Finansal özellikler: **Uygulamam finansal özellik sunmuyor.** Kredi, yatırım, para ve şirket kasası yalnızca değeri olmayan kurgu oyun mekanikleridir; gerçek para yönetimi veya finansal hizmet yoktur.
- Sağlık uygulamaları: **Uygulamam sağlık özelliği sunmuyor.**
- Haber uygulaması: **Hayır**
- Devlet uygulaması: **Hayır**
- Reklam kimliği: **Kullanılmıyor**
- Hedef kitle: 13 yaş ve üzeri; 13 yaş altını hedefleme.
- İçerik derecelendirmesi: Esnaf Çarkı'nın yalnızca değeri olmayan oyun parası kullanan şans mekaniğini sorularda doğru şekilde bildir. Gerçek para, para yatırma/çekme veya gerçek ödül yoktur.

## Kapalı test ve inceleme

- Yeni kişisel hesap şartına tabiysen en az 12 test kullanıcısını 14 gün kesintisiz kapalı testte tut.
- Test kullanıcılarının onboarding, kayıt devamlılığı, iflas, şirket kurma ve Holding finalini denemesini sağla.
- Play Console ön yayın raporundaki çökme, ANR, erişilebilirlik ve uyumluluk bulgularını kapat.
- Android 16/API 36 cihazında ve en düşük desteklenen API 24 cihazında açılışı doğrula.
- 16 KB sayfa boyutlu emülatörde release paketini test et.

## Release imzalama

1. Güvenli ve yedeklenmiş bir upload keystore üret.
2. `android/key.properties.example` dosyasını `android/key.properties` olarak kopyalayıp gerçek değerleri yalnızca yerel makinede doldur.
3. Keystore ve parolaları Git'e ekleme.
4. `flutter build appbundle --release` çalıştır.
5. `build/app/outputs/bundle/release/app-release.aab` dosyasının imzasını doğrula ve Play Console kapalı test kanalına yükle.
