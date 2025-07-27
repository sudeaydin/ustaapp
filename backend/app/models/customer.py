from app import db
from datetime import datetime

class Customer(db.Model):
    """Customer profile extending User"""
    __tablename__ = 'customers'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True)
    
    # Customer specific fields
    company_name = db.Column(db.String(255))
    tax_number = db.Column(db.String(20))
    billing_address = db.Column(db.Text)
    
    # Preferences
    preferred_contact_method = db.Column(db.String(20), default='phone')  # phone, email, sms, app
    notification_preferences = db.Column(db.Text)  # JSON string
    
    # Statistics
    total_jobs = db.Column(db.Integer, default=0)
    total_spent = db.Column(db.Numeric(12, 2), default=0.00)
    average_rating = db.Column(db.Numeric(3, 2), default=0.00)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = db.relationship('User', backref=db.backref('customer_profile', uselist=False))
    quotes_sent = db.relationship('Quote', foreign_keys='Quote.customer_id', backref='customer', lazy='dynamic')
    
    def to_dict(self, include_user=True):
        data = {
            'id': self.id,
            'company_name': self.company_name,
            'tax_number': self.tax_number,
            'billing_address': self.billing_address,
            'preferred_contact_method': self.preferred_contact_method,
            'notification_preferences': self.notification_preferences,
            'total_jobs': self.total_jobs,
            'total_spent': str(self.total_spent) if self.total_spent else '0.00',
            'average_rating': str(self.average_rating) if self.average_rating else '0.00',
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_user and self.user:
            data['user'] = self.user.to_dict()
            
        return data
    
    def __repr__(self):
        return f'<Customer {self.user.full_name if self.user else self.id}>'
