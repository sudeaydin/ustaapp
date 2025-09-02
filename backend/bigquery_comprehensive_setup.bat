@echo off
echo.
echo 🚀 ustam - COMPREHENSIVE BIGQUERY SETUP
echo ==================================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed or not in PATH
    echo Please install Python 3.7+ and try again
    pause
    exit /b 1
)

REM Check if gcloud is available
gcloud version >nul 2>&1
if errorlevel 1 (
    echo ❌ Google Cloud SDK is not installed or not in PATH
    echo Please install Google Cloud SDK and try again
    echo Download: https://cloud.google.com/sdk/docs/install
    pause
    exit /b 1
)

REM Get project ID from user
set /p PROJECT_ID="Enter your Google Cloud Project ID: "
if "%PROJECT_ID%"=="" (
    echo ❌ Project ID cannot be empty
    pause
    exit /b 1
)

echo.
echo 📊 Project ID: %PROJECT_ID%
echo 📈 Dataset: ustam_analytics
echo 🌍 Location: US
echo.

REM Confirm setup
set /p CONFIRM="Continue with comprehensive setup? (y/N): "
if /i not "%CONFIRM%"=="y" (
    echo Setup cancelled
    pause
    exit /b 0
)

echo.
echo 🔍 Checking prerequisites...

REM Check authentication
gcloud auth list | findstr "ACTIVE" >nul
if errorlevel 1 (
    echo ❌ No active authentication found
    echo Please run: gcloud auth login
    pause
    exit /b 1
)

REM Set project
echo 📊 Setting project...
gcloud config set project %PROJECT_ID%

REM Enable BigQuery API
echo 🔧 Enabling BigQuery API...
gcloud services enable bigquery.googleapis.com

REM Install Python dependencies
echo 📦 Installing Python dependencies...
pip install google-cloud-bigquery google-api-core

echo.
echo 🚀 Running comprehensive setup...
python bigquery_comprehensive_setup.py %PROJECT_ID%

if errorlevel 1 (
    echo.
    echo ❌ Setup failed! Check the error messages above.
    pause
    exit /b 1
)

echo.
echo 📤 Running initial data upload...
python bigquery_auto_upload.py %PROJECT_ID%

echo.
echo 🎉 COMPREHENSIVE SETUP COMPLETE!
echo ==================================================
echo ✅ All tables and views created
echo ✅ Analytics infrastructure ready
echo ✅ Initial data uploaded
echo ✅ Real-time logging configured
echo.
echo 🔗 Next Steps:
echo 1. Enable BigQuery logging in your app: BIGQUERY_LOGGING_ENABLED=true
echo 2. Set project ID: BIGQUERY_PROJECT_ID=%PROJECT_ID%
echo 3. View data: https://console.cloud.google.com/bigquery?project=%PROJECT_ID%
echo 4. Create dashboards in Google Cloud Console
echo.
echo 📊 Tables created:
echo   - Core tables (users, jobs, payments, etc.)
echo   - Analytics tables (user_activity_logs, business_metrics)
echo   - Error logging (error_logs, performance_metrics)
echo   - Search analytics (search_analytics)
echo   - Payment analytics (payment_analytics)
echo.
echo 📈 Views created:
echo   - daily_user_stats
echo   - craftsman_performance  
echo   - revenue_dashboard
echo   - search_insights
echo   - error_summary
echo   - platform_comparison
echo   - business_kpis
echo.
echo Happy Analytics! 📊✨
echo.
pause