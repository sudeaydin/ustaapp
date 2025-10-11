"""
Simple Auth Routes for Deployment
Basic authentication without analytics dependencies
"""

from flask import Blueprint, request, jsonify, g
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash
from app import db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.utils.validators import ResponseHelper
from datetime import datetime
import re

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

@auth_bp.route('/register', methods=['POST'])
def register():
    """User registration endpoint"""
    try:
        data = request.get_json()
        
        # Required fields
        required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return ResponseHelper.error(f'{field} alanı zorunludur', 400)
        
        # Check if user exists
        if User.query.filter_by(email=data['email']).first():
            return ResponseHelper.error('Bu email zaten kayıtlı', 400)
        
        # Create user
        user = User(
            email=data['email'],
            password_hash=generate_password_hash(data['password']),
            first_name=data['first_name'],
            last_name=data['last_name'],
            phone=data['phone'],
            user_type=data['user_type'],
            is_active=True,
            created_at=datetime.utcnow()
        )
        
        db.session.add(user)
        db.session.flush()  # Get user ID
        
        # Create profile based on user type
        if data['user_type'] == 'customer':
            profile = Customer(
                user_id=user.id,
                created_at=datetime.utcnow()
            )
            db.session.add(profile)
        elif data['user_type'] == 'craftsman':
            profile = Craftsman(
                user_id=user.id,
                business_name=data.get('business_name', ''),
                description=data.get('description', ''),
                is_available=True,
                created_at=datetime.utcnow()
            )
            db.session.add(profile)
        
        db.session.commit()
        
        # Create token
        access_token = create_access_token(identity=str(user.id))
        
        return ResponseHelper.success({
            'access_token': access_token,
            'user': {
                'id': user.id,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'user_type': user.user_type
            }
        }, 'Kayıt başarılı')
        
    except Exception as e:
        db.session.rollback()
        return ResponseHelper.error('Bir hata oluştu', 500)

@auth_bp.route('/login', methods=['POST'])
def login():
    """User login endpoint"""
    try:
        data = request.get_json()
        
        email = data.get('email')
        password = data.get('password')
        
        if not email or not password:
            return ResponseHelper.error('Email ve şifre gerekli', 400)
        
        # Find user
        user = User.query.filter_by(email=email).first()
        
        if not user or not user.check_password(password):
            return ResponseHelper.error('E-posta veya şifre hatalı', 401)
        
        if not user.is_active:
            return ResponseHelper.error('Hesabınız deaktif durumda', 401)
        
        # Update last login
        user.last_login = datetime.utcnow()
        db.session.commit()
        
        # Create token
        access_token = create_access_token(identity=str(user.id))
        
        return ResponseHelper.success({
            'access_token': access_token,
            'user': {
                'id': user.id,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'user_type': user.user_type
            }
        }, 'Giriş başarılı')
        
    except Exception as e:
        return ResponseHelper.error('Bir hata oluştu', 500)

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return ResponseHelper.error('Kullanıcı bulunamadı', 404)
        
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
        
        return ResponseHelper.success(profile_data, 'Profil bilgileri alındı')
        
    except Exception as e:
        return ResponseHelper.error('Bir hata oluştu', 500)

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """User logout endpoint"""
    try:
        return ResponseHelper.success({}, 'Çıkış başarılı')
        
    except Exception as e:
        return ResponseHelper.error('Bir hata oluştu', 500)