#!/usr/bin/env python3
"""
Fixed Automatic BigQuery Upload Script for Windows PATH issues
"""

import os
import sys
import json
import subprocess
import glob
from datetime import datetime
import logging

# Add the backend directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from bigquery_integration import UstamBigQueryExporter

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FixedAutoBigQueryUploader:
    """Fixed BigQuery uploader that handles Windows PATH issues"""
    
    def __init__(self):
        self.project_id = "ustam-analytics"
        self.dataset_id = "ustam_analytics"
        self.location = "US"
        
        # Find gcloud and bq executables
        self.gcloud_path = self.find_gcloud()
        self.bq_path = self.find_bq()
        
        # Table mappings
        self.tables = {
            'users': {'file_pattern': 'users_*.json', 'schema_file': 'schemas/users_schema.json'},
            'categories': {'file_pattern': 'categories_*.json', 'schema_file': 'schemas/categories_schema.json'},
            'customers': {'file_pattern': 'customers_*.json', 'schema_file': 'schemas/customers_schema.json'},
            'craftsmen': {'file_pattern': 'craftsmen_*.json', 'schema_file': 'schemas/craftsmen_schema.json'},
            'jobs': {'file_pattern': 'jobs_*.json', 'schema_file': 'schemas/jobs_schema.json'}
        }
    
    def find_gcloud(self):
        """Find gcloud executable in common Windows locations"""
        username = os.getenv('USERNAME', 'User')
        possible_paths = [
            f"C:\\Users\\{username}\\AppData\\Local\\Google\\Cloud SDK\\google-cloud-sdk\\bin\\gcloud.cmd",
            "C:\\Program Files\\Google\\Cloud SDK\\google-cloud-sdk\\bin\\gcloud.cmd",
            "C:\\Program Files (x86)\\Google\\Cloud SDK\\google-cloud-sdk\\bin\\gcloud.cmd",
            "C:\\google-cloud-sdk\\bin\\gcloud.cmd",
            "gcloud.cmd",  # Try PATH with .cmd
            "gcloud"       # Try PATH without .cmd
        ]
        
        print("🔍 Searching for gcloud...")
        for path in possible_paths:
            try:
                print(f"   Trying: {path}")
                if path in ["gcloud.cmd", "gcloud"]:
                    result = subprocess.run([path, "--version"], capture_output=True, text=True, check=True, timeout=10)
                else:
                    if os.path.exists(path):
                        result = subprocess.run([path, "--version"], capture_output=True, text=True, check=True, timeout=10)
                    else:
                        print(f"   ❌ Not found at: {path}")
                        continue
                
                print(f"   ✅ Found gcloud at: {path}")
                logger.info(f"✅ Found gcloud at: {path}")
                return path
            except (subprocess.CalledProcessError, FileNotFoundError, OSError, subprocess.TimeoutExpired) as e:
                print(f"   ❌ Failed: {str(e)[:50]}...")
                continue
        
        return None
    
    def find_bq(self):
        """Find bq executable in common Windows locations"""
        username = os.getenv('USERNAME', 'User')
        possible_paths = [
            f"C:\\Users\\{username}\\AppData\\Local\\Google\\Cloud SDK\\google-cloud-sdk\\bin\\bq.cmd",
            "C:\\Program Files\\Google\\Cloud SDK\\google-cloud-sdk\\bin\\bq.cmd",
            "C:\\Program Files (x86)\\Google\\Cloud SDK\\google-cloud-sdk\\bin\\bq.cmd",
            "C:\\google-cloud-sdk\\bin\\bq.cmd",
            "bq.cmd",  # Try PATH with .cmd
            "bq"       # Try PATH without .cmd
        ]
        
        print("🔍 Searching for bq...")
        for path in possible_paths:
            try:
                print(f"   Trying: {path}")
                if path in ["bq.cmd", "bq"]:
                    result = subprocess.run([path, "--version"], capture_output=True, text=True, check=True, timeout=10)
                else:
                    if os.path.exists(path):
                        result = subprocess.run([path, "--version"], capture_output=True, text=True, check=True, timeout=10)
                    else:
                        print(f"   ❌ Not found at: {path}")
                        continue
                
                print(f"   ✅ Found bq at: {path}")
                logger.info(f"✅ Found bq at: {path}")
                return path
            except (subprocess.CalledProcessError, FileNotFoundError, OSError, subprocess.TimeoutExpired) as e:
                print(f"   ❌ Failed: {str(e)[:50]}...")
                continue
        
        return None
    
    def check_prerequisites(self):
        """Check if all prerequisites are met"""
        print("🔍 Checking Google Cloud SDK installation...")
        
        if not self.gcloud_path:
            print("\n❌ Google Cloud SDK not found!")
            print("📥 Please install from: https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe")
            print("⚠️  Make sure to check 'Add gcloud to my PATH' during installation")
            print("🔄 Restart Command Prompt after installation")
            print("\n🔧 Alternative installation methods:")
            print("1. Download ZIP: https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk-456.0.0-windows-x86_64.zip")
            print("2. Extract to C:\\google-cloud-sdk")
            print("3. Run: C:\\google-cloud-sdk\\install.bat")
            return False
        
        if not self.bq_path:
            print("❌ BigQuery CLI (bq) not found!")
            print("   This should be included with Google Cloud SDK")
            return False
        
        print("✅ Google Cloud SDK found!")
        
        # Check authentication
        print("🔑 Checking authentication...")
        try:
            result = subprocess.run([self.gcloud_path, 'auth', 'list'], 
                                  capture_output=True, text=True, check=True, timeout=30)
            if 'ACTIVE' not in result.stdout:
                print("❌ No active Google Cloud authentication found")
                print(f"🔑 Please run: {self.gcloud_path} auth login")
                print(f"🔑 Then run: {self.gcloud_path} config set project your-project-id")
                return False
            else:
                print("✅ Authentication verified!")
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            print("❌ Authentication check failed")
            print(f"🔑 Please run: {self.gcloud_path} auth login")
            print(f"Error: {str(e)[:100]}...")
            return False
        
        logger.info("✅ All prerequisites met")
        return True
    
    def create_dataset(self):
        """Create BigQuery dataset if it doesn't exist"""
        try:
            print(f"📊 Checking if dataset {self.dataset_id} exists...")
            
            # Check if dataset exists
            result = subprocess.run([
                self.bq_path, 'ls', '-d', '--format=value(datasetId)', self.project_id
            ], capture_output=True, text=True, check=True, timeout=30)
            
            if self.dataset_id in result.stdout:
                print(f"✅ Dataset {self.dataset_id} already exists")
                logger.info(f"✅ Dataset {self.dataset_id} already exists")
                return True
            
            # Create dataset
            print(f"📊 Creating dataset {self.dataset_id}...")
            subprocess.run([
                self.bq_path, 'mk', '--dataset', 
                f'--location={self.location}',
                f'{self.project_id}:{self.dataset_id}'
            ], check=True, timeout=60)
            
            print(f"✅ Dataset {self.dataset_id} created successfully")
            logger.info(f"✅ Dataset {self.dataset_id} created successfully")
            return True
            
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            print(f"❌ Failed to create dataset: {e}")
            logger.error(f"❌ Failed to create dataset: {e}")
            return False
    
    def upload_table(self, table_name, file_path, schema_path):
        """Upload a single table to BigQuery"""
        try:
            table_id = f"{self.project_id}:{self.dataset_id}.{table_name}"
            
            # Check if file has data
            if not os.path.exists(file_path):
                print(f"⚠️  Skipping {table_name} - file not found: {file_path}")
                return True
                
            if os.path.getsize(file_path) == 0:
                print(f"⚠️  Skipping {table_name} - empty file")
                return True
            
            # Count records
            with open(file_path, 'r', encoding='utf-8') as f:
                record_count = sum(1 for line in f if line.strip())
            
            if record_count == 0:
                print(f"⚠️  Skipping {table_name} - no records")
                return True
            
            print(f"📤 Uploading {table_name} ({record_count} records)...")
            
            # Build bq load command
            cmd = [
                self.bq_path, 'load',
                '--source_format=NEWLINE_DELIMITED_JSON',
                '--replace',
                '--max_bad_records=10',
                table_id,
                file_path
            ]
            
            # Add schema
            if os.path.exists(schema_path):
                cmd.append(schema_path)
                print(f"   Using schema: {schema_path}")
            else:
                cmd.append('--autodetect')
                print(f"   Using autodetect schema")
            
            # Execute upload
            result = subprocess.run(cmd, capture_output=True, text=True, check=True, timeout=120)
            
            print(f"✅ {table_name} uploaded successfully ({record_count} records)")
            logger.info(f"✅ {table_name} uploaded successfully ({record_count} records)")
            return True
            
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            print(f"❌ Failed to upload {table_name}: {e}")
            if hasattr(e, 'stderr') and e.stderr:
                print(f"   Error details: {e.stderr[:200]}...")
            logger.error(f"❌ Failed to upload {table_name}: {e}")
            return False
    
    def full_upload(self):
        """Complete upload process"""
        print("🚀 USTAM - FIXED AUTOMATIC BIGQUERY UPLOAD")
        print("="*50)
        
        # Check prerequisites
        if not self.check_prerequisites():
            return False
        
        # Export data
        print("\n📤 Exporting data from SQLite...")
        try:
            exporter = UstamBigQueryExporter()
            exports = exporter.export_all_data()
            
            if not exports:
                print("❌ No data exported")
                return False
            
            print("✅ Data export completed")
            for table, info in exports.items():
                print(f"   • {table}: {info['count']} records")
                
        except Exception as e:
            print(f"❌ Data export failed: {e}")
            return False
        
        # Create dataset
        print(f"\n📊 Setting up BigQuery dataset...")
        if not self.create_dataset():
            return False
        
        # Upload tables
        print(f"\n⬆️  Uploading tables to BigQuery...")
        export_dir = 'bigquery_exports'
        success_count = 0
        total_count = 0
        
        for table_name, config in self.tables.items():
            file_pattern = os.path.join(export_dir, config['file_pattern'])
            schema_path = os.path.join(export_dir, config['schema_file'])
            
            files = glob.glob(file_pattern)
            if files:
                file_path = files[0]
                total_count += 1
                
                if self.upload_table(table_name, file_path, schema_path):
                    success_count += 1
            else:
                print(f"⚠️  No files found for {table_name} (pattern: {file_pattern})")
        
        # Summary
        print(f"\n✅ UPLOAD COMPLETE!")
        print("="*50)
        print(f"📊 Tables uploaded: {success_count}/{total_count}")
        
        if success_count > 0:
            print(f"🌐 BigQuery Console: https://console.cloud.google.com/bigquery?project={self.project_id}")
            print(f"📈 Dataset: {self.project_id}.{self.dataset_id}")
            
            print(f"\n🔍 Test Query:")
            print(f"SELECT user_type, COUNT(*) as count FROM `{self.project_id}.{self.dataset_id}.users` GROUP BY user_type;")
        
        return success_count > 0

def main():
    """Main function"""
    print("🚀 USTAM - FIXED BIGQUERY UPLOADER")
    print("This script will automatically find Google Cloud SDK on Windows")
    print("="*60)
    
    uploader = FixedAutoBigQueryUploader()
    
    # Get project ID
    if len(sys.argv) > 1:
        uploader.project_id = sys.argv[1]
        print(f"📊 Using project ID: {uploader.project_id}")
    else:
        project_id = input("📊 Enter your Google Cloud Project ID: ").strip()
        if project_id:
            uploader.project_id = project_id
        else:
            print("❌ Project ID is required")
            input("Press Enter to exit...")
            return
    
    success = uploader.full_upload()
    
    if not success:
        print("\n🔧 TROUBLESHOOTING GUIDE:")
        print("="*50)
        print("1. Download Google Cloud SDK:")
        print("   https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe")
        print("2. Run installer as Administrator")
        print("3. Check 'Add gcloud to my PATH' during installation")
        print("4. Restart Command Prompt completely")
        print("5. Run: gcloud auth login")
        print("6. Run: gcloud config set project your-project-id")
        print("7. Run: gcloud services enable bigquery.googleapis.com")
        print("\n📞 If still having issues:")
        print("- Try manual installation: Extract ZIP to C:\\google-cloud-sdk")
        print("- Run: C:\\google-cloud-sdk\\install.bat")
        print("- Add to PATH manually: C:\\google-cloud-sdk\\bin")
    
    input("\nPress Enter to exit...")
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()