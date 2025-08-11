from app import db
from datetime import datetime
from enum import Enum

class TicketStatus(Enum):
    OPEN = 'open'
    IN_PROGRESS = 'in_progress'
    WAITING_FOR_CUSTOMER = 'waiting_for_customer'
    RESOLVED = 'resolved'
    CLOSED = 'closed'

class TicketPriority(Enum):
    LOW = 'low'
    MEDIUM = 'medium'
    HIGH = 'high'
    URGENT = 'urgent'

class TicketCategory(Enum):
    TECHNICAL = 'technical'
    BILLING = 'billing'
    ACCOUNT = 'account'
    FEATURE_REQUEST = 'feature_request'
    BUG_REPORT = 'bug_report'
    GENERAL = 'general'

class SupportTicket(db.Model):
    """Support ticket model for customer service"""
    __tablename__ = 'support_tickets'
    
    id = db.Column(db.Integer, primary_key=True)
    ticket_number = db.Column(db.String(20), unique=True, nullable=False, index=True)
    
    # User information
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    user = db.relationship('User', backref='support_tickets')
    
    # Ticket details
    subject = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    category = db.Column(db.Enum(TicketCategory), default=TicketCategory.GENERAL)
    priority = db.Column(db.Enum(TicketPriority), default=TicketPriority.MEDIUM)
    status = db.Column(db.Enum(TicketStatus), default=TicketStatus.OPEN)
    
    # Assignment
    assigned_to = db.Column(db.String(100))  # Support agent email
    
    # Metadata
    attachments = db.Column(db.Text)  # JSON array of file paths
    tags = db.Column(db.Text)  # JSON array of tags
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    resolved_at = db.Column(db.DateTime)
    closed_at = db.Column(db.DateTime)
    
    # Email tracking
    last_email_sent = db.Column(db.DateTime)
    email_thread_id = db.Column(db.String(100))  # For email thread tracking
    
    def generate_ticket_number(self):
        """Generate unique ticket number"""
        import random
        import string
        
        prefix = 'UST'
        timestamp = datetime.now().strftime('%y%m%d')
        random_suffix = ''.join(random.choices(string.digits, k=4))
        
        self.ticket_number = f"{prefix}-{timestamp}-{random_suffix}"
        
        # Ensure uniqueness
        while SupportTicket.query.filter_by(ticket_number=self.ticket_number).first():
            random_suffix = ''.join(random.choices(string.digits, k=4))
            self.ticket_number = f"{prefix}-{timestamp}-{random_suffix}"
    
    def to_dict(self):
        """Convert to dictionary for API responses"""
        return {
            'id': self.id,
            'ticket_number': self.ticket_number,
            'subject': self.subject,
            'description': self.description,
            'category': self.category.value if self.category else None,
            'priority': self.priority.value if self.priority else None,
            'status': self.status.value if self.status else None,
            'assigned_to': self.assigned_to,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'resolved_at': self.resolved_at.isoformat() if self.resolved_at else None,
            'user': {
                'id': self.user.id,
                'name': f"{self.user.first_name} {self.user.last_name}",
                'email': self.user.email,
                'user_type': self.user.user_type,
            } if self.user else None,
        }

class SupportMessage(db.Model):
    """Support ticket messages/replies"""
    __tablename__ = 'support_messages'
    
    id = db.Column(db.Integer, primary_key=True)
    ticket_id = db.Column(db.Integer, db.ForeignKey('support_tickets.id'), nullable=False)
    ticket = db.relationship('SupportTicket', backref='messages')
    
    # Message details
    message = db.Column(db.Text, nullable=False)
    is_from_customer = db.Column(db.Boolean, default=True)
    sender_email = db.Column(db.String(120))  # Support agent email if from support
    
    # Attachments
    attachments = db.Column(db.Text)  # JSON array of file paths
    
    # Email tracking
    email_message_id = db.Column(db.String(200))  # Email message ID for tracking
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary for API responses"""
        return {
            'id': self.id,
            'message': self.message,
            'is_from_customer': self.is_from_customer,
            'sender_email': self.sender_email,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'attachments': self.attachments,
        }