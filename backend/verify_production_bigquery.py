#!/usr/bin/env python3
"""
Production BigQuery Verification Script
Verifies all BigQuery components are working in production
"""

import os
import sys
import json
import requests
from datetime import datetime
from google.cloud import bigquery
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_bigquery_connection():
    """Test BigQuery connection and dataset access"""
    try:
        print("🔍 Testing BigQuery connection...")
        
        # Initialize BigQuery client
        project_id = 'ustaapp-analytics'
        client = bigquery.Client(project=project_id)
        
        # Test dataset access
        dataset_id = 'ustam_analytics'
        dataset = client.dataset(dataset_id)
        
        # List tables
        tables = list(client.list_tables(dataset))
        print(f"✅ Connected to BigQuery - Found {len(tables)} tables")
        
        # Print table names
        for table in tables:
            print(f"   📊 {table.table_id}")
        
        return True, len(tables)
        
    except Exception as e:
        print(f"❌ BigQuery connection failed: {e}")
        return False, 0

def test_production_api():
    """Test production API endpoints"""
    try:
        print("\n🌐 Testing production API...")
        
        base_url = "https://ustaapp-analytics.uc.r.appspot.com"
        
        # Test health endpoint
        response = requests.get(f"{base_url}/api/health", timeout=10)
        if response.status_code == 200:
            print("✅ Health check passed")
            health_data = response.json()
            print(f"   Service: {health_data.get('service')}")
            print(f"   Environment: {health_data.get('environment')}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
        
        # Test legal documents
        response = requests.get(f"{base_url}/api/legal/documents/privacy-policy", timeout=10)
        if response.status_code == 200:
            print("✅ Legal documents accessible")
        else:
            print(f"❌ Legal documents failed: {response.status_code}")
        
        # Test registration (this will create BigQuery logs)
        test_user = {
            "email": f"test-{datetime.now().strftime('%Y%m%d-%H%M%S')}@example.com",
            "password": "test123456",
            "first_name": "Test",
            "last_name": "User",
            "phone": "5551234567",
            "user_type": "customer"
        }
        
        response = requests.post(f"{base_url}/api/auth/register", 
                               json=test_user, 
                               headers={'Content-Type': 'application/json'},
                               timeout=10)
        
        if response.status_code == 201:
            print("✅ Registration test passed")
            reg_data = response.json()
            if reg_data.get('success'):
                print("   User created successfully")
                return True
        else:
            print(f"⚠️ Registration test: {response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"❌ API test failed: {e}")
        return False

def verify_bigquery_logging():
    """Verify that BigQuery logging is working"""
    try:
        print("\n📊 Verifying BigQuery logging...")
        
        project_id = 'ustaapp-analytics'
        client = bigquery.Client(project=project_id)
        
        # Check user_activity_logs table for recent entries
        query = """
        SELECT COUNT(*) as log_count, MAX(timestamp) as latest_log
        FROM `ustaapp-analytics.ustam_analytics.user_activity_logs`
        WHERE DATE(timestamp) = CURRENT_DATE()
        """
        
        query_job = client.query(query)
        results = query_job.result()
        
        for row in results:
            log_count = row.log_count
            latest_log = row.latest_log
            
            print(f"📈 Today's activity logs: {log_count}")
            if latest_log:
                print(f"📅 Latest log: {latest_log}")
            
            if log_count > 0:
                print("✅ BigQuery logging is active")
                return True
            else:
                print("⚠️ No activity logs found today")
                return False
        
    except Exception as e:
        print(f"❌ BigQuery logging verification failed: {e}")
        return False

def run_performance_test():
    """Run basic performance tests"""
    try:
        print("\n⚡ Running performance tests...")
        
        base_url = "https://ustaapp-analytics.uc.r.appspot.com"
        
        # Test multiple requests
        total_time = 0
        successful_requests = 0
        
        for i in range(5):
            start_time = datetime.now()
            response = requests.get(f"{base_url}/api/health", timeout=10)
            end_time = datetime.now()
            
            response_time = (end_time - start_time).total_seconds()
            total_time += response_time
            
            if response.status_code == 200:
                successful_requests += 1
                print(f"   Request {i+1}: {response_time:.3f}s")
            else:
                print(f"   Request {i+1}: FAILED ({response.status_code})")
        
        avg_time = total_time / 5
        success_rate = (successful_requests / 5) * 100
        
        print(f"📊 Performance Summary:")
        print(f"   Average response time: {avg_time:.3f}s")
        print(f"   Success rate: {success_rate:.1f}%")
        
        if avg_time < 1.0 and success_rate >= 80:
            print("✅ Performance test passed")
            return True
        else:
            print("⚠️ Performance test concerns")
            return False
        
    except Exception as e:
        print(f"❌ Performance test failed: {e}")
        return False

def main():
    """Main verification function"""
    print("🚀 USTAM APP - Production BigQuery Verification")
    print("=" * 50)
    print(f"⏰ Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Run all tests
    tests_passed = 0
    total_tests = 4
    
    # Test 1: BigQuery Connection
    success, table_count = test_bigquery_connection()
    if success:
        tests_passed += 1
    
    # Test 2: Production API
    if test_production_api():
        tests_passed += 1
    
    # Test 3: BigQuery Logging
    if verify_bigquery_logging():
        tests_passed += 1
    
    # Test 4: Performance
    if run_performance_test():
        tests_passed += 1
    
    # Final Summary
    print("\n" + "=" * 50)
    print("📋 VERIFICATION SUMMARY")
    print("=" * 50)
    print(f"✅ Tests passed: {tests_passed}/{total_tests}")
    print(f"📊 BigQuery tables: {table_count if 'table_count' in locals() else 'Unknown'}")
    print(f"🌐 Production URL: https://ustaapp-analytics.uc.r.appspot.com")
    print(f"📈 BigQuery Console: https://console.cloud.google.com/bigquery?project=ustaapp-analytics")
    
    if tests_passed == total_tests:
        print("\n🎉 All systems operational!")
        return 0
    elif tests_passed >= 2:
        print("\n⚠️ Some issues detected, but core systems working")
        return 1
    else:
        print("\n❌ Critical issues detected")
        return 2

if __name__ == "__main__":
    sys.exit(main())