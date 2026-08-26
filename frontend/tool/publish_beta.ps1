# Publica el APK más liviano al portal (círculo cerrado).
#
# - Sube solo el +N en pubspec (1.0.0+2 → 1.0.0+3)
# - Release + R8 + solo arm64 (~20–25 MB; cabe en plan Free ≤50 MB)
# - Sube a Storage + actualiza beta_release
#
# Uso:
#   .\tool\publish_beta.ps1
#   .\tool\publish_beta.ps1 -SkipBump   # reusa la versión actual del pubspec

param(
  [switch]$SkipBump
)

$ErrorActionPreference = 'Stop'
$frontend = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$repo = (Resolve-Path (Join-Path $frontend '..')).Path
Set-Location $frontend

$envFile = Join-Path $frontend '.env'
if (-not (Test-Path $envFile)) {
  Write-Error "Falta frontend/.env (copia .env.example)."
}

$pubspec = Join-Path $frontend 'pubspec.yaml'
$text = Get-Content $pubspec -Raw -Encoding UTF8
if ($text -notmatch '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+(\d+)\s*$') {
  Write-Error "No pude leer version: x.y.z+N en pubspec.yaml"
}
$versionName = $Matches[1]
$build = [int]$Matches[2]

if (-not $SkipBump) {
  $build = $build + 1
  $newLine = "version: $versionName+$build"
  $text = [regex]::Replace($text, '(?m)^version:\s*[0-9]+\.[0-9]+\.[0-9]+\+\d+\s*$', $newLine)
  Set-Content -Path $pubspec -Value $text -Encoding UTF8 -NoNewline
  Write-Host "Versión → $versionName+$build"
} else {
  Write-Host "Versión (sin bump) $versionName+$build"
}

Write-Host "Compilando APK más liviano (release + R8 + arm64)…"
flutter build apk --release `
  --dart-define-from-file=.env `
  --target-platform android-arm64
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$apk = Join-Path $frontend 'build\app\outputs\flutter-apk\app-release.apk'
if (-not (Test-Path $apk)) {
  Write-Error "No apareció $apk"
}

Write-Host "Subiendo al portal…"
python (Join-Path $repo 'backend\scripts\publish_beta_apk.py') `
  --version $versionName `
  --build $build `
  --apk $apk
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Listo. Portal: https://johntibagan.github.io/chevere_plan/"
