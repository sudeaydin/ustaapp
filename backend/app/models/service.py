from app.extensions import db
from datetime import datetime
from enum import Enum

class PriceUnit(Enum):
    PER_HOUR = "per_hour"
    PER_DAY = "per_day" 
    PER_JOB = "per_job"
    PER_M2 = "per_m2"
    PER_PIECE = "per_piece"

class Service(db.Model):
    """Services offered by craftsmen"""
    __tablename__ = 'services'
    
    id = db.Column(db.Integer, primary_key=True)
    craftsman_id = db.Column(db.Integer, db.ForeignKey('craftsmen.id'), nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'), nullable=False)
    
    # Service details
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    
    # Pricing
    price_min = db.Column(db.Float)
    price_max = db.Column(db.Float)
    price_unit = db.Column(db.Enum(PriceUnit), default=PriceUnit.PER_JOB)
    
    # Service area
    service_cities = db.Column(db.JSON)  # List of cities served
    
    # Media
    images = db.Column(db.JSON)  # List of image URLs
    
    # Status
    is_active = db.Column(db.Boolean, default=True)
     
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    quotes = db.relationship('Quote', backref='service', lazy='dynamic')
    
    def to_dict(self, include_craftsman=False):
        data = {
            'id': self.id,
            'craftsman_id': self.craftsman_id,
            'category_id': self.category_id,
            'title': self.title,
            'description': self.description,
            'price_min': self.price_min,
            'price_max': self.price_max,
            'price_unit': self.price_unit.value if self.price_unit else None,
            'service_cities': self.service_cities or [],
            'images': self.images or [],
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_craftsman and self.craftsman:
            data['craftsman'] = {
                'id': self.craftsman.id,
                'user': {
                    'first_name': self.craftsman.user.first_name,
                    'last_name': self.craftsman.user.last_name,
                    'profile_image': self.craftsman.user.profile_image
                },
                'rating': self.craftsman.rating,
                'review_count': self.craftsman.review_count,
                'location': self.craftsman.location,
                'experience_years': self.craftsman.experience_years
            }
            
        if hasattr(self, 'category') and self.category:
            data['category'] = self.category.to_dict()
            
        return data
    
    @property
    def price_display(self):
        """Get formatted price display"""
        if self.price_min and self.price_max:
            if self.price_min == self.price_max:
                return f"₺{self.price_min}"
            else:
                return f"₺{self.price_min}-{self.price_max}"
        elif self.price_min:
            return f"₺{self.price_min}+"
        else:
            return "Fiyat görüşülür"
    
    def __repr__(self):
        return f'<Service {self.title}>'
