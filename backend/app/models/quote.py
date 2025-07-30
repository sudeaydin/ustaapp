from app import db
from datetime import datetime
from sqlalchemy import Numeric

class Quote(db.Model):
    __tablename__ = 'quotes'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Customer and Craftsman
    customer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    craftsman_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # Quote Details
    category = db.Column(db.String(100), nullable=False)
    job_type = db.Column(db.String(100), nullable=False)
    location = db.Column(db.String(200), nullable=False)
    area_type = db.Column(db.String(100), nullable=False)
    room_count = db.Column(db.String(50), nullable=False)
    square_meters = db.Column(db.Integer)
    description = db.Column(db.Text, nullable=False)
    
    # Quote Status
    status = db.Column(db.String(50), default='pending')  # pending, accepted, rejected, completed
    price = db.Column(Numeric(10, 2))
    estimated_duration = db.Column(db.String(100))
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    customer = db.relationship('User', foreign_keys=[customer_id], backref='customer_quotes')
    craftsman = db.relationship('User', foreign_keys=[craftsman_id], backref='craftsman_quotes')
    
    def to_dict(self):
        return {
            'id': self.id,
            'customer_id': self.customer_id,
            'craftsman_id': self.craftsman_id,
            'category': self.category,
            'job_type': self.job_type,
            'location': self.location,
            'area_type': self.area_type,
            'room_count': self.room_count,
            'square_meters': self.square_meters,
            'description': self.description,
            'status': self.status,
            'price': str(self.price) if self.price else None,
            'estimated_duration': self.estimated_duration,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'customer': {
                'id': self.customer.id,
                'name': f"{self.customer.first_name} {self.customer.last_name}",
                'phone': self.customer.phone,
            } if self.customer else None,
            'craftsman': {
                'id': self.craftsman.id,
                'name': f"{self.craftsman.first_name} {self.craftsman.last_name}",
                'business_name': self.craftsman.craftsman.business_name if self.craftsman.craftsman else None,
                'phone': self.craftsman.phone,
            } if self.craftsman else None,
        }
