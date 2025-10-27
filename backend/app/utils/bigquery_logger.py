"""
Real-time BigQuery Logging Utility
Streams logs and analytics data to BigQuery in real-time
"""

import os
import json
import uuid
from datetime import datetime
from typing import Dict, Any, Optional
import logging
from flask import request, g
import threading
import queue
import time

try:  # Optional BigQuery dependency
    from google.cloud import bigquery  # type: ignore
    try:
        from google.auth.exceptions import DefaultCredentialsError  # type: ignore
    except ModuleNotFoundError:  # pragma: no cover - google-auth not installed
        DefaultCredentialsError = Exception  # type: ignore
    _BIGQUERY_IMPORT_ERROR: Optional[ModuleNotFoundError] = None
except ModuleNotFoundError as import_error:  # pragma: no cover - optional dependency missing
    bigquery = None  # type: ignore
    DefaultCredentialsError = Exception  # type: ignore
    _BIGQUERY_IMPORT_ERROR = import_error

# Configure logging
logger = logging.getLogger(__name__)

class BigQueryLogger:
    """Real-time BigQuery logger for ustam app"""
    
    def __init__(self, project_id=None, dataset_id="ustam_analytics"):
        self.project_id = project_id or os.environ.get('BIGQUERY_PROJECT_ID', 'ustaapp-analytics')
        self.dataset_id = dataset_id
        self.client = None
        self.credentials_path = os.environ.get('BIGQUERY_CREDENTIALS_PATH')
        self._configured_flag = os.environ.get('BIGQUERY_LOGGING_ENABLED', 'auto').strip().lower()
        if self._configured_flag not in {'true', 'false', 'auto'}:
            logger.warning(
                "Unknown BIGQUERY_LOGGING_ENABLED value '%s'. Falling back to 'false'.",
                self._configured_flag
            )
            self._configured_flag = 'false'
        self.enabled = False

        # Streaming buffer
        self.log_queue = queue.Queue(maxsize=1000)
        self.batch_size = 50
        self.flush_interval = 30  # seconds

        # Start background worker when conditions allow
        self._bootstrap()

    def _bootstrap(self):
        """Configure the logger and start workers when enabled."""
        if self._configured_flag == 'false':
            logger.info("BigQuery logging disabled by configuration.")
            return

        if _BIGQUERY_IMPORT_ERROR is not None:
            logger.info(
                "BigQuery logging disabled: %s. Install optional google-cloud-bigquery dependencies to enable.",
                _BIGQUERY_IMPORT_ERROR
            )
            return

        credentials_status = self._configure_credentials()
        if credentials_status is False:
            message = "BigQuery credentials not found; logging disabled."
            if self._configured_flag == 'true':
                logger.error("%s Set BIGQUERY_CREDENTIALS_PATH or GOOGLE_APPLICATION_CREDENTIALS.", message)
            else:
                logger.info("%s Provide credentials to enable logging.", message)
            return

        if not self._initialize_client():
            # _initialize_client logs the reason and ensures self.enabled is False
            return

        self._start_background_worker()

    def _configure_credentials(self) -> Optional[bool]:
        """Ensure credentials are available for the BigQuery client."""
        explicit_path = self.credentials_path
        if explicit_path:
            if os.path.isfile(explicit_path):
                os.environ.setdefault('GOOGLE_APPLICATION_CREDENTIALS', explicit_path)
                return True
            logger.warning(
                "BIGQUERY_CREDENTIALS_PATH set to '%s' but file does not exist.",
                explicit_path
            )
            return False

        env_path = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
        if env_path:
            if os.path.isfile(env_path):
                return True
            logger.warning(
                "GOOGLE_APPLICATION_CREDENTIALS set to '%s' but file does not exist.",
                env_path
            )
            return False

        # No explicit credentials provided; return None so ADC can be attempted.
        return None

    def _initialize_client(self):
        """Initialize BigQuery client"""
        if bigquery is None:  # Safety guard when optional dependency is missing
            return False
        try:
            self.client = bigquery.Client(project=self.project_id)
            logger.info(f"BigQuery logger initialized for project: {self.project_id}")
            self.enabled = True
            return True
        except DefaultCredentialsError as e:  # pragma: no cover - depends on environment
            logger.info("BigQuery credentials unavailable: %s. Disabling logger.", e)
        except Exception as e:
            logger.error(f"Failed to initialize BigQuery client: {e}")
        self.enabled = False
        self.client = None
        return False

    def _start_background_worker(self):
        """Start background worker for batch processing"""
        def worker():
            batch = []
            last_flush = time.time()
            
            while True:
                try:
                    # Get item from queue with timeout
                    try:
                        item = self.log_queue.get(timeout=1)
                        batch.append(item)
                    except queue.Empty:
                        pass
                    
                    # Flush if batch is full or time interval passed
                    current_time = time.time()
                    should_flush = (
                        len(batch) >= self.batch_size or 
                        (batch and current_time - last_flush >= self.flush_interval)
                    )
                    
                    if should_flush:
                        self._flush_batch(batch)
                        batch = []
                        last_flush = current_time
                        
                except Exception as e:
                    logger.error(f"BigQuery worker error: {e}")
                    time.sleep(5)  # Wait before retrying
        
        # Start worker thread
        worker_thread = threading.Thread(target=worker, daemon=True)
        worker_thread.start()
        logger.info("BigQuery background worker started")

    def _flush_batch(self, batch):
        """Flush batch of logs to BigQuery"""
        if not batch or not self.enabled or not self.client:
            return
        
        # Group by table
        tables_data = {}
        for item in batch:
            table_name = item['table']
            if table_name not in tables_data:
                tables_data[table_name] = []
            tables_data[table_name].append(item['data'])
        
        # Insert to each table
        for table_name, rows in tables_data.items():
            try:
                table_ref = self.client.dataset(self.dataset_id).table(table_name)
                errors = self.client.insert_rows_json(table_ref, rows)
                
                if errors:
                    logger.error(f"BigQuery insert errors for {table_name}: {errors}")
                else:
                    logger.debug(f"Successfully inserted {len(rows)} rows to {table_name}")
                    
            except Exception as e:
                logger.error(f"Failed to insert to {table_name}: {e}")

    def _queue_log(self, table_name: str, data: Dict[str, Any]):
        """Queue log data for batch processing"""
        if not self.enabled:
            return
        
        try:
            self.log_queue.put({
                'table': table_name,
                'data': data
            }, block=False)
        except queue.Full:
            logger.warning("BigQuery log queue is full, dropping log entry")

    def log_user_activity(self, action_type: str, action_category: str, 
                         user_id: Optional[int] = None, success: bool = True,
                         duration_ms: Optional[int] = None, 
                         action_details: Optional[Dict] = None,
                         error_message: Optional[str] = None):
        """Log user activity"""
        data = {
            'log_id': str(uuid.uuid4()),
            'user_id': user_id,
            'session_id': getattr(g, 'session_id', None),
            'action_type': action_type,
            'action_category': action_category,
            'page_url': request.url if request else None,
            'user_agent': request.headers.get('User-Agent') if request else None,
            'ip_address': request.remote_addr if request else None,
            'device_type': self._detect_device_type(),
            'platform': self._detect_platform(),
            'action_details': json.dumps(action_details) if action_details else None,
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'duration_ms': duration_ms,
            'success': success,
            'error_message': error_message,
            'location_city': getattr(g, 'user_city', None),
            'location_country': 'TR'
        }
        
        self._queue_log('user_activity_logs', data)

    def log_error(self, error_type: str, error_level: str, error_message: str,
                  user_id: Optional[int] = None, endpoint: Optional[str] = None,
                  error_stack: Optional[str] = None, request_data: Optional[Dict] = None):
        """Log application errors"""
        data = {
            'error_id': str(uuid.uuid4()),
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'user_id': user_id,
            'session_id': getattr(g, 'session_id', None),
            'error_type': error_type,
            'error_level': error_level,
            'error_message': error_message,
            'error_stack': error_stack,
            'endpoint': endpoint or (request.endpoint if request else None),
            'http_method': request.method if request else None,
            'http_status': getattr(g, 'response_status', None),
            'request_data': json.dumps(request_data) if request_data else None,
            'user_agent': request.headers.get('User-Agent') if request else None,
            'ip_address': request.remote_addr if request else None,
            'platform': self._detect_platform(),
            'app_version': '1.0.0',  # Get from config
            'device_info': json.dumps(self._get_device_info()),
            'resolved': False,
            'resolution_notes': None
        }
        
        self._queue_log('error_logs', data)

    def log_performance_metric(self, endpoint: str, response_time_ms: int,
                              memory_usage_mb: Optional[float] = None,
                              cpu_usage_percent: Optional[float] = None,
                              database_query_time_ms: Optional[int] = None,
                              success: bool = True, error_count: int = 0):
        """Log performance metrics"""
        data = {
            'metric_id': str(uuid.uuid4()),
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'endpoint': endpoint,
            'response_time_ms': response_time_ms,
            'memory_usage_mb': memory_usage_mb,
            'cpu_usage_percent': cpu_usage_percent,
            'database_query_time_ms': database_query_time_ms,
            'cache_hit_rate': None,  # To be implemented
            'concurrent_users': getattr(g, 'concurrent_users', None),
            'platform': self._detect_platform(),
            'user_type': getattr(g, 'user_type', None),
            'success': success,
            'error_count': error_count
        }
        
        self._queue_log('performance_metrics', data)

    def log_search_analytics(self, search_query: str, search_type: str,
                           results_count: int, response_time_ms: int,
                           filters_applied: Optional[Dict] = None,
                           clicked_result_id: Optional[int] = None,
                           clicked_position: Optional[int] = None,
                           user_id: Optional[int] = None):
        """Log search analytics"""
        data = {
            'search_id': str(uuid.uuid4()),
            'user_id': user_id,
            'session_id': getattr(g, 'session_id', None),
            'search_query': search_query,
            'search_type': search_type,
            'filters_applied': json.dumps(filters_applied) if filters_applied else None,
            'results_count': results_count,
            'page_number': filters_applied.get('page', 1) if filters_applied else 1,
            'results_per_page': filters_applied.get('per_page', 10) if filters_applied else 10,
            'response_time_ms': response_time_ms,
            'clicked_result_id': clicked_result_id,
            'clicked_position': clicked_position,
            'location_city': filters_applied.get('city') if filters_applied else None,
            'location_district': filters_applied.get('district') if filters_applied else None,
            'platform': self._detect_platform(),
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        
        self._queue_log('search_analytics', data)

    def log_payment_analytics(self, payment_id: str, transaction_id: Optional[str],
                            user_id: int, amount: float, payment_type: str,
                            payment_method: str, status: str, provider: str,
                            platform_fee: float, craftsman_amount: float,
                            processing_time_ms: Optional[int] = None,
                            failure_reason: Optional[str] = None,
                            provider_response: Optional[Dict] = None):
        """Log payment analytics"""
        data = {
            'payment_id': payment_id,
            'transaction_id': transaction_id,
            'user_id': user_id,
            'craftsman_id': getattr(g, 'craftsman_id', None),
            'job_id': getattr(g, 'job_id', None),
            'quote_id': getattr(g, 'quote_id', None),
            'payment_type': payment_type,
            'payment_method': payment_method,
            'amount': amount,
            'platform_fee': platform_fee,
            'craftsman_amount': craftsman_amount,
            'currency': 'TL',
            'status': status,
            'provider': provider,
            'provider_response': json.dumps(provider_response) if provider_response else None,
            'failure_reason': failure_reason,
            'processing_time_ms': processing_time_ms,
            'ip_address': request.remote_addr if request else None,
            'user_agent': request.headers.get('User-Agent') if request else None,
            'platform': self._detect_platform(),
            'created_at': datetime.utcnow().isoformat() + 'Z',
            'completed_at': datetime.utcnow().isoformat() + 'Z' if status == 'completed' else None
        }
        
        self._queue_log('payment_analytics', data)

    def _detect_device_type(self) -> Optional[str]:
        """Detect device type from user agent"""
        if not request:
            return None
        
        user_agent = request.headers.get('User-Agent', '').lower()
        if 'mobile' in user_agent or 'android' in user_agent or 'iphone' in user_agent:
            return 'mobile'
        elif 'tablet' in user_agent or 'ipad' in user_agent:
            return 'tablet'
        else:
            return 'desktop'

    def _detect_platform(self) -> Optional[str]:
        """Detect platform from user agent or headers"""
        if not request:
            return None
        
        user_agent = request.headers.get('User-Agent', '').lower()
        if 'android' in user_agent:
            return 'android'
        elif 'iphone' in user_agent or 'ipad' in user_agent:
            return 'ios'
        else:
            return 'web'

    def _get_device_info(self) -> Dict[str, Any]:
        """Get device information"""
        if not request:
            return {}
        
        return {
            'user_agent': request.headers.get('User-Agent'),
            'accept_language': request.headers.get('Accept-Language'),
            'accept_encoding': request.headers.get('Accept-Encoding'),
            'connection': request.headers.get('Connection'),
        }

# Global instance
bigquery_logger = BigQueryLogger()

# Decorator for automatic performance logging
def log_performance(func):
    """Decorator to automatically log API performance"""
    def wrapper(*args, **kwargs):
        start_time = time.time()
        endpoint = request.endpoint if request else func.__name__
        
        try:
            result = func(*args, **kwargs)
            duration_ms = int((time.time() - start_time) * 1000)
            
            # Log successful performance
            bigquery_logger.log_performance_metric(
                endpoint=endpoint,
                response_time_ms=duration_ms,
                success=True
            )
            
            return result
            
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            
            # Log failed performance
            bigquery_logger.log_performance_metric(
                endpoint=endpoint,
                response_time_ms=duration_ms,
                success=False,
                error_count=1
            )
            
            # Log error
            bigquery_logger.log_error(
                error_type='API_ERROR',
                error_level='ERROR',
                error_message=str(e),
                endpoint=endpoint,
                error_stack=str(e.__traceback__) if hasattr(e, '__traceback__') else None
            )
            
            raise
    
    return wrapper

# Middleware for automatic user activity logging
def init_bigquery_middleware(app):
    """Initialize BigQuery logging middleware"""
    
    @app.before_request
    def before_request():
        g.start_time = time.time()
        g.session_id = request.headers.get('X-Session-ID', str(uuid.uuid4()))
    
    @app.after_request
    def after_request(response):
        if hasattr(g, 'start_time'):
            duration_ms = int((time.time() - g.start_time) * 1000)
            
            # Log user activity
            bigquery_logger.log_user_activity(
                action_type=request.method,
                action_category='API',
                user_id=getattr(g, 'current_user_id', None),
                success=200 <= response.status_code < 400,
                duration_ms=duration_ms,
                action_details={
                    'endpoint': request.endpoint,
                    'status_code': response.status_code,
                    'content_length': response.content_length
                }
            )
        
        return response
    
    logger.info("BigQuery middleware initialized")

# Convenience functions for common logging scenarios
def log_user_login(user_id: int, success: bool, error_message: Optional[str] = None):
    """Log user login attempt"""
    bigquery_logger.log_user_activity(
        action_type='login',
        action_category='auth',
        user_id=user_id if success else None,
        success=success,
        error_message=error_message
    )

def log_user_registration(user_id: int, user_type: str, success: bool, error_message: Optional[str] = None):
    """Log user registration"""
    bigquery_logger.log_user_activity(
        action_type='register',
        action_category='auth',
        user_id=user_id if success else None,
        success=success,
        action_details={'user_type': user_type},
        error_message=error_message
    )

def log_job_creation(user_id: int, job_id: int, category: str, success: bool):
    """Log job creation"""
    bigquery_logger.log_user_activity(
        action_type='job_create',
        action_category='job',
        user_id=user_id,
        success=success,
        action_details={'job_id': job_id, 'category': category}
    )

def log_search(user_id: Optional[int], search_query: str, search_type: str, 
               results_count: int, response_time_ms: int, filters: Optional[Dict] = None):
    """Log search activity"""
    bigquery_logger.log_search_analytics(
        search_query=search_query,
        search_type=search_type,
        results_count=results_count,
        response_time_ms=response_time_ms,
        filters_applied=filters,
        user_id=user_id
    )

def log_payment(payment_data: Dict[str, Any]):
    """Log payment transaction"""
    bigquery_logger.log_payment_analytics(**payment_data)

def log_api_error(error_type: str, error_message: str, endpoint: Optional[str] = None,
                  user_id: Optional[int] = None, error_stack: Optional[str] = None):
    """Log API errors"""
    bigquery_logger.log_error(
        error_type=error_type,
        error_level='ERROR',
        error_message=error_message,
        user_id=user_id,
        endpoint=endpoint,
        error_stack=error_stack
    )