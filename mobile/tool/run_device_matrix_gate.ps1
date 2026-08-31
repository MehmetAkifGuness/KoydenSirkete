param(
  [Parameter(Mandatory = $true)][string]$LowDeviceId,
  [Parameter(Mandatory = $true)][string]$MidDeviceId,
  [Parameter(Mandatory = $true)][string]$HighDeviceId
)

$ErrorActionPreference = 'Stop'
$devices = @(
  @{ Tier = 'low'; Id = $LowDeviceId },
  @{ Tier = 'mid'; Id = $MidDeviceId },
  @{ Tier = 'high'; Id = $HighDeviceId }
)
if (($devices.Id | Select-Object -Unique).Count -ne 3) {
  throw 'Düşük, orta ve yüksek testleri üç farklı fiziksel cihazda çalışmalıdır.'
}

foreach ($device in $devices) {
  $id = $device.Id
  $tier = $device.Tier
  if ((adb -s $id shell getprop ro.kernel.qemu).Trim() -eq '1') {
    throw "$tier profili emülatör olamaz: $id"
  }
  adb -s $id get-state
  if ($LASTEXITCODE -ne 0) { throw "$tier cihazına erişilemiyor: $id" }
  $model = (adb -s $id shell getprop ro.product.model).Trim()
  $memory = (adb -s $id shell cat /proc/meminfo | Select-String 'MemTotal').Line.Trim()
  Write-Output "$tier cihazı: $model · $memory"
  flutter test integration_test/performance_smoke_test.dart -d $id --profile "--dart-define=PERFORMANCE_TIER=$tier"
  if ($LASTEXITCODE -ne 0) { throw "$tier cihaz performans kapısı başarısız." }
  flutter test integration_test/release_smoke_test.dart -d $id --profile
  if ($LASTEXITCODE -ne 0) { throw "$tier cihaz duman kapısı başarısız." }
}

Write-Output 'Düşük, orta ve yüksek fiziksel Android cihaz matrisi başarılı.'
