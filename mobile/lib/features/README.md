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

İlk sürümde `earning` ve `training` oynanabilir; `jobs`, `career`, `cities` ve `company` sonraki offline sürümlerde açılır.
