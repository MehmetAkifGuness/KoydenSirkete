# Flutter feature planı

Mobil uygulama çalışma zamanında tamamen offline çalışır. UI iş kurallarını içermez; kurallar feature içindeki domain/application katmanında tutulur.

Her feature için hedef yapı:

```text
features/<feature>/
├── presentation/pages
├── presentation/widgets
├── presentation/state
├── presentation/models
├── domain/entities
├── domain/repositories
├── data/datasources
├── data/models
├── data/mappers
└── data/repositories
```

2.24.0 itibarıyla `earning`, `training`, `skills`, `sport`, `jobs`, `career`, `cities`, `finance`, `employment`, `company`, `assets` ve `wheel` offline oynanabilir durumdadır. Oyun saati yalnızca foreground'da ilerler; enerji gerçek zamanla, uygulama kapalıyken de tamamlanır ve tüm kalıcı veri SQLite v29 üzerinde tutulur. Ev/araba alım-satımı ve kiralama `assets`, yaşam bütçesi `cities`; hesap bazlı kişisel/şirket hareketleri `finance`; açık uçlu kariyer başarı puanı ve tekrar eden prestij hedefleri `progress`; müşteri, teslim süresi, gecikme ve kalite sonuçlu 15 projeli dört kategorili portföy, proje riski, çalışan uzmanlığı, moral ve sadakat, karakter ve sektör profilli kurgu rakipler, rakiplerin deterministik şirket ilerlemeleri, 30 günlük rekabet sezonları, kalıcı sezon geçmişi, sezon piyasa kuralları, dengeli deterministik sezon olay takvimi, sezonluk oyuncu stratejileri ve dereceye bağlı kupa/sponsor/davet/itibar ödülleri, kalıcı kupa geçmişi ve avantajları, şirket aşamaları, yedi stratejik bölge, satın alma/birleşme işlemleri, piyasa dönemleri, şirket hazinesi, bayi seviyeleri ve değerleme ise `company` domain sınırlarında yönetilir. Ortak kontrast ve hareket davranışları feature'ların dışında app/core tema katmanında tutulur.
