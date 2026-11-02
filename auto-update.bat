@echo off
rem Pulls the latest Indybox theme from GitHub.
rem   auto-update.bat           -> just download updates (safe any time)
rem   auto-update.bat restart   -> download, then restart Pegasus so it shows them
cd /d "%~dp0"
git pull --autostash --quiet
if /i not "%~1"=="restart" exit /b 0
powershell -NoProfile -Command "$p = Get-Process pegasus-fe -ErrorAction SilentlyContinue; if ($p) { $path = $p[0].Path; $p | Stop-Process -Force; Start-Sleep -Seconds 3; Start-Process $path }"
exit /b 0
