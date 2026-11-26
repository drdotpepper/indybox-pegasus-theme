@echo off
rem Pulls the latest released theme (the release branch) now. Your config.js edits are kept.
cd /d "%~dp0"
git fetch origin release
git checkout release 2>nul || git checkout -b release --track origin/release
git pull --ff-only --autostash origin release
echo.
echo Done. Press F5 in Pegasus to reload the theme.
pause
