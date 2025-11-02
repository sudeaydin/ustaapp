#!/usr/bin/env python3
"""
Google Cloud Scheduler BigQuery Sync Endpoint
Bu endpoint Cloud Scheduler tarafından günlük olarak çağrılacak
"""

import os
import logging
from datetime import datetime, timedelta
from flask import Flask, request, jsonify
from google.cloud import bigquery
import sqlalchemy
from config.cloud_sql import get_cloud_sql_url, validate_cloud_sql_config

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class CloudSchedulerSync:
    """Cloud Scheduler ile BigQuery sync"""
    
    def __init__(self):
        self.project_id = os.environ.get('GOOGLE_CLOUD_PROJECT', 'ustaapp-analytics')
        self.dataset_id = "ustam_analytics"
        self.bigquery_client = bigquery.Client(project=self.project_id)
        
        # Cloud SQL connection
        self.cloud_sql_settings = validate_cloud_sql_config()
        self.db_url = get_cloud_sql_url(self.cloud_sql_settings)
        self.db_engine = sqlalchemy.create_engine(self.db_url)

    def sync_table_data(self, table_name, sync_config):
        """Sync single table to BigQuery"""
        try:
            logger.info(f"📊 Syncing {table_name}...")
            
            # Execute SQL query
            with self.db_engine.connect() as conn:
                result = conn.execute(sqlalchemy.text(sync_config['sql']))
                rows = result.fetchall()
                columns = result.keys()
            
            if not rows:
                logger.info(f"   No new data for {table_name}")
                return True
            
            # Convert to list of dicts
            data = []
            for row in rows:
                row_dict = dict(zip(columns, row))
                # Convert datetime objects to ISO format
                for key, value in row_dict.items():
                    if isinstance(value, datetime):
                        row_dict[key] = value.isoformat() + 'Z'
                    elif value is None:
                        row_dict[key] = None
                data.append(row_dict)
            
            # Insert to BigQuery
            table_ref = self.bigquery_client.dataset(self.dataset_id).table(table_name)
            errors = self.bigquery_client.insert_rows_json(table_ref, data)
            
            if errors:
                logger.error(f"❌ BigQuery insert errors for {table_name}: {errors}")
                return False
            else:
                logger.info(f"✅ Synced {len(data)} rows to {table_name}")
                return True
                
        except Exception as e:
            logger.error(f"❌ Failed to sync {table_name}: {e}")
            return False

    def generate_business_metrics(self):
        """Generate daily business metrics"""
        try:
            logger.info("📈 Generating business metrics...")
            
            yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
            
            metrics_query = f"""
            SELECT 
                '{yesterday}' as date,
                'daily_summary' as metric_type,
                (SELECT COUNT(*) FROM users) as total_users,
                (SELECT COUNT(*) FROM users WHERE is_active = true) as active_users,
                (SELECT COUNT(*) FROM users WHERE DATE(created_at) = '{yesterday}') as new_users,
                (SELECT COUNT(*) FROM jobs) as total_jobs,
                (SELECT COUNT(*) FROM jobs WHERE status = 'completed') as completed_jobs,
                (SELECT COUNT(*) FROM jobs WHERE DATE(created_at) = '{yesterday}') as new_jobs,
                (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'completed') as total_revenue,
                (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'completed' AND DATE(created_at) = '{yesterday}') as daily_revenue,
                (SELECT COALESCE(AVG(rating), 0) FROM reviews) as average_rating,
                '{datetime.now().isoformat()}Z' as created_at
            """
            
            with self.db_engine.connect() as conn:
                result = conn.execute(sqlalchemy.text(metrics_query))
                row = result.fetchone()
                columns = result.keys()
            
            if row:
                metrics_dict = dict(zip(columns, row))
                
                # Insert to BigQuery
                table_ref = self.bigquery_client.dataset(self.dataset_id).table('business_metrics')
                errors = self.bigquery_client.insert_rows_json(table_ref, [metrics_dict])
                
                if errors:
                    logger.error(f"❌ Metrics insert errors: {errors}")
                    return False
                else:
                    logger.info("✅ Business metrics generated successfully")
                    return True
            
            return False
            
        except Exception as e:
            logger.error(f"❌ Failed to generate business metrics: {e}")
            return False

    def run_daily_sync(self):
        """Run complete daily sync"""
        logger.info("🚀 Starting Cloud Scheduler BigQuery Sync")
        
        # Define tables to sync
        sync_tables = {
            'users': {
                'sql': '''
                SELECT 
                    id as user_id, email, first_name, last_name, phone,
                    user_type, is_active, is_verified, created_at, updated_at
                FROM users 
                WHERE DATE(created_at) >= CURRENT_DATE - INTERVAL '2 days'
                   OR DATE(updated_at) >= CURRENT_DATE - INTERVAL '2 days'
                '''
            },
            'jobs': {
                'sql': '''
                SELECT 
                    id, title, description, category, location, budget, status,
                    customer_id, assigned_craftsman_id, created_at, updated_at, completed_at
                FROM jobs 
                WHERE DATE(created_at) >= CURRENT_DATE - INTERVAL '2 days'
                   OR DATE(updated_at) >= CURRENT_DATE - INTERVAL '2 days'
                '''
            },
            'payments': {
                'sql': '''
                SELECT 
                    id, user_id, job_id, amount, status, payment_method,
                    transaction_id, created_at, completed_at
                FROM payments 
                WHERE DATE(created_at) >= CURRENT_DATE - INTERVAL '2 days'
                   OR DATE(updated_at) >= CURRENT_DATE - INTERVAL '2 days'
                '''
            }
        }
        
        # Sync tables
        success_count = 0
        total_tables = len(sync_tables)
        
        for table_name, config in sync_tables.items():
            if self.sync_table_data(table_name, config):
                success_count += 1
        
        # Generate business metrics
        metrics_success = self.generate_business_metrics()
        
        # Return results
        return {
            'success': success_count == total_tables and metrics_success,
            'tables_synced': f"{success_count}/{total_tables}",
            'metrics_generated': metrics_success,
            'timestamp': datetime.now().isoformat()
        }

# Flask app for Cloud Scheduler endpoint
app = Flask(__name__)

@app.route('/cron/bigquery-sync', methods=['POST'])
def bigquery_sync_endpoint():
    """Cloud Scheduler endpoint for BigQuery sync"""
    
    # Verify request is from Cloud Scheduler
    if request.headers.get('X-Appengine-Cron') != 'true':
        return jsonify({'error': 'Unauthorized'}), 401
    
    try:
        syncer = CloudSchedulerSync()
        result = syncer.run_daily_sync()
        
        if result['success']:
            logger.info("🎉 Daily sync completed successfully")
            return jsonify(result), 200
        else:
            logger.error("⚠️ Daily sync completed with errors")
            return jsonify(result), 500
            
    except Exception as e:
        logger.error(f"❌ Sync failed: {e}")
        return jsonify({
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/health')
def health():
    """Health check"""
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)