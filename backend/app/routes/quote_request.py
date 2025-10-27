from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.quote import Quote, QuoteStatus, BudgetRange, AreaType
from app.models.user import User, UserType
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from app.models.message import Message
from datetime import datetime, date
import json

quote_request_bp = Blueprint('quote_request', __name__)

@quote_request_bp.route('/request', methods=['POST'])
@jwt_required()
def create_quote_request():
    """Create a quote request (customer to craftsman)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        # Only customers can create quote requests
        if not user or user.user_type != UserType.CUSTOMER.value:
            return jsonify({
                'error': True,
                'message': 'Bu işlem sadece müşteriler tarafından yapılabilir',
                'code': 'UNAUTHORIZED'
            }), 403
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['craftsman_id', 'category', 'area_type', 'budget_range', 'description']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} alanı zorunludur',
                    'code': 'MISSING_FIELD'
                }), 400
        
        # Validate craftsman exists
        craftsman_user = User.query.filter_by(
            id=data['craftsman_id'], 
            user_type=UserType.CRAFTSMAN.value
        ).first()
        if not craftsman_user:
            return jsonify({
                'error': True,
                'message': 'Usta bulunamadı',
                'code': 'CRAFTSMAN_NOT_FOUND'
            }), 404
        
        # Validate budget range
        valid_budget_ranges = [e.value for e in BudgetRange]
        if data['budget_range'] not in valid_budget_ranges:
            return jsonify({
                'error': True,
                'message': 'Geçersiz bütçe aralığı',
                'code': 'INVALID_BUDGET_RANGE'
            }), 400
        
        # Validate area type
        valid_area_types = [e.value for e in AreaType]
        if data['area_type'] not in valid_area_types:
            return jsonify({
                'error': True,
                'message': 'Geçersiz alan türü',
                'code': 'INVALID_AREA_TYPE'
            }), 400
        
        # Check if there's already a pending quote between these users
        existing_quote = Quote.query.filter_by(
            customer_id=user_id,
            craftsman_id=data['craftsman_id'],
            status=QuoteStatus.PENDING.value
        ).first()
        
        if existing_quote:
            return jsonify({
                'error': True,
                'message': 'Bu usta ile zaten bekleyen bir teklif talebiniz bulunmaktadır',
                'code': 'QUOTE_ALREADY_EXISTS'
            }), 400
        
        # Create quote request
        quote = Quote(
            customer_id=user_id,
            craftsman_id=data['craftsman_id'],
            category=data['category'],
            job_type=data.get('job_type', data['category']),
            location=data.get('location', f"{user.city}, {user.district}"),
            area_type=data['area_type'],
            square_meters=data.get('square_meters'),
            budget_range=data['budget_range'],
            description=data['description'],
            additional_details=data.get('additional_details'),
            status=QuoteStatus.PENDING.value
        )
        
        db.session.add(quote)
        db.session.commit()
        
        # Create initial message in the conversation
        square_meters_text = f"Metrekare: {data.get('square_meters')} m²\n" if data.get('square_meters') else ""
        additional_details_text = data.get('additional_details', '')
        
        initial_message = Message(
            quote_id=quote.id,
            sender_id=user_id,
            receiver_id=data['craftsman_id'],
            content=f"Teklif Talebi:\n\nKategori: {data['category']}\nAlan: {data['area_type']}\nBütçe: {data['budget_range']} TL\n{square_meters_text}\nAçıklama: {data['description']}\n\n{additional_details_text}",
            message_type='quote_request'
        )
        
        db.session.add(initial_message)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Teklif talebiniz başarıyla gönderildi',
            'quote': quote.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Teklif talebi oluşturulurken bir hata oluştu',
            'code': 'QUOTE_REQUEST_ERROR'
        }), 500

@quote_request_bp.route('/respond', methods=['POST'])
@jwt_required()
def respond_to_quote():
    """Craftsman responds to quote request"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        # Only craftsmen can respond to quotes
        if not user or user.user_type != UserType.CRAFTSMAN.value:
            return jsonify({
                'error': True,
                'message': 'Bu işlem sadece ustalar tarafından yapılabilir',
                'code': 'UNAUTHORIZED'
            }), 403
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['quote_id', 'response_type']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} alanı zorunludur',
                    'code': 'MISSING_FIELD'
                }), 400
        
        # Get quote
        quote = Quote.query.filter_by(
            id=data['quote_id'],
            craftsman_id=user_id,
            status=QuoteStatus.PENDING.value
        ).first()
        
        if not quote:
            return jsonify({
                'error': True,
                'message': 'Teklif talebi bulunamadı veya yanıtlanamaz durumda',
                'code': 'QUOTE_NOT_FOUND'
            }), 404
        
        response_type = data['response_type']
        
        if response_type == 'quote':
            # Craftsman provides a quote
            if not data.get('quoted_price') or not data.get('estimated_start_date') or not data.get('estimated_end_date'):
                return jsonify({
                    'error': True,
                    'message': 'Teklif verirken fiyat ve tarih aralığı zorunludur',
                    'code': 'MISSING_QUOTE_DETAILS'
                }), 400
            
            quote.craftsman_response_type = 'quote'
            quote.quoted_price = data['quoted_price']
            quote.craftsman_notes = data.get('notes', '')
            quote.estimated_start_date = datetime.strptime(data['estimated_start_date'], '%Y-%m-%d').date()
            quote.estimated_end_date = datetime.strptime(data['estimated_end_date'], '%Y-%m-%d').date()
            quote.estimated_duration_days = (quote.estimated_end_date - quote.estimated_start_date).days
            quote.update_status(QuoteStatus.QUOTED.value)
            
            # Create message with quote details
            message_content = f"Teklif:\n\nFiyat: {data['quoted_price']} TL\nTahmini Başlangıç: {data['estimated_start_date']}\nTahmini Bitiş: {data['estimated_end_date']}\n\n{data.get('notes', '')}"
            
        elif response_type == 'details_request':
            # Craftsman requests more details
            quote.craftsman_response_type = 'details_request'
            quote.craftsman_notes = data.get('notes', 'Daha fazla detay gerekiyor')
            quote.update_status(QuoteStatus.DETAILS_REQUESTED.value)
            
            message_content = f"Detay Talebi:\n\n{data.get('notes', 'Bu iş hakkında daha fazla detay verebilir misiniz?')}"
            
        elif response_type == 'reject':
            # Craftsman rejects the quote
            quote.craftsman_response_type = 'reject'
            quote.craftsman_notes = data.get('notes', 'Teklif reddedildi')
            quote.update_status(QuoteStatus.REJECTED.value)
            
            message_content = f"Teklif Reddedildi:\n\n{data.get('notes', 'Üzgünüm, bu iş için teklif veremiyorum.')}"
            
        else:
            return jsonify({
                'error': True,
                'message': 'Geçersiz yanıt türü',
                'code': 'INVALID_RESPONSE_TYPE'
            }), 400
        
        # Create response message
        response_message = Message(
            quote_id=quote.id,
            sender_id=user_id,
            receiver_id=quote.customer_id,
            content=message_content,
            message_type='quote_response'
        )
        
        db.session.add(response_message)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Yanıtınız başarıyla gönderildi',
            'quote': quote.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Teklif yanıtı gönderilirken bir hata oluştu',
            'code': 'QUOTE_RESPONSE_ERROR'
        }), 500

@quote_request_bp.route('/customer-decision', methods=['POST'])
@jwt_required()
def customer_quote_decision():
    """Customer accepts, rejects, or requests revision for a quote"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        # Only customers can make decisions on quotes
        if not user or user.user_type != UserType.CUSTOMER.value:
            return jsonify({
                'error': True,
                'message': 'Bu işlem sadece müşteriler tarafından yapılabilir',
                'code': 'UNAUTHORIZED'
            }), 403
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['quote_id', 'decision']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} alanı zorunludur',
                    'code': 'MISSING_FIELD'
                }), 400
        
        # Get quote
        quote = Quote.query.filter_by(
            id=data['quote_id'],
            customer_id=user_id,
            status=QuoteStatus.QUOTED.value
        ).first()
        
        if not quote:
            return jsonify({
                'error': True,
                'message': 'Teklif bulunamadı veya karar verilemez durumda',
                'code': 'QUOTE_NOT_FOUND'
            }), 404
        
        decision = data['decision']
        
        if decision == 'accept':
            quote.update_status(QuoteStatus.ACCEPTED.value)
            message_content = "Teklif Kabul Edildi!\n\nTeklifiniz kabul edildi. Ödeme işlemlerini tamamlayabilirsiniz."
            
        elif decision == 'reject':
            quote.update_status(QuoteStatus.REJECTED.value)
            message_content = f"Teklif Reddedildi\n\n{data.get('notes', 'Teklif reddedildi.')}"
            
        elif decision == 'revision':
            quote.update_status(QuoteStatus.REVISION_REQUESTED.value)
            message_content = f"Yeni Teklif Talebi\n\n{data.get('notes', 'Lütfen teklifinizi gözden geçirebilir misiniz?')}"
            
        else:
            return jsonify({
                'error': True,
                'message': 'Geçersiz karar türü',
                'code': 'INVALID_DECISION'
            }), 400
        
        # Create decision message
        decision_message = Message(
            quote_id=quote.id,
            sender_id=user_id,
            receiver_id=quote.craftsman_id,
            content=message_content,
            message_type='quote_decision'
        )
        
        db.session.add(decision_message)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Kararınız başarıyla iletildi',
            'quote': quote.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Karar iletilirken bir hata oluştu',
            'code': 'DECISION_ERROR'
        }), 500

@quote_request_bp.route('/my-quotes', methods=['GET'])
@jwt_required()
def get_my_quotes():
    """Get user's quotes (both as customer and craftsman)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'error': True,
                'message': 'Kullanıcı bulunamadı',
                'code': 'USER_NOT_FOUND'
            }), 404
        
        # Get quotes based on user type
        if user.user_type == UserType.CUSTOMER.value:
            quotes = Quote.query.filter_by(customer_id=user_id).order_by(Quote.created_at.desc()).all()
        elif user.user_type == UserType.CRAFTSMAN.value:
            quotes = Quote.query.filter_by(craftsman_id=user_id).order_by(Quote.created_at.desc()).all()
        else:
            quotes = []
        
        return jsonify({
            'success': True,
            'quotes': [quote.to_dict() for quote in quotes]
        })
        
    except Exception as e:
        return jsonify({
            'error': True,
            'message': 'Teklifler alınırken bir hata oluştu',
            'code': 'GET_QUOTES_ERROR'
        }), 500

@quote_request_bp.route('/<int:quote_id>', methods=['GET'])
@jwt_required()
def get_quote_detail(quote_id):
    """Get quote details"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'error': True,
                'message': 'Kullanıcı bulunamadı',
                'code': 'USER_NOT_FOUND'
            }), 404
        
        # Get quote - user must be either customer or craftsman of this quote
        quote = Quote.query.filter(
            Quote.id == quote_id,
            (Quote.customer_id == user_id) | (Quote.craftsman_id == user_id)
        ).first()
        
        if not quote:
            return jsonify({
                'error': True,
                'message': 'Teklif bulunamadı',
                'code': 'QUOTE_NOT_FOUND'
            }), 404
        
        # Get messages for this quote
        messages = Message.query.filter_by(quote_id=quote.id).order_by(Message.created_at.asc()).all()
        
        return jsonify({
            'success': True,
            'quote': quote.to_dict(),
            'messages': [message.to_dict() for message in messages]
        })
        
    except Exception as e:
        return jsonify({
            'error': True,
            'message': 'Teklif detayları alınırken bir hata oluştu',
            'code': 'GET_QUOTE_DETAIL_ERROR'
        }), 500

@quote_request_bp.route('/budget-ranges', methods=['GET'])
def get_budget_ranges():
    """Get available budget ranges"""
    return jsonify({
        'success': True,
        'budget_ranges': [
            {'value': e.value, 'label': f"{e.value} TL"} 
            for e in BudgetRange
        ]
    })

@quote_request_bp.route('/area-types', methods=['GET'])
def get_area_types():
    """Get available area types"""
    return jsonify({
        'success': True,
        'area_types': [
            {'value': e.value, 'label': e.value.replace('_', ' ').title()} 
            for e in AreaType
        ]
    })