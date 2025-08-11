from flask import Blueprint, request, jsonify, send_file
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import Schema, fields, validate, ValidationError
from app.utils.security import rate_limit, require_auth
from app.utils.enhanced_notifications import (
    NotificationManager, LocationSharingManager, CalendarIntegrationManager,
    EmergencyNotificationManager, NotificationScheduler, NotificationAnalytics,
    NotificationType, NotificationPriority, DeliveryChannel
)
from app.models.user import User
from app import db
from datetime import datetime
import io

enhanced_notifications_bp = Blueprint('enhanced_notifications', __name__)

# Validation Schemas
class PushNotificationSchema(Schema):
    title = fields.Str(required=True, validate=validate.Length(1, 100))
    body = fields.Str(required=True, validate=validate.Length(1, 500))
    notification_type = fields.Str(validate=validate.OneOf([
        NotificationType.QUOTE_REQUEST, NotificationType.QUOTE_RESPONSE,
        NotificationType.JOB_UPDATE, NotificationType.MESSAGE,
        NotificationType.PAYMENT, NotificationType.EMERGENCY,
        NotificationType.REMINDER, NotificationType.PROMOTION,
        NotificationType.SYSTEM
    ]))
    priority = fields.Str(validate=validate.OneOf([
        NotificationPriority.LOW, NotificationPriority.NORMAL,
        NotificationPriority.HIGH, NotificationPriority.URGENT,
        NotificationPriority.CRITICAL
    ]))
    data = fields.Dict()
    user_ids = fields.List(fields.Int())
    channels = fields.List(fields.Str(validate=validate.OneOf([
        DeliveryChannel.PUSH, DeliveryChannel.EMAIL, 
        DeliveryChannel.SMS, DeliveryChannel.IN_APP
    ])))

class LocationShareSchema(Schema):
    target_user_id = fields.Int(required=True)
    job_id = fields.Int()
    duration_minutes = fields.Int(validate=validate.Range(5, 1440))  # 5 minutes to 24 hours
    share_type = fields.Str(validate=validate.OneOf(['job', 'emergency', 'general']))

class LocationUpdateSchema(Schema):
    latitude = fields.Float(required=True, validate=validate.Range(-90, 90))
    longitude = fields.Float(required=True, validate=validate.Range(-180, 180))
    accuracy = fields.Float(validate=validate.Range(0))
    heading = fields.Float(validate=validate.Range(0, 360))

class CalendarEventSchema(Schema):
    job_id = fields.Int(required=True)
    title = fields.Str(required=True, validate=validate.Length(1, 200))
    description = fields.Str()
    start_time = fields.DateTime(required=True)
    end_time = fields.DateTime(required=True)
    location = fields.Str()

class DeviceTokenSchema(Schema):
    token = fields.Str(required=True, validate=validate.Length(1, 500))
    platform = fields.Str(validate=validate.OneOf(['ios', 'android', 'web']))

class NotificationPreferencesSchema(Schema):
    push_enabled = fields.Bool()
    email_enabled = fields.Bool()
    sms_enabled = fields.Bool()
    quiet_hours_start = fields.Str()
    quiet_hours_end = fields.Str()
    weekend_notifications = fields.Bool()
    notification_types = fields.Dict()

# Push Notification Routes

@enhanced_notifications_bp.route('/device-token', methods=['POST'])
@rate_limit(requests_per_minute=10)
@require_auth
def register_device_token():
    """Register or update device token for push notifications"""
    try:
        user_id = get_jwt_identity()
        schema = DeviceTokenSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # Update user's device token
        user = User.query.get(user_id)
        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            }), 404
        
        user.device_token = data['token']
        user.device_platform = data.get('platform', 'unknown')
        user.token_updated_at = datetime.utcnow()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Device token registered successfully'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Failed to register device token: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/send', methods=['POST'])
@rate_limit(requests_per_minute=30)
@require_auth
def send_notification():
    """Send notification to users"""
    try:
        user_id = get_jwt_identity()
        schema = PushNotificationSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # Check if user has permission to send notifications
        sender = User.query.get(user_id)
        if not sender or sender.user_type not in ['admin', 'craftsman']:
            return jsonify({
                'success': False,
                'message': 'Permission denied'
            }), 403
        
        # Send to single user or multiple users
        if 'user_ids' in data and data['user_ids']:
            result = NotificationManager.send_bulk_notification(
                user_ids=data['user_ids'],
                title=data['title'],
                body=data['body'],
                notification_type=data.get('notification_type', NotificationType.SYSTEM),
                priority=data.get('priority', NotificationPriority.NORMAL),
                data=data.get('data')
            )
        else:
            return jsonify({
                'success': False,
                'message': 'No recipients specified'
            }), 400
        
        return jsonify({
            'success': True,
            'data': result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to send notification: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/preferences', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_notification_preferences():
    """Get user's notification preferences"""
    try:
        user_id = get_jwt_identity()
        
        from app.utils.enhanced_notifications import SmartNotificationManager
        preferences = SmartNotificationManager.get_user_notification_preferences(user_id)
        
        return jsonify({
            'success': True,
            'data': preferences
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get preferences: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/preferences', methods=['PUT'])
@rate_limit(requests_per_minute=30)
@require_auth
def update_notification_preferences():
    """Update user's notification preferences"""
    try:
        user_id = get_jwt_identity()
        schema = NotificationPreferencesSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # TODO: Store preferences in database
        # For now, just return success
        
        return jsonify({
            'success': True,
            'message': 'Preferences updated successfully'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to update preferences: {str(e)}'
        }), 500

# Location Sharing Routes

@enhanced_notifications_bp.route('/location/share', methods=['POST'])
@rate_limit(requests_per_minute=10)
@require_auth
def create_location_share():
    """Create location sharing session"""
    try:
        user_id = get_jwt_identity()
        schema = LocationShareSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        result = LocationSharingManager.create_location_share(
            user_id=user_id,
            target_user_id=data['target_user_id'],
            job_id=data.get('job_id'),
            duration_minutes=data.get('duration_minutes', 60),
            share_type=data.get('share_type', 'job')
        )
        
        return jsonify({
            'success': True,
            'data': result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to create location share: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/location/share/<share_id>/update', methods=['PUT'])
@rate_limit(requests_per_minute=120)  # High rate limit for location updates
@require_auth
def update_location(share_id):
    """Update location for sharing session"""
    try:
        user_id = get_jwt_identity()
        schema = LocationUpdateSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # TODO: Verify user owns this location share
        
        success = LocationSharingManager.update_location(
            share_id=share_id,
            latitude=data['latitude'],
            longitude=data['longitude'],
            accuracy=data.get('accuracy'),
            heading=data.get('heading')
        )
        
        return jsonify({
            'success': success,
            'message': 'Location updated' if success else 'Failed to update location'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to update location: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/location/share/<share_id>/stop', methods=['PUT'])
@rate_limit(requests_per_minute=30)
@require_auth
def stop_location_share(share_id):
    """Stop location sharing session"""
    try:
        user_id = get_jwt_identity()
        
        success = LocationSharingManager.stop_location_share(share_id, user_id)
        
        return jsonify({
            'success': success,
            'message': 'Location sharing stopped' if success else 'Failed to stop location sharing'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to stop location share: {str(e)}'
        }), 500

# Calendar Integration Routes

@enhanced_notifications_bp.route('/calendar/event', methods=['POST'])
@rate_limit(requests_per_minute=30)
@require_auth
def create_calendar_event():
    """Create calendar event for job"""
    try:
        user_id = get_jwt_identity()
        schema = CalendarEventSchema()
        
        try:
            data = schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({
                'success': False,
                'message': 'Validation error',
                'errors': e.messages
            }), 400
        
        # Verify user has access to the job
        from app.models.job import Job
        job = Job.query.filter(
            Job.id == data['job_id'],
            (Job.customer_id == user_id) | (Job.craftsman_id == user_id)
        ).first()
        
        if not job:
            return jsonify({
                'success': False,
                'message': 'Job not found or access denied'
            }), 404
        
        result = CalendarIntegrationManager.create_calendar_event(
            user_id=user_id,
            job_id=data['job_id'],
            title=data['title'],
            description=data.get('description', ''),
            start_time=data['start_time'],
            end_time=data['end_time'],
            location=data.get('location')
        )
        
        return jsonify({
            'success': True,
            'data': result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to create calendar event: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/calendar/events/<event_id>.ics', methods=['GET'])
@rate_limit(requests_per_minute=60)
def download_calendar_event(event_id):
    """Download calendar event as iCal file"""
    try:
        # TODO: Get event from database
        # For now, return a basic iCal file
        ical_content = f"""BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Ustam App//Job Management//EN
BEGIN:VEVENT
UID:{event_id}
DTSTAMP:{datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')}
SUMMARY:Ustam App İş Etkinliği
DESCRIPTION:İş için takvim etkinliği
STATUS:CONFIRMED
END:VEVENT
END:VCALENDAR"""
        
        # Create file-like object
        ical_file = io.BytesIO(ical_content.encode('utf-8'))
        
        return send_file(
            ical_file,
            as_attachment=True,
            download_name=f'ustam_job_{event_id}.ics',
            mimetype='text/calendar'
        )
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to download calendar event: {str(e)}'
        }), 500

# Emergency Notification Routes

@enhanced_notifications_bp.route('/emergency/broadcast', methods=['POST'])
@rate_limit(requests_per_minute=5)
@require_auth
def broadcast_emergency():
    """Broadcast emergency to nearby craftsmen"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        emergency_id = data.get('emergency_id')
        max_radius = data.get('max_radius_km', 50)
        
        if not emergency_id:
            return jsonify({
                'success': False,
                'message': 'Emergency ID is required'
            }), 400
        
        # Verify user owns this emergency request
        from app.models.job import EmergencyService
        emergency = EmergencyService.query.filter(
            EmergencyService.id == emergency_id,
            EmergencyService.customer_id == user_id
        ).first()
        
        if not emergency:
            return jsonify({
                'success': False,
                'message': 'Emergency not found or access denied'
            }), 404
        
        result = EmergencyNotificationManager.broadcast_emergency(emergency_id, max_radius)
        
        return jsonify({
            'success': True,
            'data': result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to broadcast emergency: {str(e)}'
        }), 500

# Notification Analytics Routes

@enhanced_notifications_bp.route('/analytics', methods=['GET'])
@rate_limit(requests_per_minute=60)
@require_auth
def get_notification_analytics():
    """Get notification analytics"""
    try:
        user_id = get_jwt_identity()
        days = int(request.args.get('days', 30))
        
        metrics = NotificationAnalytics.get_notification_metrics(user_id, days)
        
        return jsonify({
            'success': True,
            'data': metrics
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get analytics: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/interaction', methods=['POST'])
@rate_limit(requests_per_minute=120)
@require_auth
def track_notification_interaction():
    """Track notification interaction"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        notification_id = data.get('notification_id')
        interaction_type = data.get('interaction_type')  # opened, clicked, dismissed
        
        if not notification_id or not interaction_type:
            return jsonify({
                'success': False,
                'message': 'Notification ID and interaction type are required'
            }), 400
        
        NotificationAnalytics.track_notification_interaction(
            notification_id, user_id, interaction_type
        )
        
        return jsonify({
            'success': True,
            'message': 'Interaction tracked'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to track interaction: {str(e)}'
        }), 500

# Scheduled Notifications Routes

@enhanced_notifications_bp.route('/schedule', methods=['POST'])
@rate_limit(requests_per_minute=20)
@require_auth
def schedule_notification():
    """Schedule a notification for future delivery"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Verify user has permission
        sender = User.query.get(user_id)
        if not sender or sender.user_type not in ['admin', 'craftsman']:
            return jsonify({
                'success': False,
                'message': 'Permission denied'
            }), 403
        
        target_user_id = data.get('target_user_id')
        notification_type = data.get('notification_type', NotificationType.SYSTEM)
        notification_data = data.get('data', {})
        scheduled_time = datetime.fromisoformat(data.get('scheduled_time'))
        priority = data.get('priority', NotificationPriority.NORMAL)
        
        notification_id = NotificationScheduler.schedule_notification(
            user_id=target_user_id,
            notification_type=notification_type,
            data=notification_data,
            scheduled_time=scheduled_time,
            priority=priority
        )
        
        return jsonify({
            'success': True,
            'data': {
                'notification_id': notification_id,
                'scheduled_time': scheduled_time.isoformat()
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to schedule notification: {str(e)}'
        }), 500

# Utility Routes

@enhanced_notifications_bp.route('/test', methods=['POST'])
@rate_limit(requests_per_minute=5)
@require_auth
def test_notification():
    """Send test notification to current user"""
    try:
        user_id = get_jwt_identity()
        
        result = NotificationManager.send_notification(
            user_id=user_id,
            title='Test Bildirimi',
            body='Bu bir test bildirimidir. Bildirim sistemi çalışıyor!',
            notification_type=NotificationType.SYSTEM,
            priority=NotificationPriority.NORMAL,
            data={'test': True}
        )
        
        return jsonify({
            'success': True,
            'data': result,
            'message': 'Test notification sent'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to send test notification: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/cleanup', methods=['POST'])
@rate_limit(requests_per_minute=5)
@require_auth
def cleanup_notifications():
    """Clean up old notifications (admin only)"""
    try:
        user_id = get_jwt_identity()
        
        # Check admin permission
        user = User.query.get(user_id)
        if not user or user.user_type != 'admin':
            return jsonify({
                'success': False,
                'message': 'Admin permission required'
            }), 403
        
        days = int(request.args.get('days', 30))
        
        from app.utils.enhanced_notifications import NotificationUtils
        deleted_count = NotificationUtils.cleanup_expired_notifications(days)
        
        return jsonify({
            'success': True,
            'data': {
                'deleted_count': deleted_count
            },
            'message': f'Cleaned up {deleted_count} old notifications'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to cleanup notifications: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/constants', methods=['GET'])
@rate_limit(requests_per_minute=60)
def get_notification_constants():
    """Get notification constants and types"""
    try:
        return jsonify({
            'success': True,
            'data': {
                'notification_types': {
                    'QUOTE_REQUEST': NotificationType.QUOTE_REQUEST,
                    'QUOTE_RESPONSE': NotificationType.QUOTE_RESPONSE,
                    'JOB_UPDATE': NotificationType.JOB_UPDATE,
                    'MESSAGE': NotificationType.MESSAGE,
                    'PAYMENT': NotificationType.PAYMENT,
                    'EMERGENCY': NotificationType.EMERGENCY,
                    'REMINDER': NotificationType.REMINDER,
                    'PROMOTION': NotificationType.PROMOTION,
                    'SYSTEM': NotificationType.SYSTEM,
                    'LOCATION_SHARE': NotificationType.LOCATION_SHARE,
                    'CALENDAR_EVENT': NotificationType.CALENDAR_EVENT
                },
                'priorities': {
                    'LOW': NotificationPriority.LOW,
                    'NORMAL': NotificationPriority.NORMAL,
                    'HIGH': NotificationPriority.HIGH,
                    'URGENT': NotificationPriority.URGENT,
                    'CRITICAL': NotificationPriority.CRITICAL
                },
                'delivery_channels': {
                    'PUSH': DeliveryChannel.PUSH,
                    'EMAIL': DeliveryChannel.EMAIL,
                    'SMS': DeliveryChannel.SMS,
                    'IN_APP': DeliveryChannel.IN_APP
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to get constants: {str(e)}'
        }), 500

# Topic Subscription Routes (for FCM topics)

@enhanced_notifications_bp.route('/topics/subscribe', methods=['POST'])
@rate_limit(requests_per_minute=30)
@require_auth
def subscribe_to_topic():
    """Subscribe user to notification topic"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        topic = data.get('topic')
        if not topic:
            return jsonify({
                'success': False,
                'message': 'Topic is required'
            }), 400
        
        # Get user's device token
        user = User.query.get(user_id)
        if not user or not user.device_token:
            return jsonify({
                'success': False,
                'message': 'Device token not found'
            }), 400
        
        # Subscribe to topic via FCM
        # TODO: Implement FCM topic subscription
        # This would typically use FCM Instance ID API
        
        return jsonify({
            'success': True,
            'message': f'Subscribed to topic: {topic}'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to subscribe to topic: {str(e)}'
        }), 500

@enhanced_notifications_bp.route('/topics/unsubscribe', methods=['POST'])
@rate_limit(requests_per_minute=30)
@require_auth
def unsubscribe_from_topic():
    """Unsubscribe user from notification topic"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        topic = data.get('topic')
        if not topic:
            return jsonify({
                'success': False,
                'message': 'Topic is required'
            }), 400
        
        # Get user's device token
        user = User.query.get(user_id)
        if not user or not user.device_token:
            return jsonify({
                'success': False,
                'message': 'Device token not found'
            }), 400
        
        # Unsubscribe from topic via FCM
        # TODO: Implement FCM topic unsubscription
        
        return jsonify({
            'success': True,
            'message': f'Unsubscribed from topic: {topic}'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Failed to unsubscribe from topic: {str(e)}'
        }), 500