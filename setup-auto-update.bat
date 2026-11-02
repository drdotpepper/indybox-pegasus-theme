@echo off
rem Run this ONCE on the cabinet PC. It schedules:
rem   - every 15 minutes: download theme updates quietly
rem   - every night at 05:00: download, then restart Pegasus so the new look appears
cd /d "%~dp0"
schtasks /create /tn "Indybox download updates" /tr "\"%~dp0auto-update.bat\"" /sc minute /mo 15 /f
schtasks /create /tn "Indybox restart Pegasus" /tr "\"%~dp0auto-update.bat\" restart" /sc daily /st 05:00 /f
echo.
echo Done. Updates will download every 15 minutes and show up after the 05:00 restart.
pause
