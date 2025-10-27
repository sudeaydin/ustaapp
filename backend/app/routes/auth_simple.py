"""
Simple Auth Routes for Deployment
Basic authentication without analytics dependencies
"""

from flask import Blueprint, request
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.utils.validators import ResponseHelper, ValidationUtils
from app.utils.security import rate_limit
from datetime import datetime

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

@auth_bp.route('/register', methods=['POST'])
@rate_limit(max_requests=10, window_minutes=5, namespace='auth-simple-register')
def register():
    """User registration endpoint"""
    try:
        data = request.get_json() or {}

        # Required fields
        required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return ResponseHelper.error(f'{field} alanı zorunludur', status_code=400)

        if data['user_type'] not in ['customer', 'craftsman']:
            return ResponseHelper.error('Geçersiz kullanıcı tipi', status_code=400)

        if not ValidationUtils.is_valid_email(data['email']):
            return ResponseHelper.error('Geçerli bir e-posta adresi girin', status_code=400)

        if data.get('phone') and not ValidationUtils.is_valid_phone(data['phone']):
            return ResponseHelper.error('Geçerli bir telefon numarası girin', status_code=400)

        # Check if user exists
        if User.query.filter_by(email=data['email']).first():
            return ResponseHelper.error('Bu email zaten kayıtlı', status_code=400)

        user = User(
            email=data['email'],
            phone=data['phone'],
            first_name=data['first_name'],
            last_name=data['last_name'],
            user_type=data['user_type'],
            is_active=True,
            created_at=datetime.utcnow()
        )
        user.set_password(data['password'])

        db.session.add(user)
        db.session.flush()

        if data['user_type'] == 'customer':
            profile = Customer(
                user_id=user.id,
                billing_address=data.get('billing_address'),
                city=data.get('city'),
                district=data.get('district'),
                created_at=datetime.utcnow()
            )
            db.session.add(profile)
        else:
            profile = Craftsman(
                user_id=user.id,
                business_name=data.get('business_name'),
                description=data.get('description'),
                specialties=data.get('specialties'),
                experience_years=data.get('experience_years'),
                hourly_rate=data.get('hourly_rate'),
                city=data.get('city'),
                district=data.get('district'),
                is_available=True,
                created_at=datetime.utcnow()
            )
            db.session.add(profile)

        db.session.commit()

        access_token = create_access_token(identity=str(user.id))

        return ResponseHelper.success({
            'access_token': access_token,
            'user': user.to_dict()
        }, 'Kayıt başarılı', status_code=201)

    except Exception:
        db.session.rollback()
        return ResponseHelper.error('Bir hata oluştu', status_code=500)

@auth_bp.route('/login', methods=['POST'])
@rate_limit(max_requests=5, window_minutes=1, namespace='auth-simple-login')
def login():
    """User login endpoint"""
    try:
        data = request.get_json() or {}

        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return ResponseHelper.error('Email ve şifre gerekli', status_code=400)

        # Find user
        user = User.query.filter_by(email=email).first()

        if not user or not user.check_password(password):
            return ResponseHelper.unauthorized('E-posta veya şifre hatalı')

        if not user.is_active:
            return ResponseHelper.unauthorized('Hesabınız deaktif durumda')

        # Update last login
        user.last_login = datetime.utcnow()
        db.session.commit()

        # Create token
        access_token = create_access_token(identity=str(user.id))

        return ResponseHelper.success({
            'access_token': access_token,
            'user': user.to_dict()
        }, 'Giriş başarılı')

    except Exception:
        return ResponseHelper.error('Bir hata oluştu', status_code=500)

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return ResponseHelper.error('Kullanıcı bulunamadı', status_code=404)
        
        profile_data = {
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone': user.phone,
            'user_type': user.user_type,
            'is_active': user.is_active,
            'created_at': user.created_at.isoformat() if user.created_at else None
        }
        
        return ResponseHelper.success({'user': profile_data}, 'Profil bilgileri alındı')

    except Exception:
        return ResponseHelper.error('Bir hata oluştu', status_code=500)

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """User logout endpoint"""
    try:
        return ResponseHelper.success({}, 'Çıkış başarılı')

    except Exception:
        return ResponseHelper.error('Bir hata oluştu', status_code=500)


@auth_bp.route('/delete-account', methods=['DELETE'])
@jwt_required()
def delete_account():
    """Delete the authenticated user's account."""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)

        if not user:
            return ResponseHelper.error('Kullanıcı bulunamadı', status_code=404)

        db.session.delete(user)
        db.session.commit()

        return ResponseHelper.success({}, 'Hesabınız başarıyla silindi')

    except Exception:
        db.session.rollback()
        return ResponseHelper.error('Bir hata oluştu', status_code=500)