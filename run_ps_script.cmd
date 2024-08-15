REM This script will execute a PowerShell script located in the same directory.
set "scriptName=MYSCRIPT.ps1"
set "scriptDir=%~dp0"
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%scriptDir%system_health_log.ps1"