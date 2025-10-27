from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.utils.validators import ResponseHelper
from app.utils.analytics import (
    AnalyticsTracker,
    BusinessMetrics,
    PerformanceMonitor,
    UserBehaviorAnalytics,
    CostCalculator,
    DashboardData,
)
from app.utils.security import rate_limit, require_auth
from app.models.user import User
from app.models.quote import Quote
from app.models.message import Message
from datetime import datetime, timedelta
from sqlalchemy import func, and_
import logging

analytics_bp = Blueprint('analytics', __name__, url_prefix='/api/analytics')

@analytics_bp.route('/track', methods=['POST'])
@rate_limit(max_requests=100, window_minutes=1)
@require_auth
def track_event():
    """Track user analytics event"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        action = data.get('action')
        details = data.get('details', {})
        page = data.get('page')
        
        if not action:
            return ResponseHelper.error('Action is required', 'MISSING_ACTION'), 400
        
        AnalyticsTracker.track_user_action(user_id, action, details, page)
        
        return ResponseHelper.success({'message': 'Event tracked successfully'})
        
    except Exception as e:
        return ResponseHelper.error('Failed to track event', 'TRACKING_ERROR'), 500

@analytics_bp.route('/dashboard/overview', methods=['GET'])
@rate_limit(max_requests=30, window_minutes=1)
@require_auth
def get_dashboard_overview():
    """Get platform overview for dashboard"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        # Check if user has access to analytics (admin or craftsman for their own data)
        if not user:
            return ResponseHelper.error('User not found', 'USER_NOT_FOUND'), 404
        
        user_type = getattr(user.user_type, 'value', user.user_type)

        if user_type == 'craftsman':
            # Craftsman gets their own metrics
            metrics = BusinessMetrics.get_craftsman_metrics(user.craftsman.id)
            if not metrics:
                return ResponseHelper.error('Craftsman metrics not found', 'METRICS_NOT_FOUND'), 404

            return ResponseHelper.success({'metrics': metrics})

        elif user_type == 'customer':
            # Customer gets their own metrics
            metrics = BusinessMetrics.get_customer_metrics(user.customer.id)
            if not metrics:
                return ResponseHelper.error('Customer metrics not found', 'METRICS_NOT_FOUND'), 404
            
            return ResponseHelper.success({'metrics': metrics})
        
        else:
            # Admin gets platform overview
            overview = BusinessMetrics.get_platform_overview()
            return ResponseHelper.success({'overview': overview})
        
    except Exception as e:
        return ResponseHelper.error('Failed to get dashboard data', 'DASHBOARD_ERROR'), 500

@analytics_bp.route('/trends', methods=['GET'])
@rate_limit(max_requests=20, window_minutes=1)
def get_trend_analysis():
    """Get platform trend analysis (public data)"""
    try:
        trends = BusinessMetrics.get_trend_analysis()
        return ResponseHelper.success({'trends': trends})
        
    except Exception as e:
        return ResponseHelper.error('Failed to get trends', 'TRENDS_ERROR'), 500

@analytics_bp.route('/cost-estimate', methods=['POST'])
@rate_limit(max_requests=50, window_minutes=1)
def estimate_cost():
    """Estimate job cost based on parameters"""
    try:
        data = request.get_json()
        
        category = data.get('category')
        area_type = data.get('area_type')
        square_meters = data.get('square_meters')
        complexity = data.get('complexity', 'orta')
        city = data.get('city', 'İstanbul')
        
        if not category or not area_type:
            return ResponseHelper.error('Category and area type are required', 'MISSING_FIELDS'), 400
        
        estimate = CostCalculator.estimate_job_cost(
            category=category,
            area_type=area_type,
            square_meters=square_meters,
            complexity=complexity,
            city=city
        )
        
        return ResponseHelper.success({'estimate': estimate})
        
    except Exception as e:
        return ResponseHelper.error('Failed to estimate cost', 'ESTIMATION_ERROR'), 500

@analytics_bp.route('/performance', methods=['GET'])
@rate_limit(max_requests=10, window_minutes=1)
@require_auth
def get_performance_metrics():
    """Get API performance metrics (admin only)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        # Check admin access (implement admin role checking)
        if not user or not getattr(user, 'is_admin', False):
            return ResponseHelper.error('Admin access required', 'ADMIN_REQUIRED'), 403
        
        hours = request.args.get('hours', 24, type=int)
        performance = PerformanceMonitor.get_performance_report(hours)
        
        return ResponseHelper.success({'performance': performance})
        
    except Exception as e:
        return ResponseHelper.error('Failed to get performance metrics', 'PERFORMANCE_ERROR'), 500

@analytics_bp.route('/user-behavior', methods=['GET'])
@rate_limit(max_requests=10, window_minutes=1)
@require_auth
def get_user_behavior():
    """Get user behavior analytics (admin only)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or not getattr(user, 'is_admin', False):
            return ResponseHelper.error('Admin access required', 'ADMIN_REQUIRED'), 403
        
        journey = UserBehaviorAnalytics.get_user_journey_analysis()
        search_analytics = UserBehaviorAnalytics.get_search_analytics()
        
        return ResponseHelper.success({
            'user_journey': journey,
            'search_analytics': search_analytics
        })
        
    except Exception as e:
        return ResponseHelper.error('Failed to get user behavior data', 'BEHAVIOR_ERROR'), 500

@analytics_bp.route('/live-stats', methods=['GET'])
@rate_limit(max_requests=30, window_minutes=1)
@require_auth
def get_live_stats():
    """Get live platform statistics"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return ResponseHelper.error('User not found', 'USER_NOT_FOUND'), 404
        
        # Different data based on user type
        user_type = getattr(user.user_type, 'value', user.user_type)

        if user_type == 'craftsman':
            # Craftsman gets their live stats
            live_data = {
                'pending_quotes': Quote.query.filter_by(
                    craftsman_id=user.craftsman.id,
                    status='PENDING'
                ).count(),
                'unread_messages': Message.query.filter_by(
                    recipient_id=user_id,
                    is_read=False
                ).count()
            }
        else:
            # Customer gets their live stats
            live_data = {
                'active_quotes': Quote.query.filter_by(
                    customer_id=user.customer.id
                ).filter(Quote.status.in_(['PENDING', 'QUOTED', 'DETAILS_REQUESTED'])).count(),
                'unread_messages': Message.query.filter_by(
                    recipient_id=user_id,
                    is_read=False
                ).count()
            }
        
        # Add general live stats
        general_stats = DashboardData.get_live_stats()
        live_data.update(general_stats)
        
        return ResponseHelper.success({'live_stats': live_data})
        
    except Exception as e:
        return ResponseHelper.error('Failed to get live stats', 'LIVE_STATS_ERROR'), 500

@analytics_bp.route('/export', methods=['GET'])
@rate_limit(max_requests=5, window_minutes=60)  # Very limited for export
@require_auth
def export_analytics():
    """Export analytics data (admin only)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or not getattr(user, 'is_admin', False):
            return ResponseHelper.error('Admin access required', 'ADMIN_REQUIRED'), 403
        
        export_type = request.args.get('type', 'overview')
        date_from = request.args.get('from')
        date_to = request.args.get('to')
        
        # Generate export data based on type
        if export_type == 'overview':
            data = BusinessMetrics.get_platform_overview()
        elif export_type == 'trends':
            data = BusinessMetrics.get_trend_analysis()
        elif export_type == 'performance':
            hours = request.args.get('hours', 168, type=int)  # 1 week default
            data = PerformanceMonitor.get_performance_report(hours)
        else:
            return ResponseHelper.error('Invalid export type', 'INVALID_EXPORT_TYPE'), 400
        
        return ResponseHelper.success({
            'export_data': data,
            'export_type': export_type,
            'generated_at': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        return ResponseHelper.error('Failed to export data', 'EXPORT_ERROR'), 500