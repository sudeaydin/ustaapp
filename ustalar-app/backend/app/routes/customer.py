from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..models.customer import Customer
from ..models.quote import Quote
from ..models.review import Review
from ..models.craftsman import Craftsman
from ..schemas.customer import CustomerSchema
from datetime import datetime
import logging

customer_bp = Blueprint('customer', __name__)
customer_schema = CustomerSchema()

@customer_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get customer profile"""
    try:
        user_id = get_jwt_identity()
        customer = Customer.query.filter_by(user_id=user_id).first()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        return jsonify({
            'success': True,
            'customer': customer_schema.dump(customer)
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting customer profile: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@customer_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update customer profile"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        # Update fields
        if 'first_name' in data:
            customer.first_name = data['first_name']
        if 'last_name' in data:
            customer.last_name = data['last_name']
        if 'phone' in data:
            customer.phone = data['phone']
        if 'address' in data:
            customer.address = data['address']
        if 'city' in data:
            customer.city = data['city']
        if 'preferences' in data:
            customer.preferences = data['preferences']
            
        customer.updated_at = datetime.utcnow()
        customer.save()
        
        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'customer': customer_schema.dump(customer)
        }), 200
        
    except Exception as e:
        logging.error(f"Error updating customer profile: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@customer_bp.route('/quotes', methods=['GET'])
@jwt_required()
def get_quotes():
    """Get customer's quote requests"""
    try:
        user_id = get_jwt_identity()
        customer = Customer.query.filter_by(user_id=user_id).first()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        status = request.args.get('status')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        query = Quote.query.filter_by(customer_id=customer.id)
        
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
        logging.error(f"Error getting customer quotes: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@customer_bp.route('/quotes/<int:quote_id>/accept', methods=['POST'])
@jwt_required()
def accept_quote():
    """Accept a quote"""
    try:
        user_id = get_jwt_identity()
        quote_id = request.view_args['quote_id']
        
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        quote = Quote.query.filter_by(id=quote_id, customer_id=customer.id).first()
        if not quote:
            return jsonify({'error': 'Quote not found'}), 404
            
        if quote.status != 'quoted':
            return jsonify({'error': 'Quote cannot be accepted'}), 400
            
        quote.status = 'accepted'
        quote.accepted_at = datetime.utcnow()
        quote.save()
        
        return jsonify({
            'success': True,
            'message': 'Quote accepted successfully',
            'quote': quote.to_dict()
        }), 200
        
    except Exception as e:
        logging.error(f"Error accepting quote: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@customer_bp.route('/quotes/<int:quote_id>/reject', methods=['POST'])
@jwt_required()
def reject_quote():
    """Reject a quote"""
    try:
        user_id = get_jwt_identity()
        quote_id = request.view_args['quote_id']
        data = request.get_json()
        
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        quote = Quote.query.filter_by(id=quote_id, customer_id=customer.id).first()
        if not quote:
            return jsonify({'error': 'Quote not found'}), 404
            
        quote.status = 'rejected'
        quote.rejection_reason = data.get('reason')
        quote.rejected_at = datetime.utcnow()
        quote.save()
        
        return jsonify({
            'success': True,
            'message': 'Quote rejected successfully'
        }), 200
        
    except Exception as e:
        logging.error(f"Error rejecting quote: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@customer_bp.route('/reviews', methods=['GET'])
@jwt_required()
def get_reviews():
    """Get customer's reviews"""
    try:
        user_id = get_jwt_identity()
        customer = Customer.query.filter_by(user_id=user_id).first()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        reviews = Review.query.filter_by(customer_id=customer.id).order_by(
            Review.created_at.desc()
        ).paginate(page=page, per_page=per_page, error_out=False)
        
        return jsonify({
            'success': True,
            'reviews': [review.to_dict() for review in reviews.items],
            'pagination': {
                'page': page,
                'pages': reviews.pages,
                'per_page': per_page,
                'total': reviews.total
            }
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting customer reviews: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@customer_bp.route('/reviews', methods=['POST'])
@jwt_required()
def create_review():
    """Create a review for a craftsman"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        # Validate required fields
        required_fields = ['craftsman_id', 'rating', 'comment']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'{field} is required'}), 400
                
        # Check if customer has completed job with this craftsman
        completed_quote = Quote.query.filter_by(
            customer_id=customer.id,
            craftsman_id=data['craftsman_id'],
            status='completed'
        ).first()
        
        if not completed_quote:
            return jsonify({'error': 'You can only review craftsmen you have worked with'}), 400
            
        # Check if review already exists
        existing_review = Review.query.filter_by(
            customer_id=customer.id,
            craftsman_id=data['craftsman_id'],
            quote_id=completed_quote.id
        ).first()
        
        if existing_review:
            return jsonify({'error': 'Review already exists for this job'}), 400
            
        review = Review(
            customer_id=customer.id,
            craftsman_id=data['craftsman_id'],
            quote_id=completed_quote.id,
            rating=data['rating'],
            comment=data['comment']
        )
        
        review.save()
        
        # Update craftsman's average rating
        craftsman = Craftsman.query.get(data['craftsman_id'])
        if craftsman:
            craftsman.update_average_rating()
        
        return jsonify({
            'success': True,
            'message': 'Review created successfully',
            'review': review.to_dict()
        }), 201
        
    except Exception as e:
        logging.error(f"Error creating review: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@customer_bp.route('/favorites', methods=['GET'])
@jwt_required()
def get_favorites():
    """Get customer's favorite craftsmen"""
    try:
        user_id = get_jwt_identity()
        customer = Customer.query.filter_by(user_id=user_id).first()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        # This would require a favorites table, for now return empty
        return jsonify({
            'success': True,
            'favorites': []
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting customer favorites: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@customer_bp.route('/statistics', methods=['GET'])
@jwt_required()
def get_statistics():
    """Get customer's statistics"""
    try:
        user_id = get_jwt_identity()
        customer = Customer.query.filter_by(user_id=user_id).first()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
            
        # Calculate basic statistics
        total_quotes = Quote.query.filter_by(customer_id=customer.id).count()
        completed_quotes = Quote.query.filter_by(customer_id=customer.id, status='completed').count()
        total_reviews = Review.query.filter_by(customer_id=customer.id).count()
        
        stats = {
            'total_quotes_requested': total_quotes,
            'completed_jobs': completed_quotes,
            'total_reviews_given': total_reviews,
            'member_since': customer.created_at.strftime('%Y-%m-%d'),
            'total_spent': 0  # Would need to calculate from completed quotes
        }
        
        return jsonify({
            'success': True,
            'statistics': stats
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting customer statistics: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500
