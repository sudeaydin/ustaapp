from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..models.review import Review
from ..models.craftsman import Craftsman
from ..models.customer import Customer
from ..models.quote import Quote
from ..schemas.review import ReviewSchema
from datetime import datetime
import logging

review_bp = Blueprint('review', __name__)
review_schema = ReviewSchema()

@review_bp.route('/', methods=['GET'])
def get_reviews():
    """Get reviews with filtering"""
    try:
        craftsman_id = request.args.get('craftsman_id', type=int)
        customer_id = request.args.get('customer_id', type=int)
        rating = request.args.get('rating', type=int)
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        query = Review.query
        
        if craftsman_id:
            query = query.filter_by(craftsman_id=craftsman_id)
        if customer_id:
            query = query.filter_by(customer_id=customer_id)
        if rating:
            query = query.filter_by(rating=rating)
            
        reviews = query.order_by(Review.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        # Build safe review data without complex relationships
        reviews_data = []
        for review in reviews.items:
            review_data = {
                'id': review.id,
                'rating': review.rating,
                'comment': review.comment or '',
                'title': review.title or '',
                'work_quality': review.quality_rating or 0,
                'communication': review.communication_rating or 0,
                'punctuality': review.punctuality_rating or 0,
                'value_for_money': review.cleanliness_rating or 0,
                'created_at': review.created_at.isoformat() if review.created_at else None,
                'customer_name': "Müşteri",  # Simple name to avoid relationship issues
                'craftsman_id': review.craftsman_id,
            }
            reviews_data.append(review_data)
        
        return jsonify({
            'success': True,
            'reviews': reviews_data,
            'pagination': {
                'page': page,
                'pages': reviews.pages,
                'per_page': per_page,
                'total': reviews.total
            }
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting reviews: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@review_bp.route('/<int:review_id>', methods=['GET'])
def get_review():
    """Get a specific review"""
    try:
        review_id = request.view_args['review_id']
        review = Review.query.get(review_id)
        
        if not review:
            return jsonify({'error': 'Review not found'}), 404
            
        return jsonify({
            'success': True,
            'review': review_schema.dump(review)
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting review: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@review_bp.route('/', methods=['POST'])
@jwt_required()
def create_review():
    """Create a new review"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Check if user is a customer
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({'error': 'Only customers can create reviews'}), 403
            
        # Validate required fields
        required_fields = ['craftsman_id', 'quote_id', 'rating', 'comment']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'{field} is required'}), 400
                
        # Validate rating
        if not 1 <= data['rating'] <= 5:
            return jsonify({'error': 'Rating must be between 1 and 5'}), 400
            
        # Check if quote exists and belongs to customer
        quote = Quote.query.filter_by(
            id=data['quote_id'],
            customer_id=customer.id,
            craftsman_id=data['craftsman_id'],
            status='completed'
        ).first()
        
        if not quote:
            return jsonify({'error': 'Quote not found or not completed'}), 404
            
        # Check if review already exists
        existing_review = Review.query.filter_by(
            customer_id=customer.id,
            craftsman_id=data['craftsman_id'],
            quote_id=data['quote_id']
        ).first()
        
        if existing_review:
            return jsonify({'error': 'Review already exists for this quote'}), 400
            
        # Create review
        review = Review(
            customer_id=customer.id,
            craftsman_id=data['craftsman_id'],
            quote_id=data['quote_id'],
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
            'review': review_schema.dump(review)
        }), 201
        
    except Exception as e:
        logging.error(f"Error creating review: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@review_bp.route('/<int:review_id>', methods=['PUT'])
@jwt_required()
def update_review():
    """Update a review"""
    try:
        user_id = get_jwt_identity()
        review_id = request.view_args['review_id']
        data = request.get_json()
        
        # Check if user is a customer
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({'error': 'Only customers can update reviews'}), 403
            
        review = Review.query.filter_by(
            id=review_id,
            customer_id=customer.id
        ).first()
        
        if not review:
            return jsonify({'error': 'Review not found or unauthorized'}), 404
            
        # Update fields
        if 'rating' in data:
            if not 1 <= data['rating'] <= 5:
                return jsonify({'error': 'Rating must be between 1 and 5'}), 400
            review.rating = data['rating']
            
        if 'comment' in data:
            review.comment = data['comment']
            
        review.updated_at = datetime.utcnow()
        review.save()
        
        # Update craftsman's average rating
        craftsman = Craftsman.query.get(review.craftsman_id)
        if craftsman:
            craftsman.update_average_rating()
        
        return jsonify({
            'success': True,
            'message': 'Review updated successfully',
            'review': review_schema.dump(review)
        }), 200
        
    except Exception as e:
        logging.error(f"Error updating review: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@review_bp.route('/<int:review_id>', methods=['DELETE'])
@jwt_required()
def delete_review():
    """Delete a review"""
    try:
        user_id = get_jwt_identity()
        review_id = request.view_args['review_id']
        
        # Check if user is a customer
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({'error': 'Only customers can delete reviews'}), 403
            
        review = Review.query.filter_by(
            id=review_id,
            customer_id=customer.id
        ).first()
        
        if not review:
            return jsonify({'error': 'Review not found or unauthorized'}), 404
            
        craftsman_id = review.craftsman_id
        review.delete()
        
        # Update craftsman's average rating
        craftsman = Craftsman.query.get(craftsman_id)
        if craftsman:
            craftsman.update_average_rating()
        
        return jsonify({
            'success': True,
            'message': 'Review deleted successfully'
        }), 200
        
    except Exception as e:
        logging.error(f"Error deleting review: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@review_bp.route('/statistics/<int:craftsman_id>', methods=['GET'])
def get_review_statistics(craftsman_id):
    """Get review statistics for a craftsman"""
    try:
        # Check if craftsman exists
        craftsman = Craftsman.query.get(craftsman_id)
        if not craftsman:
            return jsonify({'error': 'Craftsman not found'}), 404
            
        # Get rating distribution
        rating_stats = {}
        for rating in range(1, 6):
            count = Review.query.filter_by(
                craftsman_id=craftsman_id,
                rating=rating
            ).count()
            rating_stats[f'{rating}_star'] = count
            
        total_reviews = Review.query.filter_by(craftsman_id=craftsman_id).count()
        average_rating = craftsman.average_rating or 0
        
        return jsonify({
            'success': True,
            'statistics': {
                'total_reviews': total_reviews,
                'average_rating': average_rating,
                'rating_distribution': rating_stats
            }
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting review statistics: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@review_bp.route('/recent', methods=['GET'])
def get_recent_reviews():
    """Get recent reviews"""
    try:
        limit = request.args.get('limit', 10, type=int)
        craftsman_id = request.args.get('craftsman_id', type=int)
        
        query = Review.query
        
        if craftsman_id:
            query = query.filter_by(craftsman_id=craftsman_id)
            
        reviews = query.order_by(Review.created_at.desc()).limit(limit).all()
        
        return jsonify({
            'success': True,
            'reviews': [review_schema.dump(review) for review in reviews]
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting recent reviews: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500
