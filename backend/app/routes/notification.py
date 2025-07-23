from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.notification import Notification, NotificationType, NotificationPriority
from datetime import datetime
import logging

notification_bp = Blueprint('notification', __name__)

@notification_bp.route('/', methods=['GET'])
@jwt_required()
def get_notifications():
    """Get notifications for the current user"""
    try:
        user_id = get_jwt_identity()
        
        # Get query parameters
        unread_only = request.args.get('unread_only', 'false').lower() == 'true'
        limit = request.args.get('limit', type=int)
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # Get notifications
        notifications = Notification.get_user_notifications(
            user_id, 
            unread_only=unread_only, 
            limit=limit
        )
        
        # Apply pagination if not using limit
        if not limit:
            start_idx = (page - 1) * per_page
            end_idx = start_idx + per_page
            paginated_notifications = notifications[start_idx:end_idx]
        else:
            paginated_notifications = notifications
        
        return jsonify({
            'success': True,
            'notifications': [n.to_dict() for n in paginated_notifications],
            'total': len(notifications),
            'unread_count': Notification.get_unread_count(user_id),
            'page': page if not limit else 1,
            'per_page': per_page if not limit else len(paginated_notifications)
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting notifications: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@notification_bp.route('/unread-count', methods=['GET'])
@jwt_required()
def get_unread_count():
    """Get count of unread notifications"""
    try:
        user_id = get_jwt_identity()
        count = Notification.get_unread_count(user_id)
        
        return jsonify({
            'success': True,
            'unread_count': count
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting unread count: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@notification_bp.route('/<int:notification_id>/read', methods=['POST'])
@jwt_required()
def mark_as_read():
    """Mark a notification as read"""
    try:
        user_id = get_jwt_identity()
        notification_id = request.view_args['notification_id']
        
        notification = Notification.query.filter_by(
            id=notification_id,
            user_id=user_id
        ).first()
        
        if not notification:
            return jsonify({
                'error': True,
                'message': 'Notification not found'
            }), 404
        
        notification.mark_as_read()
        
        return jsonify({
            'success': True,
            'message': 'Notification marked as read'
        }), 200
        
    except Exception as e:
        logging.error(f"Error marking notification as read: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@notification_bp.route('/mark-all-read', methods=['POST'])
@jwt_required()
def mark_all_as_read():
    """Mark all notifications as read"""
    try:
        user_id = get_jwt_identity()
        count = Notification.mark_all_as_read(user_id)
        
        return jsonify({
            'success': True,
            'message': f'{count} notifications marked as read'
        }), 200
        
    except Exception as e:
        logging.error(f"Error marking all notifications as read: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@notification_bp.route('/<int:notification_id>', methods=['DELETE'])
@jwt_required()
def delete_notification():
    """Delete a notification"""
    try:
        user_id = get_jwt_identity()
        notification_id = request.view_args['notification_id']
        
        notification = Notification.query.filter_by(
            id=notification_id,
            user_id=user_id
        ).first()
        
        if not notification:
            return jsonify({
                'error': True,
                'message': 'Notification not found'
            }), 404
        
        notification.is_deleted = True
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Notification deleted'
        }), 200
        
    except Exception as e:
        logging.error(f"Error deleting notification: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@notification_bp.route('/create', methods=['POST'])
@jwt_required()
def create_notification():
    """Create a new notification (admin/system use)"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['user_id', 'type', 'title', 'message']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} is required'
                }), 400
        
        # Validate notification type
        valid_types = [t.value for t in NotificationType]
        if data['type'] not in valid_types:
            return jsonify({
                'error': True,
                'message': f'Invalid notification type. Valid types: {valid_types}'
            }), 400
        
        # Validate priority if provided
        priority = data.get('priority', NotificationPriority.NORMAL.value)
        valid_priorities = [p.value for p in NotificationPriority]
        if priority not in valid_priorities:
            return jsonify({
                'error': True,
                'message': f'Invalid priority. Valid priorities: {valid_priorities}'
            }), 400
        
        # Create notification
        notification = Notification.create_notification(
            user_id=data['user_id'],
            notification_type=data['type'],
            title=data['title'],
            message=data['message'],
            priority=priority,
            related_id=data.get('related_id'),
            related_type=data.get('related_type'),
            action_url=data.get('action_url')
        )
        
        return jsonify({
            'success': True,
            'message': 'Notification created successfully',
            'notification': notification.to_dict()
        }), 201
        
    except Exception as e:
        logging.error(f"Error creating notification: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@notification_bp.route('/settings', methods=['GET'])
@jwt_required()
def get_notification_settings():
    """Get notification settings for user"""
    try:
        user_id = get_jwt_identity()
        
        # For now, return default settings
        # In a real app, you'd have a user_notification_settings table
        settings = {
            'email_notifications': True,
            'push_notifications': True,
            'sms_notifications': False,
            'notification_types': {
                'messages': True,
                'jobs': True,
                'proposals': True,
                'reviews': True,
                'payments': True,
                'reminders': True,
                'system': True
            }
        }
        
        return jsonify({
            'success': True,
            'settings': settings
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting notification settings: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@notification_bp.route('/settings', methods=['PUT'])
@jwt_required()
def update_notification_settings():
    """Update notification settings for user"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # For now, just return success
        # In a real app, you'd update the user_notification_settings table
        
        return jsonify({
            'success': True,
            'message': 'Notification settings updated successfully'
        }), 200
        
    except Exception as e:
        logging.error(f"Error updating notification settings: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

# Helper functions for creating specific notification types
def create_message_notification(recipient_id, sender_name, message_preview):
    """Create a message notification"""
    return Notification.create_notification(
        user_id=recipient_id,
        notification_type=NotificationType.MESSAGE.value,
        title=f"Yeni mesaj - {sender_name}",
        message=f"{sender_name} size bir mesaj gönderdi: {message_preview[:50]}...",
        priority=NotificationPriority.NORMAL.value,
        action_url="/messages"
    )

def create_job_notification(user_id, title, message, job_id=None):
    """Create a job-related notification"""
    return Notification.create_notification(
        user_id=user_id,
        notification_type=NotificationType.JOB.value,
        title=title,
        message=message,
        priority=NotificationPriority.NORMAL.value,
        related_id=job_id,
        related_type="job",
        action_url=f"/job/{job_id}" if job_id else "/jobs"
    )

def create_payment_notification(user_id, title, message, payment_id=None):
    """Create a payment notification"""
    return Notification.create_notification(
        user_id=user_id,
        notification_type=NotificationType.PAYMENT.value,
        title=title,
        message=message,
        priority=NotificationPriority.HIGH.value,
        related_id=payment_id,
        related_type="payment",
        action_url="/payment-history"
    )