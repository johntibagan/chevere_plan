# Desde cualquier carpeta:
#   Solo datos de usuario (conserva DIVIPOLA + sitios masivos):
#     powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1
#   Cero absoluto + DIVIPOLA + carga masiva:
#     powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1 -Full

param(
  [switch]$Full
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PYTHONIOENCODING = "utf-8"
Set-Location $PSScriptRoot
if ($Full) {
  python .\reset_all.py --full
} else {
  python .\reset_all.py
}
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
