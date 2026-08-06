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

2.0.0 itibarıyla `earning`, `training`, `skills`, `sport`, `jobs`, `career`, `cities`, `employment`, `company` ve `wheel` offline oynanabilir durumdadır. Oyun saati yalnızca foreground'da ilerler ve tüm kalıcı veri SQLite v17 üzerinde tutulur.
