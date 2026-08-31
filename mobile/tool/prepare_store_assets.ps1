$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$mobileRoot = Split-Path -Parent $PSScriptRoot
$storeRoot = Join-Path $mobileRoot 'distribution\google_play'
$featureSource = Join-Path $storeRoot 'feature_graphic_source.png'
$featureOutput = Join-Path $storeRoot 'feature_graphic.png'
$screenshots = Join-Path $storeRoot 'tr-TR\phoneScreenshots'
New-Item -ItemType Directory -Force $screenshots | Out-Null

function Save-CoveredImage {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Destination,
    [Parameter(Mandatory = $true)][int]$Width,
    [Parameter(Mandatory = $true)][int]$Height,
    [switch]$Contain
  )

  $sourceImage = [Drawing.Image]::FromFile($Source)
  try {
    $bitmap = New-Object Drawing.Bitmap($Width, $Height)
    try {
      $graphics = [Drawing.Graphics]::FromImage($bitmap)
      try {
        $graphics.Clear([Drawing.Color]::FromArgb(13, 15, 20))
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $scaleX = $Width / $sourceImage.Width
        $scaleY = $Height / $sourceImage.Height
        $scale = if ($Contain) { [Math]::Min($scaleX, $scaleY) } else { [Math]::Max($scaleX, $scaleY) }
        $drawWidth = [int][Math]::Round($sourceImage.Width * $scale)
        $drawHeight = [int][Math]::Round($sourceImage.Height * $scale)
        $left = [int](($Width - $drawWidth) / 2)
        $top = [int](($Height - $drawHeight) / 2)
        $graphics.DrawImage($sourceImage, $left, $top, $drawWidth, $drawHeight)
      } finally {
        $graphics.Dispose()
      }
      $bitmap.Save($Destination, [Drawing.Imaging.ImageFormat]::Png)
    } finally {
      $bitmap.Dispose()
    }
  } finally {
    $sourceImage.Dispose()
  }
}

Save-CoveredImage -Source $featureSource -Destination $featureOutput -Width 1024 -Height 500

$goldenRoot = Join-Path $mobileRoot 'test\goldens'
$names = @('dashboard', 'finance', 'company')
for ($index = 0; $index -lt $names.Length; $index++) {
  $number = ($index + 1).ToString('00')
  $source = Join-Path $goldenRoot ($names[$index] + '.png')
  $destination = Join-Path $screenshots ($number + '_' + $names[$index] + '.png')
  Save-CoveredImage -Source $source -Destination $destination -Width 1080 -Height 1920 -Contain
}

Write-Output 'Google Play görselleri hazırlandı: 1024x500 kapak, 1080x1920 ekran görüntüleri.'
