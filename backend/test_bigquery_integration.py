#!/usr/bin/env python3
"""
BigQuery Integration Test Script
Tests if BigQuery logging is working correctly
"""

import os
import sys
import time
from datetime import datetime

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.utils.bigquery_logger import bigquery_logger, log_user_login, log_search, log_api_error

def test_bigquery_connection():
    """Test BigQuery connection"""
    print("🔍 Testing BigQuery Connection...")
    
    if not bigquery_logger.enabled:
        print("❌ BigQuery logging is disabled")
        print("   Set BIGQUERY_LOGGING_ENABLED=true in .env file")
        return False
    
    if not bigquery_logger.client:
        print("❌ BigQuery client not initialized")
        print("   Check your authentication and project settings")
        return False
    
    print(f"✅ BigQuery connection OK")
    print(f"   Project: {bigquery_logger.project_id}")
    print(f"   Dataset: {bigquery_logger.dataset_id}")
    return True

def test_manual_logging():
    """Test manual logging functions"""
    print("\n📝 Testing Manual Logging...")
    
    try:
        # Test user login log
        print("   Testing user login log...")
        log_user_login(user_id=999, success=True)
        
        # Test search log
        print("   Testing search log...")
        log_search(
            user_id=999,
            search_query="elektrikçi istanbul",
            search_type="craftsman",
            results_count=15,
            response_time_ms=250,
            filters={"city": "istanbul", "category": "electrical"}
        )
        
        # Test error log
        print("   Testing error log...")
        log_api_error(
            error_type="TEST_ERROR",
            error_message="This is a test error for BigQuery integration",
            endpoint="/api/test",
            user_id=999
        )
        
        print("✅ Manual logging tests completed")
        print("   Data queued for BigQuery (will be sent in batches)")
        return True
        
    except Exception as e:
        print(f"❌ Manual logging failed: {e}")
        return False

def test_bigquery_tables():
    """Test if required BigQuery tables exist"""
    print("\n📊 Testing BigQuery Tables...")
    
    try:
        client = bigquery_logger.client
        dataset_ref = client.dataset(bigquery_logger.dataset_id)
        
        # Check if dataset exists
        try:
            dataset = client.get_dataset(dataset_ref)
            print(f"✅ Dataset exists: {dataset.dataset_id}")
        except Exception as e:
            print(f"❌ Dataset not found: {e}")
            print("   Run: python bigquery_comprehensive_setup.py ustaapp-analytics")
            return False
        
        # Check required tables
        required_tables = [
            'user_activity_logs',
            'error_logs', 
            'search_analytics',
            'users',
            'jobs'
        ]
        
        existing_tables = []
        for table in client.list_tables(dataset_ref):
            existing_tables.append(table.table_id)
        
        print(f"   Existing tables: {len(existing_tables)}")
        for table_name in required_tables:
            if table_name in existing_tables:
                print(f"   ✅ {table_name}")
            else:
                print(f"   ❌ {table_name} (missing)")
        
        return len([t for t in required_tables if t in existing_tables]) > 0
        
    except Exception as e:
        print(f"❌ Table check failed: {e}")
        return False

def simulate_user_session():
    """Simulate a user session with multiple activities"""
    print("\n🎭 Simulating User Session...")
    
    user_id = 1001
    session_activities = [
        ("register", "auth", {"user_type": "customer"}),
        ("search", "engagement", {"query": "elektrikçi", "results": 12}),
        ("profile_view", "engagement", {"craftsman_id": 5}),
        ("contact", "conversion", {"craftsman_id": 5}),
        ("payment", "conversion", {"amount": 250.0})
    ]
    
    try:
        for i, (action, category, details) in enumerate(session_activities, 1):
            print(f"   Step {i}: {action}")
            
            bigquery_logger.log_user_activity(
                action_type=action,
                action_category=category,
                user_id=user_id,
                success=True,
                duration_ms=100 + i * 50,
                action_details=details
            )
            
            time.sleep(0.5)  # Simulate time between actions
        
        print("✅ User session simulation completed")
        return True
        
    except Exception as e:
        print(f"❌ Session simulation failed: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 BigQuery Integration Test")
    print("=" * 50)
    
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv()
    
    # Run tests
    tests = [
        ("BigQuery Connection", test_bigquery_connection),
        ("BigQuery Tables", test_bigquery_tables),
        ("Manual Logging", test_manual_logging),
        ("User Session Simulation", simulate_user_session)
    ]
    
    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} failed with exception: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n📊 Test Results:")
    print("=" * 50)
    passed = 0
    for test_name, result in results:
        status = "✅ PASSED" if result else "❌ FAILED"
        print(f"{test_name:<25} {status}")
        if result:
            passed += 1
    
    print(f"\nTotal: {passed}/{len(results)} tests passed")
    
    if passed == len(results):
        print("\n🎉 All tests passed! BigQuery integration is working.")
        print("\n🔗 Next Steps:")
        print("1. Check BigQuery console: https://console.cloud.google.com/bigquery?project=ustaapp-analytics")
        print("2. Wait 1-2 minutes for data to appear (streaming delay)")
        print("3. Run sample queries to verify data")
    else:
        print("\n⚠️  Some tests failed. Check the errors above.")
        print("\n🔧 Troubleshooting:")
        print("1. Ensure BigQuery tables are created: python bigquery_comprehensive_setup.py ustaapp-analytics")
        print("2. Check authentication: gcloud auth application-default login")
        print("3. Verify project permissions in Google Cloud Console")
    
    return passed == len(results)

if __name__ == '__main__':
    main()