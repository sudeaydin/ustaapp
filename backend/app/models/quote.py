from app.extensions import db
from datetime import datetime
from sqlalchemy import Numeric
from sqlalchemy.orm import validates
from enum import Enum

class QuoteStatus(Enum):
    PENDING = "pending"  # Müşteri teklif talep etti, usta henüz yanıtlamadı
    DETAILS_REQUESTED = "details_requested"  # Usta daha fazla detay istedi
    QUOTED = "quoted"  # Usta teklif verdi
    ACCEPTED = "accepted"  # Müşteri teklifi kabul etti
    REJECTED = "rejected"  # Müşteri teklifi reddetti
    REVISION_REQUESTED = "revision_requested"  # Müşteri yeni teklif istedi
    CANCELLED = "cancelled"  # İptal edildi
    COMPLETED = "completed"  # İş tamamlandı

class BudgetRange(Enum):
    RANGE_0_1000 = "0-1000"
    RANGE_1000_3000 = "1000-3000"
    RANGE_3000_5000 = "3000-5000"
    RANGE_5000_10000 = "5000-10000"
    RANGE_10000_20000 = "10000-20000"
    RANGE_20000_PLUS = "20000+"

class AreaType(Enum):
    SALON = "salon"
    MUTFAK = "mutfak"
    YATAK_ODASI = "yatak_odası"
    BANYO = "banyo"
    BALKON = "balkon"
    BAHCE = "bahçe"
    OFIS = "ofis"
    DIGER = "diğer"

class Quote(db.Model):
    __tablename__ = 'quotes'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Customer and Craftsman
    customer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    craftsman_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # 🔹 Service ilişkisi için ForeignKey
    service_id = db.Column(
        db.Integer,
        db.ForeignKey('services.id'),
        nullable=False                  # zorunlu yapmak istiyorsan False yaparsın
    )

    # Quote Request Details (from customer)
    category = db.Column(db.String(100), nullable=False)
    job_type = db.Column(db.String(100), nullable=False)
    location = db.Column(db.String(200), nullable=False)
    area_type = db.Column(db.String(100), nullable=False)  # salon, mutfak, etc.
    square_meters = db.Column(db.Integer)  # Optional
    budget_range = db.Column(db.String(20), nullable=False)  # 0-1000, 1000-2000, etc.
    description = db.Column(db.Text, nullable=False)
    additional_details = db.Column(db.Text)  # Extra details from customer
    
    # Date preferences from customer
    preferred_start_date = db.Column(db.Date)  # Earliest preferred start date
    preferred_end_date = db.Column(db.Date)    # Latest preferred completion date
    is_flexible_dates = db.Column(db.Boolean, default=True)  # Whether dates are flexible
    urgency_level = db.Column(db.String(20), default='normal')  # normal, urgent, emergency
    
    # Quote Response Details (from craftsman)
    craftsman_response_type = db.Column(db.String(50))  # quote, details_request, reject
    quoted_price = db.Column(Numeric(10, 2))
    craftsman_notes = db.Column(db.Text)
    estimated_start_date = db.Column(db.Date)
    estimated_end_date = db.Column(db.Date)
    estimated_duration_days = db.Column(db.Integer)
    
    # Quote Status
    status = db.Column(db.String(50), default=QuoteStatus.PENDING.value)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    craftsman_responded_at = db.Column(db.DateTime)
    customer_decision_at = db.Column(db.DateTime)
    
    # Relationships
    customer = db.relationship('User', foreign_keys=[customer_id], backref='customer_quotes')
    craftsman = db.relationship('User', foreign_keys=[craftsman_id], backref='craftsman_quotes')
    
    def __init__(self, **kwargs):
        quoted_amount = kwargs.pop('quoted_amount', None)
        status = kwargs.get('status')
        if isinstance(status, QuoteStatus):
            kwargs['status'] = status.value

        category_value = kwargs.get('category')
        if not kwargs.get('job_type'):
            kwargs['job_type'] = category_value or 'general'
        if kwargs.get('location') is None:
            kwargs['location'] = '' if category_value is None else (kwargs.get('location') or '')

        super().__init__(**kwargs)

        if quoted_amount is not None:
            self.quoted_price = quoted_amount

    @property
    def quoted_amount(self):
        return float(self.quoted_price) if self.quoted_price is not None else None

    @quoted_amount.setter
    def quoted_amount(self, value):
        self.quoted_price = value

    @validates('status')
    def _normalize_status(self, key, value):
        if isinstance(value, QuoteStatus):
            return value.value
        return value

    def to_dict(self):
        return {
            'id': self.id,
            'customer_id': self.customer_id,
            'service_id': self.service_id,
            'craftsman_id': self.craftsman_id,
            'category': self.category,
            'job_type': self.job_type,
            'location': self.location,
            'area_type': self.area_type,
            'square_meters': self.square_meters,
            'budget_range': self.budget_range,
            'description': self.description,
            'additional_details': self.additional_details,
            'preferred_start_date': self.preferred_start_date.isoformat() if self.preferred_start_date else None,
            'preferred_end_date': self.preferred_end_date.isoformat() if self.preferred_end_date else None,
            'is_flexible_dates': self.is_flexible_dates,
            'urgency_level': self.urgency_level,
            'craftsman_response_type': self.craftsman_response_type,
            'quoted_price': str(self.quoted_price) if self.quoted_price else None,
            'craftsman_notes': self.craftsman_notes,
            'estimated_start_date': self.estimated_start_date.isoformat() if self.estimated_start_date else None,
            'estimated_end_date': self.estimated_end_date.isoformat() if self.estimated_end_date else None,
            'estimated_duration_days': self.estimated_duration_days,
            'status': self.status,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'craftsman_responded_at': self.craftsman_responded_at.isoformat() if self.craftsman_responded_at else None,
            'customer_decision_at': self.customer_decision_at.isoformat() if self.customer_decision_at else None,
            'customer': {
                'id': self.customer.id,
                'name': f"{self.customer.first_name} {self.customer.last_name}",
                'phone': self.customer.phone,
                'email': self.customer.email,
            } if self.customer else None,
            'craftsman': {
                'id': self.craftsman.id,
                'name': f"{self.craftsman.first_name} {self.craftsman.last_name}",
                'phone': self.craftsman.phone,
                'email': self.craftsman.email,
            } if self.craftsman else None,
        }
    
    def update_status(self, new_status):
        """Update quote status with timestamp"""
        if isinstance(new_status, QuoteStatus):
            new_status = new_status.value
        self.status = new_status
        self.updated_at = datetime.utcnow()
        
        if new_status in [QuoteStatus.QUOTED.value, QuoteStatus.DETAILS_REQUESTED.value, QuoteStatus.REJECTED.value]:
            self.craftsman_responded_at = datetime.utcnow()
        elif new_status in [QuoteStatus.ACCEPTED.value, QuoteStatus.REJECTED.value, QuoteStatus.REVISION_REQUESTED.value]:
            self.customer_decision_at = datetime.utcnow()
        
        db.session.commit()
    
    def __repr__(self):
        return f'<Quote {self.id} - {self.status}>'
