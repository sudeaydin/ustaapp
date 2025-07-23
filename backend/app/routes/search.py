from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.craftsman import Craftsman
from app.models.category import Category
from sqlalchemy import or_, and_

search_bp = Blueprint('search', __name__)

@search_bp.route('/craftsmen', methods=['GET'])
def search_craftsmen():
    """Search craftsmen with filters"""
    try:
        # Get query parameters
        query = request.args.get('q', '').strip()
        category_id = request.args.get('category_id', type=int)
        city = request.args.get('city', '').strip()
        district = request.args.get('district', '').strip()
        min_rating = request.args.get('min_rating', type=float)
        max_rate = request.args.get('max_rate', type=float)
        is_available = request.args.get('is_available', type=bool)
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        # Start with base query
        craftsmen_query = Craftsman.query.join(User).filter(User.is_active == True)
        
        # Apply filters
        if query:
            craftsmen_query = craftsmen_query.filter(
                or_(
                    Craftsman.business_name.ilike(f'%{query}%'),
                    Craftsman.description.ilike(f'%{query}%'),
                    User.first_name.ilike(f'%{query}%'),
                    User.last_name.ilike(f'%{query}%')
                )
            )
        
        if category_id:
            # For now, we'll search in description - later we can add category relationships
            category = Category.query.get(category_id)
            if category:
                craftsmen_query = craftsmen_query.filter(
                    Craftsman.description.ilike(f'%{category.name}%')
                )
        
        if city:
            craftsmen_query = craftsmen_query.filter(
                Craftsman.city.ilike(f'%{city}%')
            )
        
        if district:
            craftsmen_query = craftsmen_query.filter(
                Craftsman.district.ilike(f'%{district}%')
            )
        
        if min_rating is not None:
            craftsmen_query = craftsmen_query.filter(
                Craftsman.average_rating >= min_rating
            )
        
        if max_rate is not None:
            craftsmen_query = craftsmen_query.filter(
                Craftsman.hourly_rate <= max_rate
            )
        
        if is_available is not None:
            craftsmen_query = craftsmen_query.filter(
                Craftsman.is_available == is_available
            )
        
        # Order by rating and availability
        craftsmen_query = craftsmen_query.order_by(
            Craftsman.is_available.desc(),
            Craftsman.average_rating.desc()
        )
        
        # Paginate
        craftsmen = craftsmen_query.paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        result = []
        for craftsman in craftsmen.items:
            result.append({
                'id': craftsman.id,
                'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
                'business_name': craftsman.business_name,
                'description': craftsman.description,
                'city': craftsman.city,
                'district': craftsman.district,
                'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                'average_rating': craftsman.average_rating,
                'total_reviews': craftsman.total_reviews,
                'is_available': craftsman.is_available,
                'is_verified': craftsman.is_verified,
                'user': {
                    'phone': craftsman.user.phone,
                    'email': craftsman.user.email
                }
            })
        
        return jsonify({
            'success': True,
            'data': {
                'craftsmen': result,
                'pagination': {
                    'page': craftsmen.page,
                    'pages': craftsmen.pages,
                    'per_page': craftsmen.per_page,
                    'total': craftsmen.total
                },
                'filters_applied': {
                    'query': query,
                    'category_id': category_id,
                    'city': city,
                    'district': district,
                    'min_rating': min_rating,
                    'max_rate': max_rate,
                    'is_available': is_available
                }
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@search_bp.route('/categories', methods=['GET'])
def get_categories():
    """Get all categories for filtering"""
    try:
        categories = Category.query.filter_by(is_active=True).order_by(Category.sort_order).all()
        
        result = []
        for category in categories:
            result.append({
                'id': category.id,
                'name': category.name,
                'description': category.description,
                'icon': category.icon,
                'color': category.color
            })
        
        return jsonify({
            'success': True,
            'data': result
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@search_bp.route('/locations', methods=['GET'])
def get_locations():
    """Get available cities and districts"""
    try:
        # Get unique cities
        cities = db.session.query(Craftsman.city).filter(
            Craftsman.city.isnot(None),
            Craftsman.city != ''
        ).distinct().all()
        
        # Get unique districts
        districts = db.session.query(Craftsman.district).filter(
            Craftsman.district.isnot(None),
            Craftsman.district != ''
        ).distinct().all()
        
        return jsonify({
            'success': True,
            'data': {
                'cities': [city[0] for city in cities],
                'districts': [district[0] for district in districts]
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@search_bp.route('/popular', methods=['GET'])
def get_popular_searches():
    """Get popular search terms and categories"""
    try:
        # Get top rated craftsmen
        top_craftsmen = Craftsman.query.join(User).filter(
            User.is_active == True,
            Craftsman.is_available == True,
            Craftsman.average_rating >= 4.5
        ).order_by(Craftsman.average_rating.desc()).limit(5).all()
        
        # Get popular categories (ones with most craftsmen)
        popular_categories = db.session.query(Category).join(
            # We'll simulate this for now since we don't have direct category relationships
            Category
        ).filter(Category.is_active == True).order_by(Category.sort_order).limit(6).all()
        
        return jsonify({
            'success': True,
            'data': {
                'top_craftsmen': [{
                    'id': craftsman.id,
                    'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
                    'business_name': craftsman.business_name,
                    'average_rating': craftsman.average_rating,
                    'total_reviews': craftsman.total_reviews,
                    'city': craftsman.city
                } for craftsman in top_craftsmen],
                'popular_categories': [{
                    'id': category.id,
                    'name': category.name,
                    'icon': category.icon,
                    'color': category.color
                } for category in popular_categories]
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500