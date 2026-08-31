param(
  [Parameter(Mandatory = $true)]
  [string]$DeviceId
)

$ErrorActionPreference = 'Stop'
$isEmulator = (adb -s $DeviceId shell getprop ro.kernel.qemu).Trim()
if ($isEmulator -eq '1') {
  throw 'Sürüm kapısı fiziksel Android cihaz gerektirir; emülatör kabul edilmez.'
}

flutter pub get
flutter analyze --fatal-infos
dart tool\verify_domain_test_coverage.dart
dart tool\verify_class_size.dart
dart tool\verify_project_hygiene.dart
dart tool\verify_turkish_formatting.dart
dart tool\verify_release_readiness.dart
flutter test
flutter test integration_test/performance_smoke_test.dart -d $DeviceId --dart-define=PERFORMANCE_TIER=low --profile

if ($LASTEXITCODE -ne 0) {
  throw 'Fiziksel cihaz sürüm kapısı başarısız.'
}
