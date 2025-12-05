from flask_jwt_extended import get_jwt_identity, decode_token, jwt_required
from flask import request, jsonify, g
from functools import wraps

def get_current_user_id():
    """
    Get current user ID from JWT token as integer
    Handles the conversion from string to integer consistently
    """
    identity = get_jwt_identity()

    try: 
        user_id = int(identity)
    except (TypeError, ValueError):
        user_id = identity

    g.current_user_id = user_id
    return user_id

def require_auth(f):
    """Decorator to require authentication"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
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
            return jsonify({'error': 'Authentication failed'}), 401
    
    return decorated_function

def require_admin(f):
    """Decorator to require admin role"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
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
            return jsonify({'error': 'Admin authentication failed'}), 403
    
    return decorated_function