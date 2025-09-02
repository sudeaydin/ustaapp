@echo off
echo 🔄 Setting up Daily BigQuery Sync for Production...
echo.

set /p PROJECT_ID="Enter your BigQuery Project ID (ustaapp-analytics): "
if "%PROJECT_ID%"=="" set PROJECT_ID=ustaapp-analytics

echo.
echo 📅 Setting up Windows Task Scheduler for daily sync...
echo.

REM Create task that runs daily at 2 AM
schtasks /create /tn "ustam BigQuery Daily Sync" /tr "\"%CD%\daily_sync.bat\"" /sc daily /st 02:00 /f

echo.
echo ✅ Daily sync task created!
echo.
echo 📋 Task Details:
echo    Name: ustam BigQuery Daily Sync
echo    Schedule: Daily at 2:00 AM
echo    Command: %CD%\daily_sync.bat
echo.
echo 🔧 To manage this task:
echo    - View: schtasks /query /tn "ustam BigQuery Daily Sync"
echo    - Delete: schtasks /delete /tn "ustam BigQuery Daily Sync" /f
echo.

REM Create the daily sync batch file
echo @echo off > daily_sync.bat
echo cd /d "%CD%" >> daily_sync.bat
echo echo %%date%% %%time%% - Starting BigQuery sync... ^>^> sync.log >> daily_sync.bat
echo python production_bigquery_sync.py %PROJECT_ID% ^>^> sync.log 2^>^&1 >> daily_sync.bat
echo echo %%date%% %%time%% - Sync completed ^>^> sync.log >> daily_sync.bat

echo ✅ Created daily_sync.bat script
echo.
echo 🎯 Manual Test:
echo    Run: daily_sync.bat
echo.
echo 📊 Logs will be saved to:
echo    - sync.log (Windows Task Scheduler output)  
echo    - bigquery_sync.log (Python script output)
echo.
pause