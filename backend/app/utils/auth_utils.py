from flask_jwt_extended import get_jwt_identity, decode_token
from flask import request, jsonify

def get_current_user_id_with_mock():
    """
    Get current user ID supporting both real JWT and mock tokens
    Returns tuple: (user_id, error_response)
    """
    try:
        auth_header = request.headers.get('Authorization')
        
        if not auth_header or not auth_header.startswith('Bearer '):
            return None, jsonify({
                'error': True, 
                'message': 'Authorization header gerekli',
                'code': 'MISSING_AUTH'
            }), 401
            
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
            return None, jsonify({
                'error': True, 
                'message': 'Geçersiz token',
                'code': 'INVALID_TOKEN'
            }), 422
            
    except Exception as e:
        print(f"❌ Auth error: {e}")
        return None, jsonify({
            'error': True, 
            'message': 'Authentication hatası',
            'code': 'AUTH_ERROR'
        }), 500

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