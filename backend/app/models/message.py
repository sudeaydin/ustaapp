from app import db
from datetime import datetime

class Message(db.Model):
    """Messages between customers and craftsmen"""
    __tablename__ = 'messages'
    
    id = db.Column(db.Integer, primary_key=True)
    quote_id = db.Column(db.Integer, db.ForeignKey('quotes.id'), nullable=False)
    sender_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # Message content
    content = db.Column(db.Text, nullable=False)
    message_type = db.Column(db.String(20), default='text')  # text, image, file
    
    # File attachments
    attachments = db.Column(db.JSON)  # List of file URLs
    
    # Status
    is_read = db.Column(db.Boolean, default=False)
    is_system = db.Column(db.Boolean, default=False)  # System messages
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    read_at = db.Column(db.DateTime)
    
    # Relationships
    sender = db.relationship('User', backref='sent_messages')
    
    def to_dict(self):
        return {
            'id': self.id,
            'quote_id': self.quote_id,
            'sender_id': self.sender_id,
            'content': self.content,
            'message_type': self.message_type,
            'attachments': self.attachments or [],
            'is_read': self.is_read,
            'is_system': self.is_system,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'read_at': self.read_at.isoformat() if self.read_at else None,
            'sender': {
                'id': self.sender.id,
                'first_name': self.sender.first_name,
                'last_name': self.sender.last_name,
                'profile_image': self.sender.profile_image
            } if self.sender else None
        }
    
    def mark_as_read(self):
        """Mark message as read"""
        if not self.is_read:
            self.is_read = True
            self.read_at = datetime.utcnow()
            db.session.commit()
    
    def __repr__(self):
        return f'<Message {self.id} from {self.sender_id}>'


class CustomerServiceCase(db.Model):
    """Customer service cases"""
    __tablename__ = 'customer_service_cases'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    quote_id = db.Column(db.Integer, db.ForeignKey('quotes.id'))  # Optional, if case is related to a quote
    
    # Case details
    subject = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(50))  # complaint, question, technical, billing
    priority = db.Column(db.String(20), default='normal')  # low, normal, high, urgent
    status = db.Column(db.String(20), default='open')  # open, in_progress, resolved, closed
    
    # Assignment
    assigned_to = db.Column(db.Integer, db.ForeignKey('users.id'))  # Admin/support user
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    resolved_at = db.Column(db.DateTime)
    
    # Relationships
    user = db.relationship('User', foreign_keys=[user_id], backref='support_cases')
    assignee = db.relationship('User', foreign_keys=[assigned_to])
    quote = db.relationship('Quote', backref='support_cases')
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'quote_id': self.quote_id,
            'subject': self.subject,
            'description': self.description,
            'category': self.category,
            'priority': self.priority,
            'status': self.status,
            'assigned_to': self.assigned_to,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'resolved_at': self.resolved_at.isoformat() if self.resolved_at else None,
            'user': {
                'id': self.user.id,
                'first_name': self.user.first_name,
                'last_name': self.user.last_name,
                'email': self.user.email
            } if self.user else None,
            'assignee': {
                'id': self.assignee.id,
                'first_name': self.assignee.first_name,
                'last_name': self.assignee.last_name
            } if self.assignee else None
        }
    
    def __repr__(self):
        return f'<CustomerServiceCase {self.id} - {self.subject}>'
