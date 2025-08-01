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
        possible_paths = [
            r"C:\Users\{}\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd".format(os.getenv('USERNAME')),
            r"C:\Program Files\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
            r"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
            r"C:\google-cloud-sdk\bin\gcloud.cmd",
            "gcloud"  # Try PATH
        ]
        
        for path in possible_paths:
            try:
                if path == "gcloud":
                    result = subprocess.run([path, "--version"], capture_output=True, text=True, check=True)
                else:
                    if os.path.exists(path):
                        result = subprocess.run([path, "--version"], capture_output=True, text=True, check=True)
                    else:
                        continue
                
                logger.info(f"✅ Found gcloud at: {path}")
                return path
            except (subprocess.CalledProcessError, FileNotFoundError, OSError):
                continue
        
        return None
    
    def find_bq(self):
        """Find bq executable in common Windows locations"""
        possible_paths = [
            r"C:\Users\{}\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin\bq.cmd".format(os.getenv('USERNAME')),
            r"C:\Program Files\Google\Cloud SDK\google-cloud-sdk\bin\bq.cmd",
            r"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\bq.cmd",
            r"C:\google-cloud-sdk\bin\bq.cmd",
            "bq"  # Try PATH
        ]
        
        for path in possible_paths:
            try:
                if path == "bq":
                    result = subprocess.run([path, "--version"], capture_output=True, text=True, check=True)
                else:
                    if os.path.exists(path):
                        result = subprocess.run([path, "--version"], capture_output=True, text=True, check=True)
                    else:
                        continue
                
                logger.info(f"✅ Found bq at: {path}")
                return path
            except (subprocess.CalledProcessError, FileNotFoundError, OSError):
                continue
        
        return None
    
    def check_prerequisites(self):
        """Check if all prerequisites are met"""
        if not self.gcloud_path:
            print("❌ Google Cloud SDK not found!")
            print("📥 Please install from: https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe")
            print("⚠️  Make sure to check 'Add gcloud to my PATH' during installation")
            print("🔄 Restart Command Prompt after installation")
            return False
        
        if not self.bq_path:
            print("❌ BigQuery CLI (bq) not found!")
            return False
        
        # Check authentication
        try:
            result = subprocess.run([self.gcloud_path, 'auth', 'list'], 
                                  capture_output=True, text=True, check=True)
            if 'ACTIVE' not in result.stdout:
                print("❌ No active Google Cloud authentication found")
                print(f"🔑 Please run: {self.gcloud_path} auth login")
                return False
        except subprocess.CalledProcessError:
            print("❌ Authentication check failed")
            print(f"🔑 Please run: {self.gcloud_path} auth login")
            return False
        
        logger.info("✅ All prerequisites met")
        return True
    
    def create_dataset(self):
        """Create BigQuery dataset if it doesn't exist"""
        try:
            # Check if dataset exists
            result = subprocess.run([
                self.bq_path, 'ls', '-d', '--format=value(datasetId)', self.project_id
            ], capture_output=True, text=True, check=True)
            
            if self.dataset_id in result.stdout:
                logger.info(f"✅ Dataset {self.dataset_id} already exists")
                return True
            
            # Create dataset
            logger.info(f"📊 Creating dataset {self.dataset_id}...")
            subprocess.run([
                self.bq_path, 'mk', '--dataset', 
                f'--location={self.location}',
                f'{self.project_id}:{self.dataset_id}'
            ], check=True)
            
            logger.info(f"✅ Dataset {self.dataset_id} created successfully")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Failed to create dataset: {e}")
            return False
    
    def upload_table(self, table_name, file_path, schema_path):
        """Upload a single table to BigQuery"""
        try:
            table_id = f"{self.project_id}:{self.dataset_id}.{table_name}"
            
            # Check if file has data
            if not os.path.exists(file_path) or os.path.getsize(file_path) == 0:
                logger.warning(f"⚠️  Skipping {table_name} - file not found or empty")
                return True
            
            # Count records
            with open(file_path, 'r', encoding='utf-8') as f:
                record_count = sum(1 for line in f if line.strip())
            
            if record_count == 0:
                logger.warning(f"⚠️  Skipping {table_name} - no records")
                return True
            
            logger.info(f"📤 Uploading {table_name} ({record_count} records)...")
            
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
            else:
                cmd.append('--autodetect')
            
            # Execute upload
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            
            logger.info(f"✅ {table_name} uploaded successfully ({record_count} records)")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Failed to upload {table_name}: {e}")
            if e.stderr:
                logger.error(f"Error details: {e.stderr}")
            return False
    
    def full_upload(self):
        """Complete upload process"""
        print("🚀 USTAM - FIXED AUTOMATIC BIGQUERY UPLOAD")
        print("="*50)
        
        # Check prerequisites
        print("🔍 Checking prerequisites...")
        if not self.check_prerequisites():
            return False
        
        # Export data
        print("\n📤 Exporting data from SQLite...")
        exporter = UstamBigQueryExporter()
        exports = exporter.export_all_data()
        
        if not exports:
            print("❌ No data exported")
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
        
        # Summary
        print(f"\n✅ UPLOAD COMPLETE!")
        print("="*50)
        print(f"📊 Tables uploaded: {success_count}/{total_count}")
        print(f"🌐 BigQuery Console: https://console.cloud.google.com/bigquery?project={self.project_id}")
        
        if success_count > 0:
            print(f"\n🔍 Test Query:")
            print(f"SELECT user_type, COUNT(*) as count FROM `{self.project_id}.{self.dataset_id}.users` GROUP BY user_type;")
        
        return success_count > 0

def main():
    """Main function"""
    uploader = FixedAutoBigQueryUploader()
    
    if len(sys.argv) > 1:
        uploader.project_id = sys.argv[1]
        print(f"Using project ID: {uploader.project_id}")
    
    success = uploader.full_upload()
    
    if not success:
        print("\n🔧 TROUBLESHOOTING:")
        print("1. Install Google Cloud SDK: https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe")
        print("2. Check 'Add gcloud to my PATH' during installation")
        print("3. Restart Command Prompt")
        print("4. Run: gcloud auth login")
        print("5. Run: gcloud config set project your-project-id")
    
    input("\nPress Enter to exit...")
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()