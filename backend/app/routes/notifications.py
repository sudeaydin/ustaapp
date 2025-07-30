from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.notification import Notification
from app.models.user import User

notifications_bp = Blueprint('notifications', __name__)

@notifications_bp.route('/api/notifications', methods=['GET'])
@jwt_required()
def get_notifications():
    """Get notifications for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get query parameters
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        unread_only = request.args.get('unread_only', 'false').lower() == 'true'
        
        # Build query
        query = Notification.query.filter_by(user_id=current_user_id)
        
        if unread_only:
            query = query.filter_by(is_read=False)
        
        # Order by created_at desc and paginate
        notifications = query.order_by(Notification.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        return jsonify({
            'success': True,
            'data': {
                'notifications': [notification.to_dict() for notification in notifications.items],
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': notifications.total,
                    'pages': notifications.pages,
                    'has_next': notifications.has_next,
                    'has_prev': notifications.has_prev,
                }
            }
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@notifications_bp.route('/api/notifications/<int:notification_id>/read', methods=['PUT'])
@jwt_required()
def mark_notification_read(notification_id):
    """Mark a notification as read"""
    try:
        current_user_id = get_jwt_identity()
        notification = Notification.query.get_or_404(notification_id)
        
        # Check if user owns this notification
        if notification.user_id != current_user_id:
            return jsonify({'success': False, 'message': 'Access denied'}), 403
        
        notification.mark_as_read()
        
        return jsonify({
            'success': True,
            'message': 'Notification marked as read'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@notifications_bp.route('/api/notifications/mark-all-read', methods=['PUT'])
@jwt_required()
def mark_all_notifications_read():
    """Mark all notifications as read for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get all unread notifications for user
        unread_notifications = Notification.query.filter_by(
            user_id=current_user_id,
            is_read=False
        ).all()
        
        # Mark all as read
        for notification in unread_notifications:
            notification.mark_as_read()
        
        return jsonify({
            'success': True,
            'message': f'{len(unread_notifications)} notifications marked as read'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@notifications_bp.route('/api/notifications/<int:notification_id>', methods=['DELETE'])
@jwt_required()
def delete_notification(notification_id):
    """Delete a notification"""
    try:
        current_user_id = get_jwt_identity()
        notification = Notification.query.get_or_404(notification_id)
        
        # Check if user owns this notification
        if notification.user_id != current_user_id:
            return jsonify({'success': False, 'message': 'Access denied'}), 403
        
        db.session.delete(notification)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Notification deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

@notifications_bp.route('/api/notifications/unread-count', methods=['GET'])
@jwt_required()
def get_unread_count():
    """Get unread notification count for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        count = Notification.query.filter_by(
            user_id=current_user_id,
            is_read=False
        ).count()
        
        return jsonify({
            'success': True,
            'data': {'unread_count': count}
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500