"""
Security Middleware for ustam App
Handles authentication, authorization, and security measures
"""

import os
import logging
from functools import wraps
from flask import request, jsonify, g
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity, get_jwt
import time

logger = logging.getLogger(__name__)

def init_security_middleware(app):
    """Initialize security middleware"""
    
    @app.before_request
    def security_before_request():
        """Security checks before each request"""
        # Skip security for health checks and static files
        if request.endpoint in ['health_check', 'static']:
            return
        
        # Add security headers
        g.security_start_time = time.time()
        
        # Rate limiting (basic implementation)
        client_ip = request.remote_addr
        # In production, implement proper rate limiting with Redis
        
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