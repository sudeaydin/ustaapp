#!/usr/bin/env python3
"""
Automatic BigQuery Upload Script
Exports data from SQLite and automatically uploads to BigQuery
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

from bigquery_integration import ustamBigQueryExporter

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AutoBigQueryUploader:
    """Automatic BigQuery uploader with Google Cloud SDK integration"""
    
    def __init__(self):
        self.project_id = "ustam-analytics"  # Change this to your project ID
        self.dataset_id = "ustam_analytics"
        self.location = "US"
        
        # Table mappings
        self.tables = {
            'users': {
                'file_pattern': 'users_*.json',
                'schema_file': 'schemas/users_schema.json'
            },
            'jobs': {
                'file_pattern': 'jobs_*.json', 
                'schema_file': 'schemas/jobs_schema.json'
            },
            'categories': {
                'file_pattern': 'categories_*.json',
                'schema_file': 'schemas/categories_schema.json'
            },
            'customers': {
                'file_pattern': 'customers_*.json',
                'schema_file': 'schemas/customers_schema.json'
            },
            'craftsmen': {
                'file_pattern': 'craftsmen_*.json',
                'schema_file': 'schemas/craftsmen_schema.json'
            },
            'payments': {
                'file_pattern': 'payments_*.json',
                'schema_file': 'schemas/payments_schema.json'
            },
            'messages': {
                'file_pattern': 'messages_*.json',
                'schema_file': 'schemas/messages_schema.json'
            },
            'reviews': {
                'file_pattern': 'reviews_*.json',
                'schema_file': 'schemas/reviews_schema.json'
            },
            'quotes': {
                'file_pattern': 'quotes_*.json',
                'schema_file': 'schemas/quotes_schema.json'
            },
            'notifications': {
                'file_pattern': 'notifications_*.json',
                'schema_file': 'schemas/notifications_schema.json'
            }
        }
    
    def check_gcloud_auth(self):
        """Check if gcloud is authenticated"""
        try:
            result = subprocess.run(['gcloud', 'auth', 'list'], 
                                  capture_output=True, text=True, check=True)
            if 'ACTIVE' in result.stdout:
                logger.info("✅ Google Cloud authentication verified")
                return True
            else:
                logger.error("❌ No active Google Cloud authentication found")
                return False
        except subprocess.CalledProcessError:
            logger.error("❌ gcloud command not found. Please install Google Cloud SDK")
            return False
        except FileNotFoundError:
            logger.error("❌ gcloud command not found. Please install Google Cloud SDK")
            return False
    
    def check_bigquery_api(self):
        """Check if BigQuery API is enabled"""
        try:
            result = subprocess.run([
                'gcloud', 'services', 'list', '--enabled', 
                '--filter=name:bigquery.googleapis.com', '--format=value(name)'
            ], capture_output=True, text=True, check=True)
            
            if 'bigquery.googleapis.com' in result.stdout:
                logger.info("✅ BigQuery API is enabled")
                return True
            else:
                logger.warning("⚠️  BigQuery API not enabled. Enabling now...")
                subprocess.run(['gcloud', 'services', 'enable', 'bigquery.googleapis.com'], 
                             check=True)
                logger.info("✅ BigQuery API enabled")
                return True
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Failed to check/enable BigQuery API: {e}")
            return False
    
    def create_dataset(self):
        """Create BigQuery dataset if it doesn't exist"""
        try:
            # Check if dataset exists
            result = subprocess.run([
                'bq', 'ls', '-d', '--format=value(datasetId)', self.project_id
            ], capture_output=True, text=True, check=True)
            
            if self.dataset_id in result.stdout:
                logger.info(f"✅ Dataset {self.dataset_id} already exists")
                return True
            
            # Create dataset
            logger.info(f"📊 Creating dataset {self.dataset_id}...")
            subprocess.run([
                'bq', 'mk', '--dataset', 
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
            if os.path.getsize(file_path) == 0:
                logger.warning(f"⚠️  Skipping {table_name} - empty file")
                return True
            
            # Count records in file
            with open(file_path, 'r', encoding='utf-8') as f:
                record_count = sum(1 for line in f if line.strip())
            
            if record_count == 0:
                logger.warning(f"⚠️  Skipping {table_name} - no records")
                return True
            
            logger.info(f"📤 Uploading {table_name} ({record_count} records)...")
            
            # Build bq load command
            cmd = [
                'bq', 'load',
                '--source_format=NEWLINE_DELIMITED_JSON',
                '--replace',  # Replace existing table
                '--max_bad_records=10',
                table_id,
                file_path
            ]
            
            # Add schema if exists
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
    
    def create_views(self):
        """Create BigQuery views from SQL files"""
        views_dir = os.path.join('bigquery_exports', 'views')
        
        if not os.path.exists(views_dir):
            logger.warning("⚠️  No views directory found")
            return True
        
        view_files = glob.glob(os.path.join(views_dir, '*_view.sql'))
        
        for view_file in view_files:
            try:
                view_name = os.path.basename(view_file).replace('_view.sql', '')
                
                logger.info(f"📊 Creating view {view_name}...")
                
                # Read SQL content
                with open(view_file, 'r', encoding='utf-8') as f:
                    sql_content = f.read()
                
                # Replace placeholder project name
                sql_content = sql_content.replace('ustam_analytics', f'{self.project_id}.{self.dataset_id}')
                
                # Execute SQL
                result = subprocess.run([
                    'bq', 'query', '--use_legacy_sql=false', sql_content
                ], capture_output=True, text=True, check=True)
                
                logger.info(f"✅ View {view_name} created successfully")
                
            except subprocess.CalledProcessError as e:
                logger.error(f"❌ Failed to create view {view_name}: {e}")
            except Exception as e:
                logger.error(f"❌ Error processing view {view_name}: {e}")
        
        return True
    
    def full_upload(self):
        """Complete upload process: export data and upload to BigQuery"""
        print("🚀 ustam - AUTOMATIC BIGQUERY UPLOAD")
        print("="*50)
        
        # Step 1: Check prerequisites
        print("🔍 Checking prerequisites...")
        if not self.check_gcloud_auth():
            print("\n❌ Please run: gcloud auth login")
            return False
        
        if not self.check_bigquery_api():
            print("\n❌ BigQuery API setup failed")
            return False
        
        # Step 2: Export data
        print("\n📤 Exporting data from SQLite...")
        exporter = ustamBigQueryExporter()
        exports = exporter.export_all_data()
        
        if not exports:
            print("❌ No data exported")
            return False
        
        # Step 3: Create dataset
        print(f"\n📊 Setting up BigQuery dataset...")
        if not self.create_dataset():
            return False
        
        # Step 4: Upload tables
        print(f"\n⬆️  Uploading tables to BigQuery...")
        export_dir = os.path.join('bigquery_exports')
        success_count = 0
        total_count = 0
        
        for table_name, config in self.tables.items():
            file_pattern = os.path.join(export_dir, config['file_pattern'])
            schema_path = os.path.join(export_dir, config['schema_file'])
            
            # Find matching files
            files = glob.glob(file_pattern)
            if files:
                file_path = files[0]  # Use the most recent file
                total_count += 1
                
                if self.upload_table(table_name, file_path, schema_path):
                    success_count += 1
        
        # Step 5: Create views
        print(f"\n📊 Creating analytics views...")
        self.create_views()
        
        # Summary
        print(f"\n✅ UPLOAD COMPLETE!")
        print("="*50)
        print(f"📊 Tables uploaded: {success_count}/{total_count}")
        print(f"🌐 BigQuery Console: https://console.cloud.google.com/bigquery?project={self.project_id}")
        print(f"📈 Dataset: {self.project_id}.{self.dataset_id}")
        
        # Show sample queries
        print(f"\n🔍 Sample Queries:")
        print(f"-- View all users")
        print(f"SELECT * FROM `{self.project_id}.{self.dataset_id}.users`;")
        print(f"\n-- User statistics")
        print(f"SELECT user_type, COUNT(*) as count FROM `{self.project_id}.{self.dataset_id}.users` GROUP BY user_type;")
        
        return success_count > 0

def main():
    """Main function"""
    uploader = AutoBigQueryUploader()
    
    # Get project ID from user if needed
    if len(sys.argv) > 1:
        uploader.project_id = sys.argv[1]
        print(f"Using project ID: {uploader.project_id}")
    
    success = uploader.full_upload()
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()