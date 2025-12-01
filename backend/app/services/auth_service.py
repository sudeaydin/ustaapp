import bcrypt
from flask_jwt_extended import create_access_token
from ..models.user import User, UserType
from ..models.customer import Customer
from ..models.craftsman import Craftsman
from .. import db
from app.utils.password_validator import validate_password_strength
from app.utils.validators import ValidationUtils
from flask_jwt_extended import create_refresh_token

class AuthService:
    @staticmethod
    def register_user(data):
        """Register a new user with strong validation."""
        required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return None, f'{field} alanı zorunludur'

        # Validate email/phone
        if not ValidationUtils.is_valid_email(data['email']):
            return None, 'Geçerli bir e-posta adresi girin'

        if not ValidationUtils.is_valid_phone(data['phone']):
            return None, 'Geçerli bir telefon numarası girin'

        # Password strength
        is_valid, error_message = validate_password_strength(data['password'])
        if not is_valid:
            return None, error_message or 'Şifre gereksinimleri karşılanmıyor'

        # User type
        if data['user_type'] not in ['customer', 'craftsman']:
            return None, 'Geçersiz kullanıcı tipi'

        # Existing user checks
        existing_user = User.query.filter(
            (User.email == data['email']) | (User.phone == data['phone'])
        ).first()
        if existing_user:
            field = 'E-posta' if existing_user.email == data['email'] else 'Telefon'
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
        return user, None
    
    @staticmethod
    def login_user(email, password):
        """Login user"""
        user = User.query.filter_by(email=email, is_active=True).first()
        
        if not user or not user.check_password(password):
            return None, "Geçersiz email veya şifre"
        
        # Create access token
        access_token = create_access_token(identity=str(user.id))
        refresh_token = create_refresh_token(identity=str(user.id))

        return {
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': {
                'id': user.id,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'user_type': user.user_type,
                'avatar': user.avatar
            }
        }, None
    
    @staticmethod
    def get_user_profile(user_id):
        """Get user profile with related data"""
        user = User.query.get(user_id)
        if not user:
            return None
        
        profile_data = {
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone': user.phone,
            'user_type': user.user_type,
            'avatar': user.avatar,
            'is_active': user.is_active,
            'created_at': user.created_at
        }
        
        # Add profile-specific data
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                profile_data['customer'] = {
                    'id': customer.id,
                    'address': customer.address,
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
        
        return profile_data
    
    @staticmethod
    def update_user_profile(user_id, data):
        """Update user profile"""
        user = User.query.get(user_id)
        if not user:
            return None, "Kullanıcı bulunamadı"
        
        # Update user fields
        for key, value in data.items():
            if key in ['first_name', 'last_name', 'phone'] and hasattr(user, key):
                setattr(user, key, value)
        
        db.session.commit()
        return user, None
    
    @staticmethod
    def change_password(user_id, old_password, new_password):
        """Change user password"""
        user = User.query.get(user_id)
        if not user:
            return False, "Kullanıcı bulunamadı"
        
        if not user.check_password(old_password):
            return False, "Mevcut şifre yanlış"
        
        user.set_password(new_password)
        db.session.commit()
        return True, "Şifre başarıyla değiştirildi"
