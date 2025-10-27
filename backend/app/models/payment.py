from datetime import datetime
from enum import Enum

from app import db
from app.models.customer import Customer
from app.models.craftsman import Craftsman

class PaymentStatus(Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    REFUNDED = "refunded"
    CANCELLED = "cancelled"

class PaymentMethod(Enum):
    CREDIT_CARD = "credit_card"
    DEBIT_CARD = "debit_card"
    WALLET = "wallet"

class Payment(db.Model):
    """Payment model for handling transactions"""
    __tablename__ = 'payments'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Payment identifiers
    payment_id = db.Column(db.String(100), unique=True, nullable=False, index=True)
    transaction_id = db.Column(db.String(100), unique=True, nullable=False, index=True)
    
    # Relationships
    quote_id = db.Column(db.Integer, db.ForeignKey('quotes.id'), nullable=False)
    customer_id = db.Column(db.Integer, db.ForeignKey('customers.id'), nullable=False)
    craftsman_id = db.Column(db.Integer, db.ForeignKey('craftsmen.id'), nullable=False)
    
    # Payment details
    amount = db.Column(db.Numeric(10, 2), nullable=False)
    installment = db.Column(db.Integer, default=1)
    installment_fee = db.Column(db.Numeric(10, 2), default=0)
    total_amount = db.Column(db.Numeric(10, 2), nullable=False)
    
    # Payment method info
    payment_method = db.Column(db.String(20), nullable=False)
    card_type = db.Column(db.String(20))
    card_last_four = db.Column(db.String(4))
    
    # Status and processing
    status = db.Column(db.String(20), nullable=False, default=PaymentStatus.PENDING.value)
    provider = db.Column(db.String(50), default='iyzico')
    provider_payment_id = db.Column(db.String(100))
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    paid_at = db.Column(db.DateTime)
    
    # Relationships
    quote = db.relationship('Quote', backref='payments')
    customer = db.relationship('Customer', backref='payments')
    craftsman = db.relationship('Craftsman', backref='received_payments')
    
    def to_dict(self):
        """Convert payment to dictionary"""
        return {
            'id': self.id,
            'payment_id': self.payment_id,
            'transaction_id': self.transaction_id,
            'quote_id': self.quote_id,
            'amount': float(self.amount),
            'installment': self.installment,
            'installment_fee': float(self.installment_fee),
            'total_amount': float(self.total_amount),
            'payment_method': self.payment_method,
            'card_type': self.card_type,
            'card_last_four': self.card_last_four,
            'status': self.status,
            'provider': self.provider,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'paid_at': self.paid_at.isoformat() if self.paid_at else None
        }
    
    @staticmethod
    def get_user_payments(user_id, user_type='customer'):
        """Get payments for a specific user"""
        if user_type == 'customer':
            return Payment.query.join(Customer).filter(
                Customer.user_id == user_id
            ).order_by(Payment.created_at.desc()).all()
        else:
            return Payment.query.join(Craftsman).filter(
                Craftsman.user_id == user_id
            ).order_by(Payment.created_at.desc()).all()
    
    @staticmethod
    def get_payment_stats(user_id, user_type='customer'):
        """Get payment statistics for a user"""
        payments = Payment.get_user_payments(user_id, user_type)
        
        total_amount = sum(float(p.total_amount) for p in payments if p.status == PaymentStatus.COMPLETED.value)
        completed_count = len([p for p in payments if p.status == PaymentStatus.COMPLETED.value])
        pending_count = len([p for p in payments if p.status == PaymentStatus.PENDING.value])
        
        return {
            'total_amount': total_amount,
            'total_payments': len(payments),
            'completed_payments': completed_count,
            'pending_payments': pending_count,
            'average_amount': total_amount / completed_count if completed_count > 0 else 0
        }
