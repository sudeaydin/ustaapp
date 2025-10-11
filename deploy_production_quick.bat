@echo off
echo.
echo ========================================
echo   ustam - QUICK PRODUCTION DEPLOYMENT
echo ========================================
echo.

REM Check if project ID is provided
if "%1"=="" (
    echo Error: Google Cloud Project ID required
    echo Usage: deploy_production_quick.bat YOUR_PROJECT_ID
    echo.
    pause
    exit /b 1
)

set PROJECT_ID=%1

echo Project ID: %PROJECT_ID%
echo.

echo [1/6] Setting up Google Cloud project...
gcloud config set project %PROJECT_ID%
gcloud services enable appengine.googleapis.com
gcloud services enable bigquery.googleapis.com

echo.
echo [2/6] Installing dependencies...
cd backend
pip install -r requirements.txt

echo.
echo [3/6] Setting up BigQuery analytics...
python production_analytics_setup.py %PROJECT_ID% --environment production

echo.
echo [4/6] Creating production database...
python create_db_with_data.py

echo.
echo [5/6] Updating app.yaml with project ID...
powershell -Command "(gc app.yaml) -replace 'ustaapp-analytics', '%PROJECT_ID%' | Out-File -encoding ASCII app.yaml"

echo.
echo [6/6] Deploying to Google App Engine...
gcloud app deploy --quiet

echo.
echo ========================================
echo   DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo Your app is now live at:
echo https://%PROJECT_ID%.appspot.com
echo.
echo Analytics Dashboard:
echo https://console.cloud.google.com/bigquery?project=%PROJECT_ID%
echo.
echo Next steps:
echo 1. Test your application
echo 2. Set up custom domain (optional)
echo 3. Configure monitoring alerts
echo 4. Update mobile app API URLs
echo.
pause