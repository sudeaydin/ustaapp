from app import db
from datetime import datetime
from enum import Enum

class AppointmentStatus(Enum):
    PENDING = 'pending'
    CONFIRMED = 'confirmed'
    IN_PROGRESS = 'in_progress'
    COMPLETED = 'completed'
    CANCELLED = 'cancelled'
    RESCHEDULED = 'rescheduled'

class AppointmentType(Enum):
    CONSULTATION = 'consultation'
    WORK = 'work'
    FOLLOW_UP = 'follow_up'
    EMERGENCY = 'emergency'

class Appointment(db.Model):
    """Appointment model for scheduling"""
    __tablename__ = 'appointments'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Participants
    customer_id = db.Column(db.Integer, db.ForeignKey('customers.id'), nullable=False)
    craftsman_id = db.Column(db.Integer, db.ForeignKey('craftsmen.id'), nullable=False)
    quote_id = db.Column(db.Integer, db.ForeignKey('quotes.id'), nullable=True)
    
    # Appointment details
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    start_time = db.Column(db.DateTime, nullable=False)
    end_time = db.Column(db.DateTime, nullable=False)
    status = db.Column(db.Enum(AppointmentStatus), default=AppointmentStatus.PENDING)
    type = db.Column(db.Enum(AppointmentType), default=AppointmentType.CONSULTATION)
    
    # Location and notes
    location = db.Column(db.String(500))
    notes = db.Column(db.Text)
    is_all_day = db.Column(db.Boolean, default=False)
    reminder_time = db.Column(db.String(50))  # e.g., "30 minutes", "1 hour"
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    customer = db.relationship('Customer', backref='appointments')
    craftsman = db.relationship('Craftsman', backref='appointments')
    quote = db.relationship('Quote', backref='appointments')
    
    def to_dict(self, include_relations=True):
        """Convert to dictionary for API responses"""
        data = {
            'id': self.id,
            'customer_id': self.customer_id,
            'craftsman_id': self.craftsman_id,
            'quote_id': self.quote_id,
            'title': self.title,
            'description': self.description,
            'start_time': self.start_time.isoformat() if self.start_time else None,
            'end_time': self.end_time.isoformat() if self.end_time else None,
            'status': self.status.value if self.status else None,
            'type': self.type.value if self.type else None,
            'location': self.location,
            'notes': self.notes,
            'is_all_day': self.is_all_day,
            'reminder_time': self.reminder_time,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
        
        if include_relations:
            if self.customer and self.customer.user:
                data['customer'] = {
                    'id': self.customer.id,
                    'name': f"{self.customer.user.first_name} {self.customer.user.last_name}",
                    'phone': self.customer.user.phone,
                    'email': self.customer.user.email,
                    'profile_image': self.customer.user.profile_image,
                }
            
            if self.craftsman and self.craftsman.user:
                data['craftsman'] = {
                    'id': self.craftsman.id,
                    'name': f"{self.craftsman.user.first_name} {self.craftsman.user.last_name}",
                    'business_name': self.craftsman.business_name,
                    'phone': self.craftsman.user.phone,
                    'email': self.craftsman.user.email,
                    'profile_image': self.craftsman.user.profile_image,
                }
            
            if self.quote:
                data['quote'] = {
                    'id': self.quote.id,
                    'title': self.quote.title,
                    'price': float(self.quote.price) if self.quote.price else None,
                    'status': self.quote.status,
                }
        
        return data
    
    @property
    def duration_minutes(self):
        """Get appointment duration in minutes"""
        if self.start_time and self.end_time:
            return int((self.end_time - self.start_time).total_seconds() / 60)
        return 0
    
    @property
    def is_today(self):
        """Check if appointment is today"""
        if not self.start_time:
            return False
        today = datetime.now().date()
        return self.start_time.date() == today
    
    @property
    def is_upcoming(self):
        """Check if appointment is in the future"""
        if not self.start_time:
            return False
        return self.start_time > datetime.now()
    
    @property
    def is_past(self):
        """Check if appointment is in the past"""
        if not self.end_time:
            return False
        return self.end_time < datetime.now()
    
    @property
    def is_active(self):
        """Check if appointment is currently active"""
        if not self.start_time or not self.end_time:
            return False
        now = datetime.now()
        return self.start_time <= now <= self.end_time
    
    def can_be_cancelled(self):
        """Check if appointment can be cancelled"""
        return self.status in [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] and self.is_upcoming
    
    def can_be_rescheduled(self):
        """Check if appointment can be rescheduled"""
        return self.status in [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] and self.is_upcoming
    
    def __repr__(self):
        return f'<Appointment {self.id} - {self.title}>'