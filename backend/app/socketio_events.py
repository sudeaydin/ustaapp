from flask_socketio import SocketIO, emit, join_room, leave_room, disconnect
from flask_jwt_extended import decode_token, get_jwt_identity
from app.models.user import User
from app.models.message import Message
from app.models.notification import Notification
from app import db
from datetime import datetime
import logging

# Store active connections
active_users = {}

def init_socketio_events(socketio):
    """Initialize all SocketIO event handlers"""
    
    @socketio.on('connect')
    def handle_connect(auth):
        """Handle client connection"""
        try:
            # Get token from auth data
            token = auth.get('token') if auth else None
            if not token:
                logging.warning("Connection attempt without token")
                disconnect()
                return False
            
            # Decode JWT token
            try:
                decoded_token = decode_token(token)
                user_id = decoded_token['sub']
            except Exception as e:
                logging.error(f"Invalid token on connect: {str(e)}")
                disconnect()
                return False
            
            # Get user info
            user = User.query.get(user_id)
            if not user:
                logging.error(f"User not found: {user_id}")
                disconnect()
                return False
            
            # Store connection info
            active_users[request.sid] = {
                'user_id': user_id,
                'user_type': user.user_type,
                'name': f"{user.first_name} {user.last_name}",
                'connected_at': datetime.utcnow()
            }
            
            # Join user's personal room for notifications
            join_room(f"user_{user_id}")
            
            logging.info(f"User {user_id} connected")
            
            # Emit connection success
            emit('connect_success', {
                'message': 'Connected successfully',
                'user_id': user_id
            })
            
            # Send unread notifications count
            unread_count = Notification.get_unread_count(user_id)
            emit('notification_count', {'count': unread_count})
            
            return True
            
        except Exception as e:
            logging.error(f"Connection error: {str(e)}")
            disconnect()
            return False
    
    @socketio.on('disconnect')
    def handle_disconnect():
        """Handle client disconnection"""
        try:
            if request.sid in active_users:
                user_info = active_users[request.sid]
                user_id = user_info['user_id']
                
                # Leave all rooms
                leave_room(f"user_{user_id}")
                
                # Remove from active users
                del active_users[request.sid]
                
                logging.info(f"User {user_id} disconnected")
        except Exception as e:
            logging.error(f"Disconnect error: {str(e)}")
    
    @socketio.on('join_conversation')
    def handle_join_conversation(data):
        """Join a conversation room for real-time messaging"""
        try:
            if request.sid not in active_users:
                emit('error', {'message': 'Not authenticated'})
                return
            
            user_id = active_users[request.sid]['user_id']
            partner_id = data.get('partner_id')
            
            if not partner_id:
                emit('error', {'message': 'Partner ID required'})
                return
            
            # Create conversation room ID (consistent regardless of who joins first)
            room_id = f"conv_{min(user_id, partner_id)}_{max(user_id, partner_id)}"
            
            # Join the conversation room
            join_room(room_id)
            
            emit('joined_conversation', {
                'room_id': room_id,
                'partner_id': partner_id
            })
            
            logging.info(f"User {user_id} joined conversation with {partner_id}")
            
        except Exception as e:
            logging.error(f"Join conversation error: {str(e)}")
            emit('error', {'message': 'Failed to join conversation'})
    
    @socketio.on('leave_conversation')
    def handle_leave_conversation(data):
        """Leave a conversation room"""
        try:
            if request.sid not in active_users:
                return
            
            user_id = active_users[request.sid]['user_id']
            partner_id = data.get('partner_id')
            
            if partner_id:
                room_id = f"conv_{min(user_id, partner_id)}_{max(user_id, partner_id)}"
                leave_room(room_id)
                
                logging.info(f"User {user_id} left conversation with {partner_id}")
                
        except Exception as e:
            logging.error(f"Leave conversation error: {str(e)}")
    
    @socketio.on('send_message')
    def handle_send_message(data):
        """Handle real-time message sending"""
        try:
            if request.sid not in active_users:
                emit('error', {'message': 'Not authenticated'})
                return
            
            user_id = active_users[request.sid]['user_id']
            receiver_id = data.get('receiver_id')
            content = data.get('content')
            
            if not receiver_id or not content:
                emit('error', {'message': 'Receiver ID and content required'})
                return
            
            # Validate receiver exists
            receiver = User.query.get(receiver_id)
            if not receiver:
                emit('error', {'message': 'Receiver not found'})
                return
            
            # Create message in database
            message = Message(
                sender_id=user_id,
                receiver_id=receiver_id,
                content=content.strip()
            )
            
            db.session.add(message)
            db.session.commit()
            
            # Prepare message data
            message_data = message.to_dict()
            
            # Create conversation room ID
            room_id = f"conv_{min(user_id, receiver_id)}_{max(user_id, receiver_id)}"
            
            # Emit to conversation room (both sender and receiver if online)
            socketio.emit('new_message', message_data, room=room_id)
            
            # Send notification to receiver if they're online but not in conversation
            socketio.emit('message_notification', {
                'type': 'message',
                'sender_id': user_id,
                'sender_name': active_users[request.sid]['name'],
                'content': content[:50] + '...' if len(content) > 50 else content,
                'message_id': message.id
            }, room=f"user_{receiver_id}")
            
            # Create persistent notification
            Notification.create_notification(
                user_id=receiver_id,
                notification_type='message',
                title=f'Yeni mesaj - {active_users[request.sid]["name"]}',
                message=content[:100] + '...' if len(content) > 100 else content,
                related_id=message.id,
                related_type='message',
                action_url='/messages'
            )
            
            logging.info(f"Message sent from {user_id} to {receiver_id}")
            
        except Exception as e:
            db.session.rollback()
            logging.error(f"Send message error: {str(e)}")
            emit('error', {'message': 'Failed to send message'})
    
    @socketio.on('mark_message_read')
    def handle_mark_message_read(data):
        """Mark message as read"""
        try:
            if request.sid not in active_users:
                return
            
            user_id = active_users[request.sid]['user_id']
            message_id = data.get('message_id')
            
            if not message_id:
                return
            
            # Find and update message
            message = Message.query.filter_by(
                id=message_id,
                receiver_id=user_id
            ).first()
            
            if message and not message.is_read:
                message.is_read = True
                message.read_at = datetime.utcnow()
                db.session.commit()
                
                # Notify sender that message was read
                socketio.emit('message_read', {
                    'message_id': message_id,
                    'read_at': message.read_at.isoformat()
                }, room=f"user_{message.sender_id}")
                
        except Exception as e:
            db.session.rollback()
            logging.error(f"Mark message read error: {str(e)}")
    
    @socketio.on('typing_start')
    def handle_typing_start(data):
        """Handle typing indicator start"""
        try:
            if request.sid not in active_users:
                return
            
            user_id = active_users[request.sid]['user_id']
            partner_id = data.get('partner_id')
            
            if not partner_id:
                return
            
            # Emit typing indicator to partner
            socketio.emit('user_typing', {
                'user_id': user_id,
                'typing': True
            }, room=f"user_{partner_id}")
            
        except Exception as e:
            logging.error(f"Typing start error: {str(e)}")
    
    @socketio.on('typing_stop')
    def handle_typing_stop(data):
        """Handle typing indicator stop"""
        try:
            if request.sid not in active_users:
                return
            
            user_id = active_users[request.sid]['user_id']
            partner_id = data.get('partner_id')
            
            if not partner_id:
                return
            
            # Emit typing stop to partner
            socketio.emit('user_typing', {
                'user_id': user_id,
                'typing': False
            }, room=f"user_{partner_id}")
            
        except Exception as e:
            logging.error(f"Typing stop error: {str(e)}")
    
    @socketio.on('get_online_status')
    def handle_get_online_status(data):
        """Get online status of users"""
        try:
            if request.sid not in active_users:
                return
            
            user_ids = data.get('user_ids', [])
            online_status = {}
            
            # Check which users are online
            for user_id in user_ids:
                is_online = any(
                    info['user_id'] == user_id 
                    for info in active_users.values()
                )
                online_status[user_id] = is_online
            
            emit('online_status', online_status)
            
        except Exception as e:
            logging.error(f"Get online status error: {str(e)}")
    
    @socketio.on('job_update')
    def handle_job_update(data):
        """Handle real-time job status updates"""
        try:
            if request.sid not in active_users:
                return
            
            user_id = active_users[request.sid]['user_id']
            job_id = data.get('job_id')
            status = data.get('status')
            message = data.get('message', '')
            
            if not job_id or not status:
                return
            
            # Emit job update to relevant users
            # This would be expanded based on job participants
            socketio.emit('job_status_update', {
                'job_id': job_id,
                'status': status,
                'message': message,
                'updated_by': user_id,
                'timestamp': datetime.utcnow().isoformat()
            }, room=f"job_{job_id}")
            
        except Exception as e:
            logging.error(f"Job update error: {str(e)}")
    
    @socketio.on('notification_read')
    def handle_notification_read(data):
        """Handle notification read status update"""
        try:
            if request.sid not in active_users:
                return
            
            user_id = active_users[request.sid]['user_id']
            notification_id = data.get('notification_id')
            
            if not notification_id:
                return
            
            # Mark notification as read
            notification = Notification.query.filter_by(
                id=notification_id,
                user_id=user_id
            ).first()
            
            if notification:
                notification.mark_as_read()
                
                # Send updated unread count
                unread_count = Notification.get_unread_count(user_id)
                emit('notification_count', {'count': unread_count})
                
        except Exception as e:
            logging.error(f"Notification read error: {str(e)}")

def send_real_time_notification(user_id, notification_data):
    """Send real-time notification to a specific user"""
    try:
        from app import socketio
        socketio.emit('new_notification', notification_data, room=f"user_{user_id}")
        
        # Update notification count
        unread_count = Notification.get_unread_count(user_id)
        socketio.emit('notification_count', {'count': unread_count}, room=f"user_{user_id}")
        
    except Exception as e:
        logging.error(f"Send real-time notification error: {str(e)}")

def broadcast_job_update(job_id, update_data):
    """Broadcast job update to all relevant users"""
    try:
        from app import socketio
        socketio.emit('job_update_broadcast', update_data, room=f"job_{job_id}")
        
    except Exception as e:
        logging.error(f"Broadcast job update error: {str(e)}")

def get_active_users():
    """Get list of currently active users"""
    return {
        sid: {
            'user_id': info['user_id'],
            'user_type': info['user_type'],
            'name': info['name'],
            'connected_at': info['connected_at'].isoformat()
        }
        for sid, info in active_users.items()
    }

def is_user_online(user_id):
    """Check if a specific user is online"""
    return any(info['user_id'] == user_id for info in active_users.values())