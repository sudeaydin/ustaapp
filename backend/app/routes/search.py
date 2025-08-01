from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.craftsman import Craftsman
from app.models.category import Category
from sqlalchemy import or_, and_, func
import json

search_bp = Blueprint('search', __name__)

@search_bp.route('/craftsmen', methods=['GET'])
def search_craftsmen():
    """Search craftsmen with filters"""
    try:
        # Get query parameters
        query = request.args.get('q', '').strip()
        category_id = request.args.get('category_id', type=int)
        category_name = request.args.get('category', '').strip()
        city = request.args.get('city', '').strip()
        district = request.args.get('district', '').strip()
        min_rating = request.args.get('min_rating', type=float)
        max_rate = request.args.get('max_rate', type=float)
        is_available = request.args.get('is_available', type=bool)
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 12, type=int)
        sort_by = request.args.get('sort_by', 'rating')  # rating, rate, name, distance
        
        # Start with base query
        craftsmen_query = Craftsman.query.join(User).filter(User.is_active == True)
        
        # Apply filters
        if query:
            craftsmen_query = craftsmen_query.filter(
                or_(
                    Craftsman.business_name.ilike(f'%{query}%'),
                    Craftsman.description.ilike(f'%{query}%'),
                    User.first_name.ilike(f'%{query}%'),
                    User.last_name.ilike(f'%{query}%'),
                    Craftsman.skills.ilike(f'%{query}%')
                )
            )
        
        if category_id:
            # For now, we'll search in description - later we can add category relationships
            category = Category.query.get(category_id)
            if category:
                craftsmen_query = craftsmen_query.filter(
                    or_(
                        Craftsman.description.ilike(f'%{category.name}%'),
                        Craftsman.skills.ilike(f'%{category.name}%')
                    )
                )
        
        if category_name:
            craftsmen_query = craftsmen_query.filter(
                or_(
                    Craftsman.description.ilike(f'%{category_name}%'),
                    Craftsman.skills.ilike(f'%{category_name}%')
                )
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
        
        # Apply sorting
        if sort_by == 'rating':
            craftsmen_query = craftsmen_query.order_by(
                Craftsman.average_rating.desc(),
                Craftsman.is_available.desc()
            )
        elif sort_by == 'rate':
            craftsmen_query = craftsmen_query.order_by(
                Craftsman.hourly_rate.asc(),
                Craftsman.average_rating.desc()
            )
        elif sort_by == 'name':
            craftsmen_query = craftsmen_query.order_by(
                User.first_name.asc(),
                User.last_name.asc()
            )
        else:  # default: rating
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
            # Parse skills from JSON string
            skills = []
            if craftsman.skills:
                try:
                    skills = json.loads(craftsman.skills) if isinstance(craftsman.skills, str) else craftsman.skills
                except:
                    skills = [craftsman.skills] if craftsman.skills else []
            
            result.append({
                'id': craftsman.id,
                'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
                'business_name': craftsman.business_name,
                'description': craftsman.description,
                'city': craftsman.city,
                'district': craftsman.district,
                'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                'average_rating': craftsman.average_rating or 0,
                'total_reviews': craftsman.total_reviews or 0,
                'is_available': craftsman.is_available,
                'is_verified': craftsman.is_verified,
                'skills': skills,
                'experience_years': craftsman.experience_years or 0,
                'avatar': craftsman.avatar,
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
                    'page': page,
                    'per_page': per_page,
                    'total': craftsmen.total,
                    'pages': craftsmen.pages,
                    'has_next': craftsmen.has_next,
                    'has_prev': craftsmen.has_prev
                }
            }
        }), 200
        
    except Exception as e:
        print(f"Search error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Arama sırasında bir hata oluştu'
        }), 500

@search_bp.route('/craftsmen/<int:craftsman_id>', methods=['GET'])
def get_craftsman_detail(craftsman_id):
    """Get detailed craftsman information"""
    try:
        craftsman = Craftsman.query.join(User).filter(
            Craftsman.id == craftsman_id,
            User.is_active == True
        ).first()
        
        if not craftsman:
            return jsonify({
                'success': False,
                'message': 'Usta bulunamadı'
            }), 404
        
        # Parse skills from JSON string
        skills = []
        if craftsman.skills:
            try:
                skills = json.loads(craftsman.skills) if isinstance(craftsman.skills, str) else craftsman.skills
            except:
                skills = [craftsman.skills] if craftsman.skills else []
        
        # Parse certifications from JSON string
        certifications = []
        if craftsman.certifications:
            try:
                certifications = json.loads(craftsman.certifications) if isinstance(craftsman.certifications, str) else craftsman.certifications
            except:
                certifications = [craftsman.certifications] if craftsman.certifications else []
        
        # Parse working hours from JSON string
        working_hours = {}
        if craftsman.working_hours:
            try:
                working_hours = json.loads(craftsman.working_hours) if isinstance(craftsman.working_hours, str) else craftsman.working_hours
            except:
                working_hours = {}
        
        result = {
            'id': craftsman.id,
            'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
            'business_name': craftsman.business_name,
            'description': craftsman.description,
            'city': craftsman.city,
            'district': craftsman.district,
            'address': craftsman.address,
            'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
            'average_rating': craftsman.average_rating or 0,
            'total_reviews': craftsman.total_reviews or 0,
            'is_available': craftsman.is_available,
            'is_verified': craftsman.is_verified,
            'is_online': craftsman.is_online,
            'last_seen': craftsman.last_seen,
            'response_time': craftsman.response_time,
            'experience_years': craftsman.experience_years or 0,
            'skills': skills,
            'certifications': certifications,
            'working_hours': working_hours,
            'service_areas': craftsman.service_areas or [],
            'avatar': craftsman.avatar,
            'contact': {
                'phone': craftsman.user.phone,
                'email': craftsman.user.email,
                'website': craftsman.website
            }
        }
        
        return jsonify({
            'success': True,
            'data': result
        }), 200
        
    except Exception as e:
        print(f"Craftsman detail error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Usta bilgileri alınırken bir hata oluştu'
        }), 500

@search_bp.route('/categories', methods=['GET'])
def get_categories():
    """Get all categories"""
    try:
        categories = Category.query.filter_by(is_active=True).order_by(Category.name).all()
        
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
        print(f"Categories error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Kategoriler alınırken bir hata oluştu'
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
                'cities': [city[0] for city in cities if city[0]],
                'districts': [district[0] for district in districts if district[0]]
            }
        }), 200
        
    except Exception as e:
        print(f"Locations error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Lokasyon bilgileri alınırken bir hata oluştu'
        }), 500

@search_bp.route('/popular', methods=['GET'])
def get_popular_searches():
    """Get popular search terms"""
    try:
        # Mock popular searches - in real app, this would be based on actual search data
        popular_searches = [
            'Elektrikçi',
            'Tesisatçı',
            'Boyacı',
            'Marangoz',
            'Temizlik',
            'Bahçıvan',
            'Klima',
            'Su Tesisatı',
            'Elektrik Arızası',
            'LED Aydınlatma'
        ]
        
        return jsonify({
            'success': True,
            'data': popular_searches
        }), 200
        
    except Exception as e:
        print(f"Popular searches error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Popüler aramalar alınırken bir hata oluştu'
        }), 500

@search_bp.route('/suggestions', methods=['GET'])
def get_search_suggestions():
    """Get search suggestions based on query"""
    try:
        query = request.args.get('q', '').strip()
        
        if not query or len(query) < 2:
            return jsonify({
                'success': True,
                'data': []
            }), 200
        
        # Search in business names and skills
        suggestions = db.session.query(Craftsman.business_name).filter(
            Craftsman.business_name.ilike(f'%{query}%')
        ).distinct().limit(5).all()
        
        # Add skill suggestions
        skill_suggestions = db.session.query(Craftsman.skills).filter(
            Craftsman.skills.ilike(f'%{query}%')
        ).distinct().limit(3).all()
        
        result = []
        for suggestion in suggestions:
            if suggestion[0]:
                result.append(suggestion[0])
        
        for skill_suggestion in skill_suggestions:
            if skill_suggestion[0]:
                try:
                    skills = json.loads(skill_suggestion[0]) if isinstance(skill_suggestion[0], str) else skill_suggestion[0]
                    if isinstance(skills, list):
                        for skill in skills:
                            if query.lower() in skill.lower() and skill not in result:
                                result.append(skill)
                except:
                    if query.lower() in skill_suggestion[0].lower() and skill_suggestion[0] not in result:
                        result.append(skill_suggestion[0])
        
        return jsonify({
            'success': True,
            'data': result[:8]  # Limit to 8 suggestions
        }), 200
        
    except Exception as e:
        print(f"Search suggestions error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Arama önerileri alınırken bir hata oluştu'
        }), 500