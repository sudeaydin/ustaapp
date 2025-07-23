from app import db
from datetime import datetime
from enum import Enum

class NotificationType(Enum):
    MESSAGE = "message"
    JOB = "job"
    PROPOSAL = "proposal"
    REVIEW = "review"
    PAYMENT = "payment"
    REMINDER = "reminder"
    SYSTEM = "system"

class NotificationPriority(Enum):
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    URGENT = "urgent"

class Notification(db.Model):
    """Notification model for user notifications"""
    __tablename__ = 'notifications'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Recipient
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # Notification content
    type = db.Column(db.String(20), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    priority = db.Column(db.String(10), default=NotificationPriority.NORMAL.value)
    
    # Status
    is_read = db.Column(db.Boolean, default=False)
    is_deleted = db.Column(db.Boolean, default=False)
    
    # Related entities (optional)
    related_id = db.Column(db.Integer)  # ID of related entity (quote, message, etc.)
    related_type = db.Column(db.String(50))  # Type of related entity
    
    # Action URL (optional)
    action_url = db.Column(db.String(500))
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    read_at = db.Column(db.DateTime)
    
    # Relationships
    user = db.relationship('User', backref='notifications')
    
    def to_dict(self):
        """Convert notification to dictionary"""
        return {
            'id': self.id,
            'type': self.type,
            'title': self.title,
            'message': self.message,
            'priority': self.priority,
            'is_read': self.is_read,
            'related_id': self.related_id,
            'related_type': self.related_type,
            'action_url': self.action_url,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'read_at': self.read_at.isoformat() if self.read_at else None
        }
    
    def mark_as_read(self):
        """Mark notification as read"""
        if not self.is_read:
            self.is_read = True
            self.read_at = datetime.utcnow()
            db.session.commit()
    
    @staticmethod
    def create_notification(user_id, notification_type, title, message, 
                          priority=NotificationPriority.NORMAL.value,
                          related_id=None, related_type=None, action_url=None):
        """Create a new notification"""
        notification = Notification(
            user_id=user_id,
            type=notification_type,
            title=title,
            message=message,
            priority=priority,
            related_id=related_id,
            related_type=related_type,
            action_url=action_url
        )
        
        db.session.add(notification)
        db.session.commit()
        return notification
    
    @staticmethod
    def get_user_notifications(user_id, unread_only=False, limit=None):
        """Get notifications for a user"""
        query = Notification.query.filter_by(
            user_id=user_id,
            is_deleted=False
        )
        
        if unread_only:
            query = query.filter_by(is_read=False)
        
        query = query.order_by(Notification.created_at.desc())
        
        if limit:
            query = query.limit(limit)
        
        return query.all()
    
    @staticmethod
    def get_unread_count(user_id):
        """Get count of unread notifications for a user"""
        return Notification.query.filter_by(
            user_id=user_id,
            is_read=False,
            is_deleted=False
        ).count()
    
    @staticmethod
    def mark_all_as_read(user_id):
        """Mark all notifications as read for a user"""
        notifications = Notification.query.filter_by(
            user_id=user_id,
            is_read=False,
            is_deleted=False
        ).all()
        
        for notification in notifications:
            notification.is_read = True
            notification.read_at = datetime.utcnow()
        
        db.session.commit()
        return len(notifications)
    
    @staticmethod
    def delete_old_notifications(days=30):
        """Delete notifications older than specified days"""
        from datetime import timedelta
        cutoff_date = datetime.utcnow() - timedelta(days=days)
        
        old_notifications = Notification.query.filter(
            Notification.created_at < cutoff_date
        ).all()
        
        for notification in old_notifications:
            db.session.delete(notification)
        
        db.session.commit()
        return len(old_notifications)