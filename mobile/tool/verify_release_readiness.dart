import 'dart:io';

void main() {
  final failures = <String>[];
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();
  final strings = File(
    'android/app/src/main/res/values/strings.xml',
  ).readAsStringSync();
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();

  _require(
    !manifest.contains('android.permission.INTERNET'),
    failures,
    'Android manifesti INTERNET izni istememeli.',
  );
  _require(
    manifest.contains('android:allowBackup="false"'),
    failures,
    'Yerel kayıtlar Android bulut yedeğine açılmamalı.',
  );
  _require(
    strings.contains('<string name="app_name">Müdür</string>'),
    failures,
    'Android uygulama adı Müdür olmalı.',
  );
  _require(
    pubspec.contains('description: Müdür - tamamen offline'),
    failures,
    'Flutter uygulama açıklaması çevrimdışı sınırı belirtmeli.',
  );
  _require(
    !gradle.contains('signingConfigs.getByName("debug")'),
    failures,
    'Release derlemesi debug anahtarına düşmemeli.',
  );
  _require(
    gradle.contains('requestedReleaseBuild'),
    failures,
    'Release derlemesi eksik imzalama yapılandırmasında durmalı.',
  );

  final title = _read('distribution/google_play/tr-TR/title.txt', failures);
  final shortDescription = _read(
    'distribution/google_play/tr-TR/short_description.txt',
    failures,
  );
  final fullDescription = _read(
    'distribution/google_play/tr-TR/full_description.txt',
    failures,
  );
  _require(
    title.trim().length <= 30,
    failures,
    'Mağaza başlığı 30 karakteri aşmamalı.',
  );
  _require(
    shortDescription.trim().length <= 80,
    failures,
    'Kısa açıklama 80 karakteri aşmamalı.',
  );
  _require(
    fullDescription.trim().length <= 4000,
    failures,
    'Tam açıklama 4000 karakteri aşmamalı.',
  );
  _require(
    File('../PRIVACY.md').existsSync(),
    failures,
    'Kök dizinde gizlilik politikası bulunmalı.',
  );
  _require(
    File('android/key.properties.example').existsSync(),
    failures,
    'İmzalama örnek yapılandırması bulunmalı.',
  );

  _expectPngSize(
    'distribution/google_play/feature_graphic.png',
    width: 1024,
    height: 500,
    failures: failures,
  );
  final screenshots = Directory(
    'distribution/google_play/tr-TR/phoneScreenshots',
  ).listSync().whereType<File>().where((file) => file.path.endsWith('.png'));
  _require(
    screenshots.length >= 3,
    failures,
    'En az üç Türkçe telefon ekran görüntüsü bulunmalı.',
  );
  for (final screenshot in screenshots) {
    _expectPngSize(
      screenshot.path,
      width: 1080,
      height: 1920,
      failures: failures,
    );
  }

  if (failures.isNotEmpty) {
    stderr.writeln(failures.map((failure) => '- $failure').join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Android yayın metadatası, gizlilik, imzalama ve görseller hazır.',
  );
}

String _read(String path, List<String> failures) {
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Eksik yayın dosyası: $path');
    return '';
  }
  return file.readAsStringSync();
}

void _expectPngSize(
  String path, {
  required int width,
  required int height,
  required List<String> failures,
}) {
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Eksik PNG: $path');
    return;
  }
  final bytes = file.readAsBytesSync();
  if (bytes.length < 24 ||
      bytes[0] != 0x89 ||
      bytes[1] != 0x50 ||
      bytes[2] != 0x4e ||
      bytes[3] != 0x47) {
    failures.add('Geçersiz PNG: $path');
    return;
  }
  int valueAt(int offset) =>
      (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
  final actualWidth = valueAt(16);
  final actualHeight = valueAt(20);
  if (actualWidth != width || actualHeight != height) {
    failures.add(
      '$path boyutu ${actualWidth}x$actualHeight; ${width}x$height olmalı.',
    );
  }
}

void _require(bool condition, List<String> failures, String message) {
  if (!condition) failures.add(message);
}
