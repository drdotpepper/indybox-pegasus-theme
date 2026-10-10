@echo off
cd /d "%~dp0"
git pull --autostash
echo.
echo Done. Press F5 in Pegasus to reload the theme.
pause
