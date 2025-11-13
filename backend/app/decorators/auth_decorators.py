"""
Authentication and authorization decorators
"""
from functools import wraps
from flask import jsonify, request
from flask_jwt_extended import get_jwt_identity, verify_jwt_in_request
from app.models.user import User, UserType
import logging

logger = logging.getLogger(__name__)


def require_auth(f):
    """
    Require authentication for endpoint.
    
    Usage:
        @app.route('/protected')
        @require_auth
        def protected():
            pass
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            verify_jwt_in_request()
            return f(*args, **kwargs)
        except Exception as e:
            logger.warning(f"Authentication failed: {str(e)}")
            return jsonify({
                'error': True,
                'message': 'Kimlik doğrulama gerekli',
                'code': 'AUTHENTICATION_REQUIRED'
            }), 401
    
    return decorated_function


def require_role(*allowed_roles):
    """
    Require specific user role(s) for endpoint.
    
    Usage:
        @app.route('/admin/users')
        @require_role('admin', 'super_admin')
        def admin_users():
            pass
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            try:
                verify_jwt_in_request()
                user_id = get_jwt_identity()
                
                user = User.query.get(user_id)
                if not user:
                    logger.warning(f"User not found: {user_id}")
                    return jsonify({
                        'error': True,
                        'message': 'Kullanıcı bulunamadı',
                        'code': 'USER_NOT_FOUND'
                    }), 404
                
                # Check if user has required role
                user_role = user.user_type.value if hasattr(user.user_type, 'value') else user.user_type
                
                if user_role not in allowed_roles:
                    logger.warning(f"Unauthorized access attempt by user {user_id} with role {user_role}")
                    return jsonify({
                        'error': True,
                        'message': 'Bu işlem için yetkiniz yok',
                        'code': 'INSUFFICIENT_PERMISSIONS'
                    }), 403
                
                return f(*args, **kwargs)
                
            except Exception as e:
                logger.error(f"Authorization error: {str(e)}")
                return jsonify({
                    'error': True,
                    'message': 'Yetkilendirme hatası',
                    'code': 'AUTHORIZATION_ERROR'
                }), 500
        
        return decorated_function
    return decorator


def require_user_type(user_type: str):
    """
    Require specific user type for endpoint.
    
    Usage:
        @app.route('/craftsman/profile')
        @require_user_type('craftsman')
        def craftsman_profile():
            pass
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            try:
                verify_jwt_in_request()
                user_id = get_jwt_identity()
                
                user = User.query.get(user_id)
                if not user:
                    return jsonify({
                        'error': True,
                        'message': 'Kullanıcı bulunamadı',
                        'code': 'USER_NOT_FOUND'
                    }), 404
                
                current_user_type = user.user_type.value if hasattr(user.user_type, 'value') else user.user_type
                
                if current_user_type != user_type:
                    logger.warning(f"User {user_id} tried to access {user_type} endpoint with type {current_user_type}")
                    return jsonify({
                        'error': True,
                        'message': f'Bu işlem sadece {user_type} kullanıcıları için geçerlidir',
                        'code': 'WRONG_USER_TYPE'
                    }), 403
                
                return f(*args, **kwargs)
                
            except Exception as e:
                logger.error(f"User type check error: {str(e)}")
                return jsonify({
                    'error': True,
                    'message': 'Yetkilendirme hatası',
                    'code': 'AUTHORIZATION_ERROR'
                }), 500
        
        return decorated_function
    return decorator


def require_ownership(resource_type: str, id_param: str = 'id'):
    """
    Require user to own the resource they're accessing.
    
    Usage:
        @app.route('/quotes/<int:id>')
        @require_ownership('quote', 'id')
        def get_quote(id):
            pass
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            try:
                verify_jwt_in_request()
                user_id = get_jwt_identity()
                
                # Get resource ID from kwargs
                resource_id = kwargs.get(id_param)
                
                if not resource_id:
                    return jsonify({
                        'error': True,
                        'message': 'Geçersiz kaynak ID',
                        'code': 'INVALID_RESOURCE_ID'
                    }), 400
                
                user = User.query.get(user_id)
                if not user:
                    return jsonify({
                        'error': True,
                        'message': 'Kullanıcı bulunamadı',
                        'code': 'USER_NOT_FOUND'
                    }), 404
                
                # Check ownership based on resource type
                has_access = check_resource_ownership(user, resource_type, resource_id)
                
                if not has_access:
                    logger.warning(f"User {user_id} tried to access {resource_type} {resource_id} without ownership")
                    return jsonify({
                        'error': True,
                        'message': 'Bu kaynağa erişim yetkiniz yok',
                        'code': 'ACCESS_DENIED'
                    }), 403
                
                return f(*args, **kwargs)
                
            except Exception as e:
                logger.error(f"Ownership check error: {str(e)}")
                return jsonify({
                    'error': True,
                    'message': 'Yetkilendirme hatası',
                    'code': 'AUTHORIZATION_ERROR'
                }), 500
        
        return decorated_function
    return decorator


def check_resource_ownership(user, resource_type: str, resource_id: int) -> bool:
    """
    Check if user owns or has access to the resource.
    
    Args:
        user: User object
        resource_type: Type of resource (quote, job, review, etc.)
        resource_id: ID of the resource
        
    Returns:
        True if user has access
    """
    from app.models.quote import Quote
    from app.models.job import Job
    from app.models.review import Review
    from app.models.customer import Customer
    from app.models.craftsman import Craftsman
    
    try:
        if resource_type == 'quote':
            quote = Quote.query.get(resource_id)
            if not quote:
                return False
            
            # Customer or craftsman involved in the quote
            if user.user_type.value == 'customer':
                customer = Customer.query.filter_by(user_id=user.id).first()
                return quote.customer_id == customer.id if customer else False
            elif user.user_type.value == 'craftsman':
                craftsman = Craftsman.query.filter_by(user_id=user.id).first()
                return quote.craftsman_id == craftsman.user_id if craftsman else False
        
        elif resource_type == 'job':
            job = Job.query.get(resource_id)
            if not job:
                return False
            
            # Customer or craftsman involved in the job
            return job.customer_id == user.id or job.craftsman_id == user.id
        
        elif resource_type == 'review':
            review = Review.query.get(resource_id)
            if not review:
                return False
            
            # Customer who wrote the review or craftsman being reviewed
            if user.user_type.value == 'customer':
                customer = Customer.query.filter_by(user_id=user.id).first()
                return review.customer_id == customer.id if customer else False
            elif user.user_type.value == 'craftsman':
                craftsman = Craftsman.query.filter_by(user_id=user.id).first()
                return review.craftsman_id == craftsman.id if craftsman else False
        
        return False
        
    except Exception as e:
        logger.error(f"Error checking resource ownership: {str(e)}")
        return False


def require_active_user(f):
    """
    Require user account to be active.
    
    Usage:
        @app.route('/protected')
        @require_active_user
        def protected():
            pass
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            verify_jwt_in_request()
            user_id = get_jwt_identity()
            
            user = User.query.get(user_id)
            if not user:
                return jsonify({
                    'error': True,
                    'message': 'Kullanıcı bulunamadı',
                    'code': 'USER_NOT_FOUND'
                }), 404
            
            if not user.is_active:
                logger.warning(f"Inactive user {user_id} tried to access endpoint")
                return jsonify({
                    'error': True,
                    'message': 'Hesabınız deaktif durumda',
                    'code': 'ACCOUNT_INACTIVE'
                }), 403
            
            return f(*args, **kwargs)
            
        except Exception as e:
            logger.error(f"Active user check error: {str(e)}")
            return jsonify({
                'error': True,
                'message': 'Yetkilendirme hatası',
                'code': 'AUTHORIZATION_ERROR'
            }), 500
    
    return decorated_function
