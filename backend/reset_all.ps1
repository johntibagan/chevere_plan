# Desde cualquier carpeta:
#   powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PYTHONIOENCODING = "utf-8"
Set-Location $PSScriptRoot
python .\reset_all.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
