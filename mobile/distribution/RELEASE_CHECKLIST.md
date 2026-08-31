# Android yayın kontrol listesi

- `pubspec.yaml` sürüm adı/kodu ve Türkçe sürüm notları güncel.
- `android/key.properties`, repoya eklenmeyen upload anahtarını gösteriyor.
- `dart tool/verify_release_readiness.dart` başarılı.
- `flutter analyze --fatal-infos` ve `flutter test` başarılı.
- Düşük, orta ve yüksek profilli üç fiziksel Android cihaz kapısı başarılı.
- Önceki üretim APK'sından yükseltme ve çevrimdışı temiz kurulum senaryosu başarılı.
- `flutter build appbundle --release` çıktısının SHA-256 özeti yayın kaydına eklendi.
- Play Console veri güvenliği yanıtları `PRIVACY.md` ile aynı: veri toplanmıyor ve paylaşılmıyor.
