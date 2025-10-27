from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import Schema, fields, validate, ValidationError
from app.utils.security import rate_limit, require_auth
from app.utils.analytics_dashboard import (
    AnalyticsDashboardManager, CraftsmanDashboard, CustomerHistoryAnalytics,
    TrendAnalytics, PerformanceReports, CostCalculator, BusinessMetrics,
    AnalyticsDashboardConstants
)
from app.models.user import User
from app.models.quote import Quote, QuoteStatus
from app.models.job import Job, JobStatus
from app.models.message import Message
from app import db
from datetime import datetime, timedelta
import json

analytics_dashboard_bp = Blueprint('analytics_dashboard', __name__)

# Validation Schemas
class DashboardQuerySchema(Schema):
    days = fields.Integer(missing=30, validate=validate.Range(min=1, max=365))
    user_type = fields.String(missing=None, validate=validate.OneOf(['customer', 'craftsman', 'admin']))

class CustomReportSchema(Schema):
    start_date = fields.DateTime(required=True)
    end_date = fields.DateTime(required=True)
    metrics = fields.List(fields.String(), missing=[])
    export_format = fields.String(missing='json', validate=validate.OneOf(['json', 'csv', 'pdf', 'excel']))

class CostCalculationSchema(Schema):
    category = fields.String(required=True)
    estimated_hours = fields.Float(required=True, validate=validate.Range(min=0.1, max=1000))
    materials_cost = fields.Float(missing=0, validate=validate.Range(min=0))
    area_type = fields.String(missing='other')
    urgency = fields.String(missing='normal', validate=validate.OneOf(['low', 'normal', 'high', 'urgent', 'emergency']))
    complexity_score = fields.Integer(missing=5, validate=validate.Range(min=1, max=10))
    location_factor = fields.Float(missing=1.0, validate=validate.Range(min=0.5, max=2.0))
    craftsman_experience = fields.Integer(missing=1, validate=validate.Range(min=0, max=50))

class MarketComparisonSchema(Schema):
    category = fields.String(required=True)
    city = fields.String(missing=None)
    days = fields.Integer(missing=90, validate=validate.Range(min=7, max=365))

# Dashboard Routes
@analytics_dashboard_bp.route('/dashboard', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=100, window_minutes=60)
def get_dashboard():
    """Get comprehensive dashboard data"""
    try:
        schema = DashboardQuerySchema()
        args = schema.load(request.args)
        
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Override user_type if provided and user is admin
        user_type = args.get('user_type') or user.user_type
        if user.user_type != 'admin' and args.get('user_type'):
            user_type = user.user_type  # Non-admin users can only see their own type
        
        dashboard_data = AnalyticsDashboardManager.get_dashboard_data(
            user_id=user_id,
            user_type=user_type,
            days=args['days']
        )
        
        return jsonify({
            'success': True,
            'data': dashboard_data
        })
        
    except ValidationError as e:
        return jsonify({'error': 'Validation error', 'details': e.messages}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/craftsman/<int:craftsman_id>/overview', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=50, window_minutes=60)
def get_craftsman_overview(craftsman_id):
    """Get craftsman overview metrics"""
    try:
        days = request.args.get('days', 30, type=int)
        
        # Check authorization
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type not in ['admin'] and current_user_id != craftsman_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        overview = CraftsmanDashboard.get_craftsman_overview(craftsman_id, days)
        trends = CraftsmanDashboard.get_craftsman_performance_trends(craftsman_id, min(days * 3, 90))
        categories = CraftsmanDashboard.get_craftsman_top_categories(craftsman_id, days)
        
        return jsonify({
            'success': True,
            'data': {
                'overview': overview,
                'trends': trends,
                'top_categories': categories
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/customer/<int:customer_id>/history', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=50, window_minutes=60)
def get_customer_history(customer_id):
    """Get customer history analytics"""
    try:
        days = request.args.get('days', 30, type=int)
        
        # Check authorization
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type not in ['admin'] and current_user_id != customer_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        overview = CustomerHistoryAnalytics.get_customer_overview(customer_id, days)
        spending_trends = CustomerHistoryAnalytics.get_customer_spending_trends(customer_id, min(days * 3, 180))
        preferred_categories = CustomerHistoryAnalytics.get_customer_preferred_categories(customer_id)
        
        return jsonify({
            'success': True,
            'data': {
                'overview': overview,
                'spending_trends': spending_trends,
                'preferred_categories': preferred_categories
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Trend Analysis Routes
@analytics_dashboard_bp.route('/trends/platform', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=30, window_minutes=60)
def get_platform_trends():
    """Get platform-wide trends"""
    try:
        days = request.args.get('days', 30, type=int)
        
        # Only admin users can access platform trends
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type != 'admin':
            return jsonify({'error': 'Admin access required'}), 403
        
        trends = TrendAnalytics.get_platform_trends(days)
        category_trends = TrendAnalytics.get_category_trends(days)
        geographic_trends = TrendAnalytics.get_geographic_trends(days)
        
        return jsonify({
            'success': True,
            'data': {
                'platform_trends': trends,
                'category_trends': category_trends,
                'geographic_trends': geographic_trends
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/trends/categories', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=50, window_minutes=60)
def get_category_trends():
    """Get category trends"""
    try:
        days = request.args.get('days', 30, type=int)
        
        trends = TrendAnalytics.get_category_trends(days)
        
        return jsonify({
            'success': True,
            'data': trends
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/trends/geographic', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=50, window_minutes=60)
def get_geographic_trends():
    """Get geographic trends"""
    try:
        days = request.args.get('days', 30, type=int)
        
        trends = TrendAnalytics.get_geographic_trends(days)
        
        return jsonify({
            'success': True,
            'data': trends
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Performance Reports Routes
@analytics_dashboard_bp.route('/reports/custom', methods=['POST'])
@jwt_required()
@rate_limit(max_requests=20, window_minutes=60)
def generate_custom_report():
    """Generate custom performance report"""
    try:
        schema = CustomReportSchema()
        data = schema.load(request.json)
        
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        report = AnalyticsDashboardManager.generate_custom_report(
            user_id=user_id,
            user_type=user.user_type,
            start_date=data['start_date'],
            end_date=data['end_date'],
            metrics=data['metrics']
        )
        
        return jsonify({
            'success': True,
            'data': report
        })
        
    except ValidationError as e:
        return jsonify({'error': 'Validation error', 'details': e.messages}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/reports/craftsman/<int:craftsman_id>', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=30, window_minutes=60)
def get_craftsman_report(craftsman_id):
    """Get detailed craftsman performance report"""
    try:
        # Date range parameters
        start_date_str = request.args.get('start_date')
        end_date_str = request.args.get('end_date')
        
        if start_date_str and end_date_str:
            start_date = datetime.fromisoformat(start_date_str)
            end_date = datetime.fromisoformat(end_date_str)
        else:
            end_date = datetime.utcnow()
            start_date = end_date - timedelta(days=30)
        
        # Check authorization
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type not in ['admin'] and current_user_id != craftsman_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        report = PerformanceReports.generate_craftsman_report(craftsman_id, start_date, end_date)
        
        return jsonify({
            'success': True,
            'data': report
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/reports/customer/<int:customer_id>', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=30, window_minutes=60)
def get_customer_report(customer_id):
    """Get detailed customer behavior report"""
    try:
        # Date range parameters
        start_date_str = request.args.get('start_date')
        end_date_str = request.args.get('end_date')
        
        if start_date_str and end_date_str:
            start_date = datetime.fromisoformat(start_date_str)
            end_date = datetime.fromisoformat(end_date_str)
        else:
            end_date = datetime.utcnow()
            start_date = end_date - timedelta(days=30)
        
        # Check authorization
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type not in ['admin'] and current_user_id != customer_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        report = PerformanceReports.generate_customer_report(customer_id, start_date, end_date)
        
        return jsonify({
            'success': True,
            'data': report
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Cost Calculator Routes
@analytics_dashboard_bp.route('/cost-calculator', methods=['POST'])
@jwt_required()
@rate_limit(max_requests=100, window_minutes=60)
def calculate_job_cost():
    """Calculate job cost estimation"""
    try:
        schema = CostCalculationSchema()
        data = schema.load(request.json)
        
        cost_estimation = CostCalculator.calculate_job_cost(**data)
        
        return jsonify({
            'success': True,
            'data': cost_estimation
        })
        
    except ValidationError as e:
        return jsonify({'error': 'Validation error', 'details': e.messages}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/cost-calculator/market-comparison', methods=['POST'])
@jwt_required()
@rate_limit(max_requests=50, window_minutes=60)
def get_market_comparison():
    """Get market price comparison"""
    try:
        schema = MarketComparisonSchema()
        data = schema.load(request.json)
        
        comparison = CostCalculator.get_market_price_comparison(**data)
        
        return jsonify({
            'success': True,
            'data': comparison
        })
        
    except ValidationError as e:
        return jsonify({'error': 'Validation error', 'details': e.messages}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/cost-calculator/pricing-recommendations/<int:craftsman_id>', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=30, window_minutes=60)
def get_pricing_recommendations(craftsman_id):
    """Get pricing recommendations for craftsman"""
    try:
        category = request.args.get('category', required=True)
        
        # Check authorization
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type not in ['admin'] and current_user_id != craftsman_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        recommendations = CostCalculator.get_pricing_recommendations(craftsman_id, category)
        
        return jsonify({
            'success': True,
            'data': recommendations
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Business Metrics Routes
@analytics_dashboard_bp.route('/business/conversion-funnel', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=30, window_minutes=60)
def get_conversion_funnel():
    """Get conversion funnel metrics"""
    try:
        # Only admin users can access business metrics
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type != 'admin':
            return jsonify({'error': 'Admin access required'}), 403
        
        days = request.args.get('days', 30, type=int)
        funnel = BusinessMetrics.get_conversion_funnel(days)
        
        return jsonify({
            'success': True,
            'data': funnel
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/business/revenue', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=30, window_minutes=60)
def get_revenue_analytics():
    """Get detailed revenue analytics"""
    try:
        # Only admin users can access business metrics
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type != 'admin':
            return jsonify({'error': 'Admin access required'}), 403
        
        days = request.args.get('days', 30, type=int)
        revenue_data = BusinessMetrics.get_revenue_analytics(days)
        
        return jsonify({
            'success': True,
            'data': revenue_data
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analytics_dashboard_bp.route('/business/engagement', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=30, window_minutes=60)
def get_engagement_metrics():
    """Get user engagement metrics"""
    try:
        # Only admin users can access business metrics
        current_user_id = get_jwt_identity()
        current_user = User.query.get(current_user_id)
        
        if current_user.user_type != 'admin':
            return jsonify({'error': 'Admin access required'}), 403
        
        days = request.args.get('days', 30, type=int)
        engagement = BusinessMetrics.get_user_engagement_metrics(days)
        
        return jsonify({
            'success': True,
            'data': engagement
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Activity and Recent Data Routes
@analytics_dashboard_bp.route('/activity/recent', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=100, window_minutes=60)
def get_recent_activity():
    """Get recent activity for user"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        limit = request.args.get('limit', 20, type=int)
        
        if user.user_type == 'craftsman':
            activity = CraftsmanDashboard.get_craftsman_recent_activity(user_id, limit)
        else:
            # For customers, we could implement a similar method
            activity = []
        
        return jsonify({
            'success': True,
            'data': activity
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Analytics Constants Routes
@analytics_dashboard_bp.route('/constants', methods=['GET'])
@rate_limit(max_requests=10, window_minutes=60)
def get_analytics_constants():
    """Get analytics dashboard constants"""
    try:
        return jsonify({
            'success': True,
            'data': {
                'refresh_intervals': AnalyticsDashboardConstants.DASHBOARD_REFRESH_INTERVALS,
                'metric_categories': AnalyticsDashboardConstants.METRIC_CATEGORIES,
                'chart_colors': AnalyticsDashboardConstants.CHART_COLORS,
                'default_periods': AnalyticsDashboardConstants.DEFAULT_PERIODS,
                'export_formats': AnalyticsDashboardConstants.EXPORT_FORMATS,
                'kpi_thresholds': AnalyticsDashboardConstants.KPI_THRESHOLDS,
                'benchmark_categories': AnalyticsDashboardConstants.BENCHMARK_CATEGORIES,
                'cost_calculator': {
                    'base_rates': CostCalculator.BASE_RATES,
                    'area_factors': CostCalculator.AREA_FACTORS,
                    'urgency_multipliers': CostCalculator.URGENCY_MULTIPLIERS
                }
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Performance Comparison Routes
@analytics_dashboard_bp.route('/performance/compare', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=20, window_minutes=60)
def compare_performance():
    """Compare user performance against benchmarks"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        days = request.args.get('days', 30, type=int)
        category = request.args.get('category')
        
        if user.user_type == 'craftsman':
            # Get craftsman's performance
            overview = CraftsmanDashboard.get_craftsman_overview(user_id, days)
            
            # Get market benchmarks
            if category:
                market_comparison = CostCalculator.get_market_price_comparison(category, days=days)
                pricing_recommendations = CostCalculator.get_pricing_recommendations(user_id, category)
            else:
                market_comparison = None
                pricing_recommendations = None
            
            return jsonify({
                'success': True,
                'data': {
                    'user_performance': overview,
                    'market_comparison': market_comparison,
                    'pricing_recommendations': pricing_recommendations,
                    'benchmarks': AnalyticsDashboardConstants.KPI_THRESHOLDS
                }
            })
        else:
            return jsonify({'error': 'Performance comparison only available for craftsmen'}), 400
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Export Routes
@analytics_dashboard_bp.route('/export/dashboard', methods=['POST'])
@jwt_required()
@rate_limit(max_requests=10, window_minutes=60)
def export_dashboard():
    """Export dashboard data"""
    try:
        export_format = request.json.get('format', 'json')
        days = request.json.get('days', 30)
        
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        dashboard_data = AnalyticsDashboardManager.get_dashboard_data(
            user_id=user_id,
            user_type=user.user_type,
            days=days
        )
        
        if export_format == 'json':
            return jsonify({
                'success': True,
                'data': dashboard_data,
                'export_info': {
                    'format': 'json',
                    'generated_at': datetime.utcnow().isoformat(),
                    'user_id': user_id,
                    'period_days': days
                }
            })
        else:
            # For other formats (CSV, PDF, Excel), you would implement specific exporters
            return jsonify({
                'success': False,
                'error': f'Export format {export_format} not yet implemented'
            }), 501
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Real-time Metrics Routes
@analytics_dashboard_bp.route('/realtime/metrics', methods=['GET'])
@jwt_required()
@rate_limit(max_requests=200, window_minutes=60)
def get_realtime_metrics():
    """Get real-time dashboard metrics"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Get quick metrics for real-time updates
        if user.user_type == 'craftsman':
            # Quick craftsman metrics
            pending_quotes = Quote.query.filter(
                Quote.craftsman_id == user_id,
                Quote.status == QuoteStatus.PENDING
            ).count()
            
            active_jobs = Job.query.filter(
                Job.craftsman_id == user_id,
                Job.status == JobStatus.IN_PROGRESS
            ).count()
            
            unread_messages = Message.query.filter(
                Message.receiver_id == user_id,
                Message.is_read == False
            ).count()
            
            metrics = {
                'pending_quotes': pending_quotes,
                'active_jobs': active_jobs,
                'unread_messages': unread_messages
            }
        
        elif user.user_type == 'customer':
            # Quick customer metrics
            pending_requests = Quote.query.filter(
                Quote.customer_id == user_id,
                Quote.status == QuoteStatus.PENDING
            ).count()
            
            active_jobs = Job.query.filter(
                Job.customer_id == user_id,
                Job.status.in_([JobStatus.IN_PROGRESS, JobStatus.ACCEPTED])
            ).count()
            
            unread_messages = Message.query.filter(
                Message.receiver_id == user_id,
                Message.is_read == False
            ).count()
            
            metrics = {
                'pending_requests': pending_requests,
                'active_jobs': active_jobs,
                'unread_messages': unread_messages
            }
        
        else:  # admin
            # Quick platform metrics
            total_users = User.query.count()
            active_jobs = Job.query.filter(Job.status == JobStatus.IN_PROGRESS).count()
            pending_quotes = Quote.query.filter(Quote.status == QuoteStatus.PENDING).count()
            
            metrics = {
                'total_users': total_users,
                'active_jobs': active_jobs,
                'pending_quotes': pending_quotes
            }
        
        return jsonify({
            'success': True,
            'data': {
                'metrics': metrics,
                'timestamp': datetime.utcnow().isoformat(),
                'user_type': user.user_type
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Analytics Health Check
@analytics_dashboard_bp.route('/health', methods=['GET'])
@rate_limit(max_requests=50, window_minutes=60)
def analytics_health_check():
    """Health check for analytics dashboard"""
    try:
        # Basic database connectivity check
        user_count = User.query.count()
        quote_count = Quote.query.count()
        job_count = Job.query.count()
        
        return jsonify({
            'success': True,
            'data': {
                'status': 'healthy',
                'database_connected': True,
                'total_users': user_count,
                'total_quotes': quote_count,
                'total_jobs': job_count,
                'timestamp': datetime.utcnow().isoformat()
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'data': {
                'status': 'unhealthy',
                'error': str(e),
                'timestamp': datetime.utcnow().isoformat()
            }
        }), 500