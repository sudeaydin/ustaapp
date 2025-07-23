from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.payment import Payment, PaymentStatus
from app.models.quote import Quote
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.user import User
from datetime import datetime
import random
import string
import logging

payment_bp = Blueprint('payment', __name__)

def generate_payment_id():
    """Generate unique payment ID"""
    return f"pay_{datetime.now().strftime('%Y%m%d')}_{random.randint(100000, 999999)}"

def generate_transaction_id():
    """Generate unique transaction ID"""
    return f"txn_{''.join(random.choices(string.ascii_uppercase + string.digits, k=10))}"

def calculate_installment_fee(amount, installment):
    """Calculate installment fee based on installment count"""
    fee_rates = {
        1: 0.0,
        2: 0.02,
        3: 0.03,
        6: 0.06,
        9: 0.09,
        12: 0.12
    }
    return float(amount) * fee_rates.get(installment, 0.0)

def simulate_iyzico_payment(payment_data):
    """Simulate iyzico payment processing"""
    # Simulate 90% success rate
    success = random.random() > 0.1
    
    if success:
        return {
            'success': True,
            'provider_payment_id': f"iyzico_{random.randint(1000000, 9999999)}",
            'status': PaymentStatus.COMPLETED.value
        }
    else:
        return {
            'success': False,
            'error': 'Payment failed. Please try again.',
            'status': PaymentStatus.FAILED.value
        }

@payment_bp.route('/process', methods=['POST'])
@jwt_required()
def process_payment():
    """Process a payment for a quote"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['quote_id', 'card_number', 'expiry_month', 'expiry_year', 'cvc', 'card_holder_name']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': True,
                    'message': f'{field} is required'
                }), 400
        
        # Get quote
        quote = Quote.query.get(data['quote_id'])
        if not quote:
            return jsonify({
                'error': True,
                'message': 'Quote not found'
            }), 404
        
        # Verify user is the customer for this quote
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer or quote.customer_id != customer.id:
            return jsonify({
                'error': True,
                'message': 'Unauthorized to pay for this quote'
            }), 403
        
        # Check if already paid
        existing_payment = Payment.query.filter_by(
            quote_id=quote.id,
            status=PaymentStatus.COMPLETED.value
        ).first()
        
        if existing_payment:
            return jsonify({
                'error': True,
                'message': 'This quote has already been paid'
            }), 400
        
        # Calculate amounts
        installment = data.get('installment', 1)
        installment_fee = calculate_installment_fee(quote.price, installment)
        total_amount = float(quote.price) + installment_fee
        
        # Create payment record
        payment = Payment(
            payment_id=generate_payment_id(),
            transaction_id=generate_transaction_id(),
            quote_id=quote.id,
            customer_id=customer.id,
            craftsman_id=quote.craftsman_id,
            amount=quote.price,
            installment=installment,
            installment_fee=installment_fee,
            total_amount=total_amount,
            payment_method=data.get('payment_method', 'credit_card'),
            card_type=data.get('card_type', 'unknown'),
            card_last_four=data['card_number'][-4:],
            status=PaymentStatus.PENDING.value
        )
        
        db.session.add(payment)
        db.session.flush()  # Get the payment ID
        
        # Simulate payment processing
        payment_result = simulate_iyzico_payment({
            'amount': total_amount,
            'card_number': data['card_number'],
            'installment': installment
        })
        
        if payment_result['success']:
            payment.status = PaymentStatus.COMPLETED.value
            payment.provider_payment_id = payment_result['provider_payment_id']
            payment.paid_at = datetime.utcnow()
            
            # Update quote status
            quote.status = 'paid'
            quote.updated_at = datetime.utcnow()
            
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Payment completed successfully',
                'payment': payment.to_dict()
            }), 200
        else:
            payment.status = PaymentStatus.FAILED.value
            db.session.commit()
            
            return jsonify({
                'error': True,
                'message': payment_result['error']
            }), 400
            
    except Exception as e:
        db.session.rollback()
        logging.error(f"Error processing payment: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@payment_bp.route('/history', methods=['GET'])
@jwt_required()
def get_payment_history():
    """Get payment history for the current user"""
    try:
        user_id = get_jwt_identity()
        
        # Get user type
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Get payments based on user type
        payments = Payment.get_user_payments(user_id, user.user_type)
        
        # Apply filters
        status_filter = request.args.get('status')
        if status_filter and status_filter != 'all':
            payments = [p for p in payments if p.status == status_filter]
        
        # Date range filter
        date_range = request.args.get('date_range')
        if date_range and date_range != 'all':
            from datetime import timedelta
            now = datetime.utcnow()
            
            if date_range == 'today':
                start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
            elif date_range == 'week':
                start_date = now - timedelta(days=7)
            elif date_range == 'month':
                start_date = now - timedelta(days=30)
            elif date_range == 'year':
                start_date = now - timedelta(days=365)
            else:
                start_date = None
            
            if start_date:
                payments = [p for p in payments if p.created_at >= start_date]
        
        # Amount range filter
        min_amount = request.args.get('min_amount', type=float)
        max_amount = request.args.get('max_amount', type=float)
        
        if min_amount is not None:
            payments = [p for p in payments if float(p.total_amount) >= min_amount]
        if max_amount is not None:
            payments = [p for p in payments if float(p.total_amount) <= max_amount]
        
        # Search filter
        search_term = request.args.get('search_term')
        if search_term:
            search_term = search_term.lower()
            payments = [p for p in payments if 
                       search_term in p.transaction_id.lower() or
                       search_term in p.payment_id.lower() or
                       (p.card_type and search_term in p.card_type.lower())]
        
        # Pagination
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        paginated_payments = payments[start_idx:end_idx]
        
        return jsonify({
            'success': True,
            'payments': [p.to_dict() for p in paginated_payments],
            'total': len(payments),
            'page': page,
            'per_page': per_page,
            'total_pages': (len(payments) + per_page - 1) // per_page
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting payment history: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@payment_bp.route('/stats', methods=['GET'])
@jwt_required()
def get_payment_stats():
    """Get payment statistics for the current user"""
    try:
        user_id = get_jwt_identity()
        
        # Get user type
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        stats = Payment.get_payment_stats(user_id, user.user_type)
        
        return jsonify({
            'success': True,
            'stats': stats
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting payment stats: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@payment_bp.route('/<int:payment_id>', methods=['GET'])
@jwt_required()
def get_payment_details():
    """Get details of a specific payment"""
    try:
        user_id = get_jwt_identity()
        payment_id = request.view_args['payment_id']
        
        payment = Payment.query.get(payment_id)
        if not payment:
            return jsonify({'error': 'Payment not found'}), 404
        
        # Verify user has access to this payment
        user = User.query.get(user_id)
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            if not customer or payment.customer_id != customer.id:
                return jsonify({'error': 'Unauthorized'}), 403
        else:
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            if not craftsman or payment.craftsman_id != craftsman.id:
                return jsonify({'error': 'Unauthorized'}), 403
        
        return jsonify({
            'success': True,
            'payment': payment.to_dict()
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting payment details: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500

@payment_bp.route('/installment-options', methods=['GET'])
def get_installment_options():
    """Get available installment options with fees"""
    try:
        amount = request.args.get('amount', type=float)
        if not amount:
            return jsonify({'error': 'Amount is required'}), 400
        
        options = []
        fee_rates = {
            1: {'label': 'Tek Çekim', 'fee': 0},
            2: {'label': '2 Taksit', 'fee': 0.02},
            3: {'label': '3 Taksit', 'fee': 0.03},
            6: {'label': '6 Taksit', 'fee': 0.06},
            9: {'label': '9 Taksit', 'fee': 0.09},
            12: {'label': '12 Taksit', 'fee': 0.12}
        }
        
        for installment, info in fee_rates.items():
            fee_amount = amount * info['fee']
            total_amount = amount + fee_amount
            monthly_amount = total_amount / installment
            
            options.append({
                'installment': installment,
                'label': info['label'],
                'fee_rate': info['fee'],
                'fee_amount': fee_amount,
                'total_amount': total_amount,
                'monthly_amount': monthly_amount
            })
        
        return jsonify({
            'success': True,
            'options': options
        }), 200
        
    except Exception as e:
        logging.error(f"Error getting installment options: {str(e)}")
        return jsonify({
            'error': True,
            'message': 'Internal server error'
        }), 500