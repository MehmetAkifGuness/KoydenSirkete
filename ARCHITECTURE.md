# Offline mimari

```text
Flutter UI / presentation
        ↓
GameSessionController / presentation state
        ↓
GameSessionApplicationService / application
        ↓
GameClockService, ActivityService, SkillService, EmploymentService / domain
        ↓
PlayerStateRepository / domain port
        ↓
LocalPlayerStateRepository / data adapter
        ↓
PlayerStateStore / infrastructure port
        ↓
AppDatabase / SQLite
```

## SOLID sınırları

- UI widget'ları oyun kuralı veya SQL bilmez.
- Controller yalnızca state ve presentation yaşam döngüsünü yönetir.
- Application service use-case akışını ve kayıt sırasını yönetir.
- Domain servisleri para, enerji, zaman ve eğitim kurallarını hesaplar.
- Repository interface persistence ayrıntısını soyutlar.
- SQLite adapter yalnızca `PlayerStateStore` sözleşmesini uygular.
- Testlerde bellek içi fake store kullanılabilir; UI SQLite platformuna bağlanmaz.
- Her sınıf 300 satır sınırının altındadır.

## Feature sırası

`earning → training → skills → sport → jobs → career → cities → employment → company → daily_goals → progress`

## Sürüm 1.2–1.4 sınırları

- `daily_goals`: günlük aksiyon hedefi ve tek seferlik ödül kuralı.
- `progress`: kalıcı istatistik, başarı kataloğu ve ödül değerlendirmesi.
- `company`: şirket seviyesi, kapasite ve proje kataloğu.
- Yeni kurallar application service üzerinden persist edilir; widget'lar yalnızca state ve komut çağırır.

2.0.0 itibarıyla tüm oyun kuralları offline oynanabilir durumdadır. Foreground ticker yalnızca açık uygulamada saat tick'i üretir; aktif aktivite, yetenek, işveren ve istihdam verileri SQLite v15'e data katmanında JSON/alan bazlı olarak yazılır.
