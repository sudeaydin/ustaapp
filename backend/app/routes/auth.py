import os
import json
import time
from werkzeug.utils import secure_filename
from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import check_password_hash
from app import db
from app.models.user import User, UserType
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from datetime import datetime
import re
from app.models.job import Job, JobStatus
from app.models.quote import Quote
from app.models.message import Message
from app.models.notification import Notification
from app.models.review import Review
from app.models.payment import Payment

auth_bp = Blueprint('auth', __name__)

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
UPLOAD_FOLDER = 'uploads/portfolio'

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
        access_token = create_access_token(identity=str(user.id))
        
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
        access_token = create_access_token(identity=str(user.id))
        
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

@auth_bp.route('/delete-account', methods=['DELETE'])
@jwt_required()
def delete_account():
    """Delete user account permanently (KVKK compliance)"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get user
        user = User.query.get(current_user_id)
        if not user:
            return jsonify({
                'error': True,
                'message': 'Kullanıcı bulunamadı',
                'code': 'USER_NOT_FOUND'
            }), 404
        
        # Check if user has active jobs or payments
        if user.user_type == UserType.CUSTOMER.value:
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                # Check for active jobs
                active_jobs = Job.query.filter(
                    Job.customer_id == customer.id,
                    Job.status.in_([
                        JobStatus.OPEN.value,
                        JobStatus.ASSIGNED.value,
                        JobStatus.IN_PROGRESS.value
                    ])
                ).first()
                
                if active_jobs:
                    return jsonify({
                        'error': True,
                        'message': 'Aktif işleriniz bulunduğu için hesabınızı silemezsiniz. Önce işlerinizi tamamlayın.',
                        'code': 'ACTIVE_JOBS_EXIST'
                    }), 400
        
        elif user.user_type == UserType.CRAFTSMAN.value:
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                # Check for active assignments
                active_assignments = Job.query.filter(
                    Job.assigned_craftsman_id == craftsman.id,
                    Job.status.in_([
                        JobStatus.ASSIGNED.value,
                        JobStatus.IN_PROGRESS.value
                    ])
                ).first()
                
                if active_assignments:
                    return jsonify({
                        'error': True,
                        'message': 'Aktif işleriniz bulunduğu için hesabınızı silemezsiniz. Önce işlerinizi tamamlayın.',
                        'code': 'ACTIVE_ASSIGNMENTS_EXIST'
                    }), 400
        
        # Delete related data (KVKK compliance - complete data removal)
        try:
            # Delete quotes
            Quote.query.filter(
                (Quote.customer_id == user.id) | (Quote.craftsman_id == user.id)
            ).delete()
            
            # Delete messages
            Message.query.filter(
                (Message.sender_id == user.id) | (Message.receiver_id == user.id)
            ).delete()
            
            # Delete notifications
            Notification.query.filter_by(user_id=user.id).delete()
            
            # Delete reviews
            Review.query.filter(
                (Review.customer_id == user.id) | (Review.craftsman_id == user.id)
            ).delete()
            
            # Delete payments
            Payment.query.filter_by(user_id=user.id).delete()
            
            # Delete customer/craftsman specific data
            if user.user_type == UserType.CUSTOMER.value:
                customer = Customer.query.filter_by(user_id=user.id).first()
                if customer:
                    db.session.delete(customer)
            
            elif user.user_type == UserType.CRAFTSMAN.value:
                craftsman = Craftsman.query.filter_by(user_id=user.id).first()
                if craftsman:
                    db.session.delete(craftsman)
            
            # Finally delete the user
            db.session.delete(user)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Hesabınız ve tüm verileriniz başarıyla silindi'
            })
            
        except Exception as delete_error:
            db.session.rollback()
            return jsonify({
                'error': True,
                'message': 'Hesap silme işlemi sırasında bir hata oluştu',
                'code': 'DELETE_PROCESS_ERROR'
            }), 500
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Hesap silme işlemi başarısız oldu',
            'code': 'DELETE_ACCOUNT_ERROR'
        }), 500

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@auth_bp.route('/upload-portfolio-image', methods=['POST'])
@jwt_required()
def upload_portfolio_image():
    """Upload portfolio image for craftsman"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user or user.user_type != 'craftsman':
            return jsonify({'error': True, 'message': 'Sadece ustalar görsel yükleyebilir', 'code': 'UNAUTHORIZED'}), 403
            
        craftsman = Craftsman.query.filter_by(user_id=current_user_id).first()
        if not craftsman:
            return jsonify({'error': True, 'message': 'Usta profili bulunamadı', 'code': 'CRAFTSMAN_NOT_FOUND'}), 404
        
        if 'image' not in request.files:
            return jsonify({'error': True, 'message': 'Görsel dosyası bulunamadı', 'code': 'NO_FILE'}), 400
            
        file = request.files['image']
        if file.filename == '':
            return jsonify({'error': True, 'message': 'Dosya seçilmedi', 'code': 'NO_FILE_SELECTED'}), 400
            
        if file and allowed_file(file.filename):
            # Create upload directory if it doesn't exist
            os.makedirs(UPLOAD_FOLDER, exist_ok=True)
            
            # Generate secure filename
            filename = secure_filename(file.filename)
            timestamp = str(int(time.time()))
            filename = f"{current_user_id}_{timestamp}_{filename}"
            file_path = os.path.join(UPLOAD_FOLDER, filename)
            
            # Save file
            file.save(file_path)
            
            # Update craftsman portfolio images
            current_images = json.loads(craftsman.portfolio_images) if craftsman.portfolio_images else []
            image_url = f"/uploads/portfolio/{filename}"
            current_images.append(image_url)
            
            # Limit to 10 images
            if len(current_images) > 10:
                # Remove oldest image file
                oldest_image = current_images.pop(0)
                try:
                    old_file_path = os.path.join('uploads/portfolio', os.path.basename(oldest_image))
                    if os.path.exists(old_file_path):
                        os.remove(old_file_path)
                except:
                    pass
            
            craftsman.portfolio_images = json.dumps(current_images)
            db.session.commit()
            
            return jsonify({
                'success': True, 
                'message': 'Görsel başarıyla yüklendi',
                'image_url': image_url,
                'portfolio_images': current_images
            })
        else:
            return jsonify({'error': True, 'message': 'Geçersiz dosya formatı. PNG, JPG, JPEG, GIF veya WEBP dosyası yükleyin', 'code': 'INVALID_FILE_TYPE'}), 400
            
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': True, 'message': 'Görsel yükleme başarısız oldu', 'code': 'UPLOAD_ERROR'}), 500

@auth_bp.route('/delete-portfolio-image', methods=['DELETE'])
@jwt_required()
def delete_portfolio_image():
    """Delete portfolio image for craftsman"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user or user.user_type != 'craftsman':
            return jsonify({'error': True, 'message': 'Sadece ustalar görsel silebilir', 'code': 'UNAUTHORIZED'}), 403
            
        craftsman = Craftsman.query.filter_by(user_id=current_user_id).first()
        if not craftsman:
            return jsonify({'error': True, 'message': 'Usta profili bulunamadı', 'code': 'CRAFTSMAN_NOT_FOUND'}), 404
        
        data = request.get_json()
        image_url = data.get('image_url')
        
        if not image_url:
            return jsonify({'error': True, 'message': 'Görsel URL\'si gerekli', 'code': 'IMAGE_URL_REQUIRED'}), 400
        
        current_images = json.loads(craftsman.portfolio_images) if craftsman.portfolio_images else []
        
        if image_url in current_images:
            current_images.remove(image_url)
            craftsman.portfolio_images = json.dumps(current_images)
            
            # Delete physical file
            try:
                file_path = os.path.join('uploads/portfolio', os.path.basename(image_url))
                if os.path.exists(file_path):
                    os.remove(file_path)
            except:
                pass
            
            db.session.commit()
            return jsonify({
                'success': True, 
                'message': 'Görsel başarıyla silindi',
                'portfolio_images': current_images
            })
        else:
            return jsonify({'error': True, 'message': 'Görsel bulunamadı', 'code': 'IMAGE_NOT_FOUND'}), 404
            
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': True, 'message': 'Görsel silme başarısız oldu', 'code': 'DELETE_ERROR'}), 500

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile with craftsman/customer data"""
    try:
        current_user_id = get_jwt_identity()
        print(f"🔍 Profile request for user ID: {current_user_id}")
        
        user = User.query.get(current_user_id)
        
        if not user:
            print(f"❌ User not found with ID: {current_user_id}")
            return jsonify({'error': True, 'message': 'Kullanıcı bulunamadı', 'code': 'USER_NOT_FOUND'}), 404
        
        print(f"✅ User found: {user.email}, type: {user.user_type}")
        profile_data = user.to_dict()
        
        # Add specific profile data based on user type
        if user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                print(f"✅ Craftsman profile found for {user.email}")
                profile_data['craftsman_profile'] = craftsman.to_dict(include_user=False)
            else:
                print(f"❌ No craftsman profile found for {user.email}")
        elif user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                print(f"✅ Customer profile found for {user.email}")
                profile_data['customer_profile'] = customer.to_dict(include_user=False)
            else:
                print(f"❌ No customer profile found for {user.email}")
        
        print(f"✅ Returning profile data for {user.email}")
        return jsonify({
            'success': True,
            'data': profile_data
        })
        
    except Exception as e:
        print(f"❌ Profile API Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': True, 'message': 'Profil bilgileri alınamadı', 'code': 'PROFILE_ERROR'}), 500
