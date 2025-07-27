"""
Production API Routes
Optimized and secure API endpoints for production deployment
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token
from sqlalchemy import and_, or_, desc, func
from datetime import datetime, timedelta
import logging
from werkzeug.security import check_password_hash, generate_password_hash

from app import db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from app.models.job import Job
from app.models.quote import Quote
from app.models.review import Review
from app.models.payment import Payment
from app.models.notification import Notification
from app.models.message import Message

# Create blueprint
production_api = Blueprint('production_api', __name__)

# Configure logging
logger = logging.getLogger(__name__)

# ================================================
# AUTHENTICATION ENDPOINTS
# ================================================

@production_api.route('/auth/login', methods=['POST'])
def login():
    """Enhanced login with security features"""
    try:
        data = request.get_json()
        
        if not data or not data.get('email') or not data.get('password'):
            return jsonify({
                'success': False,
                'message': 'Email and password are required'
            }), 400
        
        email = data.get('email').lower().strip()
        password = data.get('password')
        
        # Find user
        user = User.query.filter_by(email=email).first()
        
        if not user or not user.check_password(password):
            logger.warning(f"Failed login attempt for email: {email}")
            return jsonify({
                'success': False,
                'message': 'Invalid email or password'
            }), 401
        
        if not user.is_active:
            return jsonify({
                'success': False,
                'message': 'Account is disabled. Please contact support.'
            }), 403
        
        # Update last login
        user.last_login = datetime.utcnow()
        db.session.commit()
        
        # Create access token
        access_token = create_access_token(
            identity=user.id,
            additional_claims={
                'user_type': user.user_type,
                'email': user.email
            }
        )
        
        # Get user profile data
        profile_data = user.to_dict()
        
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                profile_data['customer_profile'] = customer.to_dict(include_user=False)
        
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                profile_data['craftsman_profile'] = craftsman.to_dict(include_user=False)
        
        logger.info(f"Successful login for user: {user.email}")
        
        return jsonify({
            'success': True,
            'message': 'Login successful',
            'data': {
                'access_token': access_token,
                'user': profile_data
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Login error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred during login'
        }), 500

@production_api.route('/auth/register', methods=['POST'])
def register():
    """Enhanced registration with validation"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'message': f'{field} is required'
                }), 400
        
        email = data.get('email').lower().strip()
        phone = data.get('phone').strip()
        user_type = data.get('user_type')
        
        # Validate user type
        if user_type not in ['customer', 'craftsman']:
            return jsonify({
                'success': False,
                'message': 'Invalid user type'
            }), 400
        
        # Check if user already exists
        if User.query.filter_by(email=email).first():
            return jsonify({
                'success': False,
                'message': 'Email already registered'
            }), 409
        
        if User.query.filter_by(phone=phone).first():
            return jsonify({
                'success': False,
                'message': 'Phone number already registered'
            }), 409
        
        # Create user
        user = User(
            email=email,
            phone=phone,
            first_name=data.get('first_name'),
            last_name=data.get('last_name'),
            user_type=user_type,
            city=data.get('city'),
            district=data.get('district'),
            is_active=True
        )
        user.set_password(data.get('password'))
        
        db.session.add(user)
        db.session.flush()  # Get user ID
        
        # Create profile based on user type
        if user_type == 'customer':
            customer = Customer(
                user_id=user.id,
                preferred_contact_method=data.get('preferred_contact_method', 'phone')
            )
            db.session.add(customer)
        
        elif user_type == 'craftsman':
            craftsman = Craftsman(
                user_id=user.id,
                business_name=data.get('business_name'),
                description=data.get('description'),
                hourly_rate=data.get('hourly_rate'),
                is_available=True
            )
            db.session.add(craftsman)
        
        db.session.commit()
        
        logger.info(f"New user registered: {user.email} ({user_type})")
        
        return jsonify({
            'success': True,
            'message': 'Registration successful',
            'data': {
                'user_id': user.id,
                'email': user.email
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Registration error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred during registration'
        }), 500

# ================================================
# SEARCH AND DISCOVERY ENDPOINTS
# ================================================

@production_api.route('/search/craftsmen', methods=['GET'])
def search_craftsmen():
    """Advanced craftsman search with filters"""
    try:
        # Get search parameters
        query = request.args.get('q', '').strip()
        category_id = request.args.get('category_id', type=int)
        city = request.args.get('city', '').strip()
        district = request.args.get('district', '').strip()
        min_rating = request.args.get('min_rating', type=float)
        max_price = request.args.get('max_price', type=float)
        is_verified = request.args.get('is_verified', type=bool)
        is_available = request.args.get('is_available', type=bool, default=True)
        
        # Pagination
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 20, type=int), 50)  # Max 50 per page
        
        # Build query
        query_builder = db.session.query(Craftsman).join(User)
        
        # Apply filters
        if is_available:
            query_builder = query_builder.filter(Craftsman.is_available == True)
        
        query_builder = query_builder.filter(User.is_active == True)
        
        if query:
            search_filter = or_(
                User.first_name.ilike(f'%{query}%'),
                User.last_name.ilike(f'%{query}%'),
                Craftsman.business_name.ilike(f'%{query}%'),
                Craftsman.description.ilike(f'%{query}%')
            )
            query_builder = query_builder.filter(search_filter)
        
        if category_id:
            query_builder = query_builder.join(Craftsman.categories).filter(Category.id == category_id)
        
        if city:
            query_builder = query_builder.filter(User.city.ilike(f'%{city}%'))
        
        if district:
            query_builder = query_builder.filter(User.district.ilike(f'%{district}%'))
        
        if min_rating:
            query_builder = query_builder.filter(Craftsman.average_rating >= min_rating)
        
        if max_price:
            query_builder = query_builder.filter(Craftsman.hourly_rate <= max_price)
        
        if is_verified:
            query_builder = query_builder.filter(Craftsman.is_verified == True)
        
        # Order by rating and verification status
        query_builder = query_builder.order_by(
            desc(Craftsman.is_verified),
            desc(Craftsman.average_rating),
            desc(Craftsman.total_reviews)
        )
        
        # Execute pagination
        pagination = query_builder.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        # Format results
        craftsmen = []
        for craftsman in pagination.items:
            craftsman_data = craftsman.to_dict(include_user=True)
            
            # Add category information
            categories = [cat.to_dict() for cat in craftsman.categories]
            craftsman_data['categories'] = categories
            
            craftsmen.append(craftsman_data)
        
        return jsonify({
            'success': True,
            'data': {
                'craftsmen': craftsmen,
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': pagination.total,
                    'pages': pagination.pages,
                    'has_next': pagination.has_next,
                    'has_prev': pagination.has_prev
                }
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Search craftsmen error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred during search'
        }), 500

@production_api.route('/categories', methods=['GET'])
def get_categories():
    """Get all active categories"""
    try:
        categories = Category.query.filter_by(is_active=True).order_by(Category.sort_order).all()
        
        categories_data = []
        for category in categories:
            cat_data = category.to_dict()
            
            # Add statistics
            cat_data['craftsmen_count'] = db.session.query(func.count(Craftsman.id))\
                .join(Craftsman.categories)\
                .filter(Category.id == category.id)\
                .scalar()
            
            categories_data.append(cat_data)
        
        return jsonify({
            'success': True,
            'data': categories_data
        }), 200
        
    except Exception as e:
        logger.error(f"Get categories error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred while fetching categories'
        }), 500

# ================================================
# JOB MANAGEMENT ENDPOINTS
# ================================================

@production_api.route('/jobs', methods=['GET'])
@jwt_required()
def get_jobs():
    """Get jobs for current user"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'success': False, 'message': 'User not found'}), 404
        
        # Pagination
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 20, type=int), 50)
        
        # Build query based on user type
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if not customer:
                return jsonify({'success': False, 'message': 'Customer profile not found'}), 404
            
            query_builder = Job.query.filter_by(customer_id=customer.id)
        
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if not craftsman:
                return jsonify({'success': False, 'message': 'Craftsman profile not found'}), 404
            
            # Show assigned jobs or jobs in craftsman's categories
            query_builder = Job.query.filter(
                or_(
                    Job.assigned_craftsman_id == craftsman.id,
                    and_(
                        Job.status == 'open',
                        Job.category_id.in_(
                            db.session.query(Category.id)
                            .join(Craftsman.categories)
                            .filter(Craftsman.id == craftsman.id)
                        )
                    )
                )
            )
        
        else:  # admin
            query_builder = Job.query
        
        # Apply filters
        status = request.args.get('status')
        if status:
            query_builder = query_builder.filter(Job.status == status)
        
        category_id = request.args.get('category_id', type=int)
        if category_id:
            query_builder = query_builder.filter(Job.category_id == category_id)
        
        # Order by creation date
        query_builder = query_builder.order_by(desc(Job.created_at))
        
        # Execute pagination
        pagination = query_builder.paginate(
            page=page,
            per_page=per_page,
            error_out=False
        )
        
        # Format results
        jobs = []
        for job in pagination.items:
            job_data = job.to_dict()
            
            # Add related data
            if job.category:
                job_data['category'] = job.category.to_dict()
            
            if job.customer:
                job_data['customer'] = job.customer.to_dict()
            
            if job.assigned_craftsman:
                job_data['assigned_craftsman'] = job.assigned_craftsman.to_dict()
            
            jobs.append(job_data)
        
        return jsonify({
            'success': True,
            'data': {
                'jobs': jobs,
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': pagination.total,
                    'pages': pagination.pages,
                    'has_next': pagination.has_next,
                    'has_prev': pagination.has_prev
                }
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Get jobs error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred while fetching jobs'
        }), 500

@production_api.route('/jobs', methods=['POST'])
@jwt_required()
def create_job():
    """Create a new job"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user or user.user_type != 'customer':
            return jsonify({'success': False, 'message': 'Only customers can create jobs'}), 403
        
        customer = Customer.query.filter_by(user_id=user.id).first()
        if not customer:
            return jsonify({'success': False, 'message': 'Customer profile not found'}), 404
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'category_id', 'location']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'message': f'{field} is required'
                }), 400
        
        # Validate category exists
        category = Category.query.get(data.get('category_id'))
        if not category:
            return jsonify({'success': False, 'message': 'Invalid category'}), 400
        
        # Create job
        job = Job(
            title=data.get('title'),
            description=data.get('description'),
            category_id=data.get('category_id'),
            customer_id=customer.id,
            location=data.get('location'),
            city=data.get('city'),
            district=data.get('district'),
            address=data.get('address'),
            budget_min=data.get('budget_min'),
            budget_max=data.get('budget_max'),
            urgency=data.get('urgency', 'normal'),
            preferred_date=data.get('preferred_date'),
            status='open'
        )
        
        db.session.add(job)
        db.session.commit()
        
        logger.info(f"New job created: {job.id} by customer {customer.id}")
        
        return jsonify({
            'success': True,
            'message': 'Job created successfully',
            'data': job.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Create job error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred while creating the job'
        }), 500

# ================================================
# MESSAGING ENDPOINTS
# ================================================

@production_api.route('/messages', methods=['GET'])
@jwt_required()
def get_messages():
    """Get messages for current user"""
    try:
        current_user_id = get_jwt_identity()
        
        # Get conversations
        conversations = db.session.query(Message)\
            .filter(
                or_(
                    Message.sender_id == current_user_id,
                    Message.recipient_id == current_user_id
                )
            )\
            .order_by(desc(Message.created_at))\
            .all()
        
        # Group by conversation partner
        conversations_dict = {}
        for message in conversations:
            partner_id = message.sender_id if message.recipient_id == current_user_id else message.recipient_id
            
            if partner_id not in conversations_dict:
                partner = User.query.get(partner_id)
                conversations_dict[partner_id] = {
                    'partner': partner.to_dict() if partner else None,
                    'messages': [],
                    'unread_count': 0,
                    'last_message': None
                }
            
            conversations_dict[partner_id]['messages'].append(message.to_dict())
            
            if not message.is_read and message.recipient_id == current_user_id:
                conversations_dict[partner_id]['unread_count'] += 1
            
            if not conversations_dict[partner_id]['last_message']:
                conversations_dict[partner_id]['last_message'] = message.to_dict()
        
        return jsonify({
            'success': True,
            'data': list(conversations_dict.values())
        }), 200
        
    except Exception as e:
        logger.error(f"Get messages error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred while fetching messages'
        }), 500

# ================================================
# ANALYTICS ENDPOINTS
# ================================================

@production_api.route('/analytics/dashboard', methods=['GET'])
@jwt_required()
def get_dashboard_analytics():
    """Get dashboard analytics for current user"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'success': False, 'message': 'User not found'}), 404
        
        analytics_data = {}
        
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                analytics_data = {
                    'total_jobs': Job.query.filter_by(customer_id=customer.id).count(),
                    'active_jobs': Job.query.filter_by(customer_id=customer.id, status='in_progress').count(),
                    'completed_jobs': Job.query.filter_by(customer_id=customer.id, status='completed').count(),
                    'total_spent': customer.total_spent or 0,
                    'recent_jobs': [job.to_dict() for job in Job.query.filter_by(customer_id=customer.id).order_by(desc(Job.created_at)).limit(5).all()]
                }
        
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                analytics_data = {
                    'total_jobs': Job.query.filter_by(assigned_craftsman_id=craftsman.id).count(),
                    'active_jobs': Job.query.filter_by(assigned_craftsman_id=craftsman.id, status='in_progress').count(),
                    'completed_jobs': Job.query.filter_by(assigned_craftsman_id=craftsman.id, status='completed').count(),
                    'average_rating': craftsman.average_rating or 0,
                    'total_reviews': craftsman.total_reviews or 0,
                    'recent_jobs': [job.to_dict() for job in Job.query.filter_by(assigned_craftsman_id=craftsman.id).order_by(desc(Job.created_at)).limit(5).all()]
                }
        
        elif user.user_type == 'admin':
            analytics_data = {
                'total_users': User.query.count(),
                'total_customers': User.query.filter_by(user_type='customer').count(),
                'total_craftsmen': User.query.filter_by(user_type='craftsman').count(),
                'total_jobs': Job.query.count(),
                'active_jobs': Job.query.filter(Job.status.in_(['open', 'assigned', 'in_progress'])).count(),
                'completed_jobs': Job.query.filter_by(status='completed').count(),
                'recent_registrations': [user.to_dict() for user in User.query.order_by(desc(User.created_at)).limit(10).all()]
            }
        
        return jsonify({
            'success': True,
            'data': analytics_data
        }), 200
        
    except Exception as e:
        logger.error(f"Get dashboard analytics error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred while fetching analytics'
        }), 500

# ================================================
# ERROR HANDLERS
# ================================================

@production_api.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'message': 'Resource not found'
    }), 404

@production_api.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    logger.error(f"Internal server error: {str(error)}")
    return jsonify({
        'success': False,
        'message': 'Internal server error'
    }), 500

@production_api.errorhandler(429)
def ratelimit_handler(e):
    return jsonify({
        'success': False,
        'message': 'Rate limit exceeded. Please try again later.'
    }), 429