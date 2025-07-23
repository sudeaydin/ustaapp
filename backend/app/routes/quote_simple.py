from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.quote import Quote
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from datetime import datetime

quote_bp = Blueprint('quotes', __name__)

@quote_bp.route('/', methods=['POST'])
@jwt_required()
def create_quote():
    """Create a new quote request"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Get customer
        customer = Customer.query.filter_by(user_id=user_id).first()
        if not customer:
            return jsonify({
                'success': False,
                'message': 'Müşteri profili bulunamadı'
            }), 404
        
        # Validate required fields
        required_fields = ['craftsman_id', 'title', 'description', 'location']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'message': f'{field} alanı zorunludur'
                }), 400
        
        # Check if craftsman exists
        craftsman = Craftsman.query.get(data['craftsman_id'])
        if not craftsman:
            return jsonify({
                'success': False,
                'message': 'Usta bulunamadı'
            }), 404
        
        # Create quote
        quote = Quote(
            customer_id=customer.id,
            craftsman_id=data['craftsman_id'],
            title=data['title'],
            description=data['description'],
            location=data['location'],
            preferred_date=datetime.fromisoformat(data['preferred_date']) if data.get('preferred_date') else None,
            budget_min=data.get('budget_min'),
            budget_max=data.get('budget_max'),
            status='pending'
        )
        
        db.session.add(quote)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Teklif talebi oluşturuldu',
            'data': {
                'id': quote.id,
                'status': quote.status
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': 'Bir hata oluştu'
        }), 500

@quote_bp.route('/', methods=['GET'])
@jwt_required()
def get_quotes():
    """Get user's quotes"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'success': False,
                'message': 'Kullanıcı bulunamadı'
            }), 404
        
        quotes = []
        
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            if customer:
                quotes = Quote.query.filter_by(customer_id=customer.id).order_by(Quote.created_at.desc()).all()
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            if craftsman:
                quotes = Quote.query.filter_by(craftsman_id=craftsman.id).order_by(Quote.created_at.desc()).all()
        
        result = []
        for quote in quotes:
            result.append({
                'id': quote.id,
                'title': quote.title,
                'description': quote.description,
                'location': quote.location,
                'status': quote.status,
                'budget_min': str(quote.budget_min) if quote.budget_min else None,
                'budget_max': str(quote.budget_max) if quote.budget_max else None,
                'preferred_date': quote.preferred_date.isoformat() if quote.preferred_date else None,
                'created_at': quote.created_at.isoformat() if quote.created_at else None,
                'craftsman': {
                    'id': quote.craftsman.id,
                    'name': f"{quote.craftsman.user.first_name} {quote.craftsman.user.last_name}",
                    'business_name': quote.craftsman.business_name
                } if quote.craftsman else None,
                'customer': {
                    'id': quote.customer.id,
                    'name': f"{quote.customer.user.first_name} {quote.customer.user.last_name}"
                } if quote.customer else None
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

@quote_bp.route('/<int:quote_id>', methods=['GET'])
@jwt_required()
def get_quote(quote_id):
    """Get quote details"""
    try:
        user_id = get_jwt_identity()
        quote = Quote.query.get(quote_id)
        
        if not quote:
            return jsonify({
                'success': False,
                'message': 'Teklif bulunamadı'
            }), 404
        
        # Check if user has access to this quote
        user = User.query.get(user_id)
        has_access = False
        
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user_id).first()
            has_access = customer and quote.customer_id == customer.id
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user_id).first()
            has_access = craftsman and quote.craftsman_id == craftsman.id
        
        if not has_access:
            return jsonify({
                'success': False,
                'message': 'Bu teklife erişim yetkiniz yok'
            }), 403
        
        result = {
            'id': quote.id,
            'title': quote.title,
            'description': quote.description,
            'location': quote.location,
            'status': quote.status,
            'budget_min': str(quote.budget_min) if quote.budget_min else None,
            'budget_max': str(quote.budget_max) if quote.budget_max else None,
            'preferred_date': quote.preferred_date.isoformat() if quote.preferred_date else None,
            'craftsman_message': quote.craftsman_message,
            'price': str(quote.price) if quote.price else None,
            'estimated_duration': quote.estimated_duration,
            'proposed_date': quote.proposed_date.isoformat() if quote.proposed_date else None,
            'created_at': quote.created_at.isoformat() if quote.created_at else None,
            'updated_at': quote.updated_at.isoformat() if quote.updated_at else None,
            'craftsman': {
                'id': quote.craftsman.id,
                'name': f"{quote.craftsman.user.first_name} {quote.craftsman.user.last_name}",
                'business_name': quote.craftsman.business_name,
                'phone': quote.craftsman.user.phone
            } if quote.craftsman else None,
            'customer': {
                'id': quote.customer.id,
                'name': f"{quote.customer.user.first_name} {quote.customer.user.last_name}",
                'phone': quote.customer.user.phone
            } if quote.customer else None
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