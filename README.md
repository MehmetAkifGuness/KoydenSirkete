# Müdür

Android-first, tamamen offline kariyer ve şirket simülasyonu.

## Kesin çalışma sınırı

- APK kurulduktan sonra internet, hesap, Google Play Games, backend veya Docker gerekmez.
- Uygulama uçak modunda çalışır.
- Oyun kuralları cihazdaki Dart `domain/application` katmanında çalışır.
- İlerleme SQLite veritabanında cihazda saklanır.
- Android manifestinde `INTERNET` izni yoktur.

## Teknoloji

- Flutter + Dart
- SQLite + sqflite
- Material 3
- Feature-first klasörleme
- SOLID bağımlılık yönü: presentation → application → domain ← data adapter

## v0.1.0 kapsamı

- Tek oyuncu kaydı
- Para, enerji, bilgi, tecrübe
- Para kazanma eylemi ve günlük azalan kazanç
- Dinlenme ve enerji yenileme
- Ücretsiz pratik, standart kurs ve yoğun eğitim
- Gün/saat ilerlemesi
- Yerel kayıt ve kayıt şema sürümü

## v1.0.0 kapsamı

- Onboarding ve yerel yeni oyun sıfırlama
- Dokunma mini oyunu ve performans bonusu
- İş ilanları, çalışma görevleri, maaş ve performans
- Kariyer yolu ve terfi
- Şehir değişimi ve günlük yaşam giderleri
- Şirket kurma, çalışan alma ve proje yönetimi
- SQLite v2-v7 geriye dönük migrasyonları

## v1.0.1 stabilizasyonu

- Yerel kayıt hatalarında tekrar deneme ekranı
- Kontrollü kayıt hatası mesajları

## v1.1.0 içerik genişletmesi

- Finans kariyer hattı ve yeni iş ilanları
- Finans/lojistik çalışma görevleri
- Uzmanlık eğitimi
- Sahil kenti ve Teknoloji vadisi

## v1.2.0 günlük hedefler

- Her oyun gününde üç üretken aksiyonluk günlük hedef.
- Hedef tamamlanınca cihazda saklanan ₺120 ödül.
- Kazanç, çalışma ve eğitim aksiyonlarının günlük takibi.

## v1.3.0 ilerleme sistemi

- Toplam kazanç, görev, eğitim ve proje istatistikleri.
- Tek seferlik ödüllü başarılar.
- Profil üzerinden başarı ve ilerleme ekranı.

## v1.4.0 şirket derinliği

- Üç şirket seviyesi ve çalışan kapasitesi.
- Seviye bazlı üç proje türü.
- Proje maliyeti, ödülü, ilerleme hızı ve deneyim kazanımı.

## v2.0.0 offline gerçek zamanlı sürüm

- Yalnızca foreground'da ilerleyen oyun saati: 20 gerçek saniye = 1 oyun saati.
- Tek aktif aktivite, gerçek her 60 saniyede 10 enerji yenilenmesi ve sporla 200'e kadar maksimum enerji.
- Uygulama kapalıyken de enerji açılışta geçen gerçek süreye göre tamamlanır.
- 10 mesleki yetenek, 1000 üst sınır, çoklu yetenek eğitimleri ve göreve göre süre/enerji verimliliği.
- Türkiye'nin 81 ili, 2025 ADNKS nüfuslarıyla nüfusa bağlı teknoloji, ekonomi, maaş ve iş fırsatları.
- 20 rol, cihaz içinde seed tabanlı gizli bot rekabeti ve günlük başvuru sonucu.
- Ayrı `İşim` ve `Şirketim` ekranları; her oyun gününde değişen işveren görevleri.
- İki oyun günü görev başlatılmadığında yalnızca foreground gün geçişinde işten çıkarılma.
- SQLite şema v18; eski v10 kayıtları sıfırlanmadan okunur. Para 24 oyun saati boyunca negatif kalırsa iflas sistemi devreye girer. Aktif işlerde 50 TL bedelli, bekleme süresi olmayan 20 dilimli Esnaf Çarkı kullanılabilir.

## Çalıştırma

```powershell
cd mobile
flutter pub get
flutter run
```

APK:

```powershell
flutter build apk --release
```

Mağaza dağıtımı için `mobile/android/key.properties.example` dosyasını `key.properties` olarak kopyalayıp gerçek release keystore bilgilerini girin. Bilgi yoksa release derlemesi yalnızca yerel test için debug imzasıyla oluşturulur.
