import logging
import os
import json
import time
from flask_jwt_extended import create_access_token, create_refresh_token
from werkzeug.utils import secure_filename
from ..models.user import User, UserType
from ..models.customer import Customer
from ..models.craftsman import Craftsman
from ..models.job import Job, JobStatus
from ..models.review import Review
from ..models.quote import Quote
from ..models.message import Message
from ..models.notification import Notification
from ..models.payment import Payment
from .. import db
from app.utils.password_validator import validate_password_strength
from app.utils.validators import ValidationUtils

logger = logging.getLogger(__name__)

class AuthService:
    @staticmethod
    def register_user(data):
        """Register a new user with strong validation."""
        logger.debug("register_user:start email=%s", data.get('email'))
        required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 'user_type']
        for field in required_fields:
            if not data.get(field):
                logger.debug("register_user:missing_field %s", field)
                return None, f'{field} alanı zorunludur'

        # Validate email/phone
        if not ValidationUtils.is_valid_email(data['email']):
            logger.debug("register_user:invalid_email")
            return None, 'Geçerli bir e-posta adresi girin'

        if not ValidationUtils.is_valid_phone(data['phone']):
            logger.debug("register_user:invalid_phone")
            return None, 'Geçerli bir telefon numarası girin'

        # Password strength
        is_valid, error_message = validate_password_strength(data['password'])
        if not is_valid:
            logger.debug("register_user:weak_password")
            return None, error_message or 'Şifre gereksinimleri karşılanmıyor'

        # User type
        if data['user_type'] not in ['customer', 'craftsman']:
            logger.debug("register_user:invalid_user_type")
            return None, 'Geçersiz kullanıcı tipi'

        # Existing user checks
        existing_user = User.query.filter(
            (User.email == data['email']) | (User.phone == data['phone'])
        ).first()
        if existing_user:
            field = 'E-posta' if existing_user.email == data['email'] else 'Telefon'
            logger.debug("register_user:exists %s", field)
            return None, f'{field} adresi zaten kullanımda'

        # Create user
        user_type_value = UserType.CUSTOMER if data['user_type'] == 'customer' else UserType.CRAFTSMAN
        user = User(
            email=data['email'],
            phone=data['phone'],
            user_type=user_type_value,
            first_name=data['first_name'],
            last_name=data['last_name'],
            is_active=True,
        )
        user.set_password(data['password'])

        db.session.add(user)
        db.session.flush()  # Get user ID

        # Create profile based on user type
        if data['user_type'] == 'customer':
            profile = Customer(user_id=user.id)
        else:
            profile = Craftsman(
                user_id=user.id,
                business_name=data.get('business_name'),
                description=data.get('description'),
                address=data.get('address'),
                city=data.get('city'),
                district=data.get('district'),
                is_available=True,
            )
        db.session.add(profile)

        db.session.commit()
        logger.debug("register_user:success user_id=%s", user.id)
        return user, None
    
    @staticmethod
    def login_user(email, password):
        """Login user with enhanced JWT claims"""
        from datetime import datetime
        logger.debug("login_user:start email=%s", email)
        user = User.query.filter_by(email=email, is_active=True).first()

        if not user or not user.check_password(password):
            logger.debug("login_user:invalid_credentials")
            return None, "Geçersiz email veya şifre"

        # Update last login timestamp
        user.last_login = datetime.utcnow()
        db.session.commit()

        # Create access token with additional claims
        access_token = create_access_token(
            identity=str(user.id),
            additional_claims={
                'user_type': user.user_type,
                'email': user.email
            }
        )
        refresh_token = create_refresh_token(identity=str(user.id))

        # Get profile data with customer/craftsman info
        profile_data = {
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'user_type': user.user_type,
            'avatar': user.avatar_url,
            'is_active': user.is_active
        }

        # Add customer/craftsman profile
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                profile_data['customer_profile'] = {
                    'id': customer.id,
                    'address': customer.billing_address,
                    'city': customer.city,
                    'district': customer.district
                }
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                profile_data['craftsman_profile'] = {
                    'id': craftsman.id,
                    'business_name': craftsman.business_name,
                    'description': craftsman.description,
                    'city': craftsman.city,
                    'district': craftsman.district,
                    'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                    'average_rating': craftsman.average_rating,
                    'is_available': craftsman.is_available,
                    'is_verified': craftsman.is_verified
                }

        logger.debug("login_user:success user_id=%s", user.id)
        return {
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': profile_data
        }, None
    
    @staticmethod
    def get_user_profile(user_id):
        """Get user profile with related data"""
        logger.debug("get_user_profile:start user_id=%s", user_id)
        user = User.query.get(user_id)
        if not user:
            logger.debug("get_user_profile:not_found user_id=%s", user_id)
            return None
        
        profile_data = {
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone': user.phone,
            'user_type': user.user_type,
            'avatar': user.avatar_url,
            'is_active': user.is_active,
            'created_at': user.created_at
        }
        
        # Add profile-specific data
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                profile_data['customer'] = {
                    'id': customer.id,
                    'address': customer.billing_address,
                    'city': customer.city,
                    'district': customer.district
                }
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                profile_data['craftsman'] = {
                    'id': craftsman.id,
                    'business_name': craftsman.business_name,
                    'description': craftsman.description,
                    'address': craftsman.address,
                    'city': craftsman.city,
                    'district': craftsman.district,
                    'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                    'average_rating': craftsman.average_rating,
                    'total_reviews': craftsman.total_reviews,
                    'is_available': craftsman.is_available
                }
        
        logger.debug("get_user_profile:success user_id=%s", user_id)
        return profile_data
    
    @staticmethod
    def update_user_profile(user_id, data):
        """Update comprehensive user profile including customer/craftsman data"""
        logger.debug("update_user_profile:start user_id=%s", user_id)
        user = User.query.get(user_id)
        if not user:
            logger.debug("update_user_profile:not_found user_id=%s", user_id)
            return None, "Kullanıcı bulunamadı"

        # Update user basic info
        if 'first_name' in data:
            user.first_name = data['first_name']
        if 'last_name' in data:
            user.last_name = data['last_name']
        if 'phone' in data:
            # Validate phone
            if not ValidationUtils.is_valid_phone(data['phone']):
                return None, "Geçerli bir telefon numarası girin"
            user.phone = data['phone']
        if 'avatar' in data:
            user.avatar_url = data['avatar']

        from datetime import datetime
        user.updated_at = datetime.utcnow()

        # Update profile based on user type
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if not customer:
                customer = Customer(user_id=user.id)
                db.session.add(customer)

            if 'address' in data:
                customer.billing_address = data['address']
            if 'city' in data:
                customer.city = data['city']
            if 'district' in data:
                customer.district = data['district']

            customer.updated_at = datetime.utcnow()

        elif user.user_type == 'craftsman':
            import json
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
                except (ValueError, TypeError):
                    pass
            if 'experience_years' in data:
                try:
                    craftsman.experience_years = int(data['experience_years'])
                except (ValueError, TypeError):
                    pass
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

            craftsman.updated_at = datetime.utcnow()

        db.session.commit()
        logger.debug("update_user_profile:success user_id=%s", user_id)
        return user, None
    
    @staticmethod
    def change_password(user_id, old_password, new_password):
        """Change user password"""
        logger.debug("change_password:start user_id=%s", user_id)
        user = User.query.get(user_id)
        if not user:
            return False, "Kullanıcı bulunamadı"
        
        if not user.check_password(old_password):
            logger.debug("change_password:invalid_current user_id=%s", user_id)
            return False, "Mevcut şifre yanlış"

        is_valid, error_message = validate_password_strength(new_password)
        if not is_valid:
            logger.debug("change_password:weak_new_password user_id=%s", user_id)
            return False, error_message or "Şifre gereksinimleri karşılanmıyor"
        
        user.set_password(new_password)
        db.session.commit()
        logger.debug("change_password:success user_id=%s", user_id)
        return True, "Şifre başarıyla değiştirildi"

    @staticmethod
    def delete_account(user_id):
        """Delete user with all related data after checks."""
        logger.debug("delete_account:start user_id=%s", user_id)
        user = User.query.get(user_id)
        if not user:
            logger.debug("delete_account:not_found user_id=%s", user_id)
            return False, "Kullanıcı bulunamadı", 404

        try:
            user_type_value = getattr(user.user_type, 'value', user.user_type)

            if user_type_value == UserType.CUSTOMER.value:
                customer = Customer.query.filter_by(user_id=user.id).first()
                if customer:
                    active = Job.query.filter(
                        Job.customer_id == customer.id,
                        Job.status.in_([
                            JobStatus.PENDING.value,
                            JobStatus.ACCEPTED.value,
                            JobStatus.IN_PROGRESS.value
                        ])
                    ).first()
                    if active:
                        logger.debug("delete_account:active_jobs user_id=%s", user_id)
                        return False, 'Aktif işleriniz bulunduğu için hesabınızı silemezsiniz. Önce işlerinizi tamamlayın.', 400
            elif user_type_value == UserType.CRAFTSMAN.value:
                craftsman = Craftsman.query.filter_by(user_id=user.id).first()
                if craftsman:
                    active = Job.query.filter(
                        Job.assigned_craftsman_id == craftsman.id,
                        Job.status.in_([
                            JobStatus.ACCEPTED.value,
                            JobStatus.IN_PROGRESS.value
                        ])
                    ).first()
                    if active:
                        logger.debug("delete_account:active_assignments user_id=%s", user_id)
                        return False, 'Aktif işleriniz bulunduğu için hesabınızı silemezsiniz. Önce işlerinizi tamamlayın.', 400

            Quote.query.filter(
                (Quote.customer_id == user.id) | (Quote.craftsman_id == user.id)
            ).delete()
            Message.query.filter(
                (Message.sender_id == user.id) | (Message.receiver_id == user.id)
            ).delete()
            Notification.query.filter_by(user_id=user.id).delete()
            Review.query.filter(
                (Review.customer_id == user.id) | (Review.craftsman_id == user.id)
            ).delete()
            

            if user_type_value == UserType.CUSTOMER.value:
                cust = Customer.query.filter_by(user_id=user.id).first()
                if cust:
                    db.session.delete(cust)
            elif user_type_value == UserType.CRAFTSMAN.value:
                craft = Craftsman.query.filter_by(user_id=user.id).first()
                if craft:
                    db.session.delete(craft)

            db.session.delete(user)
            db.session.commit()
            logger.debug("delete_account:success user_id=%s", user_id)
            return True, "Hesabınız ve tüm verileriniz başarıyla silindi", 200
        except Exception as e:
            logger.exception("delete_account:error user_id=%s", user_id)
            db.session.rollback()
            return False, 'Hesap silme işlemi sırasında bir hata oluştu', 500

    @staticmethod
    def get_profile_with_details(user_id):
        """Return user with profile data."""
        logger.debug("get_profile_with_details:start user_id=%s", user_id)
        user = User.query.get(user_id)
        if not user:
            return None, "Kullanıcı bulunamadı"

        profile = user.to_dict()
        if user.user_type == UserType.CRAFTSMAN and user.craftsman_profile:
            profile['craftsman_profile'] = user.craftsman_profile.to_dict(include_user=False)
        if user.user_type == UserType.CUSTOMER and user.customer_profile:
            profile['customer_profile'] = user.customer_profile.to_dict(include_user=False)
        logger.debug("get_profile_with_details:success user_id=%s", user_id)
        return profile, None

    @staticmethod
    def google_auth(data):
        """Handle Google auth/register."""
        logger.debug("google_auth:start email=%s", data.get('email'))
        required_fields = ['user_type', 'google_id', 'email']
        for field in required_fields:
            if not data.get(field):
                return None, f'{field} is required'

        user_type = data['user_type']
        google_id = data['google_id']
        email = data['email']
        display_name = data.get('display_name', '')
        photo_url = data.get('photo_url', '')

        existing_user = User.query.filter_by(google_id=google_id).first()
        if existing_user:
            if not existing_user.is_active:
                return None, 'Hesabınız deaktif durumda'
            token = create_access_token(identity=str(existing_user.id))
            logger.debug("google_auth:login_success user_id=%s", existing_user.id)
            return {
                'token': token,
                'user': existing_user.to_dict()
            }, None

        name_parts = display_name.split(' ', 1)
        first_name = name_parts[0] if name_parts else 'Google'
        last_name = name_parts[1] if len(name_parts) > 1 else 'User'

        try:
            new_user = User(
                email=email,
                first_name=first_name,
                last_name=last_name,
                user_type=user_type,
                google_id=google_id,
                avatar_url=photo_url,
                is_active=True,
                email_verified=True,
            )
            db.session.add(new_user)
            db.session.flush()

            if user_type == 'craftsman':
                craft = Craftsman(
                    user_id=new_user.id,
                    business_name=f"{first_name} {last_name}",
                    is_available=True,
                    is_verified=False,
                )
                db.session.add(craft)

            db.session.commit()
            token = create_access_token(identity=str(new_user.id))
            logger.debug("google_auth:register_success user_id=%s", new_user.id)
            return {
                'token': token,
                'user': new_user.to_dict()
            }, None
        except Exception:
            logger.exception("google_auth:error email=%s", email)
            db.session.rollback()
            return None, 'Google authentication failed'

    @staticmethod
    def upload_avatar(user_id, file):
        """Upload user avatar with validation"""
        import uuid
        from datetime import datetime
        logger.debug("upload_avatar:start user_id=%s", user_id)

        user = User.query.get(user_id)
        if not user:
            return None, "Kullanıcı bulunamadı"

        if not file or file.filename == '':
            return None, "Dosya seçilmedi"

        # Validate file extension
        allowed_extensions = {'png', 'jpg', 'jpeg', 'gif'}
        file_extension = file.filename.rsplit('.', 1)[1].lower() if '.' in file.filename else ''
        if file_extension not in allowed_extensions:
            return None, "Sadece PNG, JPG, JPEG ve GIF dosyaları kabul edilir"

        # Generate unique filename
        filename = f"{uuid.uuid4()}.{file_extension}"

        # Create uploads directory if it doesn't exist
        upload_dir = os.path.join(os.getcwd(), 'uploads', 'avatars')
        os.makedirs(upload_dir, exist_ok=True)

        # Save file
        file_path = os.path.join(upload_dir, filename)
        file.save(file_path)

        # Update user avatar
        user.avatar_url = f"/uploads/avatars/{filename}"
        user.updated_at = datetime.utcnow()

        db.session.commit()
        logger.debug("upload_avatar:success user_id=%s filename=%s", user_id, filename)

        return user.avatar_url, None
