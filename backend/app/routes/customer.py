"""
Customer Routes

Thin controllers for customer-related endpoints.
All business logic is delegated to CustomerService.
"""

import logging
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError

from app.services.customer_service import CustomerService
from app.schemas.customer import CustomerSchema
from app.exceptions import (
    CustomerError,
    CustomerNotFoundError,
    QuoteNotFoundError,
    QuoteAccessDeniedError,
    QuoteStatusError,
    ReviewValidationError,
    ReviewAlreadyExistsError,
    NoCompletedJobError
)

logger = logging.getLogger(__name__)

customer_bp = Blueprint('customers', __name__)
customer_schema = CustomerSchema()


def _get_current_customer():
    """
    Get current customer from JWT token.

    Returns:
        Customer object

    Raises:
        CustomerNotFoundError: If customer not found
    """
    user_id = get_jwt_identity()
    customer = CustomerService.get_by_user_id(user_id)

    if not customer:
        raise CustomerNotFoundError(f"Customer not found for user {user_id}")

    return customer


@customer_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """
    Get customer profile.

    Returns:
        200: Customer profile data
        404: Customer not found
        500: Server error
    """
    try:
        user_id = get_jwt_identity()
        customer = CustomerService.get_profile(user_id)

        return jsonify({
            'success': True,
            'data': customer_schema.dump(customer)
        }), 200

    except CustomerNotFoundError as e:
        logger.warning(f"Customer not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except Exception as e:
        logger.error(f"Error getting customer profile: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500


@customer_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """
    Update customer profile.

    Request body:
        first_name: string (optional)
        last_name: string (optional)
        phone: string (optional)
        billing_address: string (optional)
        city: string (optional)
        district: string (optional)

    Returns:
        200: Updated customer profile
        400: Validation error
        404: Customer not found
        500: Server error
    """
    try:
        user_id = get_jwt_identity()
        data = request.get_json() or {}

        # Validate with schema (partial=True allows partial updates)
        validated_data = customer_schema.load(data, partial=True)

        # Update profile
        customer = CustomerService.update_profile(user_id, validated_data)

        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'data': customer_schema.dump(customer)
        }), 200

    except ValidationError as e:
        logger.warning(f"Validation error: {e.messages}")
        return jsonify({
            'success': False,
            'error': 'Validation error',
            'details': e.messages
        }), 400

    except CustomerNotFoundError as e:
        logger.warning(f"Customer not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except Exception as e:
        logger.error(f"Error updating customer profile: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500


@customer_bp.route('/quotes', methods=['GET'])
@jwt_required()
def get_quotes():
    """
    Get customer's quotes with optional filtering.

    Query parameters:
        status: string (optional) - Filter by status
        page: int (optional) - Page number (default: 1)
        per_page: int (optional) - Items per page (default: 10)

    Returns:
        200: List of quotes with pagination
        404: Customer not found
        500: Server error
    """
    try:
        customer = _get_current_customer()

        # Get query parameters
        status = request.args.get('status')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)

        # Get quotes
        quotes_pagination = CustomerService.get_quotes_for_customer(
            customer.id,
            status=status,
            page=page,
            per_page=per_page
        )

        return jsonify({
            'success': True,
            'data': {
                'quotes': [quote.to_dict() for quote in quotes_pagination.items],
                'pagination': {
                    'page': quotes_pagination.page,
                    'pages': quotes_pagination.pages,
                    'per_page': quotes_pagination.per_page,
                    'total': quotes_pagination.total
                }
            }
        }), 200

    except CustomerNotFoundError as e:
        logger.warning(f"Customer not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except Exception as e:
        logger.error(f"Error getting customer quotes: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500


@customer_bp.route('/quotes/<int:quote_id>/accept', methods=['POST'])
@jwt_required()
def accept_quote(quote_id):
    """
    Accept a quote.

    Args:
        quote_id: Quote ID from URL

    Returns:
        200: Quote accepted successfully
        400: Quote cannot be accepted (wrong status)
        403: Quote doesn't belong to customer
        404: Quote not found
        500: Server error
    """
    try:
        customer = _get_current_customer()

        # Accept quote
        quote = CustomerService.accept_quote(customer.id, quote_id)

        return jsonify({
            'success': True,
            'message': 'Quote accepted successfully',
            'data': quote.to_dict()
        }), 200

    except QuoteNotFoundError as e:
        logger.warning(f"Quote not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except QuoteAccessDeniedError as e:
        logger.warning(f"Quote access denied: {e}")
        return jsonify({
            'success': False,
            'error': 'You do not have permission to accept this quote'
        }), 403

    except QuoteStatusError as e:
        logger.warning(f"Quote status error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

    except Exception as e:
        logger.error(f"Error accepting quote: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500


@customer_bp.route('/quotes/<int:quote_id>/reject', methods=['POST'])
@jwt_required()
def reject_quote(quote_id):
    """
    Reject a quote.

    Args:
        quote_id: Quote ID from URL

    Request body (optional):
        reason: string - Rejection reason

    Returns:
        200: Quote rejected successfully
        400: Quote cannot be rejected (wrong status)
        403: Quote doesn't belong to customer
        404: Quote not found
        500: Server error
    """
    try:
        customer = _get_current_customer()
        data = request.get_json() or {}
        reason = data.get('reason')

        # Reject quote
        quote = CustomerService.reject_quote(customer.id, quote_id, reason=reason)

        return jsonify({
            'success': True,
            'message': 'Quote rejected successfully',
            'data': quote.to_dict()
        }), 200

    except QuoteNotFoundError as e:
        logger.warning(f"Quote not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except QuoteAccessDeniedError as e:
        logger.warning(f"Quote access denied: {e}")
        return jsonify({
            'success': False,
            'error': 'You do not have permission to reject this quote'
        }), 403

    except QuoteStatusError as e:
        logger.warning(f"Quote status error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

    except Exception as e:
        logger.error(f"Error rejecting quote: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500


@customer_bp.route('/reviews', methods=['GET'])
@jwt_required()
def get_reviews():
    """
    Get all reviews written by the customer.

    Returns:
        200: List of reviews
        404: Customer not found
        500: Server error
    """
    try:
        customer = _get_current_customer()

        # Get reviews
        reviews = CustomerService.get_reviews(customer.id)

        return jsonify({
            'success': True,
            'data': {
                'reviews': [review.to_dict() for review in reviews]
            }
        }), 200

    except CustomerNotFoundError as e:
        logger.warning(f"Customer not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except Exception as e:
        logger.error(f"Error getting customer reviews: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500


@customer_bp.route('/reviews', methods=['POST'])
@jwt_required()
def create_review():
    """
    Create a review for a craftsman.

    Request body:
        craftsman_id: int (required)
        rating: float (required) - Between 1 and 5
        comment: string (required) - At least 10 characters

    Returns:
        201: Review created successfully
        400: Validation error or business rule violation
        404: Customer not found
        500: Server error
    """
    try:
        customer = _get_current_customer()
        data = request.get_json() or {}

        # Extract and validate required fields
        craftsman_id = data.get('craftsman_id')
        rating = data.get('rating')
        comment = data.get('comment')

        if not craftsman_id:
            return jsonify({
                'success': False,
                'error': 'craftsman_id is required'
            }), 400

        if rating is None:
            return jsonify({
                'success': False,
                'error': 'rating is required'
            }), 400

        if not comment:
            return jsonify({
                'success': False,
                'error': 'comment is required'
            }), 400

        # Create review
        review = CustomerService.create_review(
            customer.id,
            craftsman_id,
            rating,
            comment
        )

        return jsonify({
            'success': True,
            'message': 'Review created successfully',
            'data': review.to_dict()
        }), 201

    except (ReviewValidationError, NoCompletedJobError, ReviewAlreadyExistsError) as e:
        logger.warning(f"Review error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

    except CustomerNotFoundError as e:
        logger.warning(f"Customer not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except Exception as e:
        logger.error(f"Error creating review: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500


@customer_bp.route('/favorites', methods=['GET'])
@jwt_required()
def get_favorites():
    """
    Get customer's favorite craftsmen.

    Returns:
        200: List of favorite craftsmen
        404: Customer not found
        500: Server error

    Note:
        Currently returns empty list - favorites functionality not implemented.
    """
    try:
        customer = _get_current_customer()

        # Get favorites
        favorites = CustomerService.get_favorites(customer.id)

        return jsonify({
            'success': True,
            'data': {
                'favorites': [fav.to_dict() for fav in favorites]
            }
        }), 200

    except CustomerNotFoundError as e:
        logger.warning(f"Customer not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except Exception as e:
        logger.error(f"Error getting favorites: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500


@customer_bp.route('/statistics', methods=['GET'])
@jwt_required()
def get_statistics():
    """
    Get customer statistics.

    Returns statistics including:
    - Total quotes
    - Active quotes
    - Completed jobs
    - Total reviews given
    - Total spent
    - Member since date

    Returns:
        200: Statistics data
        404: Customer not found
        500: Server error
    """
    try:
        customer = _get_current_customer()

        # Get statistics
        statistics = CustomerService.get_statistics(customer.id)

        return jsonify({
            'success': True,
            'data': statistics
        }), 200

    except CustomerNotFoundError as e:
        logger.warning(f"Customer not found: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404

    except Exception as e:
        logger.error(f"Error getting customer statistics: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500
