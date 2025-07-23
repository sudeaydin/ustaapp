import bcrypt
from flask_jwt_extended import create_access_token
from ..models.user import User
from ..models.customer import Customer
from ..models.craftsman import Craftsman
from .. import db

class AuthService:
    @staticmethod
    def register_user(data, user_type='customer'):
        """Register a new user"""
        # Check if user already exists
        if User.query.filter_by(email=data['email']).first():
            return None, "Bu email adresi zaten kullanılıyor"
        
        # Check if passwords match
        if data['password'] != data['confirm_password']:
            return None, "Şifreler eşleşmiyor"
        
        # Create user
        user = User(
            email=data['email'],
            first_name=data['first_name'],
            last_name=data['last_name'],
            phone=data['phone'],
            user_type=user_type
        )
        user.set_password(data['password'])
        
        db.session.add(user)
        db.session.flush()  # Get user ID
        
        # Create profile based on user type
        if user_type == 'customer':
            profile = Customer(user_id=user.id)
            db.session.add(profile)
        elif user_type == 'craftsman':
            profile = Craftsman(
                user_id=user.id,
                business_name=data.get('business_name', ''),
                description=data.get('description', ''),
                address=data.get('address', ''),
                city=data.get('city', ''),
                district=data.get('district', '')
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
        access_token = create_access_token(identity=user.id)
        
        return {
            'access_token': access_token,
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