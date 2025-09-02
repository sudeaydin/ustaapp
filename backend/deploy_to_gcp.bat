@echo off
echo 🚀 Deploying ustam App to Google Cloud Platform
echo ==================================================

REM Check if gcloud is installed
gcloud version >nul 2>&1
if errorlevel 1 (
    echo ❌ gcloud CLI not found. Please install Google Cloud SDK
    pause
    exit /b 1
)

REM Set project
set PROJECT_ID=%1
if "%PROJECT_ID%"=="" set PROJECT_ID=ustaapp-analytics
echo 📊 Using project: %PROJECT_ID%

gcloud config set project %PROJECT_ID%

REM Enable required APIs
echo 🔧 Enabling required Google Cloud APIs...
gcloud services enable appengine.googleapis.com
gcloud services enable cloudsql.googleapis.com  
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable secretmanager.googleapis.com

REM Create App Engine app (if not exists)
echo 🏗️ Setting up App Engine...
gcloud app describe >nul 2>&1
if errorlevel 1 (
    echo Creating App Engine app...
    gcloud app create --region=us-central
) else (
    echo ✅ App Engine app already exists
)

REM Create Cloud SQL instance (if not exists)
echo 🗄️ Setting up Cloud SQL PostgreSQL...
set INSTANCE_NAME=ustam-db
gcloud sql instances describe %INSTANCE_NAME% >nul 2>&1
if errorlevel 1 (
    echo Creating Cloud SQL instance...
    gcloud sql instances create %INSTANCE_NAME% ^
        --database-version=POSTGRES_13 ^
        --tier=db-f1-micro ^
        --region=us-central1 ^
        --storage-type=SSD ^
        --storage-size=10GB ^
        --backup-start-time=02:00
    
    REM Create database
    gcloud sql databases create ustam --instance=%INSTANCE_NAME%
    
    REM Create user
    echo Enter password for database user 'ustam_user':
    gcloud sql users create ustam_user --instance=%INSTANCE_NAME% --password
) else (
    echo ✅ Cloud SQL instance already exists
)

REM Setup BigQuery
echo 📊 Setting up BigQuery...
python bigquery_comprehensive_setup.py %PROJECT_ID%

REM Deploy to App Engine
echo 🚀 Deploying to App Engine...
gcloud app deploy app.yaml --quiet

REM Create Cloud Scheduler job
echo ⏰ Setting up Cloud Scheduler...
gcloud scheduler jobs describe bigquery-daily-sync --location=us-central1 >nul 2>&1
if errorlevel 1 (
    gcloud scheduler jobs create http bigquery-daily-sync ^
        --location=us-central1 ^
        --schedule="0 2 * * *" ^
        --uri="https://%PROJECT_ID%.appspot.com/cron/bigquery-sync" ^
        --http-method=POST ^
        --headers="X-Appengine-Cron=true" ^
        --description="Daily BigQuery sync for ustam app"
) else (
    echo ✅ Cloud Scheduler job already exists
)

REM Success message
set APP_URL=https://%PROJECT_ID%.appspot.com

echo.
echo 🎉 Deployment Complete!
echo ==================================================
echo 📱 App URL: %APP_URL%
echo 📊 BigQuery: https://console.cloud.google.com/bigquery?project=%PROJECT_ID%
echo 🗄️ Cloud SQL: https://console.cloud.google.com/sql/instances?project=%PROJECT_ID%
echo ⏰ Scheduler: https://console.cloud.google.com/cloudscheduler?project=%PROJECT_ID%
echo.
echo 🧪 Test your deployment:
echo    curl %APP_URL%/api/health
echo.
echo 📊 BigQuery data will sync daily at 2 AM UTC
echo 💰 Estimated monthly cost: $30-70
echo.
echo Happy coding! 🚀
echo.
pause