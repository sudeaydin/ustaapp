#!/bin/bash

echo ""
echo "========================================"
echo "  ustam - COMPLETE ANALYTICS SETUP"
echo "========================================"
echo ""

# Check if project ID is provided
if [ -z "$1" ]; then
    echo "Error: Project ID required"
    echo "Usage: ./setup_complete_analytics.sh YOUR_PROJECT_ID [environment]"
    echo ""
    echo "Examples:"
    echo "  ./setup_complete_analytics.sh ustam-production"
    echo "  ./setup_complete_analytics.sh ustam-staging staging"
    echo "  ./setup_complete_analytics.sh ustam-dev development"
    echo ""
    exit 1
fi

PROJECT_ID=$1
ENVIRONMENT=${2:-production}

echo "Project ID: $PROJECT_ID"
echo "Environment: $ENVIRONMENT"
echo ""

# Change to backend directory
cd backend

echo "[1/5] Installing Python dependencies..."
pip install google-cloud-bigquery google-api-core streamlit plotly pandas

echo ""
echo "[2/5] Setting up BigQuery infrastructure..."
python production_analytics_setup.py $PROJECT_ID --environment $ENVIRONMENT

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Analytics setup failed!"
    exit 1
fi

echo ""
echo "[3/5] Creating environment configuration..."
cat > .env.$ENVIRONMENT << EOF
BIGQUERY_PROJECT_ID=$PROJECT_ID
BIGQUERY_DATASET_ID=ustam_analytics
BIGQUERY_LOGGING_ENABLED=true
ANALYTICS_ENVIRONMENT=$ENVIRONMENT
EOF

echo ""
echo "[4/5] Testing BigQuery connection..."
python -c "from app.utils.bigquery_logger import bigquery_logger; print('BigQuery connection:', 'OK' if bigquery_logger.client else 'FAILED')"

echo ""
echo "[5/5] Starting analytics dashboard..."
echo ""
echo "========================================"
echo "  SETUP COMPLETE!"
echo "========================================"
echo ""
echo "Project: $PROJECT_ID"
echo "Environment: $ENVIRONMENT"
echo "Dashboard: Starting Streamlit..."
echo ""
echo "Next steps:"
echo "1. Dashboard will open in your browser"
echo "2. Deploy your app with the new environment variables"
echo "3. Monitor real-time analytics data"
echo ""

# Start Streamlit dashboard
streamlit run enhanced_analytics_dashboard.py