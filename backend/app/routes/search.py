from flask import Blueprint
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import or_, and_
from app import db
from app.models.craftsman import Craftsman
from app.models.user import User
from app.utils.validators import (
    validate_query_params, SearchSchema, ResponseHelper, PaginationHelper
)

search_bp = Blueprint('search', __name__)

@search_bp.route('/categories', methods=['GET'])
def get_categories():
    """Get available categories"""
    try:
        # For now, return static categories
        # In production, this could come from a categories table
        categories = [
            {'id': 1, 'name': 'Elektrik', 'icon': 'electrical_services'},
            {'id': 2, 'name': 'Su Tesisatı', 'icon': 'plumbing'},
            {'id': 3, 'name': 'Boyacı', 'icon': 'format_paint'},
            {'id': 4, 'name': 'Marangoz', 'icon': 'carpenter'},
            {'id': 5, 'name': 'Temizlik', 'icon': 'cleaning_services'},
            {'id': 6, 'name': 'Bahçıvan', 'icon': 'yard'},
            {'id': 7, 'name': 'Klima Teknik', 'icon': 'ac_unit'},
            {'id': 8, 'name': 'Cam Balkon', 'icon': 'window'},
        ]
        
        return ResponseHelper.success(
            data=categories,
            message='Kategoriler başarıyla getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Kategoriler getirilemedi', str(e))

@search_bp.route('/locations', methods=['GET'])
def get_locations():
    """Get available locations/cities"""
    try:
        # Get unique cities from craftsmen
        cities = db.session.query(Craftsman.city).distinct().filter(
            Craftsman.city.isnot(None)
        ).all()
        
        city_list = [city[0] for city in cities if city[0]]
        city_list.sort()
        
        # Add some default cities if empty
        if not city_list:
            city_list = [
                'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya',
                'Adana', 'Konya', 'Gaziantep', 'Kayseri', 'Mersin'
            ]
        
        return ResponseHelper.success(
            data=city_list,
            message='Şehirler başarıyla getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Şehirler getirilemedi', str(e))

@search_bp.route('/craftsmen', methods=['GET'])
@validate_query_params(SearchSchema)
def search_craftsmen(validated_data):
    """Search craftsmen with filters and pagination"""
    try:
        query = db.session.query(Craftsman).join(User).filter(
            User.is_active == True,
            Craftsman.is_available == True
        )
        
        # Apply search filters
        if validated_data.get('q'):
            search_term = f"%{validated_data['q']}%"
            query = query.filter(
                or_(
                    User.first_name.ilike(search_term),
                    User.last_name.ilike(search_term),
                    Craftsman.business_name.ilike(search_term),
                    Craftsman.description.ilike(search_term),
                    Craftsman.skills.ilike(search_term)
                )
            )
        
        if validated_data.get('category'):
            query = query.filter(
                Craftsman.skills.ilike(f"%{validated_data['category']}%")
            )
        
        if validated_data.get('city'):
            query = query.filter(Craftsman.city == validated_data['city'])
        
        # Apply sorting
        sort_by = validated_data.get('sort_by', 'rating')
        if sort_by == 'rating':
            query = query.order_by(Craftsman.average_rating.desc())
        elif sort_by == 'price':
            query = query.order_by(Craftsman.hourly_rate.asc())
        elif sort_by == 'reviews':
            query = query.order_by(Craftsman.total_reviews.desc())
        else:
            query = query.order_by(Craftsman.created_at.desc())
        
        # Apply pagination
        page = validated_data.get('page', 1)
        per_page = validated_data.get('per_page', 20)
        
        paginated_result = PaginationHelper.paginate_query(query, page, per_page)
        
        # Format craftsmen data
        craftsmen_data = []
        for craftsman_dict in paginated_result['items']:
            craftsman = Craftsman.query.get(craftsman_dict['id'])
            if craftsman:
                craftsman_data.append({
                    'id': craftsman.id,
                    'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
                    'business_name': craftsman.business_name,
                    'description': craftsman.description,
                    'specialties': craftsman.skills,
                    'city': craftsman.city,
                    'district': craftsman.district,
                    'hourly_rate': float(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                    'average_rating': craftsman.average_rating,
                    'total_reviews': craftsman.total_reviews,
                    'is_verified': craftsman.is_verified,
                    'is_available': craftsman.is_available,
                    'avatar': f"/uploads/avatars/{craftsman.user.id}.jpg" if craftsman.user else None,
                    'portfolio_images': craftsman.portfolio_images or [],
                })
        
        return ResponseHelper.success(
            data={
                'craftsmen': craftsmen_data,
                'pagination': paginated_result['pagination']
            },
            message=f'{len(craftsmen_data)} usta bulundu'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Arama sırasında hata oluştu', str(e))

@search_bp.route('/craftsmen/<int:craftsman_id>', methods=['GET'])
def get_craftsman_detail(craftsman_id):
    """Get detailed craftsman information"""
    try:
        craftsman = Craftsman.query.filter_by(id=craftsman_id).first()
        
        if not craftsman:
            return ResponseHelper.not_found('Usta bulunamadı')
        
        if not craftsman.user.is_active:
            return ResponseHelper.not_found('Usta aktif değil')
        
        # Get recent jobs/reviews for this craftsman
        recent_jobs = []  # TODO: Implement when jobs system is ready
        
        craftsman_data = {
            'id': craftsman.id,
            'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
            'business_name': craftsman.business_name,
            'description': craftsman.description,
            'specialties': craftsman.specialties,
            'address': craftsman.address,
            'city': craftsman.city,
            'district': craftsman.district,
            'hourly_rate': float(craftsman.hourly_rate) if craftsman.hourly_rate else None,
            'average_rating': craftsman.average_rating,
            'total_reviews': craftsman.total_reviews,
            'is_verified': craftsman.is_verified,
            'is_available': craftsman.is_available,
            'created_at': craftsman.created_at.isoformat() if craftsman.created_at else None,
            'portfolio_images': craftsman.portfolio_images or [],
            'recent_jobs': recent_jobs,
            'contact': {
                'email': craftsman.user.email,
                'phone': craftsman.user.phone,
            }
        }
        
        return ResponseHelper.success(
            data=craftsman_data,
            message='Usta bilgileri getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Usta bilgileri getirilemedi', str(e))