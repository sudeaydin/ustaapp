#!/usr/bin/env python3
"""
Production Readiness Test for ustam App
Tests all critical components before deployment
"""

import os
import sys
import requests
import json
import time
from pathlib import Path

class ProductionReadinessTest:
    """Test suite for production readiness"""
    
    def __init__(self, base_url="http://localhost:5000"):
        self.base_url = base_url.rstrip('/')
        self.test_results = []
        self.passed = 0
        self.failed = 0
    
    def log_test(self, test_name: str, success: bool, message: str = ""):
        """Log test result"""
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name}")
        if message:
            print(f"    {message}")
        
        self.test_results.append({
            'test': test_name,
            'success': success,
            'message': message
        })
        
        if success:
            self.passed += 1
        else:
            self.failed += 1
    
    def test_backend_health(self):
        """Test backend health endpoint"""
        try:
            response = requests.get(f"{self.base_url}/api/health", timeout=10)
            success = response.status_code == 200
            message = f"Status: {response.status_code}"
            if success:
                data = response.json()
                message += f" - Service: {data.get('service', 'unknown')}"
        except Exception as e:
            success = False
            message = f"Connection failed: {e}"
        
        self.log_test("Backend Health Check", success, message)
        return success
    
    def test_analytics_health(self):
        """Test analytics service health"""
        try:
            response = requests.get(f"{self.base_url}/api/analytics/v2/health", timeout=10)
            success = response.status_code == 200
            message = f"Status: {response.status_code}"
            if success:
                data = response.json()
                message += f" - BigQuery: {'Connected' if data.get('bigquery_connected') else 'Disconnected'}"
        except Exception as e:
            success = False
            message = f"Analytics service failed: {e}"
        
        self.log_test("Analytics Service Health", success, message)
        return success
    
    def test_auth_endpoints(self):
        """Test authentication endpoints"""
        # Test registration
        try:
            test_user = {
                "email": f"test_{int(time.time())}@example.com",
                "password": "testpass123",
                "first_name": "Test",
                "last_name": "User",
                "phone": "05551234567",
                "user_type": "customer"
            }
            
            response = requests.post(f"{self.base_url}/api/auth/register", 
                                   json=test_user, timeout=10)
            success = response.status_code in [200, 201]
            message = f"Registration status: {response.status_code}"
            
        except Exception as e:
            success = False
            message = f"Auth test failed: {e}"
        
        self.log_test("Authentication Endpoints", success, message)
        return success
    
    def test_craftsmen_endpoint(self):
        """Test craftsmen listing endpoint"""
        try:
            response = requests.get(f"{self.base_url}/api/craftsmen", timeout=10)
            success = response.status_code == 200
            message = f"Status: {response.status_code}"
            
            if success:
                data = response.json()
                craftsmen_count = len(data.get('data', {}).get('craftsmen', []))
                message += f" - Found {craftsmen_count} craftsmen"
                
        except Exception as e:
            success = False
            message = f"Craftsmen endpoint failed: {e}"
        
        self.log_test("Craftsmen Listing", success, message)
        return success
    
    def test_database_connection(self):
        """Test database connectivity"""
        try:
            # Import here to avoid issues if backend not available
            sys.path.insert(0, 'backend')
            from app import create_app, db
            
            app = create_app()
            with app.app_context():
                # Try a simple query
                from app.models.user import User
                user_count = User.query.count()
                success = True
                message = f"Database connected - {user_count} users found"
                
        except Exception as e:
            success = False
            message = f"Database connection failed: {e}"
        
        self.log_test("Database Connection", success, message)
        return success
    
    def test_bigquery_connection(self):
        """Test BigQuery connection"""
        try:
            sys.path.insert(0, 'backend')
            from app.utils.bigquery_logger import bigquery_logger
            
            success = bigquery_logger.client is not None
            message = "BigQuery client initialized" if success else "BigQuery client not available"
            
        except Exception as e:
            success = False
            message = f"BigQuery test failed: {e}"
        
        self.log_test("BigQuery Connection", success, message)
        return success
    
    def test_file_structure(self):
        """Test required files exist"""
        required_files = [
            "backend/main.py",
            "backend/app/__init__.py", 
            "backend/requirements.txt",
            "backend/app.yaml",
            "backend/.env.example",
            "ustam_mobile_app/pubspec.yaml",
            "PRODUCTION_DEPLOYMENT_CHECKLIST.md"
        ]
        
        missing_files = []
        for file_path in required_files:
            if not Path(file_path).exists():
                missing_files.append(file_path)
        
        success = len(missing_files) == 0
        message = f"All required files present" if success else f"Missing: {', '.join(missing_files)}"
        
        self.log_test("File Structure", success, message)
        return success
    
    def test_environment_config(self):
        """Test environment configuration"""
        try:
            env_files = [".env.production", ".env.development", ".env.example"]
            backend_path = Path("backend")
            
            existing_env_files = []
            for env_file in env_files:
                if (backend_path / env_file).exists():
                    existing_env_files.append(env_file)
            
            success = len(existing_env_files) >= 2  # At least 2 env files should exist
            message = f"Environment files: {', '.join(existing_env_files)}"
            
        except Exception as e:
            success = False
            message = f"Environment config test failed: {e}"
        
        self.log_test("Environment Configuration", success, message)
        return success
    
    def test_mobile_app_structure(self):
        """Test mobile app structure"""
        try:
            flutter_path = Path("ustam_mobile_app")
            required_flutter_files = [
                "pubspec.yaml",
                "lib/main.dart",
                "android/app/build.gradle",
            ]
            
            missing_flutter_files = []
            for file_path in required_flutter_files:
                if not (flutter_path / file_path).exists():
                    missing_flutter_files.append(file_path)
            
            success = len(missing_flutter_files) == 0
            message = "Flutter app structure complete" if success else f"Missing: {', '.join(missing_flutter_files)}"
            
        except Exception as e:
            success = False
            message = f"Mobile app test failed: {e}"
        
        self.log_test("Mobile App Structure", success, message)
        return success
    
    def run_all_tests(self):
        """Run all production readiness tests"""
        print("🧪 ustam - PRODUCTION READINESS TEST")
        print("=" * 50)
        print()
        
        # File structure tests (don't require running server)
        self.test_file_structure()
        self.test_environment_config()
        self.test_mobile_app_structure()
        
        # Database tests
        self.test_database_connection()
        self.test_bigquery_connection()
        
        # API tests (require running server)
        print("\n📡 Testing API endpoints...")
        print("Note: Make sure backend server is running (python backend/run.py)")
        
        self.test_backend_health()
        self.test_analytics_health()
        self.test_auth_endpoints()
        self.test_craftsmen_endpoint()
        
        # Summary
        print("\n" + "=" * 50)
        print("📊 TEST SUMMARY")
        print("=" * 50)
        print(f"✅ Passed: {self.passed}")
        print(f"❌ Failed: {self.failed}")
        print(f"📈 Success Rate: {(self.passed / (self.passed + self.failed) * 100):.1f}%")
        
        if self.failed == 0:
            print("\n🎉 ALL TESTS PASSED! Ready for production deployment.")
            return True
        else:
            print(f"\n⚠️  {self.failed} tests failed. Please fix issues before deployment.")
            print("\nFailed tests:")
            for result in self.test_results:
                if not result['success']:
                    print(f"  - {result['test']}: {result['message']}")
            return False

def main():
    """Main function"""
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:5000"
    
    tester = ProductionReadinessTest(base_url)
    success = tester.run_all_tests()
    
    print("\n🔗 Next Steps:")
    if success:
        print("1. Run deployment: ./deploy_production_quick.sh YOUR_PROJECT_ID")
        print("2. Update mobile app URLs: python update_mobile_urls_production.py YOUR_PROJECT_ID")
        print("3. Test production deployment")
        print("4. Monitor analytics dashboard")
    else:
        print("1. Fix failing tests")
        print("2. Re-run test: python test_production_ready.py")
        print("3. Check logs for detailed error messages")
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()