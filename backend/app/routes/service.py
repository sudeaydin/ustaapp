from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.service import Service
from app.models.category import Category
from app.models.craftsman import Craftsman
from app.models.user import User
from sqlalchemy import or_, and_

service_bp = Blueprint('service', __name__)

@service_bp.route('', methods=['GET'])
def get_services():
    """Get services with filtering and pagination"""
    try:
        # Get query parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('limit', 20, type=int), 100)  # Max 100 items per page
        category_id = request.args.get('category_id', type=int)
        city = request.args.get('city', type=str)
        search = request.args.get('search', type=str)
        min_price = request.args.get('min_price', type=float)
        max_price = request.args.get('max_price', type=float)
        sort_by = request.args.get('sort_by', 'created_at')  # created_at, price, rating
        sort_order = request.args.get('sort_order', 'desc')  # asc, desc
        
        # Base query
        query = db.session.query(Service).filter(Service.is_active == True)
        
        # Join with craftsman and user for filtering and sorting
        query = query.join(Craftsman).join(User)
        
        # Apply filters
        if category_id:
            query = query.filter(Service.category_id == category_id)
        
        if city:
            # Filter by service cities (JSON field) or craftsman location
            query = query.filter(
                or_(
                    Service.service_cities.contains([city]),
                    Craftsman.location.ilike(f'%{city}%')
                )
            )
        
        if search:
            # Search in title, description, craftsman name
            search_term = f'%{search}%'
            query = query.filter(
                or_(
                    Service.title.ilike(search_term),
                    Service.description.ilike(search_term),
                    User.first_name.ilike(search_term),
                    User.last_name.ilike(search_term)
                )
            )
        
        if min_price:
            query = query.filter(Service.price_min >= min_price)
        
        if max_price:
            query = query.filter(Service.price_max <= max_price)
        
        # Apply sorting
        if sort_by == 'price':
            if sort_order == 'asc':
                query = query.order_by(Service.price_min.asc())
            else:
                query = query.order_by(Service.price_max.desc())
        elif sort_by == 'rating':
            if sort_order == 'asc':
                query = query.order_by(Craftsman.rating.asc())
            else:
                query = query.order_by(Craftsman.rating.desc())
        else:  # created_at
            if sort_order == 'asc':
                query = query.order_by(Service.created_at.asc())
            else:
                query = query.order_by(Service.created_at.desc())
        
        # Paginate
        services_paginated = query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        # Format response
        services_data = []
        for service in services_paginated.items:
            service_dict = service.to_dict(include_craftsman=True)
            services_data.append(service_dict)
        
        return jsonify({
            'success': True,
            'data': {
                'services': services_data,
                'pagination': {
                    'page': page,
                    'pages': services_paginated.pages,
                    'per_page': per_page,
                    'total': services_paginated.total,
                    'has_next': services_paginated.has_next,
                    'has_prev': services_paginated.has_prev
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'error': True,
            'message': 'Hizmetler yüklenirken bir hata oluştu',
            'code': 'SERVICES_FETCH_ERROR'
        }), 500

@service_bp.route('/<int:service_id>', methods=['GET'])
def get_service_detail(service_id):
    """Get detailed service information"""
    try:
        service = Service.query.filter_by(id=service_id, is_active=True).first()
        
        if not service:
            return jsonify({
                'error': True,
                'message': 'Hizmet bulunamadı',
                'code': 'SERVICE_NOT_FOUND'
            }), 404
        
        # Get service data with craftsman details
        service_data = service.to_dict(include_craftsman=True)
        
        # Add craftsman's other services
        other_services = Service.query.filter(
            and_(
                Service.craftsman_id == service.craftsman_id,
                Service.id != service_id,
                Service.is_active == True
            )
        ).limit(5).all()
        
        service_data['craftsman']['other_services'] = [
            s.to_dict() for s in other_services
        ]
        
        # Add craftsman's reviews (latest 5)
        from app.models.review import Review
        recent_reviews = Review.query.filter_by(
            craftsman_id=service.craftsman_id,
            is_visible=True
        ).order_by(Review.created_at.desc()).limit(5).all()
        
        service_data['craftsman']['recent_reviews'] = [
            review.to_dict() for review in recent_reviews
        ]
        
        return jsonify({
            'success': True,
            'data': service_data
        })
        
    except Exception as e:
        return jsonify({
            'error': True,
            'message': 'Hizmet detayları yüklenirken bir hata oluştu',
            'code': 'SERVICE_DETAIL_ERROR'
        }), 500

@service_bp.route('', methods=['POST'])
@jwt_required()
def create_service():
    """Create a new service (craftsman only)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or not user.craftsman_profile:
            return jsonify({
                'error': True,
                'message': 'Bu işlem sadece ustalar tarafından yapılabilir',
                'code': 'UNAUTHORIZED'
            }), 403
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'category_id']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} alanı zorunludur',
                    'code': 'MISSING_FIELD'
                }), 400
        
        # Validate category exists
        category = Category.query.get(data['category_id'])
        if not category:
            return jsonify({
                'error': True,
                'message': 'Geçersiz kategori',
                'code': 'INVALID_CATEGORY'
            }), 400
        
        # Create service
        service = Service(
            craftsman_id=user.craftsman_profile.id,
            category_id=data['category_id'],
            title=data['title'],
            description=data['description'],
            price_min=data.get('price_min'),
            price_max=data.get('price_max'),
            price_unit=data.get('price_unit', 'per_job'),
            service_cities=data.get('service_cities', []),
            images=data.get('images', [])
        )
        
        db.session.add(service)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Hizmet başarıyla oluşturuldu',
            'data': service.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Hizmet oluşturulurken bir hata oluştu',
            'code': 'SERVICE_CREATE_ERROR'
        }), 500

@service_bp.route('/<int:service_id>', methods=['PUT'])
@jwt_required()
def update_service(service_id):
    """Update service (craftsman only, own services)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or not user.craftsman_profile:
            return jsonify({
                'error': True,
                'message': 'Bu işlem sadece ustalar tarafından yapılabilir',
                'code': 'UNAUTHORIZED'
            }), 403
        
        service = Service.query.filter_by(
            id=service_id,
            craftsman_id=user.craftsman_profile.id
        ).first()
        
        if not service:
            return jsonify({
                'error': True,
                'message': 'Hizmet bulunamadı veya güncelleme yetkiniz yok',
                'code': 'SERVICE_NOT_FOUND'
            }), 404
        
        data = request.get_json()
        
        # Update fields
        if 'title' in data:
            service.title = data['title']
        if 'description' in data:
            service.description = data['description']
        if 'price_min' in data:
            service.price_min = data['price_min']
        if 'price_max' in data:
            service.price_max = data['price_max']
        if 'price_unit' in data:
            service.price_unit = data['price_unit']
        if 'service_cities' in data:
            service.service_cities = data['service_cities']
        if 'images' in data:
            service.images = data['images']
        if 'is_active' in data:
            service.is_active = data['is_active']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Hizmet başarıyla güncellendi',
            'data': service.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Hizmet güncellenirken bir hata oluştu',
            'code': 'SERVICE_UPDATE_ERROR'
        }), 500

@service_bp.route('/<int:service_id>', methods=['DELETE'])
@jwt_required()
def delete_service(service_id):
    """Delete service (craftsman only, own services)"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or not user.craftsman_profile:
            return jsonify({
                'error': True,
                'message': 'Bu işlem sadece ustalar tarafından yapılabilir',
                'code': 'UNAUTHORIZED'
            }), 403
        
        service = Service.query.filter_by(
            id=service_id,
            craftsman_id=user.craftsman_profile.id
        ).first()
        
        if not service:
            return jsonify({
                'error': True,
                'message': 'Hizmet bulunamadı veya silme yetkiniz yok',
                'code': 'SERVICE_NOT_FOUND'
            }), 404
        
        # Soft delete (deactivate)
        service.is_active = False
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Hizmet başarıyla silindi'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': True,
            'message': 'Hizmet silinirken bir hata oluştu',
            'code': 'SERVICE_DELETE_ERROR'
        }), 500
