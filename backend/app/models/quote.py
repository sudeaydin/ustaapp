from app import db
from datetime import datetime
from enum import Enum

class QuoteStatus(Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class Quote(db.Model):
    """Quote requests between customers and craftsmen"""
    __tablename__ = 'quotes'
    
    id = db.Column(db.Integer, primary_key=True)
    customer_id = db.Column(db.Integer, db.ForeignKey('customers.id'), nullable=False)
    craftsman_id = db.Column(db.Integer, db.ForeignKey('craftsmen.id'), nullable=False)
    service_id = db.Column(db.Integer, db.ForeignKey('services.id'), nullable=True)
    
    # Quote details
    status = db.Column(db.String(20), default='pending')
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    location = db.Column(db.String(200))
    
    # Budget from customer
    budget_min = db.Column(db.Float)
    budget_max = db.Column(db.Float)
    
    # Quote from craftsman
    quoted_price = db.Column(db.Float)
    craftsman_notes = db.Column(db.Text)
    
    # Work details
    preferred_date = db.Column(db.Date)
    estimated_duration = db.Column(db.String(100))  # e.g., "2-3 gün"
    work_address = db.Column(db.Text)
    contact_phone = db.Column(db.String(20))
    
    # Media
    customer_images = db.Column(db.JSON)  # Images from customer
    craftsman_images = db.Column(db.JSON)  # Images from craftsman
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    accepted_at = db.Column(db.DateTime)
    completed_at = db.Column(db.DateTime)
    
    # Relationships
    messages = db.relationship('Message', backref='quote', lazy='dynamic')
    
    def to_dict(self, include_details=False):
        data = {
            'id': self.id,
            'customer_id': self.customer_id,
            'craftsman_id': self.craftsman_id,
            'service_id': self.service_id,
            'status': self.status.value,
            'description': self.description,
            'budget_min': self.budget_min,
            'budget_max': self.budget_max,
            'quoted_price': self.quoted_price,
            'craftsman_notes': self.craftsman_notes,
            'preferred_date': self.preferred_date.isoformat() if self.preferred_date else None,
            'estimated_duration': self.estimated_duration,
            'work_address': self.work_address,
            'contact_phone': self.contact_phone,
            'customer_images': self.customer_images or [],
            'craftsman_images': self.craftsman_images or [],
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'accepted_at': self.accepted_at.isoformat() if self.accepted_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None
        }
        
        if include_details:
            if hasattr(self, 'customer') and self.customer:
                data['customer'] = {
                    'id': self.customer.id,
                    'user': {
                        'first_name': self.customer.user.first_name,
                        'last_name': self.customer.user.last_name,
                        'profile_image': self.customer.user.profile_image,
                        'phone': self.customer.user.phone
                    }
                }
                
            if hasattr(self, 'craftsman') and self.craftsman:
                data['craftsman'] = {
                    'id': self.craftsman.id,
                    'user': {
                        'first_name': self.craftsman.user.first_name,
                        'last_name': self.craftsman.user.last_name,
                        'profile_image': self.craftsman.user.profile_image,
                        'phone': self.craftsman.user.phone
                    },
                    'rating': self.craftsman.rating,
                    'review_count': self.craftsman.review_count
                }
                
            if hasattr(self, 'service') and self.service:
                data['service'] = {
                    'id': self.service.id,
                    'title': self.service.title,
                    'category': self.service.category.to_dict() if self.service.category else None
                }
        
        return data
    
    @property
    def budget_display(self):
        """Get formatted budget display"""
        if self.budget_min and self.budget_max:
            if self.budget_min == self.budget_max:
                return f"₺{self.budget_min}"
            else:
                return f"₺{self.budget_min}-{self.budget_max}"
        elif self.budget_min:
            return f"₺{self.budget_min}+"
        else:
            return "Bütçe belirtilmemiş"
    
    def can_chat(self):
        """Check if parties can chat (after quote is accepted)"""
        return self.status == QuoteStatus.ACCEPTED
    
    def __repr__(self):
        return f'<Quote {self.id} - {self.status.value}>'
