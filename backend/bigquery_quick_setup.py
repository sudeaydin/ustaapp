#!/usr/bin/env python3
"""
Quick BigQuery Setup - Prerequisites check'ini atlar
"""

import os
import sys
import json
import logging
from datetime import datetime
from google.cloud import bigquery
from google.api_core import exceptions

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class QuickBigQuerySetup:
    """Quick BigQuery setup without prerequisites check"""
    
    def __init__(self, project_id="ustaapp-analytics"):
        self.project_id = project_id
        self.dataset_id = "ustam_analytics"
        self.location = "US"
        self.client = None

    def initialize_client(self):
        """Initialize BigQuery client"""
        try:
            self.client = bigquery.Client(project=self.project_id)
            logger.info(f"✅ BigQuery client initialized for project: {self.project_id}")
            return True
        except Exception as e:
            logger.error(f"❌ Failed to initialize BigQuery client: {e}")
            logger.error("Make sure you have run: gcloud auth application-default login")
            return False

    def create_dataset(self):
        """Create BigQuery dataset if it doesn't exist"""
        try:
            dataset_ref = self.client.dataset(self.dataset_id)
            
            try:
                dataset = self.client.get_dataset(dataset_ref)
                logger.info(f"✅ Dataset {self.dataset_id} already exists")
            except exceptions.NotFound:
                # Create dataset
                dataset = bigquery.Dataset(dataset_ref)
                dataset.location = self.location
                dataset.description = "ustam App Analytics and Logging Data"
                
                dataset = self.client.create_dataset(dataset)
                logger.info(f"✅ Dataset {self.dataset_id} created successfully")
            
            return True
        except Exception as e:
            logger.error(f"❌ Failed to create dataset: {e}")
            return False

    def create_basic_table(self):
        """Create a basic test table"""
        try:
            table_id = "user_activity_logs"
            table_ref = self.client.dataset(self.dataset_id).table(table_id)
            
            # Check if table exists
            try:
                table = self.client.get_table(table_ref)
                logger.info(f"✅ Table {table_id} already exists")
                return True
            except exceptions.NotFound:
                pass
            
            # Create basic schema
            schema = [
                bigquery.SchemaField("log_id", "STRING", mode="REQUIRED"),
                bigquery.SchemaField("user_id", "INTEGER", mode="NULLABLE"),
                bigquery.SchemaField("action_type", "STRING", mode="REQUIRED"),
                bigquery.SchemaField("timestamp", "TIMESTAMP", mode="REQUIRED"),
                bigquery.SchemaField("success", "BOOLEAN", mode="REQUIRED"),
                bigquery.SchemaField("platform", "STRING", mode="NULLABLE"),
            ]
            
            # Create table
            table = bigquery.Table(table_ref, schema=schema)
            table.description = "User activity logs for ustam app"
            
            # Add partitioning
            table.time_partitioning = bigquery.TimePartitioning(
                type_=bigquery.TimePartitioningType.DAY,
                field='timestamp'
            )
            
            table = self.client.create_table(table)
            logger.info(f"✅ Table {table_id} created successfully")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to create table: {e}")
            return False

    def test_insert(self):
        """Test inserting data"""
        try:
            table_ref = self.client.dataset(self.dataset_id).table("user_activity_logs")
            
            # Test data
            rows_to_insert = [
                {
                    "log_id": "test_001",
                    "user_id": 999,
                    "action_type": "test_action",
                    "timestamp": datetime.utcnow().isoformat() + "Z",
                    "success": True,
                    "platform": "test"
                }
            ]
            
            errors = self.client.insert_rows_json(table_ref, rows_to_insert)
            
            if errors:
                logger.error(f"❌ Insert errors: {errors}")
                return False
            else:
                logger.info("✅ Test data inserted successfully")
                return True
                
        except Exception as e:
            logger.error(f"❌ Test insert failed: {e}")
            return False

    def quick_setup(self):
        """Run quick setup"""
        logger.info("🚀 Quick BigQuery Setup Starting...")
        
        # Step 1: Initialize client
        if not self.initialize_client():
            return False
        
        # Step 2: Create dataset
        if not self.create_dataset():
            return False
        
        # Step 3: Create basic table
        if not self.create_basic_table():
            return False
        
        # Step 4: Test insert
        if not self.test_insert():
            return False
        
        logger.info("✅ QUICK SETUP COMPLETE!")
        logger.info(f"🌐 Console: https://console.cloud.google.com/bigquery?project={self.project_id}")
        return True

def main():
    """Main function"""
    project_id = sys.argv[1] if len(sys.argv) > 1 else "ustaapp-analytics"
    
    setup = QuickBigQuerySetup(project_id)
    success = setup.quick_setup()
    
    if success:
        print("\n🎉 SUCCESS! Your BigQuery is ready for testing.")
        print("\nNext step: Run the integration test:")
        print("python test_bigquery_integration.py")
    else:
        print("\n❌ Setup failed. Check errors above.")
    
    return success

if __name__ == '__main__':
    main()