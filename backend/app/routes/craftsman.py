from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..models.craftsman import Craftsman
from ..models.service import Service
from ..models.quote import Quote
from ..models.review import Review
from ..schemas.craftsman import CraftsmanSchema
from ..services.craftsman_service import CraftsmanService
from datetime import datetime
import logging

craftsman_bp = Blueprint('craftsman', __name__)
craftsman_schema = CraftsmanSchema()
craftsman_service = CraftsmanService()

@craftsman_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get craftsman profile"""
    try:
        user_id = get_jwt_identity()
        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
        
        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404
            
        return jsonify({
            'success': True,
            'craftsman': craftsman_schema.dump(craftsman)
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting craftsman profile: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@craftsman_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update craftsman profile"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
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

@craftsman_bp.route('/services', methods=['GET'])
@jwt_required()
def get_services():
    """Get craftsman's services"""
    try:
        user_id = get_jwt_identity()
        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
        
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

@craftsman_bp.route('/quotes', methods=['GET'])
@jwt_required()
def get_quotes():
    """Get craftsman's quotes"""
    try:
        user_id = get_jwt_identity()
        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
        
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

@craftsman_bp.route('/statistics', methods=['GET'])
@jwt_required()
def get_statistics():
    """Get craftsman's statistics"""
    try:
        user_id = get_jwt_identity()
        craftsman = Craftsman.query.filter_by(user_id=user_id).first()
        
        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404
            
        # Calculate basic statistics
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
