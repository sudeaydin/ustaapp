"""
Enhanced Analytics API Endpoints for ustam App
Provides comprehensive business intelligence and real-time analytics
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime, timedelta
import logging
from typing import Dict, List, Any, Optional
import json
import os

try:  # Optional BigQuery dependency
    from google.cloud import bigquery  # type: ignore
    _BIGQUERY_IMPORT_ERROR = None
except ImportError as import_error:  # pragma: no cover - optional dependency missing
    bigquery = None  # type: ignore
    _BIGQUERY_IMPORT_ERROR = import_error

from app.utils.auth_utils import require_auth, require_admin
from app.utils.bigquery_logger import bigquery_logger, log_performance

# Configure logging
logger = logging.getLogger(__name__)

# Create blueprint
enhanced_analytics_bp = Blueprint('enhanced_analytics', __name__, url_prefix='/api/analytics/v2')

class AnalyticsService:
    """Enhanced analytics service with BigQuery integration"""
    
    def __init__(self):
        self.project_id = os.environ.get('BIGQUERY_PROJECT_ID', 'ustam-analytics')
        self.dataset_id = "ustam_analytics"
        self.client = None
        self._initialize_client()

    def _initialize_client(self):
        """Initialize BigQuery client"""
        if bigquery is None:
            logger.info(
                "Enhanced analytics BigQuery integration disabled: %s",
                _BIGQUERY_IMPORT_ERROR or "google-cloud-bigquery not installed",
            )
            self.client = None
            return

        try:
            self.client = bigquery.Client(project=self.project_id)
            logger.info(f"Analytics service initialized for project: {self.project_id}")
        except Exception as e:  # pragma: no cover - depends on external services
            logger.error(f"Failed to initialize BigQuery client: {e}")
            self.client = None

    def execute_query(self, query: str) -> List[Dict[str, Any]]:
        """Execute BigQuery query and return results"""
        try:
            if not self.client:
                logger.info("Skipping BigQuery query; client not initialized.")
                return []
            
            job = self.client.query(query)
            results = []
            
            for row in job:
                # Convert BigQuery row to dictionary
                row_dict = {}
                for key, value in row.items():
                    if isinstance(value, datetime):
                        row_dict[key] = value.isoformat()
                    else:
                        row_dict[key] = value
                results.append(row_dict)
            
            return results
        except Exception as e:
            logger.error(f"BigQuery query failed: {e}")
            return []
    
    def get_realtime_dashboard(self) -> Dict[str, Any]:
        """Get real-time dashboard metrics"""
        query = f"""
        WITH 
        -- Current metrics (last 24 hours)
        current_metrics AS (
          SELECT
            COUNT(DISTINCT user_id) as active_users,
            COUNT(*) as total_actions,
            AVG(duration_ms) as avg_response_time,
            SUM(CASE WHEN success = true THEN 1 ELSE 0 END) / COUNT(*) as success_rate
          FROM `{self.project_id}.{self.dataset_id}.user_activity_logs`
          WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
        ),
        
        -- Error metrics (last 24 hours)
        error_metrics AS (
          SELECT
            COUNT(*) as total_errors,
            COUNT(DISTINCT user_id) as affected_users,
            COUNT(CASE WHEN error_level = 'CRITICAL' THEN 1 END) as critical_errors
          FROM `{self.project_id}.{self.dataset_id}.error_logs`
          WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
        ),
        
        -- Payment metrics (today)
        payment_metrics AS (
          SELECT
            COUNT(*) as total_transactions,
            COALESCE(SUM(amount), 0) as total_revenue,
            COALESCE(SUM(platform_fee), 0) as platform_fees,
            COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful_payments
          FROM `{self.project_id}.{self.dataset_id}.payment_analytics`
          WHERE DATE(created_at) = CURRENT_DATE()
        ),
        
        -- Search metrics (last 24 hours)
        search_metrics AS (
          SELECT
            COUNT(*) as total_searches,
            AVG(results_count) as avg_results_count,
            COUNT(CASE WHEN clicked_result_id IS NOT NULL THEN 1 END) / COUNT(*) as click_through_rate
          FROM `{self.project_id}.{self.dataset_id}.search_analytics`
          WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
        )
        
        SELECT
          CURRENT_TIMESTAMP() as last_updated,
          cm.active_users,
          cm.total_actions,
          cm.avg_response_time,
          cm.success_rate,
          em.total_errors,
          em.affected_users,
          em.critical_errors,
          pm.total_transactions,
          pm.total_revenue,
          pm.platform_fees,
          pm.successful_payments,
          sm.total_searches,
          sm.avg_results_count,
          sm.click_through_rate
        FROM current_metrics cm
        CROSS JOIN error_metrics em
        CROSS JOIN payment_metrics pm
        CROSS JOIN search_metrics sm
        """
        
        results = self.execute_query(query)
        return results[0] if results else {}
    
    def get_business_kpis(self, days: int = 30) -> Dict[str, Any]:
        """Get key business performance indicators"""
        query = f"""
        WITH date_range AS (
          SELECT DATE_SUB(CURRENT_DATE(), INTERVAL {days} DAY) as start_date,
                 CURRENT_DATE() as end_date
        ),
        
        user_metrics AS (
          SELECT
            COUNT(DISTINCT u.id) as total_users,
            COUNT(DISTINCT CASE WHEN u.is_active = true THEN u.id END) as active_users,
            COUNT(DISTINCT CASE WHEN DATE(u.created_at) >= dr.start_date THEN u.id END) as new_users,
            COUNT(DISTINCT CASE WHEN u.user_type = 'customer' THEN u.id END) as total_customers,
            COUNT(DISTINCT CASE WHEN u.user_type = 'craftsman' THEN u.id END) as total_craftsmen
          FROM users u
          CROSS JOIN date_range dr
        ),
        
        job_metrics AS (
          SELECT
            COUNT(*) as total_jobs,
            COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_jobs,
            COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_jobs,
            COUNT(CASE WHEN DATE(created_at) >= dr.start_date THEN 1 END) as new_jobs
          FROM jobs j
          CROSS JOIN date_range dr
        ),
        
        payment_metrics AS (
          SELECT
            COALESCE(SUM(amount), 0) as total_revenue,
            COALESCE(SUM(platform_fee), 0) as platform_fees,
            COUNT(*) as total_transactions,
            AVG(amount) as avg_transaction_value
          FROM payments p
          CROSS JOIN date_range dr
          WHERE p.status = 'completed'
          AND DATE(p.created_at) >= dr.start_date
        ),
        
        review_metrics AS (
          SELECT
            COUNT(*) as total_reviews,
            AVG(rating) as avg_rating
          FROM reviews r
          CROSS JOIN date_range dr
          WHERE DATE(r.created_at) >= dr.start_date
        )
        
        SELECT
          um.*,
          jm.*,
          pm.*,
          rm.*,
          CASE 
            WHEN jm.total_jobs > 0 
            THEN jm.completed_jobs / jm.total_jobs 
            ELSE 0 
          END as completion_rate,
          CURRENT_TIMESTAMP() as calculated_at
        FROM user_metrics um
        CROSS JOIN job_metrics jm
        CROSS JOIN payment_metrics pm
        CROSS JOIN review_metrics rm
        """
        
        results = self.execute_query(query)
        return results[0] if results else {}
    
    def get_hourly_trends(self, hours: int = 24) -> List[Dict[str, Any]]:
        """Get hourly trend data"""
        query = f"""
        SELECT
          DATETIME_TRUNC(DATETIME(timestamp, 'Europe/Istanbul'), HOUR) as hour_tr,
          COUNT(DISTINCT user_id) as unique_users,
          COUNT(*) as total_actions,
          AVG(duration_ms) as avg_response_time,
          SUM(CASE WHEN success = true THEN 1 ELSE 0 END) / COUNT(*) as success_rate,
          COUNT(CASE WHEN action_category = 'auth' THEN 1 END) as auth_actions,
          COUNT(CASE WHEN action_category = 'job' THEN 1 END) as job_actions,
          COUNT(CASE WHEN action_category = 'payment' THEN 1 END) as payment_actions
        FROM `{self.project_id}.{self.dataset_id}.user_activity_logs`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {hours} HOUR)
        GROUP BY hour_tr
        ORDER BY hour_tr DESC
        """
        
        return self.execute_query(query)
    
    def get_user_funnel_analysis(self, days: int = 30) -> Dict[str, Any]:
        """Get user conversion funnel analysis"""
        query = f"""
        WITH user_journey AS (
          SELECT
            user_id,
            MIN(CASE WHEN action_type = 'register' THEN timestamp END) as registered_at,
            MIN(CASE WHEN action_type = 'login' THEN timestamp END) as first_login_at,
            MIN(CASE WHEN action_category = 'job' AND action_type != 'view' THEN timestamp END) as first_job_action_at,
            MIN(CASE WHEN action_category = 'payment' THEN timestamp END) as first_payment_at,
            COUNT(DISTINCT DATE(timestamp)) as active_days
          FROM `{self.project_id}.{self.dataset_id}.user_activity_logs`
          WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
          GROUP BY user_id
        )
        SELECT
          COUNT(*) as total_users,
          COUNT(first_login_at) as logged_in_users,
          COUNT(first_job_action_at) as job_active_users,
          COUNT(first_payment_at) as paying_users,
          AVG(active_days) as avg_active_days,
          COUNT(first_login_at) / COUNT(*) as login_conversion_rate,
          COUNT(first_job_action_at) / COUNT(*) as job_conversion_rate,
          COUNT(first_payment_at) / COUNT(*) as payment_conversion_rate
        FROM user_journey
        """
        
        results = self.execute_query(query)
        return results[0] if results else {}
    
    def get_platform_performance(self, days: int = 7) -> List[Dict[str, Any]]:
        """Get platform performance comparison"""
        query = f"""
        SELECT
          platform,
          COUNT(DISTINCT user_id) as unique_users,
          COUNT(*) as total_actions,
          AVG(duration_ms) as avg_response_time,
          SUM(CASE WHEN success = true THEN 1 ELSE 0 END) / COUNT(*) as success_rate,
          COUNT(CASE WHEN action_category = 'payment' THEN 1 END) as payment_actions
        FROM `{self.project_id}.{self.dataset_id}.user_activity_logs`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
        GROUP BY platform
        ORDER BY unique_users DESC
        """
        
        return self.execute_query(query)
    
    def get_revenue_trends(self, days: int = 30) -> List[Dict[str, Any]]:
        """Get revenue trend analysis"""
        query = f"""
        SELECT
          DATE(created_at) as date,
          COUNT(*) as transaction_count,
          SUM(amount) as daily_revenue,
          SUM(platform_fee) as daily_fees,
          AVG(amount) as avg_transaction_value,
          COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful_transactions,
          COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_transactions
        FROM `{self.project_id}.{self.dataset_id}.payment_analytics`
        WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
        GROUP BY DATE(created_at)
        ORDER BY date DESC
        """
        
        return self.execute_query(query)
    
    def get_search_insights(self, days: int = 7) -> List[Dict[str, Any]]:
        """Get search behavior insights"""
        query = f"""
        SELECT
          search_type,
          COUNT(*) as total_searches,
          AVG(results_count) as avg_results,
          AVG(response_time_ms) as avg_response_time,
          COUNT(CASE WHEN clicked_result_id IS NOT NULL THEN 1 END) / COUNT(*) as click_through_rate,
          COUNT(DISTINCT user_id) as unique_searchers
        FROM `{self.project_id}.{self.dataset_id}.search_analytics`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
        GROUP BY search_type
        ORDER BY total_searches DESC
        """
        
        return self.execute_query(query)
    
    def get_error_analysis(self, days: int = 7) -> List[Dict[str, Any]]:
        """Get error analysis"""
        query = f"""
        SELECT
          DATE(timestamp) as date,
          error_type,
          error_level,
          COUNT(*) as error_count,
          COUNT(DISTINCT user_id) as affected_users,
          COUNT(DISTINCT session_id) as affected_sessions,
          SUM(CASE WHEN resolved = true THEN 1 ELSE 0 END) as resolved_errors
        FROM `{self.project_id}.{self.dataset_id}.error_logs`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
        GROUP BY DATE(timestamp), error_type, error_level
        ORDER BY date DESC, error_count DESC
        """
        
        return self.execute_query(query)
    
    def get_top_craftsmen(self, limit: int = 20) -> List[Dict[str, Any]]:
        """Get top performing craftsmen"""
        query = f"""
        SELECT
          c.user_id,
          u.first_name,
          u.last_name,
          c.business_name,
          c.average_rating,
          c.total_reviews,
          c.total_jobs,
          COALESCE(SUM(p.craftsman_amount), 0) as total_earnings,
          COUNT(DISTINCT j.id) as jobs_completed
        FROM craftsmen c
        JOIN users u ON c.user_id = u.id
        LEFT JOIN jobs j ON j.assigned_craftsman_id = c.id AND j.status = 'completed'
        LEFT JOIN payments p ON p.job_id = j.id AND p.status = 'completed'
        GROUP BY c.user_id, u.first_name, u.last_name, c.business_name, c.average_rating, c.total_reviews, c.total_jobs
        ORDER BY total_earnings DESC
        LIMIT {limit}
        """
        
        return self.execute_query(query)

# Initialize analytics service
analytics_service = AnalyticsService()

@enhanced_analytics_bp.route('/dashboard/realtime', methods=['GET'])
@require_admin
@log_performance
def get_realtime_dashboard():
    """Get real-time dashboard metrics"""
    try:
        data = analytics_service.get_realtime_dashboard()
        
        # Log analytics access
        bigquery_logger.log_user_activity(
            action_type='dashboard_view',
            action_category='analytics',
            user_id=g.current_user.id,
            success=True,
            action_details={'dashboard_type': 'realtime'}
        )
        
        return jsonify({
            'status': 'success',
            'data': data,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Real-time dashboard error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch real-time dashboard data'
        }), 500

@enhanced_analytics_bp.route('/kpis', methods=['GET'])
@require_admin
@log_performance
def get_business_kpis():
    """Get key business performance indicators"""
    try:
        days = request.args.get('days', 30, type=int)
        data = analytics_service.get_business_kpis(days)
        
        return jsonify({
            'status': 'success',
            'data': data,
            'period_days': days,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Business KPIs error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch business KPIs'
        }), 500

@enhanced_analytics_bp.route('/trends/hourly', methods=['GET'])
@require_admin
@log_performance
def get_hourly_trends():
    """Get hourly trend data"""
    try:
        hours = request.args.get('hours', 24, type=int)
        data = analytics_service.get_hourly_trends(hours)
        
        return jsonify({
            'status': 'success',
            'data': data,
            'hours': hours,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Hourly trends error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch hourly trends'
        }), 500

@enhanced_analytics_bp.route('/funnel', methods=['GET'])
@require_admin
@log_performance
def get_user_funnel():
    """Get user conversion funnel analysis"""
    try:
        days = request.args.get('days', 30, type=int)
        data = analytics_service.get_user_funnel_analysis(days)
        
        return jsonify({
            'status': 'success',
            'data': data,
            'period_days': days,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"User funnel error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch user funnel data'
        }), 500

@enhanced_analytics_bp.route('/platform-performance', methods=['GET'])
@require_admin
@log_performance
def get_platform_performance():
    """Get platform performance comparison"""
    try:
        days = request.args.get('days', 7, type=int)
        data = analytics_service.get_platform_performance(days)
        
        return jsonify({
            'status': 'success',
            'data': data,
            'period_days': days,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Platform performance error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch platform performance data'
        }), 500

@enhanced_analytics_bp.route('/revenue/trends', methods=['GET'])
@require_admin
@log_performance
def get_revenue_trends():
    """Get revenue trend analysis"""
    try:
        days = request.args.get('days', 30, type=int)
        data = analytics_service.get_revenue_trends(days)
        
        return jsonify({
            'status': 'success',
            'data': data,
            'period_days': days,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Revenue trends error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch revenue trends'
        }), 500

@enhanced_analytics_bp.route('/search/insights', methods=['GET'])
@require_admin
@log_performance
def get_search_insights():
    """Get search behavior insights"""
    try:
        days = request.args.get('days', 7, type=int)
        data = analytics_service.get_search_insights(days)
        
        return jsonify({
            'status': 'success',
            'data': data,
            'period_days': days,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Search insights error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch search insights'
        }), 500

@enhanced_analytics_bp.route('/errors/analysis', methods=['GET'])
@require_admin
@log_performance
def get_error_analysis():
    """Get error analysis"""
    try:
        days = request.args.get('days', 7, type=int)
        data = analytics_service.get_error_analysis(days)
        
        return jsonify({
            'status': 'success',
            'data': data,
            'period_days': days,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error analysis error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch error analysis'
        }), 500

@enhanced_analytics_bp.route('/craftsmen/top', methods=['GET'])
@require_admin
@log_performance
def get_top_craftsmen():
    """Get top performing craftsmen"""
    try:
        limit = request.args.get('limit', 20, type=int)
        data = analytics_service.get_top_craftsmen(limit)
        
        return jsonify({
            'status': 'success',
            'data': data,
            'limit': limit,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Top craftsmen error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch top craftsmen data'
        }), 500

@enhanced_analytics_bp.route('/export/csv', methods=['POST'])
@require_admin
@log_performance
def export_analytics_csv():
    """Export analytics data to CSV"""
    try:
        data = request.get_json()
        report_type = data.get('report_type')
        date_range = data.get('date_range', 30)
        
        # Generate CSV based on report type
        if report_type == 'revenue':
            analytics_data = analytics_service.get_revenue_trends(date_range)
        elif report_type == 'users':
            analytics_data = analytics_service.get_user_funnel_analysis(date_range)
        elif report_type == 'platform':
            analytics_data = analytics_service.get_platform_performance(date_range)
        else:
            return jsonify({
                'status': 'error',
                'message': 'Invalid report type'
            }), 400
        
        # Log export action
        bigquery_logger.log_user_activity(
            action_type='export',
            action_category='analytics',
            user_id=g.current_user.id,
            success=True,
            action_details={
                'report_type': report_type,
                'date_range': date_range,
                'record_count': len(analytics_data)
            }
        )
        
        return jsonify({
            'status': 'success',
            'data': analytics_data,
            'report_type': report_type,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Analytics export error: {e}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to export analytics data'
        }), 500

@enhanced_analytics_bp.route('/health', methods=['GET'])
def analytics_health_check():
    """Health check for analytics service"""
    try:
        # Test BigQuery connection
        if analytics_service.client:
            # Simple query to test connection
            test_query = f"SELECT 1 as test_value"
            results = analytics_service.execute_query(test_query)
            
            return jsonify({
                'status': 'healthy',
                'service': 'enhanced_analytics',
                'bigquery_connected': True,
                'project_id': analytics_service.project_id,
                'dataset_id': analytics_service.dataset_id,
                'timestamp': datetime.utcnow().isoformat()
            })
        else:
            return jsonify({
                'status': 'unhealthy',
                'service': 'enhanced_analytics',
                'bigquery_connected': False,
                'error': 'BigQuery client not initialized'
            }), 503
            
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'service': 'enhanced_analytics',
            'error': str(e)
        }), 503