"""
Google Cloud Scheduler Routes
Handles scheduled BigQuery sync operations
"""

import os
import logging
from datetime import datetime, timedelta
from flask import Blueprint, request, jsonify

try:  # Optional BigQuery dependency
    from google.cloud import bigquery  # type: ignore
    _BIGQUERY_IMPORT_ERROR = None
except ImportError as import_error:  # pragma: no cover - optional dependency missing
    bigquery = None  # type: ignore
    _BIGQUERY_IMPORT_ERROR = import_error
from app import db
from app.models.user import User
from app.models.job import Job
from app.models.payment import Payment
from app.models.review import Review

# Configure logging
logger = logging.getLogger(__name__)

# Create blueprint
scheduler_bp = Blueprint('scheduler', __name__)

class CloudSchedulerBigQuerySync:
    """Cloud Scheduler BigQuery sync operations"""
    
    def __init__(self):
        self.project_id = os.environ.get('GOOGLE_CLOUD_PROJECT', 'ustaapp-analytics')
        self.dataset_id = "ustam_analytics"
        self.bigquery_client = None

        if bigquery is None:
            logger.info(
                "Cloud Scheduler BigQuery sync disabled: %s",
                _BIGQUERY_IMPORT_ERROR or "google-cloud-bigquery not installed",
            )
            return

        try:
            self.bigquery_client = bigquery.Client(project=self.project_id)
        except Exception as exc:  # pragma: no cover - depends on external services
            logger.error("Failed to initialize BigQuery client for scheduler: %s", exc)
            self.bigquery_client = None

    def sync_users_data(self):
        """Sync users data to BigQuery"""
        if not self.bigquery_client:
            logger.info("Skipping users sync; BigQuery client unavailable.")
            return True
        try:
            # Get recent users (last 2 days)
            cutoff_date = datetime.now() - timedelta(days=2)
            users = User.query.filter(
                (User.created_at >= cutoff_date) | 
                (User.updated_at >= cutoff_date)
            ).all()
            
            if not users:
                logger.info("No new users to sync")
                return True
            
            # Convert to BigQuery format
            data = []
            for user in users:
                data.append({
                    'user_id': user.id,
                    'email': user.email,
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                    'phone': user.phone,
                    'user_type': user.user_type,
                    'is_active': user.is_active,
                    'is_verified': user.is_verified,
                    'created_at': user.created_at.isoformat() + 'Z' if user.created_at else None,
                    'updated_at': user.updated_at.isoformat() + 'Z' if user.updated_at else None
                })
            
            # Insert to BigQuery
            table_ref = self.bigquery_client.dataset(self.dataset_id).table('users')
            errors = self.bigquery_client.insert_rows_json(table_ref, data)
            
            if errors:
                logger.error(f"Users sync errors: {errors}")
                return False
            else:
                logger.info(f"✅ Synced {len(data)} users to BigQuery")
                return True
                
        except Exception as e:
            logger.error(f"Failed to sync users: {e}")
            return False

    def sync_jobs_data(self):
        """Sync jobs data to BigQuery"""
        if not self.bigquery_client:
            logger.info("Skipping jobs sync; BigQuery client unavailable.")
            return True
        try:
            # Get recent jobs (last 2 days)
            cutoff_date = datetime.now() - timedelta(days=2)
            jobs = Job.query.filter(
                (Job.created_at >= cutoff_date) | 
                (Job.updated_at >= cutoff_date)
            ).all()
            
            if not jobs:
                logger.info("No new jobs to sync")
                return True
            
            # Convert to BigQuery format
            data = []
            for job in jobs:
                data.append({
                    'id': job.id,
                    'title': job.title,
                    'description': job.description,
                    'category': job.category,
                    'location': job.location,
                    'budget': float(job.budget) if job.budget else None,
                    'status': job.status,
                    'customer_id': job.customer_id,
                    'assigned_craftsman_id': job.assigned_craftsman_id,
                    'created_at': job.created_at.isoformat() + 'Z' if job.created_at else None,
                    'updated_at': job.updated_at.isoformat() + 'Z' if job.updated_at else None,
                    'completed_at': job.completed_at.isoformat() + 'Z' if job.completed_at else None
                })
            
            # Insert to BigQuery
            table_ref = self.bigquery_client.dataset(self.dataset_id).table('jobs')
            errors = self.bigquery_client.insert_rows_json(table_ref, data)
            
            if errors:
                logger.error(f"Jobs sync errors: {errors}")
                return False
            else:
                logger.info(f"✅ Synced {len(data)} jobs to BigQuery")
                return True
                
        except Exception as e:
            logger.error(f"Failed to sync jobs: {e}")
            return False

    def generate_business_metrics(self):
        """Generate daily business metrics"""
        if not self.bigquery_client:
            logger.info("Skipping business metrics generation; BigQuery client unavailable.")
            return True
        try:
            yesterday = datetime.now() - timedelta(days=1)
            yesterday_str = yesterday.strftime('%Y-%m-%d')
            
            # Calculate metrics
            total_users = User.query.count()
            active_users = User.query.filter(User.is_active == True).count()
            new_users = User.query.filter(
                db.func.date(User.created_at) == yesterday.date()
            ).count()
            
            total_jobs = Job.query.count()
            completed_jobs = Job.query.filter(Job.status == 'completed').count()
            new_jobs = Job.query.filter(
                db.func.date(Job.created_at) == yesterday.date()
            ).count()
            
            total_revenue = db.session.query(
                db.func.coalesce(db.func.sum(Payment.amount), 0)
            ).filter(Payment.status == 'completed').scalar()
            
            daily_revenue = db.session.query(
                db.func.coalesce(db.func.sum(Payment.amount), 0)
            ).filter(
                Payment.status == 'completed',
                db.func.date(Payment.created_at) == yesterday.date()
            ).scalar()
            
            avg_rating = db.session.query(
                db.func.coalesce(db.func.avg(Review.rating), 0)
            ).scalar()
            
            # Create metrics record
            metrics = {
                'date': yesterday_str,
                'metric_type': 'daily_summary',
                'total_users': total_users,
                'active_users': active_users,
                'new_users': new_users,
                'total_jobs': total_jobs,
                'completed_jobs': completed_jobs,
                'new_jobs': new_jobs,
                'total_revenue': float(total_revenue) if total_revenue else 0.0,
                'daily_revenue': float(daily_revenue) if daily_revenue else 0.0,
                'average_rating': float(avg_rating) if avg_rating else 0.0,
                'created_at': datetime.now().isoformat() + 'Z'
            }
            
            # Insert to BigQuery
            table_ref = self.bigquery_client.dataset(self.dataset_id).table('business_metrics')
            errors = self.bigquery_client.insert_rows_json(table_ref, [metrics])
            
            if errors:
                logger.error(f"Metrics sync errors: {errors}")
                return False
            else:
                logger.info("✅ Business metrics generated successfully")
                return True
                
        except Exception as e:
            logger.error(f"Failed to generate metrics: {e}")
            return False

    def run_full_sync(self):
        """Run complete daily sync"""
        logger.info("🚀 Starting scheduled BigQuery sync")

        if not self.bigquery_client:
            message = "BigQuery client unavailable; scheduled sync skipped."
            logger.info(message)
            return {
                'success': True,
                'disabled': True,
                'results': {
                    'users_sync': None,
                    'jobs_sync': None,
                    'metrics_generated': None,
                },
                'message': message,
                'timestamp': datetime.now().isoformat(),
            }

        results = {
            'users_sync': self.sync_users_data(),
            'jobs_sync': self.sync_jobs_data(),
            'metrics_generated': self.generate_business_metrics()
        }
        
        success = all(results.values())
        
        logger.info(f"📊 Sync results: {results}")
        
        return {
            'success': success,
            'results': results,
            'timestamp': datetime.now().isoformat()
        }

@scheduler_bp.route('/cron/bigquery-sync', methods=['POST'])
def bigquery_sync():
    """Cloud Scheduler endpoint for BigQuery sync"""
    
    # Verify request is from Cloud Scheduler
    if not request.headers.get('X-Appengine-Cron'):
        logger.warning("Unauthorized sync request")
        return jsonify({'error': 'Unauthorized'}), 401
    
    try:
        syncer = CloudSchedulerBigQuerySync()
        result = syncer.run_full_sync()
        
        if result['success']:
            logger.info("🎉 Scheduled sync completed successfully")
            return jsonify(result), 200
        else:
            logger.error("⚠️ Scheduled sync completed with errors")
            return jsonify(result), 500
            
    except Exception as e:
        logger.error(f"❌ Scheduled sync failed: {e}")
        return jsonify({
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@scheduler_bp.route('/cron/health', methods=['GET'])
def cron_health():
    """Health check for scheduled jobs"""
    return jsonify({
        'status': 'healthy',
        'service': 'cloud-scheduler-sync',
        'timestamp': datetime.now().isoformat()
    }), 200