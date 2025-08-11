from datetime import datetime, timedelta
from typing import List, Dict, Optional, Any
from flask import current_app
from app import db
from app.models.notification import Notification
from app.models.user import User
import json
import requests
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import smtplib
import uuid

# Notification types
class NotificationType:
    QUOTE_REQUEST = "quote_request"
    QUOTE_RESPONSE = "quote_response"
    JOB_UPDATE = "job_update"
    MESSAGE = "message"
    PAYMENT = "payment"
    EMERGENCY = "emergency"
    REMINDER = "reminder"
    PROMOTION = "promotion"
    SYSTEM = "system"
    LOCATION_SHARE = "location_share"
    CALENDAR_EVENT = "calendar_event"

# Notification priorities
class NotificationPriority:
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    URGENT = "urgent"
    CRITICAL = "critical"

# Delivery channels
class DeliveryChannel:
    PUSH = "push"
    EMAIL = "email"
    SMS = "sms"
    IN_APP = "in_app"

class PushNotificationManager:
    """Firebase Cloud Messaging (FCM) push notification manager"""
    
    def __init__(self):
        self.fcm_server_key = current_app.config.get('FCM_SERVER_KEY')
        self.fcm_url = "https://fcm.googleapis.com/fcm/send"
    
    def send_push_notification(self, device_tokens: List[str], title: str, body: str, 
                             data: Dict = None, priority: str = "high") -> Dict:
        """Send push notification via FCM"""
        try:
            if not self.fcm_server_key:
                return {'success': False, 'message': 'FCM not configured'}
            
            headers = {
                'Authorization': f'key={self.fcm_server_key}',
                'Content-Type': 'application/json'
            }
            
            # Prepare notification payload
            notification_payload = {
                'title': title,
                'body': body,
                'sound': 'default',
                'badge': 1
            }
            
            # Prepare data payload
            data_payload = data or {}
            data_payload.update({
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'timestamp': datetime.utcnow().isoformat()
            })
            
            results = []
            
            # Send to each device token
            for token in device_tokens:
                payload = {
                    'to': token,
                    'priority': priority,
                    'notification': notification_payload,
                    'data': data_payload
                }
                
                response = requests.post(
                    self.fcm_url,
                    headers=headers,
                    json=payload,
                    timeout=10
                )
                
                results.append({
                    'token': token,
                    'success': response.status_code == 200,
                    'response': response.json() if response.status_code == 200 else None,
                    'error': response.text if response.status_code != 200 else None
                })
            
            return {
                'success': True,
                'results': results,
                'sent_count': len([r for r in results if r['success']])
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'Push notification failed: {str(e)}'
            }
    
    def send_topic_notification(self, topic: str, title: str, body: str, 
                              data: Dict = None) -> Dict:
        """Send notification to a topic (e.g., all craftsmen in a city)"""
        try:
            headers = {
                'Authorization': f'key={self.fcm_server_key}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'to': f'/topics/{topic}',
                'priority': 'high',
                'notification': {
                    'title': title,
                    'body': body,
                    'sound': 'default'
                },
                'data': data or {}
            }
            
            response = requests.post(
                self.fcm_url,
                headers=headers,
                json=payload,
                timeout=10
            )
            
            return {
                'success': response.status_code == 200,
                'response': response.json() if response.status_code == 200 else None
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'Topic notification failed: {str(e)}'
            }

class LocationSharingManager:
    """Real-time location sharing for emergency services and job tracking"""
    
    @staticmethod
    def create_location_share(user_id: int, target_user_id: int, job_id: int = None, 
                            duration_minutes: int = 60, share_type: str = "job") -> Dict:
        """Create a location sharing session"""
        try:
            share_id = str(uuid.uuid4())
            expires_at = datetime.utcnow() + timedelta(minutes=duration_minutes)
            
            # Store in database (you would create a LocationShare model)
            location_share = {
                'id': share_id,
                'user_id': user_id,
                'target_user_id': target_user_id,
                'job_id': job_id,
                'share_type': share_type,
                'created_at': datetime.utcnow(),
                'expires_at': expires_at,
                'is_active': True
            }
            
            # TODO: Store in database
            # LocationShare.create(location_share)
            
            # Notify target user
            target_user = User.query.get(target_user_id)
            if target_user:
                NotificationManager.send_notification(
                    user_id=target_user_id,
                    title="Konum Paylaşımı",
                    body=f"Konum paylaşımı başlatıldı",
                    notification_type=NotificationType.LOCATION_SHARE,
                    data={
                        'share_id': share_id,
                        'job_id': job_id,
                        'duration_minutes': duration_minutes
                    }
                )
            
            return {
                'success': True,
                'share_id': share_id,
                'expires_at': expires_at.isoformat()
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'Failed to create location share: {str(e)}'
            }
    
    @staticmethod
    def update_location(share_id: str, latitude: float, longitude: float, 
                       accuracy: float = None, heading: float = None) -> bool:
        """Update location for an active sharing session"""
        try:
            # TODO: Update location in database and notify subscribers
            # This would typically use WebSocket for real-time updates
            
            location_update = {
                'share_id': share_id,
                'latitude': latitude,
                'longitude': longitude,
                'accuracy': accuracy,
                'heading': heading,
                'timestamp': datetime.utcnow().isoformat()
            }
            
            # Emit via SocketIO for real-time updates
            from app import socketio
            socketio.emit('location_update', location_update, room=f'location_share_{share_id}')
            
            return True
            
        except Exception as e:
            print(f"Failed to update location: {e}")
            return False
    
    @staticmethod
    def stop_location_share(share_id: str, user_id: int) -> bool:
        """Stop location sharing session"""
        try:
            # TODO: Update database to mark as inactive
            # location_share = LocationShare.query.filter_by(id=share_id, user_id=user_id).first()
            # location_share.is_active = False
            # db.session.commit()
            
            # Notify subscribers
            from app import socketio
            socketio.emit('location_share_ended', {'share_id': share_id}, room=f'location_share_{share_id}')
            
            return True
            
        except Exception as e:
            print(f"Failed to stop location share: {e}")
            return False

class CalendarIntegrationManager:
    """Calendar integration for job scheduling and reminders"""
    
    @staticmethod
    def create_calendar_event(user_id: int, job_id: int, title: str, description: str,
                            start_time: datetime, end_time: datetime, 
                            location: str = None) -> Dict:
        """Create calendar event for job"""
        try:
            event_id = str(uuid.uuid4())
            
            # Create iCal format event
            ical_content = CalendarIntegrationManager._generate_ical(
                event_id, title, description, start_time, end_time, location
            )
            
            # Store event data
            calendar_event = {
                'id': event_id,
                'user_id': user_id,
                'job_id': job_id,
                'title': title,
                'description': description,
                'start_time': start_time,
                'end_time': end_time,
                'location': location,
                'ical_content': ical_content,
                'created_at': datetime.utcnow()
            }
            
            # TODO: Store in database
            # CalendarEvent.create(calendar_event)
            
            # Send calendar invite notification
            user = User.query.get(user_id)
            if user:
                NotificationManager.send_notification(
                    user_id=user_id,
                    title="Takvim Etkinliği",
                    body=f"Yeni iş için takvim etkinliği oluşturuldu: {title}",
                    notification_type=NotificationType.CALENDAR_EVENT,
                    data={
                        'event_id': event_id,
                        'job_id': job_id,
                        'ical_url': f'/api/calendar/events/{event_id}.ics'
                    }
                )
            
            return {
                'success': True,
                'event_id': event_id,
                'ical_url': f'/api/calendar/events/{event_id}.ics'
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'Failed to create calendar event: {str(e)}'
            }
    
    @staticmethod
    def _generate_ical(event_id: str, title: str, description: str, 
                      start_time: datetime, end_time: datetime, location: str = None) -> str:
        """Generate iCal format content"""
        ical_lines = [
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "PRODID:-//Ustam App//Job Management//EN",
            "BEGIN:VEVENT",
            f"UID:{event_id}",
            f"DTSTAMP:{datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')}",
            f"DTSTART:{start_time.strftime('%Y%m%dT%H%M%SZ')}",
            f"DTEND:{end_time.strftime('%Y%m%dT%H%M%SZ')}",
            f"SUMMARY:{title}",
            f"DESCRIPTION:{description}",
        ]
        
        if location:
            ical_lines.append(f"LOCATION:{location}")
        
        ical_lines.extend([
            "STATUS:CONFIRMED",
            "SEQUENCE:0",
            "END:VEVENT",
            "END:VCALENDAR"
        ])
        
        return "\r\n".join(ical_lines)
    
    @staticmethod
    def create_job_reminders(job_id: int) -> List[Dict]:
        """Create automatic reminders for job milestones"""
        try:
            from app.models.job import Job
            
            job = Job.query.get(job_id)
            if not job:
                return []
            
            reminders = []
            
            # Reminder before job starts
            if job.scheduled_start:
                reminder_time = job.scheduled_start - timedelta(hours=2)
                if reminder_time > datetime.utcnow():
                    reminders.append({
                        'type': 'job_start_reminder',
                        'scheduled_time': reminder_time,
                        'title': 'İş Hatırlatması',
                        'body': f'{job.title} işi 2 saat içinde başlayacak',
                        'job_id': job_id
                    })
            
            # Daily progress reminder for in-progress jobs
            if job.status.value == 'in_progress':
                tomorrow = datetime.utcnow().replace(hour=9, minute=0, second=0, microsecond=0) + timedelta(days=1)
                reminders.append({
                    'type': 'progress_reminder',
                    'scheduled_time': tomorrow,
                    'title': 'İlerleme Güncellemesi',
                    'body': f'{job.title} işi için ilerleme güncellemesi paylaşın',
                    'job_id': job_id
                })
            
            # Warranty expiration reminder
            if job.warranty_end_date:
                warning_time = job.warranty_end_date - timedelta(days=30)
                if warning_time > datetime.utcnow():
                    reminders.append({
                        'type': 'warranty_expiring',
                        'scheduled_time': warning_time,
                        'title': 'Garanti Süresi',
                        'body': f'{job.title} işinin garantisi 30 gün içinde sona erecek',
                        'job_id': job_id
                    })
            
            return reminders
            
        except Exception as e:
            print(f"Failed to create job reminders: {e}")
            return []

class SmartNotificationManager:
    """Intelligent notification management with user preferences and timing"""
    
    @staticmethod
    def get_user_notification_preferences(user_id: int) -> Dict:
        """Get user's notification preferences"""
        try:
            # TODO: Get from database
            # For now, return default preferences
            return {
                'push_enabled': True,
                'email_enabled': True,
                'sms_enabled': False,
                'quiet_hours_start': '22:00',
                'quiet_hours_end': '08:00',
                'weekend_notifications': True,
                'notification_types': {
                    NotificationType.QUOTE_REQUEST: True,
                    NotificationType.QUOTE_RESPONSE: True,
                    NotificationType.JOB_UPDATE: True,
                    NotificationType.MESSAGE: True,
                    NotificationType.PAYMENT: True,
                    NotificationType.EMERGENCY: True,
                    NotificationType.REMINDER: True,
                    NotificationType.PROMOTION: False,
                    NotificationType.SYSTEM: True
                }
            }
            
        except Exception as e:
            print(f"Failed to get notification preferences: {e}")
            return {}
    
    @staticmethod
    def should_send_notification(user_id: int, notification_type: str, priority: str) -> bool:
        """Check if notification should be sent based on user preferences and timing"""
        try:
            preferences = SmartNotificationManager.get_user_notification_preferences(user_id)
            
            # Check if notification type is enabled
            if not preferences.get('notification_types', {}).get(notification_type, True):
                return False
            
            # Always send critical and emergency notifications
            if priority in [NotificationPriority.CRITICAL, NotificationPriority.URGENT] or \
               notification_type == NotificationType.EMERGENCY:
                return True
            
            # Check quiet hours
            current_time = datetime.utcnow().time()
            quiet_start = datetime.strptime(preferences.get('quiet_hours_start', '22:00'), '%H:%M').time()
            quiet_end = datetime.strptime(preferences.get('quiet_hours_end', '08:00'), '%H:%M').time()
            
            # Handle quiet hours spanning midnight
            if quiet_start > quiet_end:  # e.g., 22:00 to 08:00
                is_quiet_time = current_time >= quiet_start or current_time <= quiet_end
            else:  # e.g., 01:00 to 06:00
                is_quiet_time = quiet_start <= current_time <= quiet_end
            
            if is_quiet_time and priority not in [NotificationPriority.HIGH, NotificationPriority.URGENT]:
                return False
            
            # Check weekend preferences
            if not preferences.get('weekend_notifications', True):
                current_day = datetime.utcnow().weekday()
                if current_day >= 5:  # Saturday = 5, Sunday = 6
                    return False
            
            return True
            
        except Exception as e:
            print(f"Failed to check notification preferences: {e}")
            return True  # Default to sending

class NotificationTemplateManager:
    """Manage notification templates and personalization"""
    
    TEMPLATES = {
        NotificationType.QUOTE_REQUEST: {
            'title': 'Yeni Teklif Talebi',
            'body': '{customer_name} sizden teklif istedi: {job_title}',
            'action_text': 'Teklifi Görüntüle'
        },
        NotificationType.QUOTE_RESPONSE: {
            'title': 'Teklif Yanıtı',
            'body': '{craftsman_name} teklifinize yanıt verdi',
            'action_text': 'Yanıtı Görüntüle'
        },
        NotificationType.JOB_UPDATE: {
            'title': 'İş Güncellemesi',
            'body': '{job_title} işinde güncelleme: {update_message}',
            'action_text': 'Detayları Görüntüle'
        },
        NotificationType.MESSAGE: {
            'title': 'Yeni Mesaj',
            'body': '{sender_name}: {message_preview}',
            'action_text': 'Mesajı Aç'
        },
        NotificationType.EMERGENCY: {
            'title': 'Acil Servis Talebi',
            'body': 'Yakınınızda acil servis talebi: {emergency_type}',
            'action_text': 'Detayları Görüntüle'
        },
        NotificationType.REMINDER: {
            'title': 'Hatırlatma',
            'body': '{reminder_message}',
            'action_text': 'Görüntüle'
        }
    }
    
    @staticmethod
    def format_notification(notification_type: str, data: Dict) -> Dict:
        """Format notification using template and data"""
        try:
            template = NotificationTemplateManager.TEMPLATES.get(notification_type, {
                'title': 'Bildirim',
                'body': 'Yeni bildirim',
                'action_text': 'Görüntüle'
            })
            
            formatted = {}
            
            # Format title
            formatted['title'] = template['title'].format(**data) if '{' in template['title'] else template['title']
            
            # Format body
            formatted['body'] = template['body'].format(**data) if '{' in template['body'] else template['body']
            
            # Action text
            formatted['action_text'] = template['action_text']
            
            return formatted
            
        except Exception as e:
            print(f"Failed to format notification: {e}")
            return {
                'title': 'Bildirim',
                'body': 'Yeni bildirim',
                'action_text': 'Görüntüle'
            }

class NotificationScheduler:
    """Schedule and manage delayed notifications"""
    
    @staticmethod
    def schedule_notification(user_id: int, notification_type: str, data: Dict,
                            scheduled_time: datetime, priority: str = NotificationPriority.NORMAL) -> str:
        """Schedule a notification for future delivery"""
        try:
            notification_id = str(uuid.uuid4())
            
            scheduled_notification = {
                'id': notification_id,
                'user_id': user_id,
                'notification_type': notification_type,
                'data': data,
                'scheduled_time': scheduled_time,
                'priority': priority,
                'status': 'scheduled',
                'created_at': datetime.utcnow()
            }
            
            # TODO: Store in database
            # ScheduledNotification.create(scheduled_notification)
            
            return notification_id
            
        except Exception as e:
            print(f"Failed to schedule notification: {e}")
            return ""
    
    @staticmethod
    def process_scheduled_notifications() -> int:
        """Process notifications that are ready to be sent"""
        try:
            current_time = datetime.utcnow()
            
            # TODO: Query scheduled notifications that are ready
            # scheduled_notifications = ScheduledNotification.query.filter(
            #     ScheduledNotification.scheduled_time <= current_time,
            #     ScheduledNotification.status == 'scheduled'
            # ).all()
            
            processed_count = 0
            
            # For now, return 0 since we don't have the database model
            return processed_count
            
        except Exception as e:
            print(f"Failed to process scheduled notifications: {e}")
            return 0

class NotificationAnalytics:
    """Analytics for notification performance"""
    
    @staticmethod
    def track_notification_sent(notification_id: str, user_id: int, notification_type: str,
                              delivery_channel: str, success: bool) -> None:
        """Track notification delivery"""
        try:
            # TODO: Store analytics data
            analytics_data = {
                'notification_id': notification_id,
                'user_id': user_id,
                'notification_type': notification_type,
                'delivery_channel': delivery_channel,
                'success': success,
                'timestamp': datetime.utcnow()
            }
            
            # Store in analytics database
            pass
            
        except Exception as e:
            print(f"Failed to track notification: {e}")
    
    @staticmethod
    def track_notification_interaction(notification_id: str, user_id: int, 
                                     interaction_type: str) -> None:
        """Track user interaction with notification"""
        try:
            # interaction_type: 'opened', 'clicked', 'dismissed'
            interaction_data = {
                'notification_id': notification_id,
                'user_id': user_id,
                'interaction_type': interaction_type,
                'timestamp': datetime.utcnow()
            }
            
            # TODO: Store in analytics database
            pass
            
        except Exception as e:
            print(f"Failed to track notification interaction: {e}")
    
    @staticmethod
    def get_notification_metrics(user_id: int = None, days: int = 30) -> Dict:
        """Get notification performance metrics"""
        try:
            start_date = datetime.utcnow() - timedelta(days=days)
            
            # TODO: Query analytics data
            # For now, return mock data
            return {
                'total_sent': 0,
                'delivery_rate': 0.0,
                'open_rate': 0.0,
                'click_rate': 0.0,
                'by_type': {},
                'by_channel': {}
            }
            
        except Exception as e:
            print(f"Failed to get notification metrics: {e}")
            return {}

class NotificationManager:
    """Enhanced notification manager with multiple delivery channels"""
    
    def __init__(self):
        self.push_manager = PushNotificationManager()
        self.location_manager = LocationSharingManager()
        self.calendar_manager = CalendarIntegrationManager()
        self.scheduler = NotificationScheduler()
        self.analytics = NotificationAnalytics()
    
    @staticmethod
    def send_notification(user_id: int, title: str, body: str, 
                         notification_type: str = NotificationType.SYSTEM,
                         priority: str = NotificationPriority.NORMAL,
                         data: Dict = None, channels: List[str] = None) -> Dict:
        """Send notification through multiple channels"""
        try:
            # Check if notification should be sent
            if not SmartNotificationManager.should_send_notification(user_id, notification_type, priority):
                return {
                    'success': False,
                    'message': 'Notification blocked by user preferences'
                }
            
            # Get user details
            user = User.query.get(user_id)
            if not user:
                return {
                    'success': False,
                    'message': 'User not found'
                }
            
            # Generate notification ID
            notification_id = str(uuid.uuid4())
            
            # Default channels
            if channels is None:
                preferences = SmartNotificationManager.get_user_notification_preferences(user_id)
                channels = []
                if preferences.get('push_enabled', True):
                    channels.append(DeliveryChannel.PUSH)
                if preferences.get('email_enabled', True) and priority in [NotificationPriority.HIGH, NotificationPriority.URGENT]:
                    channels.append(DeliveryChannel.EMAIL)
            
            # Store in-app notification
            notification = Notification(
                id=notification_id,
                user_id=user_id,
                title=title,
                body=body,
                notification_type=notification_type,
                priority=priority,
                data=json.dumps(data or {}),
                created_at=datetime.utcnow()
            )
            db.session.add(notification)
            db.session.commit()
            
            results = {'in_app': True}
            
            # Send push notification
            if DeliveryChannel.PUSH in channels and user.device_token:
                push_result = PushNotificationManager().send_push_notification(
                    device_tokens=[user.device_token],
                    title=title,
                    body=body,
                    data=data or {},
                    priority=priority
                )
                results['push'] = push_result['success']
                
                # Track delivery
                NotificationAnalytics.track_notification_sent(
                    notification_id, user_id, notification_type, 
                    DeliveryChannel.PUSH, push_result['success']
                )
            
            # Send email notification
            if DeliveryChannel.EMAIL in channels and user.email:
                email_result = NotificationManager._send_email_notification(
                    user.email, title, body, data
                )
                results['email'] = email_result
                
                # Track delivery
                NotificationAnalytics.track_notification_sent(
                    notification_id, user_id, notification_type, 
                    DeliveryChannel.EMAIL, email_result
                )
            
            # Emit real-time notification via SocketIO
            from app import socketio
            socketio.emit('notification', {
                'id': notification_id,
                'title': title,
                'body': body,
                'type': notification_type,
                'priority': priority,
                'data': data or {},
                'timestamp': datetime.utcnow().isoformat()
            }, room=f'user_{user_id}')
            
            return {
                'success': True,
                'notification_id': notification_id,
                'delivery_results': results
            }
            
        except Exception as e:
            db.session.rollback()
            return {
                'success': False,
                'message': f'Failed to send notification: {str(e)}'
            }
    
    @staticmethod
    def _send_email_notification(email: str, title: str, body: str, data: Dict = None) -> bool:
        """Send email notification"""
        try:
            # Email configuration
            smtp_server = current_app.config.get('SMTP_SERVER', 'smtp.gmail.com')
            smtp_port = current_app.config.get('SMTP_PORT', 587)
            smtp_username = current_app.config.get('SMTP_USERNAME')
            smtp_password = current_app.config.get('SMTP_PASSWORD')
            
            if not smtp_username or not smtp_password:
                return False
            
            # Create email
            msg = MIMEMultipart()
            msg['From'] = smtp_username
            msg['To'] = email
            msg['Subject'] = title
            
            # Email body
            html_body = f"""
            <html>
                <body>
                    <h2>{title}</h2>
                    <p>{body}</p>
                    {f'<p><strong>Detaylar:</strong> {json.dumps(data, indent=2)}</p>' if data else ''}
                    <hr>
                    <p><small>Bu e-posta Ustam App tarafından gönderilmiştir.</small></p>
                </body>
            </html>
            """
            
            msg.attach(MIMEText(html_body, 'html'))
            
            # Send email
            with smtplib.SMTP(smtp_server, smtp_port) as server:
                server.starttls()
                server.login(smtp_username, smtp_password)
                server.send_message(msg)
            
            return True
            
        except Exception as e:
            print(f"Failed to send email notification: {e}")
            return False
    
    @staticmethod
    def send_bulk_notification(user_ids: List[int], title: str, body: str,
                             notification_type: str = NotificationType.SYSTEM,
                             priority: str = NotificationPriority.NORMAL,
                             data: Dict = None) -> Dict:
        """Send notification to multiple users"""
        try:
            results = []
            
            for user_id in user_ids:
                result = NotificationManager.send_notification(
                    user_id, title, body, notification_type, priority, data
                )
                results.append({
                    'user_id': user_id,
                    'success': result['success'],
                    'notification_id': result.get('notification_id')
                })
            
            success_count = len([r for r in results if r['success']])
            
            return {
                'success': True,
                'total_sent': success_count,
                'total_failed': len(results) - success_count,
                'results': results
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'Bulk notification failed: {str(e)}'
            }

class EmergencyNotificationManager:
    """Specialized emergency notification system"""
    
    @staticmethod
    def broadcast_emergency(emergency_service_id: int, max_radius_km: float = 50) -> Dict:
        """Broadcast emergency to nearby craftsmen"""
        try:
            from app.models.job import EmergencyService
            
            emergency = EmergencyService.query.get(emergency_service_id)
            if not emergency:
                return {'success': False, 'message': 'Emergency not found'}
            
            # Find nearby craftsmen
            nearby_craftsmen = EmergencyNotificationManager._find_nearby_craftsmen(
                emergency.latitude, emergency.longitude, max_radius_km, emergency.emergency_type
            )
            
            if not nearby_craftsmen:
                return {
                    'success': False,
                    'message': 'No nearby craftsmen found'
                }
            
            # Send emergency notifications
            notification_data = {
                'emergency_id': emergency_service_id,
                'emergency_type': emergency.emergency_type,
                'severity': emergency.severity,
                'address': emergency.address,
                'contact_phone': emergency.contact_phone
            }
            
            results = []
            for craftsman in nearby_craftsmen:
                result = NotificationManager.send_notification(
                    user_id=craftsman.id,
                    title='🚨 Acil Servis Talebi',
                    body=f'{emergency.emergency_type} acil servisi - Seviye {emergency.severity}',
                    notification_type=NotificationType.EMERGENCY,
                    priority=NotificationPriority.URGENT,
                    data=notification_data,
                    channels=[DeliveryChannel.PUSH, DeliveryChannel.IN_APP]
                )
                results.append(result)
            
            # Also send via topic for immediate broadcast
            push_manager = PushNotificationManager()
            topic_result = push_manager.send_topic_notification(
                topic=f'emergency_{emergency.city.lower()}',
                title='🚨 Acil Servis Talebi',
                body=f'{emergency.emergency_type} - {emergency.address}',
                data=notification_data
            )
            
            return {
                'success': True,
                'notified_craftsmen': len(nearby_craftsmen),
                'topic_broadcast': topic_result['success'],
                'results': results
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'Emergency broadcast failed: {str(e)}'
            }
    
    @staticmethod
    def _find_nearby_craftsmen(latitude: float, longitude: float, 
                             radius_km: float, emergency_type: str) -> List[User]:
        """Find craftsmen near emergency location"""
        try:
            # Simple distance calculation (for production, use PostGIS)
            lat_range = radius_km / 111.0
            lng_range = radius_km / (111.0 * abs(latitude))
            
            # Find craftsmen in the area with relevant skills
            craftsmen = User.query.filter(
                User.user_type == 'craftsman',
                User.is_active == True,
                User.latitude.between(latitude - lat_range, latitude + lat_range),
                User.longitude.between(longitude - lng_range, longitude + lng_range)
            ).all()
            
            # Filter by emergency type if possible
            # TODO: Add skill matching based on emergency_type
            
            return craftsmen
            
        except Exception as e:
            print(f"Failed to find nearby craftsmen: {e}")
            return []

# Notification utility functions
class NotificationUtils:
    """Utility functions for notification management"""
    
    @staticmethod
    def create_job_notifications(job_id: int) -> None:
        """Create all necessary notifications for a job lifecycle"""
        try:
            from app.models.job import Job
            
            job = Job.query.get(job_id)
            if not job:
                return
            
            # Create reminders
            reminders = CalendarIntegrationManager.create_job_reminders(job_id)
            
            for reminder in reminders:
                NotificationScheduler.schedule_notification(
                    user_id=job.craftsman_id if job.craftsman_id else job.customer_id,
                    notification_type=NotificationType.REMINDER,
                    data={'job_id': job_id, 'reminder_message': reminder['body']},
                    scheduled_time=reminder['scheduled_time'],
                    priority=NotificationPriority.NORMAL
                )
            
            # Create calendar event
            if job.scheduled_start and job.scheduled_end:
                CalendarIntegrationManager.create_calendar_event(
                    user_id=job.craftsman_id if job.craftsman_id else job.customer_id,
                    job_id=job_id,
                    title=job.title,
                    description=job.description or '',
                    start_time=job.scheduled_start,
                    end_time=job.scheduled_end,
                    location=job.address
                )
            
        except Exception as e:
            print(f"Failed to create job notifications: {e}")
    
    @staticmethod
    def cleanup_expired_notifications(days: int = 30) -> int:
        """Clean up old notifications"""
        try:
            cutoff_date = datetime.utcnow() - timedelta(days=days)
            
            # Delete old notifications
            deleted_count = Notification.query.filter(
                Notification.created_at < cutoff_date
            ).delete()
            
            db.session.commit()
            
            return deleted_count
            
        except Exception as e:
            db.session.rollback()
            print(f"Failed to cleanup notifications: {e}")
            return 0