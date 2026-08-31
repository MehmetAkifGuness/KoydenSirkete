param(
  [Parameter(Mandatory = $true)][string]$DeviceId,
  [Parameter(Mandatory = $true)][string]$PreviousApk,
  [Parameter(Mandatory = $true)][string]$CurrentApk
)

$ErrorActionPreference = 'Stop'
$packageName = 'com.koydensirkete'

function Invoke-Checked {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Command)
  & $Command[0] $Command[1..($Command.Length - 1)]
  if ($LASTEXITCODE -ne 0) {
    throw "Komut başarısız: $($Command -join ' ')"
  }
}

$isEmulator = (adb -s $DeviceId shell getprop ro.kernel.qemu).Trim()
if ($isEmulator -eq '1') {
  throw 'Yayın testi fiziksel Android cihaz gerektirir.'
}
if (!(Test-Path -LiteralPath $PreviousApk) -or !(Test-Path -LiteralPath $CurrentApk)) {
  throw 'Önceki ve güncel APK yolları mevcut olmalıdır.'
}

adb -s $DeviceId uninstall $packageName | Out-Null
Invoke-Checked adb -s $DeviceId install $PreviousApk
Invoke-Checked adb -s $DeviceId shell run-as $packageName sh -c 'mkdir -p files && echo preserved > files/update_gate_marker'
Invoke-Checked adb -s $DeviceId install -r $CurrentApk
$marker = (adb -s $DeviceId shell run-as $packageName cat files/update_gate_marker).Trim()
if ($marker -ne 'preserved') {
  throw 'APK güncellemesi uygulama verisini korumadı.'
}

Invoke-Checked adb -s $DeviceId shell svc wifi disable
Invoke-Checked adb -s $DeviceId shell svc data disable
try {
  flutter test integration_test/release_smoke_test.dart -d $DeviceId --profile
  if ($LASTEXITCODE -ne 0) {
    throw 'Çevrimdışı temiz kurulum/kayıt testi başarısız.'
  }
} finally {
  adb -s $DeviceId shell svc wifi enable | Out-Null
  adb -s $DeviceId shell svc data enable | Out-Null
}

Write-Output 'APK güncelleme, veri koruma ve çevrimdışı duman kapısı başarılı.'
