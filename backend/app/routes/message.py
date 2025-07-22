from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..models.message import Message
from ..models.customer import Customer
from ..models.craftsman import Craftsman
from ..models.user import User
from ..schemas.message import MessageSchema
from datetime import datetime
import logging

message_bp = Blueprint('message', __name__)
message_schema = MessageSchema()

@message_bp.route('/conversations', methods=['GET'])
@jwt_required()
def get_conversations():
    """Get user's conversations"""
    try:
        user_id = get_jwt_identity()
        
        # Get all conversations where user is either sender or receiver
        conversations = Message.query.filter(
            (Message.sender_id == user_id) | (Message.receiver_id == user_id)
        ).order_by(Message.created_at.desc()).all()
        
        # Group by conversation partner
        conversation_dict = {}
        for message in conversations:
            partner_id = message.receiver_id if message.sender_id == user_id else message.sender_id
            
            if partner_id not in conversation_dict:
                partner = User.query.get(partner_id)
                conversation_dict[partner_id] = {
                    'partner_id': partner_id,
                    'partner_name': f"{partner.first_name} {partner.last_name}",
                    'partner_email': partner.email,
                    'last_message': message.content,
                    'last_message_time': message.created_at.isoformat(),
                    'unread_count': 0
                }
            
            # Count unread messages
            if message.receiver_id == user_id and not message.is_read:
                conversation_dict[partner_id]['unread_count'] += 1
        
        conversations_list = list(conversation_dict.values())
        
        return jsonify({
            'success': True,
            'conversations': conversations_list
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting conversations: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@message_bp.route('/conversations/<int:partner_id>', methods=['GET'])
@jwt_required()
def get_conversation_messages():
    """Get messages in a conversation"""
    try:
        user_id = get_jwt_identity()
        partner_id = request.view_args['partner_id']
        
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 50, type=int)
        
        # Get messages between user and partner
        messages = Message.query.filter(
            ((Message.sender_id == user_id) & (Message.receiver_id == partner_id)) |
            ((Message.sender_id == partner_id) & (Message.receiver_id == user_id))
        ).order_by(Message.created_at.asc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        # Mark messages as read
        Message.query.filter_by(
            sender_id=partner_id,
            receiver_id=user_id,
            is_read=False
        ).update({'is_read': True})
        
        return jsonify({
            'success': True,
            'messages': [message_schema.dump(msg) for msg in messages.items],
            'pagination': {
                'page': page,
                'pages': messages.pages,
                'per_page': per_page,
                'total': messages.total
            }
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting conversation messages: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@message_bp.route('/send', methods=['POST'])
@jwt_required()
def send_message():
    """Send a message"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['receiver_id', 'content']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'{field} is required'}), 400
        
        # Check if receiver exists
        receiver = User.query.get(data['receiver_id'])
        if not receiver:
            return jsonify({'error': 'Receiver not found'}), 404
            
        # Create message
        message = Message(
            sender_id=user_id,
            receiver_id=data['receiver_id'],
            content=data['content'],
            message_type=data.get('message_type', 'text'),
            quote_id=data.get('quote_id')
        )
        
        message.save()
        
        return jsonify({
            'success': True,
            'message': 'Message sent successfully',
            'data': message_schema.dump(message)
        }), 201
        
    except Exception as e:
        logging.error(f"Error sending message: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@message_bp.route('/<int:message_id>/read', methods=['PUT'])
@jwt_required()
def mark_message_read():
    """Mark a message as read"""
    try:
        user_id = get_jwt_identity()
        message_id = request.view_args['message_id']
        
        message = Message.query.filter_by(
            id=message_id,
            receiver_id=user_id
        ).first()
        
        if not message:
            return jsonify({'error': 'Message not found'}), 404
            
        message.is_read = True
        message.read_at = datetime.utcnow()
        message.save()
        
        return jsonify({
            'success': True,
            'message': 'Message marked as read'
        }), 200
        
    except Exception as e:
        logging.error(f"Error marking message as read: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@message_bp.route('/<int:message_id>', methods=['DELETE'])
@jwt_required()
def delete_message():
    """Delete a message"""
    try:
        user_id = get_jwt_identity()
        message_id = request.view_args['message_id']
        
        message = Message.query.filter_by(
            id=message_id,
            sender_id=user_id
        ).first()
        
        if not message:
            return jsonify({'error': 'Message not found or unauthorized'}), 404
            
        message.delete()
        
        return jsonify({
            'success': True,
            'message': 'Message deleted successfully'
        }), 200
        
    except Exception as e:
        logging.error(f"Error deleting message: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@message_bp.route('/unread-count', methods=['GET'])
@jwt_required()
def get_unread_count():
    """Get total unread message count"""
    try:
        user_id = get_jwt_identity()
        
        unread_count = Message.query.filter_by(
            receiver_id=user_id,
            is_read=False
        ).count()
        
        return jsonify({
            'success': True,
            'unread_count': unread_count
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting unread count: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@message_bp.route('/search', methods=['GET'])
@jwt_required()
def search_messages():
    """Search messages"""
    try:
        user_id = get_jwt_identity()
        query = request.args.get('q', '')
        
        if not query:
            return jsonify({'error': 'Search query is required'}), 400
            
        messages = Message.query.filter(
            ((Message.sender_id == user_id) | (Message.receiver_id == user_id)) &
            Message.content.contains(query)
        ).order_by(Message.created_at.desc()).limit(20).all()
        
        return jsonify({
            'success': True,
            'messages': [message_schema.dump(msg) for msg in messages]
        }), 200
        
    except Exception as e:
        logging.error(f"Error searching messages: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500
