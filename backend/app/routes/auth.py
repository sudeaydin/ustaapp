import re
import logging
from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
)
from app import db
from app.utils.validators import (
    validate_json, UserLoginSchema, ResponseHelper, ValidationUtils
)
from app.utils.security import rate_limit
from app.utils.analytics import AnalyticsTracker
from app.services.auth_service import AuthService
from datetime import datetime
from app.utils.auth_utils import get_current_user_id

logger = logging.getLogger(__name__)

auth_bp = Blueprint('auth', __name__)



def _auth_user_rate_limit_key():
    identity = get_jwt_identity()
    if identity:
        return f"user:{identity}"

    forwarded_for = request.headers.get('X-Forwarded-For')
    if forwarded_for:
        return forwarded_for.split(',')[0].strip()

    real_ip = request.headers.get('X-Real-IP')
    if real_ip:
        return real_ip.strip()

    return request.remote_addr or 'unknown'


def validate_email(email):
    """Validate email format"""
    pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
    return re.match(pattern, email) is not None

def validate_phone(phone):
    """Validate Turkish phone number"""
    # Remove spaces and special characters
    phone = re.sub(r'[\s\-\(\)]', '', phone)
    
    # Turkish phone patterns
    patterns = [
        r'^(\+90|0)?[5][0-9]{9}$',  # Mobile
        r'^(\+90|0)?[2-4][0-9]{8}$'  # Landline
    ]
    
    return any(re.match(pattern, phone) for pattern in patterns)

@auth_bp.route('/register', methods=['POST'])
@rate_limit(max_requests=10, window_minutes=5, namespace='auth-register')
def register():
    """User registration"""
    data = request.get_json() or {}
    user, error = AuthService.register_user(data)
    if error:
        return jsonify({'error': True, 'message': error, 'code': 'REGISTER_ERROR'}), 400

    access_token = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))
    return jsonify({
        'success': True,
        'message': 'Hesabınız başarıyla oluşturuldu',
        'data': {
            'user': user.to_dict(),
            'access_token': access_token,
            'refresh_token': refresh_token,
        }
    }), 201


@auth_bp.route('/login', methods=['POST'])
@validate_json(UserLoginSchema)
@rate_limit(max_requests=5, window_minutes=1, namespace='auth-login')
def login(validated_data):
    """User login endpoint"""
    try:
        user_payload, error = AuthService.login_user(validated_data['email'], validated_data['password'])

        if error:
            AnalyticsTracker.track_user_action(
                user_id=None,
                action='login_failed',
                details={'email': validated_data['email'], 'reason': error},
                page='/api/auth/login'
            )
            return ResponseHelper.unauthorized(error)

        AnalyticsTracker.track_user_action(
            user_id=user_payload['user']['id'],
            action='login_success',
            details={
                'email': user_payload['user']['email'],
                'user_type': user_payload['user']['user_type'],
                'login_time': datetime.utcnow().isoformat()
            },
            page='/api/auth/login'
        )

        return ResponseHelper.success(
            data=user_payload,
            message='Başarıyla giriş yapıldı'
        )

    except Exception:
        db.session.rollback()
        return ResponseHelper.server_error('Giriş sırasında bir hata oluştu')


@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
@rate_limit(max_requests=10, window_minutes=5, namespace='auth-refresh')
def refresh():
    """Issue a new access token using a refresh token"""
    try:
        user_id = get_jwt_identity()
        access_token = create_access_token(identity=str(user_id))
        return ResponseHelper.success({'access_token': access_token}, 'Token yenilendi')
    except Exception:
        return ResponseHelper.server_error('Token yenileme başarısız')

@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """Get current user profile"""
    try:
        user_id = get_jwt_identity()
        profile, error = AuthService.get_profile_with_details(user_id)
        if error:
            return jsonify({'error': True, 'message': error, 'code': 'USER_NOT_FOUND'}), 404

        return jsonify({'success': True, 'data': profile})
    except Exception:
        return ResponseHelper.server_error('Profil bilgileri alınamadı')

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """User logout (client-side token removal)"""
    return jsonify({
        'success': True,
        'message': 'Başarıyla çıkış yapıldı'
    })

@auth_bp.route('/change-password', methods=['POST'])
@jwt_required()
@rate_limit(max_requests=3, window_minutes=10, namespace='auth-change-password', key_func=_auth_user_rate_limit_key)
def change_password():
    """Change user password"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        ok, message = AuthService.change_password(user_id, data.get('current_password'), data.get('new_password'))
        if not ok:
            return jsonify({'error': True, 'message': message, 'code': 'PASSWORD_ERROR'}), 400
        return jsonify({'success': True, 'message': message})

    except Exception:
        db.session.rollback()
        return ResponseHelper.server_error('Şifre güncellenirken bir hata oluştu')

@auth_bp.route('/delete-account', methods=['DELETE'])
@jwt_required()
def delete_account():
    """Delete user account permanently (KVKK compliance)"""
    try:
        current_user_id = get_jwt_identity()
        ok, message, status = AuthService.delete_account(current_user_id)
        if not ok:
            return jsonify({'error': True, 'message': message}), status
        return jsonify({'success': True, 'message': message}), status
    except Exception:
        db.session.rollback()
        return ResponseHelper.server_error('Hesap silme işlemi başarısız oldu')

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile with craftsman/customer data"""
    try:
        current_user_id = get_current_user_id()
        logger.debug("GET /profile current_user_id=%s", current_user_id)


        profile = AuthService.get_user_profile(current_user_id)
        logger.debug("GET /profile profile=%s", profile)
        
        if not profile:
            logger.warning("GET /profile user not found user_id=%s", current_user_id)
            return jsonify({'error': True, 'message': 'Kullanıcı bulunamadı', 'code': 'USER_NOT_FOUND'}), 404
        return jsonify({'success': True, 'data': profile}), 200
        
    except Exception as e:
        logger.exception("GET /profile sırasında hata oluştu")
        return jsonify({'error': True, 'message': 'Profil bilgileri alınamadı', 'code': 'PROFILE_ERROR'}), 500

@auth_bp.route('/google', methods=['POST'])
def google_auth():
    """Google OAuth authentication"""
    try:
        data = request.get_json()
        payload, error = AuthService.google_auth(data)
        if error:
            return jsonify({'error': True, 'message': error, 'code': 'GOOGLE_AUTH_ERROR'}), 400
        return ResponseHelper.success(payload, 'Google ile işlem başarılı')
            
    except Exception:
        db.session.rollback()
        return ResponseHelper.server_error('Google authentication failed')
