"""Security middleware, decorators, and rate limiting utilities for the API."""

import logging
import os
import threading
import time
from functools import wraps
from typing import Callable, Optional

from flask import current_app, g, jsonify, request
from flask_jwt_extended import get_jwt_identity, verify_jwt_in_request

try:
    import redis
except ImportError:  # pragma: no cover - optional dependency
    redis = None

logger = logging.getLogger(__name__)

_rate_limit_client = None
_rate_limit_client_available = False
_rate_limit_configured = False
_rate_limit_fallback_counters = {}
_rate_limit_lock = threading.Lock()
_rate_limit_default_requests = 100
_rate_limit_default_window = 60


def init_security_middleware(app):
    """Initialize security middleware"""

    _configure_rate_limit_backend(app)

    @app.before_request
    def security_before_request():
        """Security checks before each request"""
        # Skip security for health checks and static files
        if request.endpoint in ['health_check', 'static']:
            return

        # Add security headers
        g.security_start_time = time.time()

        # Rate limiting handled via decorators for sensitive routes

    @app.after_request
    def security_after_request(response):
        """Add security headers after request"""
        # Security headers
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'

        return response

    logger.info("Security middleware initialized")


def _configure_rate_limit_backend(app=None):
    """Configure the rate limiting backend using Redis or fall back to in-memory store."""

    global _rate_limit_client, _rate_limit_client_available, _rate_limit_configured
    global _rate_limit_default_requests, _rate_limit_default_window

    if _rate_limit_configured:
        return

    redis_url = None
    if app is not None:
        redis_url = app.config.get('RATE_LIMIT_REDIS_URL') or app.config.get('RATE_LIMIT_STORAGE_URL')
        _rate_limit_default_requests = int(app.config.get('RATE_LIMIT_DEFAULT_REQUESTS', _rate_limit_default_requests))
        _rate_limit_default_window = int(app.config.get('RATE_LIMIT_DEFAULT_WINDOW', _rate_limit_default_window))

    if not redis_url:
        redis_url = os.environ.get('RATE_LIMIT_REDIS_URL') or os.environ.get('REDIS_URL')

    if redis_url and redis:
        try:
            client = redis.Redis.from_url(redis_url, decode_responses=True)
            client.ping()
            _rate_limit_client = client
            _rate_limit_client_available = True
            logger.info("Rate limiting configured to use Redis backend at %s", redis_url)
        except Exception as exc:  # pragma: no cover - network dependency
            logger.warning("Failed to connect to Redis for rate limiting: %s", exc)
            _rate_limit_client = None
            _rate_limit_client_available = False
    elif redis_url and not redis:
        logger.warning(
            "Redis URL provided for rate limiting but redis package is not installed. "
            "Falling back to in-memory store."
        )

    if not _rate_limit_client_available:
        logger.info(
            "Rate limiting is using an in-memory fallback store. This is not shared across processes."
        )

    _rate_limit_configured = True


def _ensure_rate_limit_backend_configured():
    if not _rate_limit_configured:
        app = None
        try:
            app = current_app._get_current_object()  # type: ignore[attr-defined]
        except Exception:
            app = None
        _configure_rate_limit_backend(app)


def _get_client_identifier() -> str:
    forwarded_for = request.headers.get('X-Forwarded-For')
    if forwarded_for:
        return forwarded_for.split(',')[0].strip()
    real_ip = request.headers.get('X-Real-IP')
    if real_ip:
        return real_ip.strip()
    if getattr(g, 'current_user_id', None):
        return f"user:{g.current_user_id}"
    return request.remote_addr or 'unknown'


def _increment_rate_limit_counter(key: str, window_seconds: int) -> int:
    global _rate_limit_client_available

    if _rate_limit_client_available and _rate_limit_client is not None:
        try:
            pipeline = _rate_limit_client.pipeline()
            pipeline.incr(key, 1)
            pipeline.expire(key, window_seconds, nx=True)
            result = pipeline.execute()
            return int(result[0])
        except Exception as exc:  # pragma: no cover - network dependency
            logger.error("Redis rate limiting error, switching to in-memory store: %s", exc)
            _rate_limit_client_available = False

    now = time.time()
    with _rate_limit_lock:
        count, expires_at = _rate_limit_fallback_counters.get(key, (0, now + window_seconds))
        if expires_at <= now:
            count = 0
            expires_at = now + window_seconds
        count += 1
        _rate_limit_fallback_counters[key] = (count, expires_at)
    return count


def require_auth(f):
    """Decorator to require authentication"""

    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            verify_jwt_in_request()
            current_user_id = get_jwt_identity()

            if not current_user_id:
                return jsonify({'error': 'Authentication required'}), 401

            # Load user and set in g
            from app.models.user import User
            user = User.query.get(current_user_id)
            if not user or not user.is_active:
                return jsonify({'error': 'User not found or inactive'}), 401

            g.current_user = user
            g.current_user_id = user.id

            return f(*args, **kwargs)

        except Exception as e:
            logger.error(f"Authentication error: {e}")
            return jsonify({'error': 'Authentication failed'}), 401

    return decorated_function


def require_admin(f):
    """Decorator to require admin role"""

    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            verify_jwt_in_request()
            current_user_id = get_jwt_identity()

            from app.models.user import User
            user = User.query.get(current_user_id)

            if not user or user.user_type != 'admin':
                return jsonify({'error': 'Admin access required'}), 403

            g.current_user = user
            g.current_user_id = user.id

            return f(*args, **kwargs)

        except Exception as e:
            logger.error(f"Admin auth error: {e}")
            return jsonify({'error': 'Admin authentication failed'}), 403

    return decorated_function


def require_craftsman(f):
    """Decorator to require craftsman role"""

    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            verify_jwt_in_request()
            current_user_id = get_jwt_identity()

            from app.models.user import User
            user = User.query.get(current_user_id)

            if not user or user.user_type != 'craftsman':
                return jsonify({'error': 'Craftsman access required'}), 403

            g.current_user = user
            g.current_user_id = user.id

            return f(*args, **kwargs)

        except Exception as e:
            logger.error(f"Craftsman auth error: {e}")
            return jsonify({'error': 'Craftsman authentication failed'}), 403

    return decorated_function


def validate_input(schema):
    """Decorator to validate request input using marshmallow schema"""

    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            try:
                if request.is_json:
                    data = request.get_json()
                else:
                    data = request.form.to_dict()

                # Validate using schema
                result = schema.load(data)
                g.validated_data = result

                return f(*args, **kwargs)

            except Exception as e:
                return jsonify({'error': 'Invalid input', 'details': str(e)}), 400

        return decorated_function

    return decorator


def rate_limit(max_requests: Optional[int] = None, window_minutes: Optional[int] = None,
               namespace: Optional[str] = None, key_func: Optional[Callable[[], str]] = None):
    """Rate limiting decorator backed by Redis with in-memory fallback."""

    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            _ensure_rate_limit_backend_configured()

            window_seconds = int((window_minutes or (_rate_limit_default_window / 60)) * 60)
            if window_seconds <= 0:
                window_seconds = 60
            max_allowed = int(max_requests or _rate_limit_default_requests)

            identifier = key_func() if key_func else _get_client_identifier()
            endpoint = namespace or request.endpoint or f.__name__
            current_time = time.time()
            window_start = int(current_time // window_seconds * window_seconds)
            cache_key = f"rate-limit:{endpoint}:{identifier}:{window_start}"

            request_count = _increment_rate_limit_counter(cache_key, window_seconds)
            remaining = max(0, max_allowed - request_count)
            window_reset = window_start + window_seconds
            retry_after = max(0, int(window_reset - current_time))

            response_headers = {
                'X-RateLimit-Limit': str(max_allowed),
                'X-RateLimit-Remaining': str(remaining),
                'X-RateLimit-Reset': str(window_reset),
            }

            if request_count > max_allowed:
                logger.warning(
                    "Rate limit exceeded for endpoint=%s ip=%s count=%s/%s window=%ss",
                    endpoint,
                    identifier,
                    request_count,
                    max_allowed,
                    window_seconds,
                )
                response = jsonify({
                    'error': True,
                    'code': 'RATE_LIMIT_EXCEEDED',
                    'message': 'Çok fazla istek gönderildi. Lütfen daha sonra tekrar deneyin.'
                })
                response.status_code = 429
                response.headers.update(response_headers)
                if retry_after:
                    response.headers['Retry-After'] = str(retry_after)
                return response

            response = f(*args, **kwargs)

            if isinstance(response, tuple):
                original_response = response[0]
                if hasattr(original_response, 'headers'):
                    original_response.headers.update(response_headers)
                return response

            if hasattr(response, 'headers'):
                response.headers.update(response_headers)

            return response

        return decorated_function

    return decorator
