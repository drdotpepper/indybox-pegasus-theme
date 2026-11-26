@echo off
rem Run this ONCE on the cabinet PC, from the theme folder. Run it again if indybox-updater.bat changes.
rem It copies the updater to %LOCALAPPDATA%\Indybox\ (outside the theme folder) and schedules:
rem   - every 15 minutes: download theme updates from the release branch quietly
rem   - every night at 05:00: download, then restart Pegasus so the new look appears
rem Re-running it replaces the old scheduled tasks, including ones from the previous version.
setlocal
set "THEMEDIR=%~dp0"
set "THEMEDIR=%THEMEDIR:~0,-1%"
set "DEST=%LOCALAPPDATA%\Indybox"
if not exist "%DEST%" mkdir "%DEST%"
copy /y "%~dp0indybox-updater.bat" "%DEST%\indybox-updater.bat" >nul || goto fail
>"%DEST%\theme-path.txt" echo %THEMEDIR%
schtasks /create /tn "Indybox download updates" /tr "\"%DEST%\indybox-updater.bat\"" /sc minute /mo 15 /f || goto fail
schtasks /create /tn "Indybox restart Pegasus" /tr "\"%DEST%\indybox-updater.bat\" restart" /sc daily /st 05:00 /f || goto fail
echo.
echo Done. Updates download every 15 minutes from the release branch and show up after the 05:00 restart.
pause
exit /b 0
:fail
echo.
echo Something went wrong. Check the messages above and try again.
pause
exit /b 1
