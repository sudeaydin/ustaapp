from datetime import date, datetime
from typing import Any, Dict, List, Optional

from flask import Blueprint, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required

from app import db
from app.models.craftsman import Craftsman
from app.models.customer import Customer
from app.models.message import Message
from app.models.quote import AreaType, BudgetRange, Quote, QuoteStatus
from app.models.user import User

quotes_bp = Blueprint('quotes', __name__)


def _resolve_customer_id(quote: Quote) -> Optional[int]:
    """Return the canonical customer profile id for the quote."""
    if quote.customer_id is None:
        return None

    profile = Customer.query.get(quote.customer_id)
    if profile:
        return profile.id

    user = User.query.get(quote.customer_id)
    if user and user.customer_profile:
        return user.customer_profile.id

    return quote.customer_id


def _resolve_craftsman_id(quote: Quote) -> Optional[int]:
    """Return the canonical craftsman profile id for the quote."""
    if quote.craftsman_id is None:
        return None

    profile = Craftsman.query.get(quote.craftsman_id)
    if profile:
        return profile.id

    user = User.query.get(quote.craftsman_id)
    if user and user.craftsman_profile:
        return user.craftsman_profile.id

    return quote.craftsman_id


def _serialize_quote(quote: Quote) -> Dict[str, Any]:
    """Serialize a quote object for API responses."""
    status_value = quote.status
    if isinstance(status_value, QuoteStatus):
        status_value = status_value.value

    quoted_price = quote.quoted_price
    if quoted_price is not None:
        quoted_price = float(quoted_price)

    return {
        'id': quote.id,
        'customer_id': _resolve_customer_id(quote),
        'craftsman_id': _resolve_craftsman_id(quote),
        'category': quote.category,
        'job_type': quote.job_type,
        'location': quote.location,
        'area_type': quote.area_type,
        'square_meters': quote.square_meters,
        'budget_range': quote.budget_range,
        'description': quote.description,
        'additional_details': quote.additional_details,
        'status': status_value.upper() if status_value else None,
        'quoted_amount': quoted_price,
        'estimated_start_date': quote.estimated_start_date.isoformat() if quote.estimated_start_date else None,
        'estimated_end_date': quote.estimated_end_date.isoformat() if quote.estimated_end_date else None,
    }


def _parse_iso_date(value: Optional[str]) -> Optional[date]:
    if not value:
        return None
    try:
        return datetime.strptime(value[:10], '%Y-%m-%d').date()
    except ValueError:
        return None


def _validation_error(message: str, code: int = 400):
    return jsonify({'success': False, 'message': message}), code


@quotes_bp.route('/create-request', methods=['POST'])
@jwt_required()
def create_quote_request():
    """Create a quote request for a craftsman."""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)

        if not user or not user.customer_profile:
            return _validation_error('Bu işlem sadece müşteriler tarafından yapılabilir', 403)

        data = request.get_json() or {}
        required_fields = ['craftsman_id', 'category', 'area_type', 'budget_range', 'description']
        for field in required_fields:
            if not data.get(field):
                return _validation_error(f'{field} alanı zorunludur', 400)

        craftsman_profile = Craftsman.query.get(data['craftsman_id'])
        if not craftsman_profile:
            return _validation_error('Usta bulunamadı', 404)

        if data['budget_range'] not in [enum.value for enum in BudgetRange]:
            return _validation_error('Geçersiz bütçe aralığı', 400)

        if data['area_type'] not in [enum.value for enum in AreaType]:
            return _validation_error('Geçersiz alan türü', 400)

        quote = Quote(
            customer_id=user.customer_profile.id,
            craftsman_id=craftsman_profile.id,
            category=data['category'],
            job_type=data.get('job_type', data['category']),
            location=data.get('location') or f"{user.customer_profile.city or ''} {user.customer_profile.district or ''}".strip(),
            area_type=data['area_type'],
            square_meters=data.get('square_meters'),
            budget_range=data['budget_range'],
            description=data['description'],
            additional_details=data.get('additional_details'),
            status=QuoteStatus.PENDING.value,
        )

        db.session.add(quote)
        db.session.flush()

        initial_message = Message(
            quote_id=quote.id,
            sender_id=user.id,
            receiver_id=craftsman_profile.user_id,
            content=data['description'],
            message_type='quote_request',
        )
        db.session.add(initial_message)
        db.session.commit()

        return jsonify({
            'success': True,
            'data': {'quote': _serialize_quote(quote)}
        }), 201

    except Exception:
        db.session.rollback()
        return jsonify({'success': False, 'message': 'Teklif talebi oluşturulamadı'}), 500


@quotes_bp.route('/<int:quote_id>/respond', methods=['POST'])
@jwt_required()
def respond_to_quote(quote_id: int):
    """Allow craftsmen to respond to a quote request."""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        quote = Quote.query.get_or_404(quote_id)

        craftsman_ids: List[int] = [current_user_id]
        if user and user.craftsman_profile:
            craftsman_ids.append(user.craftsman_profile.id)

        if quote.craftsman_id not in craftsman_ids:
            return _validation_error('Bu teklife yanıt verme yetkiniz yok', 403)

        data = request.get_json() or {}
        response_type = data.get('response_type')
        if response_type not in ['give_quote', 'request_details', 'reject']:
            return _validation_error('Geçersiz yanıt türü', 400)

        if response_type == 'give_quote':
            if not data.get('quoted_amount'):
                return _validation_error('quoted_amount alanı zorunludur', 400)
            quote.quoted_price = data['quoted_amount']
            quote.status = QuoteStatus.QUOTED.value
        elif response_type == 'request_details':
            if not data.get('response_details'):
                return _validation_error('response_details alanı zorunludur', 400)
            quote.status = QuoteStatus.DETAILS_REQUESTED.value
        else:
            quote.status = QuoteStatus.REJECTED.value

        quote.craftsman_response_type = response_type
        quote.craftsman_notes = data.get('response_details')
        quote.estimated_start_date = _parse_iso_date(data.get('estimated_start_date'))
        quote.estimated_end_date = _parse_iso_date(data.get('estimated_end_date'))
        quote.craftsman_responded_at = datetime.utcnow()

        db.session.commit()

        return jsonify({
            'success': True,
            'data': {'quote': _serialize_quote(quote)}
        }), 200

    except Exception:
        db.session.rollback()
        return jsonify({'success': False, 'message': 'Teklif yanıtı kaydedilemedi'}), 500


@quotes_bp.route('/<int:quote_id>/decision', methods=['POST'])
@jwt_required()
def quote_decision(quote_id: int):
    """Allow customers to accept or reject a quote."""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        quote = Quote.query.get_or_404(quote_id)

        customer_ids: List[int] = [current_user_id]
        if user and user.customer_profile:
            customer_ids.append(user.customer_profile.id)

        if quote.customer_id not in customer_ids:
            return _validation_error('Bu teklifi yönetme yetkiniz yok', 403)

        data = request.get_json() or {}
        decision = data.get('decision')
        if decision not in ['accept', 'reject']:
            return _validation_error('Geçersiz karar', 400)

        quote.status = QuoteStatus.ACCEPTED.value if decision == 'accept' else QuoteStatus.REJECTED.value
        quote.customer_decision_at = datetime.utcnow()

        db.session.commit()

        return jsonify({
            'success': True,
            'data': {'quote': _serialize_quote(quote)}
        }), 200

    except Exception:
        db.session.rollback()
        return jsonify({'success': False, 'message': 'Teklif kararı kaydedilemedi'}), 500


@quotes_bp.route('/my-quotes', methods=['GET'])
@jwt_required()
def get_my_quotes():
    """Return quotes for the authenticated user."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)

    if not user:
        return _validation_error('Kullanıcı bulunamadı', 404)

    quotes_query = Quote.query.order_by(Quote.created_at.desc())

    if user.customer_profile:
        identifiers = [user.customer_profile.id, user.id]
        quotes_query = quotes_query.filter(Quote.customer_id.in_(identifiers))
    elif user.craftsman_profile:
        identifiers = [user.craftsman_profile.id, user.id]
        quotes_query = quotes_query.filter(Quote.craftsman_id.in_(identifiers))
    else:
        return _validation_error('Geçersiz kullanıcı profili', 400)

    quotes = [_serialize_quote(quote) for quote in quotes_query.all()]

    return jsonify({'success': True, 'data': {'quotes': quotes}}), 200


@quotes_bp.route('/budget-ranges', methods=['GET'])
def get_budget_ranges():
    """Return available budget ranges."""
    return jsonify({
        'success': True,
        'data': {'budget_ranges': [budget.value for budget in BudgetRange]}
    }), 200


@quotes_bp.route('/area-types', methods=['GET'])
def get_area_types():
    """Return available area types."""
    return jsonify({
        'success': True,
        'data': {'area_types': [area.value for area in AreaType]}
    }), 200
