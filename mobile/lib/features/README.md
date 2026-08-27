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

2.5.0 itibarıyla `earning`, `training`, `skills`, `sport`, `jobs`, `career`, `cities`, `finance`, `employment`, `company`, `assets` ve `wheel` offline oynanabilir durumdadır. Oyun saati yalnızca foreground'da ilerler; enerji gerçek zamanla, uygulama kapalıyken de tamamlanır ve tüm kalıcı veri SQLite v25 üzerinde tutulur. Ev/araba alım-satımı ve kiralama `assets`, yaşam bütçesi `cities`, finans geçmişi `finance`, değerleme ve uzun vadeli büyüme ise `company` domain sınırlarında yönetilir. Ortak kontrast ve hareket davranışları feature'ların dışında app/core tema katmanında tutulur.
