from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import json
import os

profile_bp = Blueprint('profile', __name__)

@profile_bp.route('/', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'Kullanıcı bulunamadı'
            }), 404
        
        profile_data = {
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone': user.phone,
            'user_type': user.user_type,
            'is_active': user.is_active,
            'created_at': user.created_at.isoformat() if user.created_at else None,
            'avatar': user.avatar
        }
        
        # Add specific profile data based on user type
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                profile_data['profile'] = {
                    'address': customer.address,
                    'city': customer.city,
                    'district': customer.district,
                    'created_at': customer.created_at.isoformat() if customer.created_at else None
                }
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                # Parse skills from JSON string
                skills = []
                if craftsman.skills:
                    try:
                        skills = json.loads(craftsman.skills) if isinstance(craftsman.skills, str) else craftsman.skills
                    except:
                        skills = [craftsman.skills] if craftsman.skills else []
                
                # Parse certifications from JSON string
                certifications = []
                if craftsman.certifications:
                    try:
                        certifications = json.loads(craftsman.certifications) if isinstance(craftsman.certifications, str) else craftsman.certifications
                    except:
                        certifications = [craftsman.certifications] if craftsman.certifications else []
                
                # Parse working hours from JSON string
                working_hours = {}
                if craftsman.working_hours:
                    try:
                        working_hours = json.loads(craftsman.working_hours) if isinstance(craftsman.working_hours, str) else craftsman.working_hours
                    except:
                        working_hours = {}
                
                # Parse service areas from JSON string
                service_areas = []
                if craftsman.service_areas:
                    try:
                        service_areas = json.loads(craftsman.service_areas) if isinstance(craftsman.service_areas, str) else craftsman.service_areas
                    except:
                        service_areas = []
                
                profile_data['profile'] = {
                    'business_name': craftsman.business_name,
                    'description': craftsman.description,
                    'address': craftsman.address,
                    'city': craftsman.city,
                    'district': craftsman.district,
                    'hourly_rate': float(craftsman.hourly_rate) if craftsman.hourly_rate else 0,
                    'average_rating': craftsman.average_rating or 0,
                    'total_reviews': craftsman.total_reviews or 0,
                    'is_available': craftsman.is_available,
                    'is_verified': craftsman.is_verified,
                    'experience_years': craftsman.experience_years or 0,
                    'skills': skills,
                    'certifications': certifications,
                    'working_hours': working_hours,
                    'service_areas': service_areas,
                    'website': craftsman.website,
                    'response_time': craftsman.response_time,
                    'created_at': craftsman.created_at.isoformat() if craftsman.created_at else None
                }
        
        return jsonify({
            'success': True,
            'data': profile_data
        }), 200
        
    except Exception as e:
        print(f"Get profile error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Profil bilgileri alınırken bir hata oluştu'
        }), 500

@profile_bp.route('/', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update user profile"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        data = request.get_json()
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'Kullanıcı bulunamadı'
            }), 404
        
        # Update user basic info
        if 'first_name' in data:
            user.first_name = data['first_name']
        if 'last_name' in data:
            user.last_name = data['last_name']
        if 'phone' in data:
            user.phone = data['phone']
        if 'avatar' in data:
            user.avatar = data['avatar']
        
        user.updated_at = datetime.now()
        
        # Update profile based on user type
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if not customer:
                customer = Customer(user_id=user.id)
                db.session.add(customer)
            
            if 'address' in data:
                customer.address = data['address']
            if 'city' in data:
                customer.city = data['city']
            if 'district' in data:
                customer.district = data['district']
            
            customer.updated_at = datetime.now()
            
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if not craftsman:
                craftsman = Craftsman(user_id=user.id)
                db.session.add(craftsman)
            
            if 'business_name' in data:
                craftsman.business_name = data['business_name']
            if 'description' in data:
                craftsman.description = data['description']
            if 'address' in data:
                craftsman.address = data['address']
            if 'city' in data:
                craftsman.city = data['city']
            if 'district' in data:
                craftsman.district = data['district']
            if 'hourly_rate' in data:
                try:
                    craftsman.hourly_rate = float(data['hourly_rate'])
                except:
                    craftsman.hourly_rate = None
            if 'experience_years' in data:
                try:
                    craftsman.experience_years = int(data['experience_years'])
                except:
                    craftsman.experience_years = 0
            if 'skills' in data:
                craftsman.skills = json.dumps(data['skills']) if isinstance(data['skills'], list) else data['skills']
            if 'certifications' in data:
                craftsman.certifications = json.dumps(data['certifications']) if isinstance(data['certifications'], list) else data['certifications']
            if 'working_hours' in data:
                craftsman.working_hours = json.dumps(data['working_hours']) if isinstance(data['working_hours'], dict) else data['working_hours']
            if 'service_areas' in data:
                craftsman.service_areas = json.dumps(data['service_areas']) if isinstance(data['service_areas'], list) else data['service_areas']
            if 'website' in data:
                craftsman.website = data['website']
            if 'response_time' in data:
                craftsman.response_time = data['response_time']
            if 'is_available' in data:
                craftsman.is_available = bool(data['is_available'])
            
            craftsman.updated_at = datetime.now()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Profil başarıyla güncellendi'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Update profile error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Profil güncellenirken bir hata oluştu'
        }), 500

@profile_bp.route('/password', methods=['PUT'])
@jwt_required()
def change_password():
    """Change user password"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        data = request.get_json()
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'Kullanıcı bulunamadı'
            }), 404
        
        current_password = data.get('current_password')
        new_password = data.get('new_password')
        
        if not current_password or not new_password:
            return jsonify({
                'success': False,
                'message': 'Mevcut şifre ve yeni şifre gerekli'
            }), 400
        
        # Check current password
        if not check_password_hash(user.password_hash, current_password):
            return jsonify({
                'success': False,
                'message': 'Mevcut şifre yanlış'
            }), 400
        
        # Validate new password
        if len(new_password) < 6:
            return jsonify({
                'success': False,
                'message': 'Yeni şifre en az 6 karakter olmalı'
            }), 400
        
        # Update password
        user.password_hash = generate_password_hash(new_password)
        user.updated_at = datetime.now()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Şifre başarıyla değiştirildi'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Change password error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Şifre değiştirilirken bir hata oluştu'
        }), 500

@profile_bp.route('/avatar', methods=['POST'])
@jwt_required()
def upload_avatar():
    """Upload user avatar"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'Kullanıcı bulunamadı'
            }), 404
        
        if 'avatar' not in request.files:
            return jsonify({
                'success': False,
                'message': 'Avatar dosyası gerekli'
            }), 400
        
        file = request.files['avatar']
        
        if file.filename == '':
            return jsonify({
                'success': False,
                'message': 'Dosya seçilmedi'
            }), 400
        
        # Check file type
        allowed_extensions = {'png', 'jpg', 'jpeg', 'gif'}
        if not file.filename.lower().endswith(tuple(allowed_extensions)):
            return jsonify({
                'success': False,
                'message': 'Sadece PNG, JPG, JPEG ve GIF dosyaları kabul edilir'
            }), 400
        
        # Generate unique filename
        import uuid
        filename = f"{uuid.uuid4()}_{file.filename}"
        
        # Create uploads directory if it doesn't exist
        upload_dir = os.path.join(os.getcwd(), 'uploads', 'avatars')
        os.makedirs(upload_dir, exist_ok=True)
        
        # Save file
        file_path = os.path.join(upload_dir, filename)
        file.save(file_path)
        
        # Update user avatar
        user.avatar = f"/uploads/avatars/{filename}"
        user.updated_at = datetime.now()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Avatar başarıyla yüklendi',
            'data': {
                'avatar_url': user.avatar
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Upload avatar error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Avatar yüklenirken bir hata oluştu'
        }), 500

@profile_bp.route('/delete', methods=['DELETE'])
@jwt_required()
def delete_account():
    """Delete user account"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'Kullanıcı bulunamadı'
            }), 404
        
        # Soft delete - mark as inactive
        user.is_active = False
        user.updated_at = datetime.now()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Hesap başarıyla silindi'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Delete account error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Hesap silinirken bir hata oluştu'
        }), 500