from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.quote import Quote
from app.models.notification import Notification
from app.models.user import User

quotes_bp = Blueprint('quotes', __name__)

@quotes_bp.route('/api/quotes', methods=['POST'])
@jwt_required()
def create_quote():
    """Create a new quote request"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['craftsman_id', 'category', 'job_type', 'location', 'area_type', 'room_count', 'description']
        for field in required_fields:
            if field not in data or not data[field]:
                return jsonify({'success': False, 'message': f'{field} is required'}), 400
        
        # Check if craftsman exists
        craftsman = User.query.filter_by(id=data['craftsman_id'], user_type='craftsman').first()
        if not craftsman:
            return jsonify({'success': False, 'message': 'Craftsman not found'}), 404
        
        # Create quote
        quote = Quote(
            customer_id=current_user_id,
            craftsman_id=data['craftsman_id'],
            category=data['category'],
            job_type=data['job_type'],
            location=data['location'],
            area_type=data['area_type'],
            room_count=data['room_count'],
            square_meters=data.get('square_meters'),
            description=data['description']
        )
        
        db.session.add(quote)
        db.session.commit()
        
        # Create notification for craftsman
        Notification.create_notification(
            user_id=data['craftsman_id'],
            title='Yeni Teklif Talebi',
            message=f'{quote.customer.first_name} {quote.customer.last_name} size {data["category"]} hizmeti için teklif talebi gönderdi.',
            notification_type='quote',
            related_id=quote.id,
            related_type='quote'
        )
        
        return jsonify({
            'success': True,
            'message': 'Quote created successfully',
            'data': quote.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

@quotes_bp.route('/api/quotes', methods=['GET'])
@jwt_required()
def get_quotes():
    """Get quotes for current user"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if user.user_type == 'customer':
            quotes = Quote.query.filter_by(customer_id=current_user_id).order_by(Quote.created_at.desc()).all()
        else:
            quotes = Quote.query.filter_by(craftsman_id=current_user_id).order_by(Quote.created_at.desc()).all()
        
        return jsonify({
            'success': True,
            'data': [quote.to_dict() for quote in quotes]
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@quotes_bp.route('/api/quotes/<int:quote_id>', methods=['GET'])
@jwt_required()
def get_quote(quote_id):
    """Get specific quote details"""
    try:
        current_user_id = get_jwt_identity()
        quote = Quote.query.get_or_404(quote_id)
        
        # Check if user has access to this quote
        if quote.customer_id != current_user_id and quote.craftsman_id != current_user_id:
            return jsonify({'success': False, 'message': 'Access denied'}), 403
        
        return jsonify({
            'success': True,
            'data': quote.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@quotes_bp.route('/api/quotes/<int:quote_id>', methods=['PUT'])
@jwt_required()
def update_quote(quote_id):
    """Update quote (only by craftsman)"""
    try:
        current_user_id = get_jwt_identity()
        quote = Quote.query.get_or_404(quote_id)
        
        # Only craftsman can update quote
        if quote.craftsman_id != current_user_id:
            return jsonify({'success': False, 'message': 'Only craftsman can update quote'}), 403
        
        data = request.get_json()
        
        # Update allowed fields
        if 'price' in data:
            quote.price = data['price']
        if 'estimated_duration' in data:
            quote.estimated_duration = data['estimated_duration']
        if 'status' in data:
            quote.status = data['status']
        
        db.session.commit()
        
        # Create notification for customer if quote is accepted
        if data.get('status') == 'accepted':
            Notification.create_notification(
                user_id=quote.customer_id,
                title='Teklif Kabul Edildi',
                message=f'{quote.craftsman.first_name} {quote.craftsman.last_name} teklifinizi kabul etti.',
                notification_type='quote',
                related_id=quote.id,
                related_type='quote'
            )
        
        return jsonify({
            'success': True,
            'message': 'Quote updated successfully',
            'data': quote.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500

@quotes_bp.route('/api/quotes/<int:quote_id>', methods=['DELETE'])
@jwt_required()
def delete_quote(quote_id):
    """Delete quote"""
    try:
        current_user_id = get_jwt_identity()
        quote = Quote.query.get_or_404(quote_id)
        
        # Check if user has access to this quote
        if quote.customer_id != current_user_id and quote.craftsman_id != current_user_id:
            return jsonify({'success': False, 'message': 'Access denied'}), 403
        
        db.session.delete(quote)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Quote deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': str(e)}), 500