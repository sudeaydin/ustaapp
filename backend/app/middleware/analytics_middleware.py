"""
Enhanced Analytics Middleware for ustam App
Automatically captures and logs all user interactions and system events
"""

# NOTE: This module is currently disabled.


import time
import uuid
import logging
from typing import Dict, Any, Optional
from flask import request, g, current_app, has_request_context, has_app_context
from functools import wraps

from app.utils.bigquery_logger import bigquery_logger

logger = logging.getLogger(__name__)

class AnalyticsMiddleware:
    """Enhanced analytics middleware for comprehensive data collection"""
    
    def __init__(self, app=None):
        self.app = app
        if app is not None:
            self.init_app(app)
    
    def init_app(self, app):
        """Initialize middleware with Flask app"""
        app.before_request(self.before_request)
        app.after_request(self.after_request)
        app.teardown_appcontext(self.teardown_request)
        
        # Register error handler
        app.errorhandler(Exception)(self.handle_exception)
        
        logger.info("Enhanced Analytics Middleware initialized")
    
    def before_request(self):
        """Capture request start metrics"""

        if not has_request_context():
            return

        g.start_time = time.time()
        g.request_id = str(uuid.uuid4())
        g.session_id = request.headers.get('X-Session-ID', str(uuid.uuid4()))
        g.user_agent = request.headers.get('User-Agent', '')
        g.ip_address = self._get_client_ip()
        g.platform = self._detect_platform()
        g.device_type = self._detect_device_type()
        
        # Track page views
        if request.endpoint and not request.endpoint.startswith('static'):
            self._log_page_view()
    
    def after_request(self, response):
        """Capture request completion metrics"""

        if not has_request_context():
            return response


        if hasattr(g, 'start_time'):
            duration_ms = int((time.time() - g.start_time) * 1000)
            
            # Log API request
            self._log_api_request(response, duration_ms)
            
            # Log business events based on endpoint
            self._log_business_events(response)
        
        return response
    
    def teardown_request(self, exception=None):
        """Clean up request context"""

        if not has_request_context():
            return

        if exception:
            self._log_request_exception(exception)
    
    def handle_exception(self, error):
        """Handle and log exceptions"""
        self._log_application_error(error)
        raise error
    
    def _get_client_ip(self) -> str:
        """Get real client IP address"""
        # Check for forwarded headers
        if request.headers.get('X-Forwarded-For'):
            return request.headers.get('X-Forwarded-For').split(',')[0].strip()
        elif request.headers.get('X-Real-IP'):
            return request.headers.get('X-Real-IP')
        else:
            return request.remote_addr or 'unknown'
    
    def _detect_platform(self) -> str:
        """Detect platform from user agent"""
        user_agent = g.user_agent.lower()
        
        if 'android' in user_agent:
            return 'android'
        elif 'iphone' in user_agent or 'ipad' in user_agent:
            return 'ios'
        elif 'mobile' in user_agent:
            return 'mobile_web'
        else:
            return 'web'
    
    def _detect_device_type(self) -> str:
        """Detect device type from user agent"""
        user_agent = g.user_agent.lower()
        
        if 'mobile' in user_agent or 'android' in user_agent or 'iphone' in user_agent:
            return 'mobile'
        elif 'tablet' in user_agent or 'ipad' in user_agent:
            return 'tablet'
        else:
            return 'desktop'
    
    def _log_page_view(self):
        """Log page view event"""
        if not has_request_context():
            return

        try:
            bigquery_logger.log_user_activity(
            action_type='page_view',
            action_category='navigation',
            user_id=getattr(g, 'current_user_id', None),
            success=True,
            action_details={
                'endpoint': request.endpoint,
                'method': request.method,
                'url': request.url,
                'referrer': request.referrer,
                'request_id': g.request_id
            }
            )
        except Exception as e:
            current_app.logger.warning(
            "Analytics page_view logging failed: %s", e
            )
    
    def _log_api_request(self, response, duration_ms: int):
        """Log API request metrics"""

        if not has_request_context():
            return
        
        try:
            success = 200 <= response.status_code < 400
        
            bigquery_logger.log_user_activity(
                action_type=request.method.lower(),
                action_category='api',
                user_id=getattr(g, 'current_user_id', None),
                success=success,
                duration_ms=duration_ms,
                action_details={
                    'endpoint': request.endpoint,
                    'status_code': response.status_code,
                    'content_length': response.content_length,
                    'request_id': g.request_id,
                    'query_params': dict(request.args),
                    'has_json_body': request.is_json
                },
            error_message=None if success else f"HTTP {response.status_code}"
            )  
        
            # Log performance metrics
            bigquery_logger.log_performance_metric(
                endpoint=request.endpoint or 'unknown',
                response_time_ms=duration_ms,
                success=success,
                error_count=0 if success else 1
            )
        except Exception as e:
            current_app.logger.warning(
                "Analytics API request logging failed: %s", e
            )  
    
    def _log_business_events(self, response):
        """Log business-specific events based on endpoint"""
        if not has_request_context() or not request.endpoint:
            return
        
        try:

            endpoint = request.endpoint
            success = 200 <= response.status_code < 400
        
            # Authentication events
            if 'auth' in endpoint:
                if 'login' in endpoint:
                    bigquery_logger.log_user_activity(
                        action_type='login_attempt',
                        action_category='auth',
                        user_id=getattr(g, 'current_user_id', None) if success else None,
                        success=success,
                        action_details={
                            'login_method': 'email',  # Could be enhanced to detect method
                            'request_id': g.request_id
                        }
                    )
                elif 'register' in endpoint:
                    bigquery_logger.log_user_activity(
                        action_type='registration_attempt',
                        action_category='auth',
                        user_id=getattr(g, 'current_user_id', None) if success else None,
                        success=success,
                        action_details={
                            'user_type': getattr(g, 'registration_user_type', 'unknown'),
                            'request_id': g.request_id
                        }
                    )
        
            # Job-related events
            elif 'job' in endpoint:
                if request.method == 'POST' and success:
                    bigquery_logger.log_user_activity(
                        action_type='job_create',
                        action_category='job',
                        user_id=getattr(g, 'current_user_id', None),
                        success=success,
                        action_details={
                            'job_id': getattr(g, 'created_job_id', None),
                            'category': getattr(g, 'job_category', None),
                            'request_id': g.request_id
                        }
                    )
        
            # Search events
            elif 'search' in endpoint:
                if request.method == 'GET':
                    search_query = request.args.get('q', '')
                    search_type = request.args.get('type', 'general')
                
                    # This will be enhanced by the search endpoint to include results
                    g.search_query = search_query
                    g.search_type = search_type
        
            # Payment events
            elif 'payment' in endpoint:
                if request.method == 'POST' and success:
                    bigquery_logger.log_user_activity(
                        action_type='payment_initiate',
                        action_category='payment',
                        user_id=getattr(g, 'current_user_id', None),
                        success=success,
                        action_details={
                            'payment_id': getattr(g, 'payment_id', None),
                            'amount': getattr(g, 'payment_amount', None),
                            'method': getattr(g, 'payment_method', None),
                            'request_id': g.request_id
                        }
                    )
        
            # Message events
            elif 'message' in endpoint:
                if request.method == 'POST' and success:
                    bigquery_logger.log_user_activity(
                        action_type='message_send',
                        action_category='communication',
                        user_id=getattr(g, 'current_user_id', None),
                        success=success,
                        action_details={
                            'message_id': getattr(g, 'message_id', None),
                            'recipient_id': getattr(g, 'recipient_id', None),
                            'message_type': getattr(g, 'message_type', 'text'),
                            'request_id': g.request_id
                        }
                    )
        except Exception as e:
            current_app.logger.warning(
                "Analytics business event logging failed: %s", e
            )
    
    def _log_request_exception(self, exception):
        """Log request-level exceptions"""

        if not exception:
            return
        
        has_ctx = has_request_context()
        endpoint = request.endpoint if has_ctx else None
        request_data = {}

        if has_ctx:
            request_data = {
                'method': request.method,
                'url': request.url,
                'request_id': getattr(g, 'request_id', None)
            }

        try:

            bigquery_logger.log_error(
                error_type='REQUEST_EXCEPTION',
                error_level='ERROR',
                error_message=str(exception),
                user_id=getattr(g, 'current_user_id', None) if has_ctx else None,
                endpoint=endpoint,
                error_stack=str(exception.__traceback__) if hasattr(exception, '__traceback__') else None,
                request_data=request_data
            )
        except Exception as e:
            if has_app_context():
                current_app.logger.warning(
                    "Analytics request exception logging failed: %s", e
                )
    
    def _log_application_error(self, error):
        """Log application-level errors"""
        error_type = type(error).__name__
        has_ctx = has_request_context()

        try:

            bigquery_logger.log_error(
                error_type=error_type,
                error_level='CRITICAL' if error_type in ['DatabaseError', 'ConnectionError'] else 'ERROR',
                error_message=str(error),
                user_id=getattr(g, 'current_user_id', None) if has_ctx else None,
                endpoint=request.endpoint if has_ctx else None,
                error_stack=str(error.__traceback__) if hasattr(error, '__traceback__') else None
            )

        except Exception as e:
            if has_app_context():
                current_app.logger.warning(
                    "Analytics application error logging failed: %s", e
                )

def track_business_event(event_type: str, event_category: str, **kwargs):
    """Decorator to track specific business events"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **func_kwargs):
            start_time = time.time()
            
            try:
                result = func(*args, **func_kwargs)
            
            except Exception as e:
                duration_ms = int((time.time() - start_time) * 1000)

                if has_app_context():
                    try:
                        # Log successful business event
                        bigquery_logger.log_user_activity(
                            action_type=event_type,
                            action_category=event_category,
                            user_id=getattr(g, 'current_user_id', None),
                            success=False,
                            duration_ms=duration_ms,
                            action_details=kwargs,
                            error_message=str(e)
                        )
                    except Exception as log_err:
                        current_app.logger.warning(
                            "Analytics business event logging failed: %s", log_err
                        )
                raise
        
            else:
            
                duration_ms = int((time.time() - start_time) * 1000)
            
                if has_app_context():

                    try:
                        # Log successful business event
                        bigquery_logger.log_user_activity(
                            action_type=event_type,
                            action_category=event_category,
                            user_id=getattr(g, 'current_user_id', None),
                            success=True,
                            duration_ms=duration_ms,
                            action_details=kwargs
                        )
                    except Exception as log_err:
                        current_app.logger.warning(
                            "Analytics business event logging failed: %s", log_err
                        )
                return result
        
        return wrapper
    return decorator

def track_search_event(search_query: str, search_type: str, results_count: int, 
                      response_time_ms: int, filters: Optional[Dict] = None):
    """Track search events with detailed metrics"""

    if not has_app_context():
        return
    
    try:

        bigquery_logger.log_search_analytics(
            search_query=search_query,
            search_type=search_type,
            results_count=results_count,
            response_time_ms=response_time_ms,
            filters_applied=filters,
            user_id=getattr(g, 'current_user_id', None)
        )
    except Exception as e:
        current_app.logger.warning(
            "Analytics search event logging failed: %s", e
        )

def track_payment_event(payment_data: Dict[str, Any]):
    """Track payment events with detailed transaction data"""

    if not has_app_context():
        return
    
    try:

        bigquery_logger.log_payment_analytics(**payment_data)

    except Exception as e:
        current_app.logger.warning(
            "Analytics payment event logging failed: %s", e
        )

# Convenience decorators for common events
def track_job_creation(func):
    """Track job creation events"""
    return track_business_event('job_create', 'job')(func)

def track_user_registration(func):
    """Track user registration events"""
    return track_business_event('register', 'auth')(func)

def track_login(func):
    """Track login events"""
    return track_business_event('login', 'auth')(func)

def track_message_send(func):
    """Track message sending events"""
    return track_business_event('message_send', 'communication')(func)

def track_review_create(func):
    """Track review creation events"""
    return track_business_event('review_create', 'feedback')(func)

def track_quote_submit(func):
    """Track quote submission events"""
    return track_business_event('quote_submit', 'job')(func)

# Initialize global middleware instance
analytics_middleware = AnalyticsMiddleware()