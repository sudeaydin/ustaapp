@echo off
echo 🧠 Smart Database Setup - BigQuery First Approach
echo ================================================

echo 📋 Checking data sources...

REM Try BigQuery first
echo 🔍 Checking BigQuery for existing data...
python sync_from_bigquery.py

if errorlevel 1 (
    echo ⚠️ BigQuery sync failed, using local sample data...
    python create_db_with_data.py
) else (
    echo ✅ Data synced from BigQuery successfully!
)

echo.
echo 🎯 Database setup strategy:
echo    1. First: Try to sync from BigQuery (production data)
echo    2. Fallback: Create sample data locally
echo.
echo ✅ Smart setup completed!
echo.
pause