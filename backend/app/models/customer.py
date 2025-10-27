from app import db
from datetime import datetime

class Customer(db.Model):
    __tablename__ = 'customers'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True)
    
    # Customer specific fields
    billing_address = db.Column(db.String(500))
    city = db.Column(db.String(100))
    district = db.Column(db.String(100))
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', back_populates='customer_profile', lazy='joined')
    
    def to_dict(self, include_user=True):
        data = {
            'id': self.id,
            'user_id': self.user_id,
            'billing_address': self.billing_address,
            'city': self.city,
            'district': self.district,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
        
        if include_user and self.user:
            data['user'] = self.user.to_dict()
            
        return data
