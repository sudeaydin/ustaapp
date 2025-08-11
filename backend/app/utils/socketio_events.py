from flask_socketio import emit, join_room, leave_room, disconnect
from flask_jwt_extended import decode_token
from app.models.user import User
from app.models.message import Message
from app.models.quote import Quote
from app import db, socketio
import logging

# Store active connections
active_connections = {}

@socketio.on('connect')
def handle_connect(auth):
    """Handle client connection"""
    try:
        # Verify JWT token
        if not auth or 'token' not in auth:
            disconnect()
            return False
        
        token = auth['token']
        decoded_token = decode_token(token)
        user_id = decoded_token['sub']
        
        # Get user info
        user = User.query.get(user_id)
        if not user or not user.is_active:
            disconnect()
            return False
        
        # Store connection
        active_connections[request.sid] = {
            'user_id': user_id,
            'user_type': user.user_type.value,
            'connected_at': datetime.utcnow()
        }
        
        # Join user's personal room
        join_room(f"user_{user_id}")
        
        # Join craftsman room if applicable
        if user.user_type.value == 'craftsman' and user.craftsman:
            join_room(f"craftsman_{user.craftsman.id}")
        
        # Emit connection success
        emit('connected', {
            'status': 'connected',
            'user_id': user_id,
            'timestamp': datetime.utcnow().isoformat()
        })
        
        # Notify user's contacts about online status
        emit_user_status(user_id, 'online')
        
        logging.info(f"User {user_id} connected via Socket.IO")
        
    except Exception as e:
        logging.error(f"Connection error: {e}")
        disconnect()
        return False

@socketio.on('disconnect')
def handle_disconnect():
    """Handle client disconnection"""
    try:
        if request.sid in active_connections:
            user_data = active_connections[request.sid]
            user_id = user_data['user_id']
            
            # Leave all rooms
            leave_room(f"user_{user_id}")
            if user_data['user_type'] == 'craftsman':
                # Get craftsman ID and leave room
                user = User.query.get(user_id)
                if user and user.craftsman:
                    leave_room(f"craftsman_{user.craftsman.id}")
            
            # Remove from active connections
            del active_connections[request.sid]
            
            # Notify contacts about offline status
            emit_user_status(user_id, 'offline')
            
            logging.info(f"User {user_id} disconnected from Socket.IO")
            
    except Exception as e:
        logging.error(f"Disconnection error: {e}")

@socketio.on('send_message')
def handle_send_message(data):
    """Handle real-time message sending"""
    try:
        if request.sid not in active_connections:
            emit('error', {'message': 'Unauthorized'})
            return
        
        user_id = active_connections[request.sid]['user_id']
        recipient_id = data.get('recipient_id')
        content = data.get('content')
        message_type = data.get('type', 'text')
        
        if not recipient_id or not content:
            emit('error', {'message': 'Missing required fields'})
            return
        
        # Create message in database
        message = Message(
            sender_id=user_id,
            recipient_id=recipient_id,
            content=content,
            message_type=message_type,
            is_read=False
        )
        db.session.add(message)
        db.session.commit()
        
        # Emit to recipient
        emit('new_message', {
            'message': message.to_dict(),
            'sender': message.sender.to_dict()
        }, room=f"user_{recipient_id}")
        
        # Confirm to sender
        emit('message_sent', {
            'message': message.to_dict(),
            'status': 'delivered'
        })
        
        # Send push notification if recipient is offline
        if not is_user_online(recipient_id):
            send_push_notification(recipient_id, {
                'title': f"Yeni mesaj - {message.sender.first_name}",
                'body': content[:100] + ('...' if len(content) > 100 else ''),
                'data': {
                    'type': 'message',
                    'sender_id': user_id,
                    'url': '/messages'
                }
            })
        
    except Exception as e:
        logging.error(f"Send message error: {e}")
        emit('error', {'message': 'Message could not be sent'})

@socketio.on('mark_messages_read')
def handle_mark_messages_read(data):
    """Mark messages as read"""
    try:
        if request.sid not in active_connections:
            emit('error', {'message': 'Unauthorized'})
            return
        
        user_id = active_connections[request.sid]['user_id']
        sender_id = data.get('sender_id')
        
        if not sender_id:
            emit('error', {'message': 'Sender ID required'})
            return
        
        # Mark messages as read
        messages = Message.query.filter_by(
            sender_id=sender_id,
            recipient_id=user_id,
            is_read=False
        ).all()
        
        for message in messages:
            message.is_read = True
        
        db.session.commit()
        
        # Notify sender about read status
        emit('messages_read', {
            'reader_id': user_id,
            'message_count': len(messages)
        }, room=f"user_{sender_id}")
        
    except Exception as e:
        logging.error(f"Mark messages read error: {e}")
        emit('error', {'message': 'Could not mark messages as read'})

@socketio.on('typing_start')
def handle_typing_start(data):
    """Handle typing indicator start"""
    try:
        if request.sid not in active_connections:
            return
        
        user_id = active_connections[request.sid]['user_id']
        recipient_id = data.get('recipient_id')
        
        if recipient_id:
            emit('user_typing', {
                'user_id': user_id,
                'typing': True
            }, room=f"user_{recipient_id}")
            
    except Exception as e:
        logging.error(f"Typing start error: {e}")

@socketio.on('typing_stop')
def handle_typing_stop(data):
    """Handle typing indicator stop"""
    try:
        if request.sid not in active_connections:
            return
        
        user_id = active_connections[request.sid]['user_id']
        recipient_id = data.get('recipient_id')
        
        if recipient_id:
            emit('user_typing', {
                'user_id': user_id,
                'typing': False
            }, room=f"user_{recipient_id}")
            
    except Exception as e:
        logging.error(f"Typing stop error: {e}")

@socketio.on('quote_status_update')
def handle_quote_status_update(data):
    """Handle real-time quote status updates"""
    try:
        if request.sid not in active_connections:
            emit('error', {'message': 'Unauthorized'})
            return
        
        user_id = active_connections[request.sid]['user_id']
        quote_id = data.get('quote_id')
        new_status = data.get('status')
        
        if not quote_id or not new_status:
            emit('error', {'message': 'Missing required fields'})
            return
        
        # Get quote and verify ownership
        quote = Quote.query.get(quote_id)
        if not quote:
            emit('error', {'message': 'Quote not found'})
            return
        
        # Check if user can update this quote
        user = User.query.get(user_id)
        can_update = False
        
        if user.user_type.value == 'craftsman' and quote.craftsman_id == user.craftsman.id:
            can_update = True
        elif user.user_type.value == 'customer' and quote.customer_id == user.customer.id:
            can_update = True
        
        if not can_update:
            emit('error', {'message': 'Unauthorized to update this quote'})
            return
        
        # Update quote status
        old_status = quote.status
        quote.update_status(new_status)
        db.session.commit()
        
        # Emit to both parties
        quote_data = quote.to_dict()
        
        emit('quote_updated', {
            'quote': quote_data,
            'old_status': old_status.value,
            'new_status': new_status
        }, room=f"user_{quote.customer.user_id}")
        
        emit('quote_updated', {
            'quote': quote_data,
            'old_status': old_status.value,
            'new_status': new_status
        }, room=f"user_{quote.craftsman.user_id}")
        
        # Send notifications
        if new_status == 'QUOTED':
            send_push_notification(quote.customer.user_id, {
                'title': 'Teklif Alındı!',
                'body': f"{quote.craftsman.business_name} size teklif verdi",
                'data': {'type': 'quote', 'quote_id': quote_id}
            })
        elif new_status == 'ACCEPTED':
            send_push_notification(quote.craftsman.user_id, {
                'title': 'Teklif Kabul Edildi!',
                'body': f"Teklifiniz kabul edildi",
                'data': {'type': 'quote', 'quote_id': quote_id}
            })
        
    except Exception as e:
        logging.error(f"Quote status update error: {e}")
        emit('error', {'message': 'Could not update quote status'})

@socketio.on('join_conversation')
def handle_join_conversation(data):
    """Join a conversation room"""
    try:
        if request.sid not in active_connections:
            return
        
        user_id = active_connections[request.sid]['user_id']
        other_user_id = data.get('other_user_id')
        
        if other_user_id:
            # Create conversation room ID (sorted for consistency)
            room_id = f"conv_{min(user_id, other_user_id)}_{max(user_id, other_user_id)}"
            join_room(room_id)
            
            emit('joined_conversation', {
                'room_id': room_id,
                'other_user_id': other_user_id
            })
            
    except Exception as e:
        logging.error(f"Join conversation error: {e}")

@socketio.on('leave_conversation')
def handle_leave_conversation(data):
    """Leave a conversation room"""
    try:
        if request.sid not in active_connections:
            return
        
        user_id = active_connections[request.sid]['user_id']
        other_user_id = data.get('other_user_id')
        
        if other_user_id:
            room_id = f"conv_{min(user_id, other_user_id)}_{max(user_id, other_user_id)}"
            leave_room(room_id)
            
            emit('left_conversation', {
                'room_id': room_id,
                'other_user_id': other_user_id
            })
            
    except Exception as e:
        logging.error(f"Leave conversation error: {e}")

@socketio.on('craftsman_location_update')
def handle_craftsman_location_update(data):
    """Handle craftsman location updates for nearby services"""
    try:
        if request.sid not in active_connections:
            return
        
        user_data = active_connections[request.sid]
        if user_data['user_type'] != 'craftsman':
            emit('error', {'message': 'Only craftsmen can update location'})
            return
        
        user_id = user_data['user_id']
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        
        if not latitude or not longitude:
            emit('error', {'message': 'Location coordinates required'})
            return
        
        # Update craftsman location in database
        user = User.query.get(user_id)
        if user and user.craftsman:
            user.craftsman.current_latitude = latitude
            user.craftsman.current_longitude = longitude
            user.craftsman.location_updated_at = datetime.utcnow()
            db.session.commit()
            
            # Emit to nearby customers (simplified - would use geospatial queries)
            emit('craftsman_nearby', {
                'craftsman_id': user.craftsman.id,
                'business_name': user.craftsman.business_name,
                'distance': 'Yakınınızda',
                'specialties': user.craftsman.specialties
            }, broadcast=True)
        
    except Exception as e:
        logging.error(f"Location update error: {e}")
        emit('error', {'message': 'Could not update location'})

# Utility functions
def emit_user_status(user_id, status):
    """Emit user online/offline status to contacts"""
    try:
        # Get user's recent conversations
        recent_contacts = db.session.query(Message.sender_id, Message.recipient_id)\
            .filter(db.or_(Message.sender_id == user_id, Message.recipient_id == user_id))\
            .distinct().limit(50).all()
        
        contact_ids = set()
        for contact in recent_contacts:
            if contact.sender_id != user_id:
                contact_ids.add(contact.sender_id)
            if contact.recipient_id != user_id:
                contact_ids.add(contact.recipient_id)
        
        # Emit status to contacts
        for contact_id in contact_ids:
            emit('user_status_changed', {
                'user_id': user_id,
                'status': status,
                'timestamp': datetime.utcnow().isoformat()
            }, room=f"user_{contact_id}")
            
    except Exception as e:
        logging.error(f"Emit user status error: {e}")

def is_user_online(user_id):
    """Check if user is currently online"""
    for connection in active_connections.values():
        if connection['user_id'] == user_id:
            return True
    return False

def get_online_users():
    """Get list of currently online users"""
    return [conn['user_id'] for conn in active_connections.values()]

def send_push_notification(user_id, notification_data):
    """Send push notification to user"""
    try:
        # In a real implementation, this would integrate with FCM, APNS, etc.
        # For now, we'll emit via Socket.IO if user is online
        
        if is_user_online(user_id):
            emit('push_notification', notification_data, room=f"user_{user_id}")
        else:
            # Store notification for later delivery
            # In production, this would queue for actual push notification services
            logging.info(f"Push notification queued for user {user_id}: {notification_data}")
        
    except Exception as e:
        logging.error(f"Push notification error: {e}")

def broadcast_quote_update(quote_id, update_type, data):
    """Broadcast quote updates to relevant users"""
    try:
        quote = Quote.query.get(quote_id)
        if not quote:
            return
        
        # Emit to customer
        emit('quote_broadcast', {
            'type': update_type,
            'quote_id': quote_id,
            'data': data
        }, room=f"user_{quote.customer.user_id}")
        
        # Emit to craftsman
        emit('quote_broadcast', {
            'type': update_type,
            'quote_id': quote_id,
            'data': data
        }, room=f"user_{quote.craftsman.user_id}")
        
    except Exception as e:
        logging.error(f"Quote broadcast error: {e}")

def notify_new_quote_request(craftsman_id, quote_data):
    """Notify craftsman about new quote request"""
    try:
        craftsman = Craftsman.query.get(craftsman_id)
        if not craftsman:
            return
        
        # Real-time notification
        emit('new_quote_request', {
            'quote': quote_data,
            'timestamp': datetime.utcnow().isoformat()
        }, room=f"user_{craftsman.user_id}")
        
        # Push notification
        send_push_notification(craftsman.user_id, {
            'title': 'Yeni Teklif Talebi!',
            'body': f"Yeni bir teklif talebi aldınız: {quote_data.get('category', 'Hizmet')}",
            'data': {
                'type': 'quote_request',
                'quote_id': quote_data.get('id'),
                'url': '/craftsman-quotes'
            }
        })
        
    except Exception as e:
        logging.error(f"Quote request notification error: {e}")

# Real-time analytics events
@socketio.on('page_view')
def handle_page_view(data):
    """Track page views for analytics"""
    try:
        if request.sid not in active_connections:
            return
        
        user_id = active_connections[request.sid]['user_id']
        page = data.get('page')
        
        if page:
            # Log page view (in production, send to analytics service)
            logging.info(f"Page view: User {user_id} visited {page}")
            
            # Emit to admin dashboard if needed
            emit('analytics_event', {
                'type': 'page_view',
                'user_id': user_id,
                'page': page,
                'timestamp': datetime.utcnow().isoformat()
            }, room='admin_dashboard')
        
    except Exception as e:
        logging.error(f"Page view tracking error: {e}")

@socketio.on('user_action')
def handle_user_action(data):
    """Track user actions for analytics"""
    try:
        if request.sid not in active_connections:
            return
        
        user_id = active_connections[request.sid]['user_id']
        action = data.get('action')
        details = data.get('details', {})
        
        if action:
            # Log user action
            logging.info(f"User action: User {user_id} performed {action}")
            
            # Emit to analytics
            emit('analytics_event', {
                'type': 'user_action',
                'user_id': user_id,
                'action': action,
                'details': details,
                'timestamp': datetime.utcnow().isoformat()
            }, room='admin_dashboard')
        
    except Exception as e:
        logging.error(f"User action tracking error: {e}")

# Admin events
@socketio.on('join_admin_dashboard')
def handle_join_admin_dashboard():
    """Join admin dashboard room for real-time analytics"""
    try:
        if request.sid not in active_connections:
            return
        
        user_id = active_connections[request.sid]['user_id']
        user = User.query.get(user_id)
        
        # Check if user is admin (you'd implement admin role checking)
        if user and hasattr(user, 'is_admin') and user.is_admin:
            join_room('admin_dashboard')
            emit('admin_dashboard_joined', {
                'status': 'joined',
                'online_users': len(active_connections)
            })
        
    except Exception as e:
        logging.error(f"Admin dashboard join error: {e}")

# Cleanup function for old connections
def cleanup_old_connections():
    """Clean up old/stale connections"""
    try:
        from datetime import datetime, timedelta
        
        cutoff_time = datetime.utcnow() - timedelta(hours=1)
        
        for sid, connection_data in list(active_connections.items()):
            if connection_data['connected_at'] < cutoff_time:
                del active_connections[sid]
                logging.info(f"Cleaned up old connection for user {connection_data['user_id']}")
        
    except Exception as e:
        logging.error(f"Connection cleanup error: {e}")

# Import required modules at the top
from datetime import datetime
from flask import request
from app.models.craftsman import Craftsman