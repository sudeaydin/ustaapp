from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from datetime import datetime

messages_bp = Blueprint('messages', __name__)

# Simple Message model for now (we'll add to database later)
class Message(db.Model):
    """Simple message model"""
    __tablename__ = 'messages'
    
    id = db.Column(db.Integer, primary_key=True)
    sender_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    receiver_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    content = db.Column(db.Text, nullable=False)
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.now)
    
    # Relationships
    sender = db.relationship('User', foreign_keys=[sender_id], backref='sent_messages')
    receiver = db.relationship('User', foreign_keys=[receiver_id], backref='received_messages')
    
    def to_dict(self):
        return {
            'id': self.id,
            'sender_id': self.sender_id,
            'receiver_id': self.receiver_id,
            'content': self.content,
            'is_read': self.is_read,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'sender': {
                'id': self.sender.id,
                'first_name': self.sender.first_name,
                'last_name': self.sender.last_name,
                'user_type': self.sender.user_type
            } if self.sender else None,
            'receiver': {
                'id': self.receiver.id,
                'first_name': self.receiver.first_name,
                'last_name': self.receiver.last_name,
                'user_type': self.receiver.user_type
            } if self.receiver else None
        }

@messages_bp.route('/conversations', methods=['GET'])
@jwt_required()
def get_conversations():
    """Get user's conversations"""
    try:
        user_id = get_jwt_identity()
        
        # Get all messages where user is sender or receiver
        messages = Message.query.filter(
            db.or_(Message.sender_id == user_id, Message.receiver_id == user_id)
        ).order_by(Message.created_at.desc()).all()
        
        # Group by conversation partner
        conversations = {}
        for message in messages:
            partner_id = message.sender_id if message.receiver_id == user_id else message.receiver_id
            
            if partner_id not in conversations:
                partner = User.query.get(partner_id)
                conversations[partner_id] = {
                    'partner_id': partner_id,
                    'partner_name': f"{partner.first_name} {partner.last_name}",
                    'partner_type': partner.user_type,
                    'last_message': message.to_dict(),
                    'unread_count': 0,
                    'messages': []
                }
            
            conversations[partner_id]['messages'].append(message.to_dict())
            
            # Count unread messages
            if message.receiver_id == user_id and not message.is_read:
                conversations[partner_id]['unread_count'] += 1
        
        return jsonify({
            'success': True,
            'data': list(conversations.values())
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@messages_bp.route('/conversation/<int:partner_id>', methods=['GET'])
@jwt_required()
def get_conversation(partner_id):
    """Get messages with specific user"""
    try:
        user_id = get_jwt_identity()
        
        messages = Message.query.filter(
            db.or_(
                db.and_(Message.sender_id == user_id, Message.receiver_id == partner_id),
                db.and_(Message.sender_id == partner_id, Message.receiver_id == user_id)
            )
        ).order_by(Message.created_at.asc()).all()
        
        # Mark messages as read
        unread_messages = Message.query.filter(
            Message.sender_id == partner_id,
            Message.receiver_id == user_id,
            Message.is_read == False
        ).all()
        
        for message in unread_messages:
            message.is_read = True
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': [message.to_dict() for message in messages]
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@messages_bp.route('/send', methods=['POST'])
@jwt_required()
def send_message():
    """Send a message"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('receiver_id') or not data.get('content'):
            return jsonify({
                'success': False,
                'message': 'Alıcı ve mesaj içeriği gerekli'
            }), 400
        
        # Check if receiver exists
        receiver = User.query.get(data['receiver_id'])
        if not receiver:
            return jsonify({
                'success': False,
                'message': 'Alıcı bulunamadı'
            }), 404
        
        # Create message
        message = Message(
            sender_id=user_id,
            receiver_id=data['receiver_id'],
            content=data['content'],
            created_at=datetime.now()
        )
        
        db.session.add(message)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Mesaj gönderildi',
            'data': message.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@messages_bp.route('/mark-read/<int:message_id>', methods=['PUT'])
@jwt_required()
def mark_message_read(message_id):
    """Mark message as read"""
    try:
        user_id = get_jwt_identity()
        
        message = Message.query.filter(
            Message.id == message_id,
            Message.receiver_id == user_id
        ).first()
        
        if not message:
            return jsonify({
                'success': False,
                'message': 'Mesaj bulunamadı'
            }), 404
        
        message.is_read = True
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Mesaj okundu olarak işaretlendi'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@messages_bp.route('/unread-count', methods=['GET'])
@jwt_required()
def get_unread_count():
    """Get unread message count"""
    try:
        user_id = get_jwt_identity()
        
        count = Message.query.filter(
            Message.receiver_id == user_id,
            Message.is_read == False
        ).count()
        
        return jsonify({
            'success': True,
            'data': {'unread_count': count}
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500