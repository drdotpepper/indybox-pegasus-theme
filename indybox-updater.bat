@echo off
rem Indybox theme updater. Don't run or schedule it from the theme folder:
rem setup-auto-update.bat copies it to %LOCALAPPDATA%\Indybox\ and schedules that copy.
rem It lives outside the theme folder on purpose, so a git pull can never change what runs.
rem Updates only come from the "release" branch, so work in progress on main never reaches a venue.
rem   indybox-updater.bat           -> download updates (safe any time)
rem   indybox-updater.bat restart   -> download, then restart Pegasus so it shows them
setlocal
set "THEME="
set /p THEME=<"%~dp0theme-path.txt"
if not defined THEME exit /b 1
if not exist "%THEME%\theme.qml" exit /b 1
cd /d "%THEME%" || exit /b 1
git fetch --quiet origin release || exit /b 1
git checkout --quiet release 2>nul || git checkout --quiet -b release --track origin/release || exit /b 1
git pull --quiet --ff-only --autostash origin release
if /i not "%~1"=="restart" exit /b 0
powershell -NoProfile -Command "$p = Get-Process pegasus-fe -ErrorAction SilentlyContinue; if ($p) { $path = $p[0].Path; $p | Stop-Process -Force; Start-Sleep -Seconds 3; Start-Process $path }"
exit /b 0
