# Dev run: inyecta .env en compile-time (no va al APK como asset).
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
$envFile = Join-Path (Get-Location) '.env'
if (-not (Test-Path $envFile)) {
  Write-Host "Copia .env.example a .env y rellena valores."
  exit 1
}
flutter run --dart-define-from-file=.env @args
