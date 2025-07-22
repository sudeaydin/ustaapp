from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import check_password_hash
from app import db
from app.models.user import User, UserType
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from datetime import datetime
import re

auth_bp = Blueprint('auth', __name__)

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
def register():
    """User registration"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} alanı zorunludur',
                    'code': 'MISSING_FIELD'
                }), 400
        
        # Validate email format
        if not validate_email(data['email']):
            return jsonify({
                'error': True,
                'message': 'Geçerli bir e-posta adresi girin',
                'code': 'INVALID_EMAIL'
            }), 400
        
        # Validate phone format
        if not validate_phone(data['phone']):
            return jsonify({
                'error': True,
                'message': 'Geçerli bir telefon numarası girin',
                'code': 'INVALID_PHONE'
            }), 400
        
        # Validate password length
        if len(data['password']) < 6:
            return jsonify({
                'error': True,
                'message': 'Şifre en az 6 karakter olmalıdır',
                'code': 'PASSWORD_TOO_SHORT'
            }), 400
        
        # Validate user type
        if data['user_type'] not in ['customer', 'craftsman']:
            return jsonify({
                'error': True,
                'message': 'Geçersiz kullanıcı tipi',
                'code': 'INVALID_USER_TYPE'
            }), 400
        
        # Check if user already exists
        existing_user = User.query.filter(
            (User.email == data['email']) | (User.phone == data['phone'])
        ).first()
        
        if existing_user:
            field = 'E-posta' if existing_user.email == data['email'] else 'Telefon'
            return jsonify({
                'error': True,
                'message': f'{field} adresi zaten kullanımda',
                'code': 'USER_EXISTS'
            }), 400
        
        # Create user
        user = User(
            email=data['email'],
            phone=data['phone'],
            user_type=UserType.CUSTOMER if data['user_type'] == 'customer' else UserType.CRAFTSMAN,
            first_name=data['first_name'],
            last_name=data['last_name']
        )
        user.set_password(data['password'])
        
        db.session.add(user)
        db.session.flush()  # Get user ID
        
        # Create profile based on user type
        if data['user_type'] == 'customer':
            profile = Customer(user_id=user.id)
        else:
            profile = Craftsman(user_id=user.id)
        
        db.session.add(profile)
        db.session.commit()
        
        # Create access token
        access_token = create_access_token(identity=user.id)
        
        return jsonify({
            'success': True,
            'message': 'Hesabınız başarıyla oluşturuldu',
            'data': {
                'user': user.to_dict(),
                'access_token': access_token
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Kayıt sırasında bir hata oluştu',
            'code': 'REGISTRATION_ERROR'
        }), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """User login"""
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data.get('email') or not data.get('password'):
            return jsonify({
                'error': True,
                'message': 'E-posta ve şifre gereklidir',
                'code': 'MISSING_CREDENTIALS'
            }), 400
        
        # Find user
        user = User.query.filter_by(email=data['email']).first()
        
        if not user or not user.check_password(data['password']):
            return jsonify({
                'error': True,
                'message': 'E-posta veya şifre hatalı',
                'code': 'INVALID_CREDENTIALS'
            }), 401
        
        if not user.is_active:
            return jsonify({
                'error': True,
                'message': 'Hesabınız deaktif durumda',
                'code': 'ACCOUNT_DISABLED'
            }), 401
        
        # Update last login
        user.last_login = datetime.utcnow()
        db.session.commit()
        
        # Create access token
        access_token = create_access_token(identity=user.id)
        
        return jsonify({
            'success': True,
            'message': 'Başarıyla giriş yapıldı',
            'data': {
                'user': user.to_dict(),
                'access_token': access_token
            }
        })
        
    except Exception as e:
        return jsonify({
            'error': True,
            'message': 'Giriş sırasında bir hata oluştu',
            'code': 'LOGIN_ERROR'
        }), 500

@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """Get current user profile"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'error': True,
                'message': 'Kullanıcı bulunamadı',
                'code': 'USER_NOT_FOUND'
            }), 404
        
        # Include profile data
        profile_data = None
        if user.user_type == UserType.CUSTOMER and user.customer_profile:
            profile_data = user.customer_profile.to_dict(include_user=False)
        elif user.user_type == UserType.CRAFTSMAN and user.craftsman_profile:
            profile_data = user.craftsman_profile.to_dict(include_user=False)
        
        return jsonify({
            'success': True,
            'data': {
                'user': user.to_dict(),
                'profile': profile_data
            }
        })
        
    except Exception as e:
        return jsonify({
            'error': True,
            'message': 'Profil bilgileri alınamadı',
            'code': 'PROFILE_ERROR'
        }), 500

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
def change_password():
    """Change user password"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'error': True,
                'message': 'Kullanıcı bulunamadı',
                'code': 'USER_NOT_FOUND'
            }), 404
        
        data = request.get_json()
        
        # Validate required fields
        if not data.get('current_password') or not data.get('new_password'):
            return jsonify({
                'error': True,
                'message': 'Mevcut şifre ve yeni şifre gereklidir',
                'code': 'MISSING_PASSWORDS'
            }), 400
        
        # Validate current password
        if not user.check_password(data['current_password']):
            return jsonify({
                'error': True,
                'message': 'Mevcut şifre hatalı',
                'code': 'INVALID_CURRENT_PASSWORD'
            }), 400
        
        # Validate new password length
        if len(data['new_password']) < 6:
            return jsonify({
                'error': True,
                'message': 'Yeni şifre en az 6 karakter olmalıdır',
                'code': 'PASSWORD_TOO_SHORT'
            }), 400
        
        # Update password
        user.set_password(data['new_password'])
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Şifreniz başarıyla güncellendi'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Şifre güncellenirken bir hata oluştu',
            'code': 'PASSWORD_UPDATE_ERROR'
        }), 500
