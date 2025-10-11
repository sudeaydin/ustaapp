@echo off
echo.
echo ========================================
echo   ustam - COMPLETE ANALYTICS SETUP
echo ========================================
echo.

REM Check if project ID is provided
if "%1"=="" (
    echo Error: Project ID required
    echo Usage: setup_complete_analytics.bat YOUR_PROJECT_ID [environment]
    echo.
    echo Examples:
    echo   setup_complete_analytics.bat ustam-production
    echo   setup_complete_analytics.bat ustam-staging staging
    echo   setup_complete_analytics.bat ustam-dev development
    echo.
    pause
    exit /b 1
)

set PROJECT_ID=%1
set ENVIRONMENT=%2
if "%ENVIRONMENT%"=="" set ENVIRONMENT=production

echo Project ID: %PROJECT_ID%
echo Environment: %ENVIRONMENT%
echo.

REM Change to backend directory
cd backend

echo [1/5] Installing Python dependencies...
pip install google-cloud-bigquery google-api-core streamlit plotly pandas

echo.
echo [2/5] Setting up BigQuery infrastructure...
python production_analytics_setup.py %PROJECT_ID% --environment %ENVIRONMENT%

if errorlevel 1 (
    echo.
    echo ERROR: Analytics setup failed!
    pause
    exit /b 1
)

echo.
echo [3/5] Creating environment configuration...
echo BIGQUERY_PROJECT_ID=%PROJECT_ID% > .env.%ENVIRONMENT%
echo BIGQUERY_DATASET_ID=ustam_analytics >> .env.%ENVIRONMENT%
echo BIGQUERY_LOGGING_ENABLED=true >> .env.%ENVIRONMENT%
echo ANALYTICS_ENVIRONMENT=%ENVIRONMENT% >> .env.%ENVIRONMENT%

echo.
echo [4/5] Testing BigQuery connection...
python -c "from app.utils.bigquery_logger import bigquery_logger; print('BigQuery connection:', 'OK' if bigquery_logger.client else 'FAILED')"

echo.
echo [5/5] Starting analytics dashboard...
echo.
echo ========================================
echo   SETUP COMPLETE!
echo ========================================
echo.
echo Project: %PROJECT_ID%
echo Environment: %ENVIRONMENT%
echo Dashboard: Starting Streamlit...
echo.
echo Next steps:
echo 1. Dashboard will open in your browser
echo 2. Deploy your app with the new environment variables
echo 3. Monitor real-time analytics data
echo.

REM Start Streamlit dashboard
streamlit run enhanced_analytics_dashboard.py

pause