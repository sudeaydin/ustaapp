from app import db
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from enum import Enum
from sqlalchemy import Index
from sqlalchemy.orm import validates

class UserType(Enum):
    CUSTOMER = "customer"
    CRAFTSMAN = "craftsman"
    ADMIN = "admin"

class User(db.Model):
    """Base user model"""
    __tablename__ = 'users'
    
    # Add indexes for better performance
    __table_args__ = (
        Index('idx_user_email', 'email'),
        Index('idx_user_phone', 'phone'),
        Index('idx_user_type_active', 'user_type', 'is_active'),
        Index('idx_user_created_at', 'created_at'),
    )
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    phone = db.Column(db.String(20), unique=True, nullable=True, index=True)  # Nullable for Google users
    password_hash = db.Column(db.String(255), nullable=True)  # Nullable for Google users
    user_type = db.Column(db.String(20), nullable=False)
    
    # Profile fields
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    profile_image = db.Column(db.String(255))
    avatar_url = db.Column(db.String(500))  # For Google profile photos
    google_id = db.Column(db.String(100), unique=True, index=True)  # Google user ID
    date_of_birth = db.Column(db.Date)
    gender = db.Column(db.String(10))
    
    # Location fields
    city = db.Column(db.String(100))
    district = db.Column(db.String(100))
    address = db.Column(db.Text)
    latitude = db.Column(db.Numeric(10, 8))
    longitude = db.Column(db.Numeric(11, 8))
    
    # Status fields
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    phone_verified = db.Column(db.Boolean, default=False)
    email_verified = db.Column(db.Boolean, default=False)
    is_premium = db.Column(db.Boolean, default=False)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    
    def set_password(self, password):
        """Set password hash"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Check password against hash"""
        return check_password_hash(self.password_hash, password)

    @validates('user_type')
    def _normalize_user_type(self, key, value):
        """Allow assigning either enum instances or raw strings."""
        if isinstance(value, UserType):
            return value.value
        return value

    @property
    def user_type_enum(self):
        """Access the user type as an enum when needed."""
        try:
            return UserType(self.user_type) if self.user_type else None
        except ValueError:
            return None

    @property
    def craftsman(self):
        """Provide backwards-compatible access to the craftsman profile."""
        cached = getattr(self, '_cached_craftsman', None)
        if cached is not None:
            return cached

        profile = self.__dict__.get('craftsman_profile')
        user_id = self.__dict__.get('id')
        if user_id is None:
            state = getattr(self, '_sa_instance_state', None)
            if state and state.identity:
                user_id = state.identity[0]

        if profile is None and user_id:
            from app.models.craftsman import Craftsman

            profile = Craftsman.query.filter_by(user_id=user_id).first()

        setattr(self, '_cached_craftsman', profile)
        return profile

    @craftsman.setter
    def craftsman(self, value):
        self.craftsman_profile = value
        setattr(self, '_cached_craftsman', value)

    @property
    def customer(self):
        """Provide backwards-compatible access to the customer profile."""
        cached = getattr(self, '_cached_customer', None)
        if cached is not None:
            return cached

        profile = self.__dict__.get('customer_profile')
        user_id = self.__dict__.get('id')
        if user_id is None:
            state = getattr(self, '_sa_instance_state', None)
            if state and state.identity:
                user_id = state.identity[0]

        if profile is None and user_id:
            from app.models.customer import Customer

            profile = Customer.query.filter_by(user_id=user_id).first()

        setattr(self, '_cached_customer', profile)
        return profile

    @customer.setter
    def customer(self, value):
        self.customer_profile = value
        setattr(self, '_cached_customer', value)
    
    @property
    def full_name(self):
        """Get full name"""
        return f"{self.first_name} {self.last_name}"
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'email': self.email,
            'phone': self.phone,
            'user_type': self.user_type,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'full_name': self.full_name,
            'profile_image': self.profile_image,
            'date_of_birth': self.date_of_birth.isoformat() if self.date_of_birth else None,
            'gender': self.gender,
            'city': self.city,
            'district': self.district,
            'address': self.address,
            'latitude': str(self.latitude) if self.latitude else None,
            'longitude': str(self.longitude) if self.longitude else None,
            'is_active': self.is_active,
            'is_verified': self.is_verified,
            'phone_verified': self.phone_verified,
            'email_verified': self.email_verified,
            'is_premium': self.is_premium,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'last_login': self.last_login.isoformat() if self.last_login else None
        }
    
    def __repr__(self):
        return f'<User {self.email}>'
