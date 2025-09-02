@echo off
echo 🚀 Complete Google Cloud Platform Deployment
echo =============================================

REM Set project
set PROJECT_ID=%1
if "%PROJECT_ID%"=="" set PROJECT_ID=ustaapp-analytics
echo 📊 Using project: %PROJECT_ID%

gcloud config set project %PROJECT_ID%

echo.
echo 📋 Deployment Plan:
echo    1. Backend API (App Engine)
echo    2. Frontend Web App (App Engine)  
echo    3. BigQuery Analytics
echo    4. Cloud SQL Database
echo    5. Scheduled Jobs
echo.

set /p CONTINUE="Continue with full deployment? (y/N): "
if /i not "%CONTINUE%"=="y" (
    echo Deployment cancelled
    pause
    exit /b 0
)

echo.
echo 🔧 Step 1: Backend API Deployment
echo =====================================
cd backend
call deploy_to_gcp.bat %PROJECT_ID%
if errorlevel 1 (
    echo ❌ Backend deployment failed
    pause
    exit /b 1
)

echo.
echo 🌐 Step 2: Frontend Web App Deployment  
echo =========================================
cd ../web

REM Build React app
echo 📦 Building React app...
call npm install
call npm run build

REM Deploy frontend
echo 🚀 Deploying frontend to App Engine...
gcloud app deploy app.yaml --quiet --version=frontend

echo.
echo 🎉 FULL DEPLOYMENT COMPLETE!
echo =============================================
echo 📱 Frontend URL: https://%PROJECT_ID%.appspot.com
echo 🔧 Backend API: https://%PROJECT_ID%.appspot.com/api
echo 📊 BigQuery: https://console.cloud.google.com/bigquery?project=%PROJECT_ID%
echo 🗄️ Cloud SQL: https://console.cloud.google.com/sql?project=%PROJECT_ID%
echo ⏰ Cron Jobs: https://console.cloud.google.com/appengine/cronjobs?project=%PROJECT_ID%
echo.
echo 🧪 Test URLs:
echo    Frontend: https://%PROJECT_ID%.appspot.com
echo    API Health: https://%PROJECT_ID%.appspot.com/api/health
echo    Cron Health: https://%PROJECT_ID%.appspot.com/cron/health
echo.
echo 💰 Estimated monthly cost: $30-70
echo 📊 BigQuery sync: Daily at 2 AM UTC
echo.
echo Happy coding! 🚀
cd ..
pause