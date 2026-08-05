# Offline mimari

```text
Flutter UI / presentation
        ↓
GameSessionController / presentation state
        ↓
GameSessionApplicationService / application
        ↓
EarningService, TrainingService, RestService / domain
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

`earning → training → jobs → career → cities → company → daily_goals → progress`

## Sürüm 1.2–1.4 sınırları

- `daily_goals`: günlük aksiyon hedefi ve tek seferlik ödül kuralı.
- `progress`: kalıcı istatistik, başarı kataloğu ve ödül değerlendirmesi.
- `company`: şirket seviyesi, kapasite ve proje kataloğu.
- Yeni kurallar application service üzerinden persist edilir; widget'lar yalnızca state ve komut çağırır.

1.4.0 itibarıyla listedeki temel özellikler offline oynanabilir durumdadır; yeni kurallar domain servislerinde, kalıcı yazma akışı application service'te tutulur.
