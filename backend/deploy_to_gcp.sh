#!/bin/bash

# Google Cloud Platform Deployment Script for ustam App
set -e

echo "🚀 Deploying ustam App to Google Cloud Platform"
echo "=================================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Please install Google Cloud SDK"
    exit 1
fi

# Set project
PROJECT_ID=${1:-ustaapp-analytics}
echo "📊 Using project: $PROJECT_ID"

gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required Google Cloud APIs..."
gcloud services enable appengine.googleapis.com
gcloud services enable cloudsql.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable secretmanager.googleapis.com

# Create App Engine app (if not exists)
echo "🏗️ Setting up App Engine..."
if ! gcloud app describe &> /dev/null; then
    gcloud app create --region=us-central
fi

# Create Cloud SQL instance (if not exists)
echo "🗄️ Setting up Cloud SQL PostgreSQL..."
INSTANCE_NAME="ustam-db"
if ! gcloud sql instances describe $INSTANCE_NAME &> /dev/null; then
    echo "Creating Cloud SQL instance..."
    gcloud sql instances create $INSTANCE_NAME \
        --database-version=POSTGRES_13 \
        --tier=db-f1-micro \
        --region=us-central1 \
        --storage-type=SSD \
        --storage-size=10GB \
        --backup-start-time=02:00
    
    # Create database
    gcloud sql databases create ustam --instance=$INSTANCE_NAME
    
    # Create user
    echo "Enter password for database user 'ustam_user':"
    gcloud sql users create ustam_user --instance=$INSTANCE_NAME --password
else
    echo "✅ Cloud SQL instance already exists"
fi

# Create secrets in Secret Manager
echo "🔐 Setting up secrets..."
echo -n "$(openssl rand -base64 32)" | gcloud secrets create flask-secret-key --data-file=-
echo -n "$(openssl rand -base64 32)" | gcloud secrets create jwt-secret-key --data-file=-

# Grant App Engine access to secrets
APP_ENGINE_SA="$PROJECT_ID@appspot.gserviceaccount.com"
gcloud secrets add-iam-policy-binding flask-secret-key \
    --member="serviceAccount:$APP_ENGINE_SA" \
    --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding jwt-secret-key \
    --member="serviceAccount:$APP_ENGINE_SA" \
    --role="roles/secretmanager.secretAccessor"

# Grant BigQuery permissions to App Engine
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$APP_ENGINE_SA" \
    --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$APP_ENGINE_SA" \
    --role="roles/bigquery.jobUser"

# Setup BigQuery dataset and tables
echo "📊 Setting up BigQuery..."
python3 bigquery_comprehensive_setup.py $PROJECT_ID

# Deploy to App Engine
echo "🚀 Deploying to App Engine..."
gcloud app deploy app.yaml --quiet

# Create Cloud Scheduler job for daily sync
echo "⏰ Setting up Cloud Scheduler..."
if ! gcloud scheduler jobs describe bigquery-daily-sync --location=us-central1 &> /dev/null; then
    gcloud scheduler jobs create http bigquery-daily-sync \
        --location=us-central1 \
        --schedule="0 2 * * *" \
        --uri="https://$PROJECT_ID.appspot.com/cron/bigquery-sync" \
        --http-method=POST \
        --headers="X-Appengine-Cron=true" \
        --description="Daily BigQuery sync for ustam app"
else
    echo "✅ Cloud Scheduler job already exists"
fi

# Get the deployed URL
APP_URL="https://$PROJECT_ID.appspot.com"

echo ""
echo "🎉 Deployment Complete!"
echo "=================================================="
echo "📱 App URL: $APP_URL"
echo "📊 BigQuery: https://console.cloud.google.com/bigquery?project=$PROJECT_ID"
echo "🗄️ Cloud SQL: https://console.cloud.google.com/sql/instances?project=$PROJECT_ID"
echo "⏰ Scheduler: https://console.cloud.google.com/cloudscheduler?project=$PROJECT_ID"
echo ""
echo "🧪 Test your deployment:"
echo "   curl $APP_URL/api/health"
echo ""
echo "📊 BigQuery data will sync daily at 2 AM UTC"
echo "💰 Estimated monthly cost: \$30-70"
echo ""
echo "Happy coding! 🚀"