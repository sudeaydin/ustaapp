from flask_jwt_extended import get_jwt_identity, decode_token, jwt_required
from flask import request, jsonify, g
from functools import wraps

def get_current_user_id_with_mock():
    """
    Get current user ID supporting both real JWT and mock tokens
    Returns tuple: (user_id, error_response)
    """
    try:
        auth_header = request.headers.get('Authorization')
        
        if not auth_header or not auth_header.startswith('Bearer '):
            error_response = jsonify({
                'error': True, 
                'message': 'Authorization header gerekli',
                'code': 'MISSING_AUTH'
            })
            error_response.status_code = 401
            return None, error_response
            
        token = auth_header.split(' ')[1]
        
        # Handle mock token for testing
        if token == 'mock_jwt_token_12345':
            print("🧪 Using mock token - returning test user")
            return '1', None  # Default to customer user ID 1
        
        # Try to get real JWT identity
        try:
            decoded = decode_token(token)
            user_id = decoded['sub']
            print(f"✅ Real JWT decoded - User ID: {user_id}")
            return user_id, None
        except Exception as e:
            print(f"❌ JWT decode failed: {e}")
            error_response = jsonify({
                'error': True, 
                'message': 'Geçersiz token',
                'code': 'INVALID_TOKEN'
            })
            error_response.status_code = 422
            return None, error_response
            
    except Exception as e:
        print(f"❌ Auth error: {e}")
        error_response = jsonify({
            'error': True, 
            'message': 'Authentication hatası',
            'code': 'AUTH_ERROR'
        })
        error_response.status_code = 500
        return None, error_response

def get_current_user_id():
    """
    Get current user ID from JWT token as integer
    Handles the conversion from string to integer consistently
    """
    try:
        identity = get_jwt_identity()
        return int(identity) if identity else None
    except (ValueError, TypeError):
        return None

def get_current_user_id_str():
    """
    Get current user ID from JWT token as string
    For cases where string ID is needed
    """
    return get_jwt_identity()

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