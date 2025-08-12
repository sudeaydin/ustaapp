from flask import Blueprint
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import or_, and_
from app import db
from app.models.craftsman import Craftsman
from app.models.user import User
from app.utils.validators import (
    validate_query_params, SearchSchema, ResponseHelper, PaginationHelper
)
import json

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
        
        # Apply advanced filters
        if validated_data.get('min_rating'):
            query = query.filter(Craftsman.average_rating >= validated_data['min_rating'])
        
        if validated_data.get('max_rating'):
            query = query.filter(Craftsman.average_rating <= validated_data['max_rating'])
        
        if validated_data.get('min_price'):
            query = query.filter(Craftsman.hourly_rate >= validated_data['min_price'])
        
        if validated_data.get('max_price'):
            query = query.filter(Craftsman.hourly_rate <= validated_data['max_price'])
        
        if validated_data.get('is_verified') is not None:
            query = query.filter(Craftsman.is_verified == validated_data['is_verified'])
        
        if validated_data.get('has_portfolio') is not None:
            if validated_data['has_portfolio']:
                query = query.filter(Craftsman.portfolio_images.isnot(None))
            else:
                query = query.filter(Craftsman.portfolio_images.is_(None))
        
        if validated_data.get('district'):
            query = query.filter(Craftsman.district == validated_data['district'])

        # Apply sorting
        sort_by = validated_data.get('sort_by', 'rating')
        sort_order = validated_data.get('sort_order', 'desc')
        
        if sort_by == 'rating':
            if sort_order == 'asc':
                query = query.order_by(Craftsman.average_rating.asc())
            else:
                query = query.order_by(Craftsman.average_rating.desc())
        elif sort_by == 'price':
            if sort_order == 'asc':
                query = query.order_by(Craftsman.hourly_rate.asc())
            else:
                query = query.order_by(Craftsman.hourly_rate.desc())
        elif sort_by == 'reviews':
            if sort_order == 'asc':
                query = query.order_by(Craftsman.total_reviews.asc())
            else:
                query = query.order_by(Craftsman.total_reviews.desc())
        elif sort_by == 'name':
            if sort_order == 'asc':
                query = query.order_by(User.first_name.asc(), User.last_name.asc())
            else:
                query = query.order_by(User.first_name.desc(), User.last_name.desc())
        elif sort_by == 'distance':
            # For now, just order by city
            query = query.order_by(Craftsman.city)
        else:
            query = query.order_by(Craftsman.created_at.desc())
        
        # Apply pagination
        page = validated_data.get('page', 1)
        per_page = validated_data.get('per_page', 20)
        
        paginated_result = PaginationHelper.paginate_query(query, page, per_page)
        
        # Format craftsmen data
        craftsmen_data = []
        print(f"🔍 Processing {len(paginated_result['items'])} craftsmen from query")
        for craftsman_dict in paginated_result['items']:
            craftsman = Craftsman.query.get(craftsman_dict['id'])
            if craftsman:
                # Parse skills from JSON
                skills_list = []
                if craftsman.skills:
                    try:
                        skills_list = json.loads(craftsman.skills)
                    except:
                        skills_list = [craftsman.skills] if craftsman.skills else []
                
                craftsmen_data.append({
                    'id': craftsman.id,
                    'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
                    'business_name': craftsman.business_name,
                    'description': craftsman.description,
                    'specialties': skills_list,
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
        
        print(f"🔍 Returning {len(craftsmen_data)} craftsmen")
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

@search_bp.route('/districts', methods=['GET'])
def get_districts():
    """Get districts for a specific city"""
    try:
        city = request.args.get('city')
        if not city:
            return ResponseHelper.validation_error('City parameter is required')
        
        # Get unique districts for the city
        districts = db.session.query(Craftsman.district).distinct().filter(
            Craftsman.city == city,
            Craftsman.district.isnot(None)
        ).all()
        
        district_list = [district[0] for district in districts if district[0]]
        district_list.sort()
        
        return ResponseHelper.success(
            data=district_list,
            message='İlçeler başarıyla getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('İlçeler getirilemedi', str(e))

@search_bp.route('/filters', methods=['GET'])
def get_search_filters():
    """Get available search filters with ranges"""
    try:
        # Get price range
        price_stats = db.session.query(
            db.func.min(Craftsman.hourly_rate).label('min_price'),
            db.func.max(Craftsman.hourly_rate).label('max_price'),
            db.func.avg(Craftsman.hourly_rate).label('avg_price')
        ).filter(
            Craftsman.hourly_rate.isnot(None),
            Craftsman.hourly_rate > 0
        ).first()
        
        # Get rating range
        rating_stats = db.session.query(
            db.func.min(Craftsman.average_rating).label('min_rating'),
            db.func.max(Craftsman.average_rating).label('max_rating'),
            db.func.avg(Craftsman.average_rating).label('avg_rating')
        ).filter(
            Craftsman.average_rating.isnot(None),
            Craftsman.average_rating > 0
        ).first()
        
        # Get verification stats
        verified_count = Craftsman.query.filter_by(is_verified=True).count()
        total_count = Craftsman.query.count()
        
        # Get portfolio stats
        portfolio_count = Craftsman.query.filter(
            Craftsman.portfolio_images.isnot(None)
        ).count()
        
        filters = {
            'price_range': {
                'min': float(price_stats.min_price) if price_stats.min_price else 0,
                'max': float(price_stats.max_price) if price_stats.max_price else 1000,
                'avg': float(price_stats.avg_price) if price_stats.avg_price else 100,
            },
            'rating_range': {
                'min': float(rating_stats.min_rating) if rating_stats.min_rating else 0,
                'max': float(rating_stats.max_rating) if rating_stats.max_rating else 5,
                'avg': float(rating_stats.avg_rating) if rating_stats.avg_rating else 0,
            },
            'verification_stats': {
                'verified_count': verified_count,
                'total_count': total_count,
                'verification_rate': (verified_count / total_count * 100) if total_count > 0 else 0,
            },
            'portfolio_stats': {
                'with_portfolio': portfolio_count,
                'without_portfolio': total_count - portfolio_count,
                'portfolio_rate': (portfolio_count / total_count * 100) if total_count > 0 else 0,
            },
            'sort_options': [
                {'value': 'rating', 'label': 'Puan'},
                {'value': 'price', 'label': 'Fiyat'},
                {'value': 'reviews', 'label': 'Değerlendirme Sayısı'},
                {'value': 'name', 'label': 'İsim'},
                {'value': 'distance', 'label': 'Mesafe'},
            ],
            'sort_orders': [
                {'value': 'desc', 'label': 'Azalan'},
                {'value': 'asc', 'label': 'Artan'},
            ]
        }
        
        return ResponseHelper.success(
            data=filters,
            message='Arama filtreleri getirildi'
        )
        
    except Exception as e:
        return ResponseHelper.server_error('Arama filtreleri getirilemedi', str(e))