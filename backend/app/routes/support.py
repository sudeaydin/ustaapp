from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.support_ticket import SupportTicket, SupportMessage, TicketStatus, TicketPriority, TicketCategory
from app.utils.validators import ResponseHelper
from app.services.email_service import EmailService
import json
from datetime import datetime

support_bp = Blueprint('support', __name__)

@support_bp.route('/tickets', methods=['POST'])
@jwt_required()
def create_ticket():
    """Create a new support ticket"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return ResponseHelper.not_found('User not found')
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['subject', 'description']
        for field in required_fields:
            if not data.get(field):
                return ResponseHelper.validation_error(f'{field} is required')
        
        # Create ticket
        ticket = SupportTicket(
            user_id=user_id,
            subject=data['subject'],
            description=data['description'],
            category=TicketCategory(data.get('category', 'general')),
            priority=TicketPriority(data.get('priority', 'medium')),
        )
        
        ticket.generate_ticket_number()
        db.session.add(ticket)
        db.session.commit()
        
        # Send email notification to support team
        try:
            EmailService.send_support_ticket_created(ticket)
        except Exception as e:
            print(f"Failed to send support email: {e}")
        
        return ResponseHelper.success(
            data=ticket.to_dict(),
            message='Destek talebi oluşturuldu'
        )
        
    except Exception as e:
        db.session.rollback()
        return ResponseHelper.server_error('Destek talebi oluşturulamadı', str(e))

@support_bp.route('/tickets', methods=['GET'])
def get_user_tickets():
    """Get user's support tickets"""
    try:
        from app.utils.auth_utils import get_current_user_id_with_mock
        
        print("🎫 Support tickets request started")
        
        # Get user ID with mock token support
        user_id, error_response = get_current_user_id_with_mock()
        if error_response:
            print(f"❌ Auth error in support tickets")
            return error_response
        
        print(f"🎫 User ID for support tickets: {user_id}")
        
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 10, type=int), 50)
        
        tickets = SupportTicket.query.filter_by(user_id=user_id)\
            .order_by(SupportTicket.created_at.desc())\
            .paginate(page=page, per_page=per_page, error_out=False)
        
        return ResponseHelper.success(
            data={
                'tickets': [ticket.to_dict() for ticket in tickets.items],
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': tickets.total,
                    'pages': tickets.pages,
                    'has_next': tickets.has_next,
                    'has_prev': tickets.has_prev,
                }
            },
            message='Destek talepleri getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Destek talepleri getirilemedi', str(e))

@support_bp.route('/tickets/<int:ticket_id>', methods=['GET'])
@jwt_required()
def get_ticket_detail(ticket_id):
    """Get ticket details with messages"""
    try:
        user_id = get_jwt_identity()
        
        ticket = SupportTicket.query.filter_by(
            id=ticket_id,
            user_id=user_id
        ).first()
        
        if not ticket:
            return ResponseHelper.not_found('Destek talebi bulunamadı')
        
        # Get messages
        messages = SupportMessage.query.filter_by(ticket_id=ticket_id)\
            .order_by(SupportMessage.created_at.asc()).all()
        
        ticket_data = ticket.to_dict()
        ticket_data['messages'] = [msg.to_dict() for msg in messages]
        
        return ResponseHelper.success(
            data=ticket_data,
            message='Destek talebi detayları getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Destek talebi getirilemedi', str(e))

@support_bp.route('/tickets/<int:ticket_id>/messages', methods=['POST'])
@jwt_required()
def add_ticket_message(ticket_id):
    """Add a message to support ticket"""
    try:
        user_id = get_jwt_identity()
        
        ticket = SupportTicket.query.filter_by(
            id=ticket_id,
            user_id=user_id
        ).first()
        
        if not ticket:
            return ResponseHelper.not_found('Destek talebi bulunamadı')
        
        data = request.get_json()
        
        if not data.get('message'):
            return ResponseHelper.validation_error('Message is required')
        
        # Create message
        message = SupportMessage(
            ticket_id=ticket_id,
            message=data['message'],
            is_from_customer=True,
        )
        
        db.session.add(message)
        
        # Update ticket status and timestamp
        if ticket.status == TicketStatus.WAITING_FOR_CUSTOMER:
            ticket.status = TicketStatus.IN_PROGRESS
        ticket.updated_at = datetime.utcnow()
        
        db.session.commit()
        
        # Send email notification to support team
        try:
            EmailService.send_support_message_reply(ticket, message)
        except Exception as e:
            print(f"Failed to send support reply email: {e}")
        
        return ResponseHelper.success(
            data=message.to_dict(),
            message='Mesaj gönderildi'
        )
        
    except Exception as e:
        db.session.rollback()
        return ResponseHelper.server_error('Mesaj gönderilemedi', str(e))

@support_bp.route('/categories', methods=['GET'])
def get_support_categories():
    """Get available support categories"""
    try:
        categories = [
            {'value': 'technical', 'label': 'Teknik Sorun'},
            {'value': 'billing', 'label': 'Faturalama'},
            {'value': 'account', 'label': 'Hesap Sorunları'},
            {'value': 'feature_request', 'label': 'Özellik İsteği'},
            {'value': 'bug_report', 'label': 'Hata Bildirimi'},
            {'value': 'general', 'label': 'Genel'},
        ]
        
        return ResponseHelper.success(
            data=categories,
            message='Destek kategorileri getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Kategoriler getirilemedi', str(e))