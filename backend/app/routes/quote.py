from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.quote import Quote, QuoteStatus
from app.models.service import Service
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from datetime import datetime, date

quote_bp = Blueprint('quote', __name__)

@quote_bp.route('', methods=['POST'])
@jwt_required()
def create_quote():
    """Create a quote request (customer only)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or not user.customer_profile:
            return jsonify({
                'error': True,
                'message': 'Bu işlem sadece müşteriler tarafından yapılabilir',
                'code': 'UNAUTHORIZED'
            }), 403
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['service_id', 'description']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} alanı zorunludur',
                    'code': 'MISSING_FIELD'
                }), 400
        
        # Validate service exists and is active
        service = Service.query.filter_by(id=data['service_id'], is_active=True).first()
        if not service:
            return jsonify({
                'error': True,
                'message': 'Hizmet bulunamadı',
                'code': 'SERVICE_NOT_FOUND'
            }), 404
        
        # Check if customer already has a pending quote for this service
        existing_quote = Quote.query.filter_by(
            customer_id=user.customer_profile.id,
            service_id=data['service_id'],
            status=QuoteStatus.PENDING
        ).first()
        
        if existing_quote:
            return jsonify({
                'error': True,
                'message': 'Bu hizmet için zaten bekleyen bir teklifiniz var',
                'code': 'QUOTE_EXISTS'
            }), 400
        
        # Parse preferred date
        preferred_date = None
        if data.get('preferred_date'):
            try:
                preferred_date = datetime.strptime(data['preferred_date'], '%Y-%m-%d').date()
            except ValueError:
                return jsonify({
                    'error': True,
                    'message': 'Geçersiz tarih formatı (YYYY-MM-DD)',
                    'code': 'INVALID_DATE'
                }), 400
        
        # Create quote
        quote = Quote(
            customer_id=user.customer_profile.id,
            craftsman_id=service.craftsman_id,
            service_id=data['service_id'],
            description=data['description'],
            budget_min=data.get('budget_min'),
            budget_max=data.get('budget_max'),
            preferred_date=preferred_date,
            work_address=data.get('work_address'),
            contact_phone=data.get('contact_phone', user.phone),
            customer_images=data.get('images', [])
        )
        
        db.session.add(quote)
        db.session.commit()
        
        # TODO: Send notification to craftsman
        
        return jsonify({
            'success': True,
            'message': 'Teklif talebiniz başarıyla gönderildi',
            'data': quote.to_dict(include_details=True)
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Teklif oluşturulurken bir hata oluştu',
            'code': 'QUOTE_CREATE_ERROR'
        }), 500

@quote_bp.route('', methods=['GET'])
@jwt_required()
def get_quotes():
    """Get user's quotes (customer: sent, craftsman: received)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'error': True,
                'message': 'Kullanıcı bulunamadı',
                'code': 'USER_NOT_FOUND'
            }), 404
        
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('limit', 20, type=int), 100)
        status = request.args.get('status')  # Filter by status
        
        # Base query based on user type
        if user.customer_profile:
            query = Quote.query.filter_by(customer_id=user.customer_profile.id)
        elif user.craftsman_profile:
            query = Quote.query.filter_by(craftsman_id=user.craftsman_profile.id)
        else:
            return jsonify({
                'error': True,
                'message': 'Geçersiz kullanıcı profili',
                'code': 'INVALID_PROFILE'
            }), 400
        
        # Apply status filter
        if status and status in [s.value for s in QuoteStatus]:
            query = query.filter(Quote.status == QuoteStatus(status))
        
        # Order by creation date (newest first)
        query = query.order_by(Quote.created_at.desc())
        
        # Paginate
        quotes_paginated = query.paginate(
            page=page,
            per_page=per_page,
            error_out=False
        )
        
        # Format response
        quotes_data = []
        for quote in quotes_paginated.items:
            quote_data = quote.to_dict(include_details=True)
            quotes_data.append(quote_data)
        
        return jsonify({
            'success': True,
            'data': {
                'quotes': quotes_data,
                'pagination': {
                    'page': page,
                    'pages': quotes_paginated.pages,
                    'per_page': per_page,
                    'total': quotes_paginated.total,
                    'has_next': quotes_paginated.has_next,
                    'has_prev': quotes_paginated.has_prev
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'error': True,
            'message': 'Teklifler yüklenirken bir hata oluştu',
            'code': 'QUOTES_FETCH_ERROR'
        }), 500

@quote_bp.route('/<int:quote_id>', methods=['GET'])
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
        
        # Find quote and check access
        quote = Quote.query.get(quote_id)
        if not quote:
            return jsonify({
                'error': True,
                'message': 'Teklif bulunamadı',
                'code': 'QUOTE_NOT_FOUND'
            }), 404
        
        # Check if user has access to this quote
        has_access = False
        if user.customer_profile and quote.customer_id == user.customer_profile.id:
            has_access = True
        elif user.craftsman_profile and quote.craftsman_id == user.craftsman_profile.id:
            has_access = True
        
        if not has_access:
            return jsonify({
                'error': True,
                'message': 'Bu teklife erişim yetkiniz yok',
                'code': 'ACCESS_DENIED'
            }), 403
        
        return jsonify({
            'success': True,
            'data': quote.to_dict(include_details=True)
        })
        
    except Exception as e:
        return jsonify({
            'error': True,
            'message': 'Teklif detayları yüklenirken bir hata oluştu',
            'code': 'QUOTE_DETAIL_ERROR'
        }), 500

@quote_bp.route('/<int:quote_id>', methods=['PUT'])
@jwt_required()
def update_quote(quote_id):
    """Update quote (craftsman: respond to quote, customer: update request)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'error': True,
                'message': 'Kullanıcı bulunamadı',
                'code': 'USER_NOT_FOUND'
            }), 404
        
        quote = Quote.query.get(quote_id)
        if not quote:
            return jsonify({
                'error': True,
                'message': 'Teklif bulunamadı',
                'code': 'QUOTE_NOT_FOUND'
            }), 404
        
        data = request.get_json()
        
        # Check user access and allowed updates
        if user.craftsman_profile and quote.craftsman_id == user.craftsman_profile.id:
            # Craftsman can respond to quote
            if 'status' in data:
                new_status = data['status']
                if new_status not in ['accepted', 'rejected']:
                    return jsonify({
                        'error': True,
                        'message': 'Geçersiz durum',
                        'code': 'INVALID_STATUS'
                    }), 400
                
                quote.status = QuoteStatus(new_status)
                if new_status == 'accepted':
                    quote.accepted_at = datetime.utcnow()
            
            if 'quoted_price' in data:
                quote.quoted_price = data['quoted_price']
            
            if 'craftsman_notes' in data:
                quote.craftsman_notes = data['craftsman_notes']
            
            if 'estimated_duration' in data:
                quote.estimated_duration = data['estimated_duration']
            
            if 'craftsman_images' in data:
                quote.craftsman_images = data['craftsman_images']
                
        elif user.customer_profile and quote.customer_id == user.customer_profile.id:
            # Customer can update request (only if pending)
            if quote.status != QuoteStatus.PENDING:
                return jsonify({
                    'error': True,
                    'message': 'Sadece bekleyen teklifler güncellenebilir',
                    'code': 'QUOTE_NOT_EDITABLE'
                }), 400
            
            if 'description' in data:
                quote.description = data['description']
            
            if 'budget_min' in data:
                quote.budget_min = data['budget_min']
            
            if 'budget_max' in data:
                quote.budget_max = data['budget_max']
            
            if 'preferred_date' in data:
                try:
                    quote.preferred_date = datetime.strptime(data['preferred_date'], '%Y-%m-%d').date()
                except ValueError:
                    return jsonify({
                        'error': True,
                        'message': 'Geçersiz tarih formatı',
                        'code': 'INVALID_DATE'
                    }), 400
            
            if 'work_address' in data:
                quote.work_address = data['work_address']
            
            if 'customer_images' in data:
                quote.customer_images = data['customer_images']
        else:
            return jsonify({
                'error': True,
                'message': 'Bu teklifi güncelleme yetkiniz yok',
                'code': 'ACCESS_DENIED'
            }), 403
        
        db.session.commit()
        
        # TODO: Send notification to other party
        
        return jsonify({
            'success': True,
            'message': 'Teklif başarıyla güncellendi',
            'data': quote.to_dict(include_details=True)
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Teklif güncellenirken bir hata oluştu',
            'code': 'QUOTE_UPDATE_ERROR'
        }), 500

@quote_bp.route('/<int:quote_id>/complete', methods=['POST'])
@jwt_required()
def complete_quote(quote_id):
    """Mark quote as completed (craftsman only)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or not user.craftsman_profile:
            return jsonify({
                'error': True,
                'message': 'Bu işlem sadece ustalar tarafından yapılabilir',
                'code': 'UNAUTHORIZED'
            }), 403
        
        quote = Quote.query.filter_by(
            id=quote_id,
            craftsman_id=user.craftsman_profile.id
        ).first()
        
        if not quote:
            return jsonify({
                'error': True,
                'message': 'Teklif bulunamadı',
                'code': 'QUOTE_NOT_FOUND'
            }), 404
        
        if quote.status != QuoteStatus.ACCEPTED:
            return jsonify({
                'error': True,
                'message': 'Sadece kabul edilmiş teklifler tamamlanabilir',
                'code': 'QUOTE_NOT_ACCEPTED'
            }), 400
        
        quote.status = QuoteStatus.COMPLETED
        quote.completed_at = datetime.utcnow()
        db.session.commit()
        
        # TODO: Send notification to customer for review
        
        return jsonify({
            'success': True,
            'message': 'Teklif tamamlandı olarak işaretlendi',
            'data': quote.to_dict(include_details=True)
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Teklif tamamlanırken bir hata oluştu',
            'code': 'QUOTE_COMPLETE_ERROR'
        }), 500
