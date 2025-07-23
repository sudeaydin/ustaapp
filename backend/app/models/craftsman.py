from app import db
from datetime import datetime
from decimal import Decimal
from sqlalchemy import Numeric

class Craftsman(db.Model):
    """Craftsman profile extending User"""
    __tablename__ = 'craftsmen'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True)
    
    # Professional info
    business_name = db.Column(db.String(255))
    description = db.Column(db.Text)
    address = db.Column(db.String(500))
    city = db.Column(db.String(100))
    district = db.Column(db.String(100))
    hourly_rate = db.Column(Numeric(10, 2))
    
    # Ratings
    average_rating = db.Column(db.Float, default=0.0)
    total_reviews = db.Column(db.Integer, default=0)
    
    # Status
    is_available = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref=db.backref('craftsman_profile', uselist=False))
    
    def to_dict(self, include_user=True):
        data = {
            'id': self.id,
            'business_name': self.business_name,
            'description': self.description,
            'address': self.address,
            'city': self.city,
            'district': self.district,
            'hourly_rate': str(self.hourly_rate) if self.hourly_rate else None,
            'average_rating': self.average_rating,
            'total_reviews': self.total_reviews,
            'is_available': self.is_available,
            'is_verified': self.is_verified,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_user and self.user:
            data['user'] = self.user.to_dict()
            
        return data
    
    def __repr__(self):
        return f'<Craftsman {self.business_name or self.id}>'


# Association table for many-to-many relationship between craftsmen and categories
craftsman_categories = db.Table('craftsman_categories',
    db.Column('craftsman_id', db.Integer, db.ForeignKey('craftsmen.id'), primary_key=True),
    db.Column('category_id', db.Integer, db.ForeignKey('categories.id'), primary_key=True),
    db.Column('created_at', db.DateTime, default=datetime.utcnow)
)
