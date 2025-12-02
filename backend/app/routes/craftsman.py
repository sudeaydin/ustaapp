import logging
import json
import os
from datetime import datetime
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from app.utils.auth_utils import get_current_user_id
from app.utils.file_utils import allowed_file
from ..models.craftsman import Craftsman
from ..models.service import Service
from ..models.quote import Quote
from ..models.review import Review
from ..models.user import User
from ..models.category import Category
from ..schemas.craftsman import CraftsmanSchema
from ..services.craftsman_service import CraftsmanService

craftsman_bp = Blueprint('craftsman', __name__)
craftsman_schema = CraftsmanSchema()
service = CraftsmanService()


@craftsman_bp.route('/craftsmen', methods=['GET'])
def list_craftsmen():
    """Public: list craftsmen with pagination."""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        filters = {}
        if request.args.get('category_id'):
            filters['category_id'] = request.args.get('category_id', type=int)
        if request.args.get('city'):
            filters['city'] = request.args.get('city')
        if request.args.get('district'):
            filters['district'] = request.args.get('district')
        if request.args.get('search'):
            filters['search'] = request.args.get('search')

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
        logging.error(f"Error listing craftsmen: {str(e)}")
        return jsonify({'success': False, 'message': 'Bir hata oluştu'}), 500


@craftsman_bp.route('/craftsmen/<int:craftsman_id>', methods=['GET'])
def get_craftsman(craftsman_id):
    """Public: get craftsman details."""
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
        logging.error(f"Error getting craftsman: {str(e)}")
        return jsonify({'success': False, 'message': 'Bir hata oluştu'}), 500


@craftsman_bp.route('/craftsmen/categories', methods=['GET'])
def get_categories():
    """Public: list categories."""
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
        logging.error(f"Error getting categories: {str(e)}")
        return jsonify({'success': False, 'message': 'Bir hata oluştu'}), 500


@craftsman_bp.route('/craftsmen/<int:craftsman_id>/business-profile', methods=['GET'])
def get_craftsman_business_profile(craftsman_id):
    """Public: detailed business profile with jobs and reviews."""
    try:
        from app.models.job import Job, JobStatus
        from app.models.review import Review

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

    except Exception as e:
        logging.error(f"Error getting business profile: {str(e)}")
        return jsonify({'success': False, 'message': 'Bir hata oluştu'}), 500


@craftsman_bp.route('/craftsman/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Protected: get craftsman profile"""
    try:
        current_user_id = get_current_user_id()
        craftsman = Craftsman.query.filter_by(user_id=current_user_id).first()

        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404

        return jsonify({
            'success': True,
            'craftsman': craftsman_schema.dump(craftsman)
        }), 200

    except Exception as e:
        logging.error(f"Error getting craftsman profile: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@craftsman_bp.route('/craftsman/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """Protected: update craftsman profile"""
    try:
        current_user_id = get_current_user_id()
        data = request.get_json()

        craftsman = Craftsman.query.filter_by(user_id=current_user_id).first()
        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404

        # Update fields
        if 'business_name' in data:
            craftsman.business_name = data['business_name']
        if 'description' in data:
            craftsman.description = data['description']
        if 'experience_years' in data:
            craftsman.experience_years = data['experience_years']
        if 'hourly_rate' in data:
            craftsman.hourly_rate = data['hourly_rate']
        if 'location' in data:
            craftsman.location = data['location']
        if 'phone' in data:
            craftsman.phone = data['phone']
        if 'website' in data:
            craftsman.website = data['website']

        craftsman.updated_at = datetime.utcnow()
        craftsman.save()

        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'craftsman': craftsman_schema.dump(craftsman)
        }), 200

    except Exception as e:
        logging.error(f"Error updating craftsman profile: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@craftsman_bp.route('/craftsman/services', methods=['GET'])
@jwt_required()
def get_services():
    """Protected: get craftsman's services"""
    try:
        current_user_id = get_current_user_id()
        craftsman = Craftsman.query.filter_by(user_id=current_user_id).first()

        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404

        services = Service.query.filter_by(craftsman_id=craftsman.id).all()

        return jsonify({
            'success': True,
            'services': [service.to_dict() for service in services]
        }), 200

    except Exception as e:
        logging.error(f"Error getting craftsman services: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@craftsman_bp.route('/craftsman/quotes', methods=['GET'])
@jwt_required()
def get_quotes():
    """Protected: get craftsman's quotes"""
    try:
        current_user_id = get_current_user_id()
        craftsman = Craftsman.query.filter_by(user_id=current_user_id).first()

        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404

        status = request.args.get('status')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)

        query = Quote.query.filter_by(craftsman_id=craftsman.id)

        if status:
            query = query.filter_by(status=status)

        quotes = query.order_by(Quote.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )

        return jsonify({
            'success': True,
            'quotes': [quote.to_dict() for quote in quotes.items],
            'pagination': {
                'page': page,
                'pages': quotes.pages,
                'per_page': per_page,
                'total': quotes.total
            }
        }), 200

    except Exception as e:
        logging.error(f"Error getting craftsman quotes: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@craftsman_bp.route('/craftsman/statistics', methods=['GET'])
@jwt_required()
def get_statistics():
    """Protected: get craftsman's statistics"""
    try:
        current_user_id = get_current_user_id()
        craftsman = Craftsman.query.filter_by(user_id=current_user_id).first()

        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404

        total_quotes = Quote.query.filter_by(craftsman_id=craftsman.id).count()
        completed_quotes = Quote.query.filter_by(craftsman_id=craftsman.id, status='completed').count()
        total_reviews = Review.query.filter_by(craftsman_id=craftsman.id).count()

        stats = {
            'total_quotes': total_quotes,
            'completed_quotes': completed_quotes,
            'completion_rate': (completed_quotes / total_quotes * 100) if total_quotes > 0 else 0,
            'total_reviews': total_reviews,
            'average_rating': craftsman.average_rating or 0,
            'total_services': Service.query.filter_by(craftsman_id=craftsman.id).count()
        }

        return jsonify({
            'success': True,
            'statistics': stats
        }), 200

    except Exception as e:
        logging.error(f"Error getting craftsman statistics: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@craftsman_bp.route('/auth/upload-portfolio-image', methods=['POST'])
@jwt_required()
def upload_portfolio_image():
    """Protected: upload portfolio image for craftsman"""
    try:
        current_user_id = get_current_user_id()
        if 'image' not in request.files:
            return jsonify({'error': True, 'message': 'Görsel dosyası bulunamadı', 'code': 'NO_FILE'}), 400

        file = request.files['image']
        if file.filename == '':
            return jsonify({'error': True, 'message': 'Dosya seçilmedi', 'code': 'NO_FILE_SELECTED'}), 400

        if file and allowed_file(file.filename):
            result, error, status = service.upload_portfolio_image(current_user_id, file, 'uploads/portfolio')
            if error:
                return jsonify({'error': True, 'message': error}), status
            return jsonify({'success': True, 'message': 'Görsel başarıyla yüklendi', **result}), status
        return jsonify({'error': True, 'message': 'Geçersiz dosya formatı. PNG, JPG, JPEG, GIF veya WEBP dosyası yükleyin', 'code': 'INVALID_FILE_TYPE'}), 400

    except Exception as e:
        logging.error(f"Upload portfolio error: {str(e)}")
        return jsonify({'error': True, 'message': 'Görsel yükleme başarısız oldu', 'code': 'UPLOAD_ERROR'}), 500


@craftsman_bp.route('/auth/delete-portfolio-image', methods=['DELETE'])
@jwt_required()
def delete_portfolio_image():
    """Protected: delete portfolio image for craftsman"""
    try:
        current_user_id = get_current_user_id()
        data = request.get_json()
        image_url = data.get('image_url') if data else None

        if not image_url:
            return jsonify({'error': True, 'message': 'Görsel URL\'si gerekli', 'code': 'IMAGE_URL_REQUIRED'}), 400

        result, error, status = service.delete_portfolio_image(current_user_id, image_url, 'uploads/portfolio')
        if error:
            return jsonify({'error': True, 'message': error}), status
        return jsonify({'success': True, 'message': 'Görsel başarıyla silindi', **result}), status

    except Exception as e:
        logging.error(f"Delete portfolio error: {str(e)}")
        return jsonify({'error': True, 'message': 'Görsel silme başarısız oldu', 'code': 'DELETE_ERROR'}), 500
