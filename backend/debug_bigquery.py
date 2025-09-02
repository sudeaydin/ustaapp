#!/usr/bin/env python3
"""
BigQuery Debug Script
Detaylı debug bilgisi verir
"""

import os
import sys
from datetime import datetime

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Load environment variables
from dotenv import load_dotenv
load_dotenv()

print("🔍 BigQuery Debug Information")
print("=" * 50)

# Check environment variables
print("📋 Environment Variables:")
print(f"   BIGQUERY_LOGGING_ENABLED: {os.environ.get('BIGQUERY_LOGGING_ENABLED', 'NOT SET')}")
print(f"   BIGQUERY_PROJECT_ID: {os.environ.get('BIGQUERY_PROJECT_ID', 'NOT SET')}")
print(f"   FLASK_ENV: {os.environ.get('FLASK_ENV', 'NOT SET')}")

# Check .env file
print(f"\n📄 .env File Check:")
if os.path.exists('.env'):
    print("   ✅ .env file exists")
    with open('.env', 'r') as f:
        content = f.read()
        print("   Content:")
        for line in content.split('\n'):
            if line.strip():
                print(f"     {line}")
else:
    print("   ❌ .env file not found")

# Test BigQuery client directly
print(f"\n🔗 Direct BigQuery Client Test:")
try:
    from google.cloud import bigquery
    client = bigquery.Client(project='ustaapp-analytics')
    print("   ✅ BigQuery client created successfully")
    
    # Test dataset access
    dataset_ref = client.dataset('ustam_analytics')
    dataset = client.get_dataset(dataset_ref)
    print(f"   ✅ Dataset accessed: {dataset.dataset_id}")
    
    # List tables
    tables = list(client.list_tables(dataset_ref))
    print(f"   📊 Tables found: {len(tables)}")
    for table in tables:
        print(f"     - {table.table_id}")
    
    # Test direct insert
    print(f"\n📤 Testing Direct Insert:")
    table_ref = client.dataset('ustam_analytics').table('user_activity_logs')
    
    test_row = {
        "log_id": f"debug_test_{int(datetime.now().timestamp())}",
        "user_id": 9999,
        "session_id": "debug_session",
        "action_type": "debug_test",
        "action_category": "testing",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "success": True,
        "platform": "debug"
    }
    
    errors = client.insert_rows_json(table_ref, [test_row])
    
    if errors:
        print(f"   ❌ Insert errors: {errors}")
    else:
        print(f"   ✅ Direct insert successful!")
        print(f"   📊 Check BigQuery console in 1-2 minutes")
    
except Exception as e:
    print(f"   ❌ Direct client test failed: {e}")

# Test Flask app BigQuery logger
print(f"\n🌐 Flask App BigQuery Logger Test:")
try:
    from app import create_app
    app = create_app()
    
    with app.app_context():
        from app.utils.bigquery_logger import bigquery_logger
        
        print(f"   Project ID: {bigquery_logger.project_id}")
        print(f"   Dataset ID: {bigquery_logger.dataset_id}")
        print(f"   Enabled: {bigquery_logger.enabled}")
        print(f"   Client: {bigquery_logger.client is not None}")
        
        if bigquery_logger.enabled and bigquery_logger.client:
            print("   ✅ Flask BigQuery logger is working")
        else:
            print("   ❌ Flask BigQuery logger has issues")
            
except Exception as e:
    print(f"   ❌ Flask app test failed: {e}")

print(f"\n🎯 Summary:")
print(f"   Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print(f"   Working Directory: {os.getcwd()}")
print(f"   Python Path: {sys.executable}")