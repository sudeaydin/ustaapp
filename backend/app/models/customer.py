from app import db
from datetime import datetime

class Customer(db.Model):
    """Customer profile extending User"""
    __tablename__ = 'customers'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True)
    
    # Profile info
    address = db.Column(db.Text)
    city = db.Column(db.String(100))
    district = db.Column(db.String(100))
    
    # Preferences
    preferred_contact = db.Column(db.String(20), default='phone')  # phone, email, app
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref=db.backref('customer_profile', uselist=False))
    quotes_sent = db.relationship('Quote', foreign_keys='Quote.customer_id', backref='customer', lazy='dynamic')
    
    def to_dict(self, include_user=True):
        data = {
            'id': self.id,
            'address': self.address,
            'city': self.city,
            'district': self.district,
            'preferred_contact': self.preferred_contact,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_user:
            data['user'] = self.user.to_dict()
            
        return data
    
    def __repr__(self):
        return f'<Customer {self.user.full_name if self.user else self.id}>'
