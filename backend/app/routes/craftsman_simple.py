from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.craftsman import Craftsman
from app.models.user import User
from app.models.category import Category
from app.services.craftsman_service import CraftsmanService
from app.models.job import Job, JobStatus
from app.models.review import Review
import json

craftsman_bp = Blueprint('craftsman_public', __name__)

@craftsman_bp.route('/', methods=['GET'])
def get_craftsmen():
    """Get all craftsmen with filters"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        # Filters
        filters = {}
        if request.args.get('category_id'):
            filters['category_id'] = request.args.get('category_id', type=int)
        if request.args.get('city'):
            filters['city'] = request.args.get('city')
        if request.args.get('search'):
            filters['search'] = request.args.get('search')
        
        # Get craftsmen (for now, return mock data since we simplified the model)
        craftsmen = Craftsman.query.join(User).filter(User.is_active == True).paginate(
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
                'user': {
                    'email': craftsman.user.email,
                    'phone': craftsman.user.phone,
                    'avatar': craftsman.user.avatar
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
                }
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@craftsman_bp.route('/<int:craftsman_id>', methods=['GET'])
def get_craftsman(craftsman_id):
    """Get craftsman details"""
    try:
        craftsman = Craftsman.query.get(craftsman_id)
        
        if not craftsman:
            return jsonify({
                'success': False,
                'message': 'Usta bulunamadı'
            }), 404
        
        result = {
            'id': craftsman.id,
            'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
            'business_name': craftsman.business_name,
            'description': craftsman.description,
            'address': craftsman.address,
            'city': craftsman.city,
            'district': craftsman.district,
            'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
            'average_rating': craftsman.average_rating,
            'total_reviews': craftsman.total_reviews,
            'is_available': craftsman.is_available,
            'is_verified': craftsman.is_verified,
            'created_at': craftsman.created_at.isoformat() if craftsman.created_at else None,
            'user': {
                'email': craftsman.user.email,
                'phone': craftsman.user.phone,
                'avatar': craftsman.user.avatar
            }
        }
        
        return jsonify({
            'success': True,
            'data': result
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@craftsman_bp.route('/<int:craftsman_id>/business-profile', methods=['GET'])
def get_craftsman_business_profile(craftsman_id):
    """Get craftsman business profile with completed jobs and portfolio"""
    try:
        craftsman = Craftsman.query.get(craftsman_id)

        if not craftsman:
            return jsonify({
                'success': False,
                'message': 'Usta bulunamadı'
            }), 404

        completed_jobs = Job.query.filter_by(
            assigned_craftsman_id=craftsman.id,
            status=JobStatus.COMPLETED.value
        ).order_by(Job.completed_at.desc()).limit(10).all()

        reviews = Review.query.filter_by(craftsman_id=craftsman.id).order_by(Review.created_at.desc()).limit(10).all()

        portfolio_images = json.loads(craftsman.portfolio_images) if craftsman.portfolio_images else []

        result = {
            'id': craftsman.id,
            'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
            'business_name': craftsman.business_name,
            'description': craftsman.description,
            'address': craftsman.address,
            'city': craftsman.city,
            'district': craftsman.district,
            'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
            'experience_years': craftsman.experience_years,
            'average_rating': craftsman.average_rating,
            'total_reviews': craftsman.total_reviews,
            'is_available': craftsman.is_available,
            'is_verified': craftsman.is_verified,
            'avatar': craftsman.avatar,
            'website': craftsman.website,
            'working_hours': craftsman.working_hours,
            'service_areas': craftsman.service_areas,
            'skills': craftsman.skills,
            'certifications': craftsman.certifications,
            'response_time': craftsman.response_time,
            'portfolio_images': portfolio_images,
            'completed_jobs': [
                {
                    'id': job.id,
                    'title': job.title,
                    'description': job.description,
                    'category': job.category,
                    'completed_at': job.completed_at.isoformat() if job.completed_at else None,
                    'location': job.location
                } for job in completed_jobs
            ],
            'recent_reviews': [
                {
                    'id': review.id,
                    'customer_name': f"{review.customer.user.first_name} {review.customer.user.last_name[0]}." if review.customer and review.customer.user else "Anonim",
                    'rating': review.rating,
                    'comment': review.comment,
                    'created_at': review.created_at.isoformat() if review.created_at else None
                } for review in reviews
            ],
            'skills_list': json.loads(craftsman.skills) if craftsman.skills else [],
            'certifications_list': json.loads(craftsman.certifications) if craftsman.certifications else [],
            'user': {
                'email': craftsman.user.email,
                'phone': craftsman.user.phone
            }
        }

        return jsonify({
            'success': True,
            'data': result
        }), 200

    except Exception:
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@craftsman_bp.route('/categories', methods=['GET'])
def get_categories():
    """Get all categories"""
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
