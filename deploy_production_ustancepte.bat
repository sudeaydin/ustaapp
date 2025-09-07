@echo off
echo 🚀 Ustam App - Production Deployment to Google Cloud
echo =====================================================
echo 📊 Project: ustaapp-analytics
echo 🌐 Domain: ustancepte.com
echo ⏰ Started: %date% %time%
echo =====================================================

REM Set project
echo 📊 Setting Google Cloud project...
gcloud config set project ustaapp-analytics

REM Enable required APIs
echo 🔧 Enabling Google Cloud APIs...
gcloud services enable appengine.googleapis.com
gcloud services enable cloudsql.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable secretmanager.googleapis.com

REM Check if App Engine app exists
echo 🏗️ Checking App Engine status...
gcloud app describe >nul 2>&1
if errorlevel 1 (
    echo Creating App Engine application...
    gcloud app create --region=us-central
) else (
    echo ✅ App Engine app already exists
)

REM Setup BigQuery dataset and tables
echo 📊 Setting up BigQuery analytics...
cd backend
python bigquery_comprehensive_setup.py ustaapp-analytics
if errorlevel 1 (
    echo ⚠️ BigQuery setup had some issues, continuing...
)

REM Create production environment file
echo 🔧 Creating production environment...
echo # Production Environment > .env.production
echo FLASK_ENV=production >> .env.production
echo BIGQUERY_LOGGING_ENABLED=true >> .env.production
echo BIGQUERY_PROJECT_ID=ustaapp-analytics >> .env.production
echo SECRET_KEY=%RANDOM%-%RANDOM%-%RANDOM% >> .env.production
echo JWT_SECRET_KEY=%RANDOM%-%RANDOM%-%RANDOM% >> .env.production

REM Update app.yaml with production settings
echo 🔧 Configuring App Engine...
(
echo runtime: python39
echo 
echo env_variables:
echo   FLASK_ENV: production
echo   BIGQUERY_LOGGING_ENABLED: true
echo   BIGQUERY_PROJECT_ID: ustaapp-analytics
echo 
echo automatic_scaling:
echo   min_instances: 1
echo   max_instances: 5
echo   target_cpu_utilization: 0.6
echo 
echo resources:
echo   cpu: 1
echo   memory_gb: 1
echo 
echo handlers:
echo - url: /.*
echo   script: auto
echo   secure: always
) > app.yaml

REM Deploy backend to App Engine
echo 🚀 Deploying backend to App Engine...
gcloud app deploy app.yaml --quiet --promote

if errorlevel 1 (
    echo ❌ Backend deployment failed
    pause
    exit /b 1
)

echo ✅ Backend deployed successfully!

REM Get App Engine URL
for /f "tokens=*" %%i in ('gcloud app browse --no-launch-browser') do set BACKEND_URL=%%i

echo 🔧 Backend URL: %BACKEND_URL%

REM Build Flutter web with production backend URL
echo 🌐 Building Flutter web for production...
cd ..\ustam_mobile_app

REM Create web build configuration
echo const config = { > lib\config\web_config.dart
echo   apiBaseUrl: '%BACKEND_URL%', >> lib\config\web_config.dart
echo   environment: 'production', >> lib\config\web_config.dart
echo }; >> lib\config\web_config.dart

REM Build Flutter web
flutter build web --release --base-href="/"

if errorlevel 1 (
    echo ❌ Flutter web build failed
    pause
    exit /b 1
)

echo ✅ Flutter web built successfully!

REM Create web app.yaml for static hosting
echo 🌐 Configuring web hosting...
(
echo runtime: python39
echo 
echo handlers:
echo - url: /
echo   static_files: build/web/index.html
echo   upload: build/web/index.html
echo   secure: always
echo 
echo - url: /(.*)
echo   static_files: build/web/\1
echo   upload: build/web/(.*)
echo   secure: always
echo 
echo - url: /.*
echo   static_files: build/web/index.html
echo   upload: build/web/index.html
echo   secure: always
) > web-app.yaml

REM Deploy web frontend
echo 🚀 Deploying web frontend...
gcloud app deploy web-app.yaml --quiet --version=web

if errorlevel 1 (
    echo ❌ Web deployment failed
    pause
    exit /b 1
)

echo ✅ Web deployed successfully!

REM Setup custom domain
echo 🌐 Setting up custom domain: ustancepte.com
gcloud app domain-mappings create ustancepte.com --certificate-management=automatic

echo 📊 Setting up www subdomain...
gcloud app domain-mappings create www.ustancepte.com --certificate-management=automatic

REM Create cron jobs for BigQuery sync
echo ⏰ Setting up scheduled BigQuery sync...
cd ..\backend
(
echo cron:
echo - description: "Daily BigQuery data sync"
echo   url: /cron/bigquery-sync
echo   schedule: every day 02:00
echo   timezone: Europe/Istanbul
) > cron.yaml

gcloud app deploy cron.yaml --quiet

echo.
echo 🎉 DEPLOYMENT COMPLETE!
echo =====================================================
echo 📱 Main Site: https://ustancepte.com
echo 📱 WWW Site: https://www.ustancepte.com
echo 🔧 Backend API: %BACKEND_URL%/api
echo 📊 BigQuery: https://console.cloud.google.com/bigquery?project=ustaapp-analytics
echo.
echo 🧪 Test URLs:
echo    Frontend: https://ustancepte.com
echo    API Health: %BACKEND_URL%/api/health
echo    Legal Docs: %BACKEND_URL%/api/legal/documents/all
echo.
echo 📊 BigQuery sync: Daily at 2 AM (Istanbul time)
echo 💰 Estimated cost: $0-20/month (mostly free tier)
echo.
echo 🔧 Next Steps:
echo 1. Test the website: https://ustancepte.com
echo 2. Check API: %BACKEND_URL%/api/health
echo 3. Verify BigQuery data sync
echo 4. Update mobile app API URLs
echo.
echo Happy coding! 🚀
cd ..
pause