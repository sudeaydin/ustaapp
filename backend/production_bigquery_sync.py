#!/usr/bin/env python3
"""
Production BigQuery Daily Sync System
Günlük olarak SQLite'dan BigQuery'ye veri senkronizasyonu
"""

import os
import sys
import json
import logging
from datetime import datetime, timedelta
from google.cloud import bigquery
import sqlite3

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('bigquery_sync.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class ProductionBigQuerySync:
    """Production BigQuery sync system"""
    
    def __init__(self, project_id=None):
        self.project_id = project_id or os.environ.get('BIGQUERY_PROJECT_ID')
        self.dataset_id = "ustam_analytics"
        self.db_path = os.environ.get('DATABASE_URL', 'sqlite:///app.db').replace('sqlite:///', '')
        self.client = None
        
        # Tables to sync
        self.sync_tables = {
            'users': {
                'sql': '''
                SELECT 
                    id as user_id,
                    email,
                    first_name,
                    last_name,
                    phone,
                    user_type,
                    is_active,
                    is_verified,
                    created_at,
                    updated_at
                FROM users 
                WHERE DATE(created_at) = DATE('now', '-1 day') OR DATE(updated_at) = DATE('now', '-1 day')
                ''',
                'write_disposition': bigquery.WriteDisposition.WRITE_APPEND
            },
            'jobs': {
                'sql': '''
                SELECT 
                    id,
                    title,
                    description,
                    category,
                    location,
                    budget,
                    status,
                    customer_id,
                    assigned_craftsman_id,
                    created_at,
                    updated_at,
                    completed_at
                FROM jobs 
                WHERE DATE(created_at) = DATE('now', '-1 day') OR DATE(updated_at) = DATE('now', '-1 day')
                ''',
                'write_disposition': bigquery.WriteDisposition.WRITE_APPEND
            },
            'payments': {
                'sql': '''
                SELECT 
                    id,
                    user_id,
                    job_id,
                    amount,
                    status,
                    payment_method,
                    transaction_id,
                    created_at,
                    completed_at
                FROM payments 
                WHERE DATE(created_at) = DATE('now', '-1 day') OR DATE(updated_at) = DATE('now', '-1 day')
                ''',
                'write_disposition': bigquery.WriteDisposition.WRITE_APPEND
            },
            'reviews': {
                'sql': '''
                SELECT 
                    id,
                    job_id,
                    customer_id,
                    craftsman_id,
                    rating,
                    comment,
                    created_at
                FROM reviews 
                WHERE DATE(created_at) = DATE('now', '-1 day')
                ''',
                'write_disposition': bigquery.WriteDisposition.WRITE_APPEND
            }
        }

    def initialize_client(self):
        """Initialize BigQuery client"""
        try:
            self.client = bigquery.Client(project=self.project_id)
            logger.info(f"✅ BigQuery client initialized for project: {self.project_id}")
            return True
        except Exception as e:
            logger.error(f"❌ Failed to initialize BigQuery client: {e}")
            return False

    def sync_table(self, table_name, config):
        """Sync single table to BigQuery"""
        try:
            logger.info(f"📊 Syncing table: {table_name}")
            
            # Connect to SQLite
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Execute query
            cursor.execute(config['sql'])
            rows = cursor.fetchall()
            
            if not rows:
                logger.info(f"   No new data for {table_name}")
                conn.close()
                return True
            
            # Convert to list of dicts
            data = []
            for row in rows:
                row_dict = dict(row)
                # Convert datetime strings to proper format
                for key, value in row_dict.items():
                    if value and ('_at' in key or key == 'timestamp'):
                        try:
                            # Convert to ISO format for BigQuery
                            if isinstance(value, str):
                                dt = datetime.fromisoformat(value.replace('Z', '+00:00'))
                                row_dict[key] = dt.isoformat() + 'Z'
                        except:
                            pass
                data.append(row_dict)
            
            conn.close()
            
            # Insert to BigQuery
            table_ref = self.client.dataset(self.dataset_id).table(table_name)
            
            job_config = bigquery.LoadJobConfig(
                write_disposition=config.get('write_disposition', bigquery.WriteDisposition.WRITE_APPEND),
                source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
            )
            
            job = self.client.load_table_from_json(data, table_ref, job_config=job_config)
            job.result()  # Wait for job to complete
            
            logger.info(f"   ✅ Synced {len(data)} rows to {table_name}")
            return True
            
        except Exception as e:
            logger.error(f"   ❌ Failed to sync {table_name}: {e}")
            return False

    def generate_daily_metrics(self):
        """Generate daily business metrics"""
        try:
            logger.info("📈 Generating daily metrics...")
            
            # Connect to SQLite
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Calculate metrics for yesterday
            yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
            
            metrics_query = f'''
            SELECT 
                '{yesterday}' as date,
                'daily_summary' as metric_type,
                (SELECT COUNT(*) FROM users) as total_users,
                (SELECT COUNT(*) FROM users WHERE is_active = 1) as active_users,
                (SELECT COUNT(*) FROM users WHERE DATE(created_at) = '{yesterday}') as new_users,
                (SELECT COUNT(*) FROM jobs) as total_jobs,
                (SELECT COUNT(*) FROM jobs WHERE status = 'completed') as completed_jobs,
                (SELECT COUNT(*) FROM jobs WHERE DATE(created_at) = '{yesterday}') as new_jobs,
                (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'completed') as total_revenue,
                (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'completed' AND DATE(created_at) = '{yesterday}') as daily_revenue,
                (SELECT COALESCE(AVG(rating), 0) FROM reviews) as average_rating,
                '{datetime.now().isoformat()}Z' as created_at
            '''
            
            cursor.execute(metrics_query)
            metrics = cursor.fetchone()
            conn.close()
            
            if metrics:
                # Convert to dict
                columns = [description[0] for description in cursor.description]
                metrics_dict = dict(zip(columns, metrics))
                
                # Insert to BigQuery
                table_ref = self.client.dataset(self.dataset_id).table('business_metrics')
                errors = self.client.insert_rows_json(table_ref, [metrics_dict])
                
                if errors:
                    logger.error(f"❌ Metrics insert errors: {errors}")
                    return False
                else:
                    logger.info("✅ Daily metrics generated successfully")
                    return True
            
            return False
            
        except Exception as e:
            logger.error(f"❌ Failed to generate daily metrics: {e}")
            return False

    def full_sync(self):
        """Run full daily sync"""
        logger.info("🚀 Starting Production BigQuery Daily Sync")
        logger.info("=" * 60)
        
        # Initialize client
        if not self.initialize_client():
            return False
        
        # Sync all tables
        success_count = 0
        total_tables = len(self.sync_tables)
        
        for table_name, config in self.sync_tables.items():
            if self.sync_table(table_name, config):
                success_count += 1
        
        # Generate daily metrics
        metrics_success = self.generate_daily_metrics()
        
        # Summary
        logger.info("=" * 60)
        logger.info(f"📊 Sync Summary:")
        logger.info(f"   Tables synced: {success_count}/{total_tables}")
        logger.info(f"   Daily metrics: {'✅' if metrics_success else '❌'}")
        logger.info(f"   Timestamp: {datetime.now().isoformat()}")
        
        if success_count == total_tables and metrics_success:
            logger.info("🎉 Daily sync completed successfully!")
            return True
        else:
            logger.error("⚠️ Some sync operations failed")
            return False

def main():
    """Main function"""
    project_id = sys.argv[1] if len(sys.argv) > 1 else None
    
    if not project_id:
        logger.error("Usage: python production_bigquery_sync.py PROJECT_ID")
        return False
    
    syncer = ProductionBigQuerySync(project_id)
    return syncer.full_sync()

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)