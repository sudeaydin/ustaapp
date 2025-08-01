from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.message import Message
from app.models.quote import Quote
from app.models.notification import Notification
from app.models.user import User
from sqlalchemy import and_, or_

messages_bp = Blueprint('messages', __name__)

@messages_bp.route('/api/messages', methods=['POST'])
@jwt_required()
def send_message():
    """Send a message"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if 'quote_id' not in data or 'content' not in data:
            return jsonify({'success': False, 'message': 'quote_id and content are required'}), 400
        
        # Check if quote exists and user has access
        quote = Quote.query.get_or_404(data['quote_id'])
        if quote.customer_id != current_user_id and quote.craftsman_id != current_user_id:
            return jsonify({'success': False, 'message': 'Access denied'}), 403
        
        # Determine receiver
        receiver_id = quote.craftsman_id if current_user_id == quote.customer_id else quote.customer_id
        
        # Create message
        message = Message(
            quote_id=data['quote_id'],
            sender_id=current_user_id,
            receiver_id=receiver_id,
            content=data['content'],
            message_type=data.get('message_type', 'text')
        )
        
        db.session.add(message)
        db.session.commit()
        
        # Create notification for receiver
        sender = User.query.get(current_user_id)
        receiver = User.query.get(receiver_id)
        
        Notification.create_notification(
            user_id=receiver_id,
            title='Yeni Mesaj',
            message=f'{sender.first_name} {sender.last_name} size mesaj gönderdi.',
            notification_type='message',
            related_id=message.id,
            related_type='message'
        )
        
        return jsonify({
            'success': True,
            'message': 'Message sent successfully',
            'data': message.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

@messages_bp.route('/api/conversations', methods=['GET'])
@jwt_required()
def get_conversations():
    """Get conversations for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get quotes where user is involved
        quotes = Quote.query.filter(
            or_(
                Quote.customer_id == current_user_id,
                Quote.craftsman_id == current_user_id
            )
        ).all()
        
        conversations = []
        for quote in quotes:
            # Get last message
            last_message = Message.query.filter_by(quote_id=quote.id).order_by(Message.created_at.desc()).first()
            
            # Get unread count
            unread_count = Message.query.filter(
                and_(
                    Message.quote_id == quote.id,
                    Message.receiver_id == current_user_id,
                    Message.is_read == False
                )
            ).count()
            
            # Get other user info
            if current_user_id == quote.customer_id:
                other_user = quote.craftsman
                business_name = quote.craftsman.craftsman.business_name if quote.craftsman.craftsman else None
            else:
                other_user = quote.customer
                business_name = None
            
            conversation = {
                'id': quote.id,
                'quote_id': quote.id,
                'other_user': {
                    'id': other_user.id,
                    'name': f"{other_user.first_name} {other_user.last_name}",
                    'business_name': business_name,
                    'avatar': other_user.avatar,
                },
                'last_message': last_message.content if last_message else None,
                'timestamp': last_message.created_at.isoformat() if last_message else quote.created_at.isoformat(),
                'unread_count': unread_count,
                'quote_status': quote.status,
                'category': quote.category,
            }
            conversations.append(conversation)
        
        # Sort by last message timestamp
        conversations.sort(key=lambda x: x['timestamp'], reverse=True)
        
        return jsonify({
            'success': True,
            'data': conversations
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@messages_bp.route('/api/conversations/<int:quote_id>/messages', methods=['GET'])
@jwt_required()
def get_messages(quote_id):
    """Get messages for a specific conversation"""
    try:
        current_user_id = get_jwt_identity()
        
        # Check if user has access to this quote
        quote = Quote.query.get_or_404(quote_id)
        if quote.customer_id != current_user_id and quote.craftsman_id != current_user_id:
            return jsonify({'success': False, 'message': 'Access denied'}), 403
        
        # Get messages
        messages = Message.query.filter_by(quote_id=quote_id).order_by(Message.created_at.asc()).all()
        
        # Mark messages as read
        unread_messages = Message.query.filter(
            and_(
                Message.quote_id == quote_id,
                Message.receiver_id == current_user_id,
                Message.is_read == False
            )
        ).all()
        
        for message in unread_messages:
            message.is_read = True
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': [message.to_dict() for message in messages]
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@messages_bp.route('/api/messages/<int:message_id>/read', methods=['PUT'])
@jwt_required()
def mark_message_read(message_id):
    """Mark a message as read"""
    try:
        current_user_id = get_jwt_identity()
        message = Message.query.get_or_404(message_id)
        
        # Check if user is the receiver
        if message.receiver_id != current_user_id:
            return jsonify({'success': False, 'message': 'Access denied'}), 403
        
        message.is_read = True
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Message marked as read'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500