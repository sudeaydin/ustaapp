from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.services.auth_service import AuthService

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    """User login"""
    try:
        data = request.get_json()
        
        if not data.get('email') or not data.get('password'):
            return jsonify({
                'success': False,
                'message': 'Email ve şifre gerekli'
            }), 400
        
        result, error = AuthService.login_user(data['email'], data['password'])
        
        if error:
            return jsonify({
                'success': False,
                'message': error
            }), 401
        
        return jsonify({
            'success': True,
            'message': 'Giriş başarılı',
            'data': result
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@auth_bp.route('/register', methods=['POST'])
def register():
    """User registration"""
    try:
        data = request.get_json()
        
        # Required fields
        required_fields = ['email', 'password', 'confirm_password', 'first_name', 'last_name', 'phone', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'message': f'{field} alanı zorunludur'
                }), 400
        
        # Register user
        user, error = AuthService.register_user(data, data['user_type'])
        
        if error:
            return jsonify({
                'success': False,
                'message': error
            }), 400
        
        # Login the user automatically
        result, _ = AuthService.login_user(data['email'], data['password'])
        
        return jsonify({
            'success': True,
            'message': 'Kayıt başarılı',
            'data': result
        }), 201
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile"""
    try:
        user_id = get_jwt_identity()
        profile = AuthService.get_user_profile(user_id)
        
        if not profile:
            return jsonify({
                'success': False,
                'message': 'Kullanıcı bulunamadı'
            }), 404
        
        return jsonify({
            'success': True,
            'data': profile
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@auth_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update user profile"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        user, error = AuthService.update_user_profile(user_id, data)
        
        if error:
            return jsonify({
                'success': False,
                'message': error
            }), 400
        
        return jsonify({
            'success': True,
            'message': 'Profil güncellendi'
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500