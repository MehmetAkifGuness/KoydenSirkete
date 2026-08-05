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

`earning → training → jobs → career → cities → company`

İlk sürüm yalnızca `earning` ve `training` özelliklerini oynanabilir hâle getirir. Diğerleri tasarımda kilitli görünür.
