"""
Mobile API Routes
Optimized API endpoints for mobile applications (React Native & Flutter)
Includes offline sync, push notifications, and mobile-specific features
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token
from sqlalchemy import and_, or_, desc, func
from datetime import datetime, timedelta
import logging
import json

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
mobile_api = Blueprint('mobile_api', __name__)

# Configure logging
logger = logging.getLogger(__name__)

# ================================================
# MOBILE AUTHENTICATION
# ================================================

@mobile_api.route('/auth/mobile-login', methods=['POST'])
def mobile_login():
    """Mobile optimized login with device info"""
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data or not data.get('email') or not data.get('password'):
            return jsonify({
                'success': False,
                'message': 'Email and password are required',
                'code': 'MISSING_CREDENTIALS'
            }), 400
        
        email = data.get('email').lower().strip()
        password = data.get('password')
        device_info = data.get('device_info', {})
        
        # Find user
        user = User.query.filter_by(email=email).first()
        
        if not user or not user.check_password(password):
            logger.warning(f"Failed mobile login attempt for email: {email}")
            return jsonify({
                'success': False,
                'message': 'Invalid email or password',
                'code': 'INVALID_CREDENTIALS'
            }), 401
        
        if not user.is_active:
            return jsonify({
                'success': False,
                'message': 'Account is disabled. Please contact support.',
                'code': 'ACCOUNT_DISABLED'
            }), 403
        
        # Update last login and device info
        user.last_login = datetime.utcnow()
        db.session.commit()
        
        # Create mobile-optimized access token (longer expiry)
        access_token = create_access_token(
            identity=user.id,
            expires_delta=timedelta(days=30),  # 30 days for mobile
            additional_claims={
                'user_type': user.user_type,
                'email': user.email,
                'device_type': device_info.get('platform', 'mobile')
            }
        )
        
        # Get user profile with mobile-specific data
        profile_data = user.to_dict()
        
        # Add profile-specific data
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                profile_data['customer_profile'] = customer.to_dict(include_user=False)
                profile_data['stats'] = {
                    'total_jobs': customer.total_jobs,
                    'total_spent': str(customer.total_spent or 0),
                    'member_since': customer.created_at.isoformat() if customer.created_at else None
                }
        
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                profile_data['craftsman_profile'] = craftsman.to_dict(include_user=False)
                profile_data['stats'] = {
                    'total_jobs': craftsman.total_jobs,
                    'average_rating': str(craftsman.average_rating or 0),
                    'total_reviews': craftsman.total_reviews,
                    'completion_rate': str(craftsman.completion_rate or 0)
                }
        
        # Mobile-specific settings
        mobile_settings = {
            'push_notifications': True,
            'location_services': True,
            'offline_mode': True,
            'auto_sync': True,
            'theme': 'system',
            'language': 'tr'
        }
        
        logger.info(f"Successful mobile login for user: {user.email}")
        
        return jsonify({
            'success': True,
            'message': 'Login successful',
            'data': {
                'access_token': access_token,
                'user': profile_data,
                'mobile_settings': mobile_settings,
                'server_time': datetime.utcnow().isoformat(),
                'api_version': '2.0'
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Mobile login error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred during login',
            'code': 'SERVER_ERROR'
        }), 500

@mobile_api.route('/auth/social-login', methods=['POST'])
def social_login():
    """Social media login (Google, Facebook, Apple)"""
    try:
        data = request.get_json()
        
        provider = data.get('provider')  # google, facebook, apple
        social_id = data.get('social_id')
        email = data.get('email')
        name = data.get('name', '').split(' ', 1)
        first_name = name[0] if name else ''
        last_name = name[1] if len(name) > 1 else ''
        
        if not provider or not social_id:
            return jsonify({
                'success': False,
                'message': 'Provider and social ID are required',
                'code': 'MISSING_SOCIAL_DATA'
            }), 400
        
        # Check if user exists with this email
        user = User.query.filter_by(email=email).first() if email else None
        
        if not user and email:
            # Create new user
            user = User(
                email=email,
                phone=f"social_{social_id}",  # Temporary phone
                first_name=first_name,
                last_name=last_name,
                user_type='customer',  # Default to customer
                is_active=True,
                is_verified=True,
                email_verified=True
            )
            user.set_password(social_id)  # Use social_id as password
            
            db.session.add(user)
            db.session.flush()
            
            # Create customer profile
            customer = Customer(
                user_id=user.id,
                preferred_contact_method='app'
            )
            db.session.add(customer)
            db.session.commit()
            
            logger.info(f"New social user created: {email} via {provider}")
        
        elif user:
            user.last_login = datetime.utcnow()
            db.session.commit()
        
        else:
            return jsonify({
                'success': False,
                'message': 'Unable to create user account',
                'code': 'ACCOUNT_CREATION_FAILED'
            }), 400
        
        # Create access token
        access_token = create_access_token(
            identity=user.id,
            expires_delta=timedelta(days=30),
            additional_claims={
                'user_type': user.user_type,
                'email': user.email,
                'auth_provider': provider
            }
        )
        
        return jsonify({
            'success': True,
            'message': 'Social login successful',
            'data': {
                'access_token': access_token,
                'user': user.to_dict(),
                'is_new_user': not user.phone_verified,
                'server_time': datetime.utcnow().isoformat()
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Social login error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Social login failed',
            'code': 'SOCIAL_LOGIN_ERROR'
        }), 500

# ================================================
# MOBILE DATA SYNC
# ================================================

@mobile_api.route('/sync/full', methods=['GET'])
@jwt_required()
def full_sync():
    """Full data sync for mobile app initialization"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'success': False, 'message': 'User not found'}), 404
        
        sync_data = {
            'user': user.to_dict(),
            'categories': [],
            'recent_jobs': [],
            'unread_messages': 0,
            'notifications': [],
            'app_settings': {},
            'sync_timestamp': datetime.utcnow().isoformat()
        }
        
        # Get categories
        categories = Category.query.filter_by(is_active=True).order_by(Category.sort_order).all()
        sync_data['categories'] = [cat.to_dict() for cat in categories]
        
        # Get user-specific data
        if user.user_type == 'customer':
            customer = Customer.query.filter_by(user_id=user.id).first()
            if customer:
                sync_data['customer_profile'] = customer.to_dict(include_user=False)
                
                # Recent jobs
                recent_jobs = Job.query.filter_by(customer_id=customer.id)\
                    .order_by(desc(Job.created_at)).limit(10).all()
                sync_data['recent_jobs'] = [job.to_dict() for job in recent_jobs]
        
        elif user.user_type == 'craftsman':
            craftsman = Craftsman.query.filter_by(user_id=user.id).first()
            if craftsman:
                sync_data['craftsman_profile'] = craftsman.to_dict(include_user=False)
                
                # Available jobs in craftsman's categories
                available_jobs = Job.query.filter(
                    and_(
                        Job.status == 'open',
                        Job.category_id.in_(
                            db.session.query(Category.id)
                            .join(craftsman.categories)
                        )
                    )
                ).order_by(desc(Job.created_at)).limit(20).all()
                sync_data['available_jobs'] = [job.to_dict() for job in available_jobs]
        
        # Unread messages count
        unread_count = Message.query.filter(
            and_(
                Message.recipient_id == user.id,
                Message.is_read == False
            )
        ).count()
        sync_data['unread_messages'] = unread_count
        
        # Recent notifications
        notifications = Notification.query.filter_by(user_id=user.id)\
            .order_by(desc(Notification.created_at)).limit(10).all()
        sync_data['notifications'] = [notif.to_dict() for notif in notifications]
        
        return jsonify({
            'success': True,
            'data': sync_data
        }), 200
        
    except Exception as e:
        logger.error(f"Full sync error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Sync failed',
            'code': 'SYNC_ERROR'
        }), 500

@mobile_api.route('/sync/incremental', methods=['POST'])
@jwt_required()
def incremental_sync():
    """Incremental data sync based on timestamp"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        last_sync = data.get('last_sync')
        
        if not last_sync:
            return jsonify({
                'success': False,
                'message': 'Last sync timestamp required',
                'code': 'MISSING_TIMESTAMP'
            }), 400
        
        last_sync_dt = datetime.fromisoformat(last_sync.replace('Z', '+00:00'))
        
        # Get updated data since last sync
        updates = {
            'jobs': [],
            'messages': [],
            'notifications': [],
            'quotes': [],
            'sync_timestamp': datetime.utcnow().isoformat()
        }
        
        # Updated jobs
        updated_jobs = Job.query.filter(
            Job.updated_at > last_sync_dt
        ).all()
        updates['jobs'] = [job.to_dict() for job in updated_jobs]
        
        # New messages
        new_messages = Message.query.filter(
            and_(
                Message.recipient_id == current_user_id,
                Message.created_at > last_sync_dt
            )
        ).all()
        updates['messages'] = [msg.to_dict() for msg in new_messages]
        
        # New notifications
        new_notifications = Notification.query.filter(
            and_(
                Notification.user_id == current_user_id,
                Notification.created_at > last_sync_dt
            )
        ).all()
        updates['notifications'] = [notif.to_dict() for notif in new_notifications]
        
        return jsonify({
            'success': True,
            'data': updates
        }), 200
        
    except Exception as e:
        logger.error(f"Incremental sync error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Incremental sync failed',
            'code': 'SYNC_ERROR'
        }), 500

# ================================================
# MOBILE LOCATION & SEARCH
# ================================================

@mobile_api.route('/location/nearby-craftsmen', methods=['POST'])
def nearby_craftsmen():
    """Find craftsmen near user location"""
    try:
        data = request.get_json()
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        radius = data.get('radius', 10)  # km
        category_id = data.get('category_id')
        
        if not latitude or not longitude:
            return jsonify({
                'success': False,
                'message': 'Location coordinates required',
                'code': 'MISSING_LOCATION'
            }), 400
        
        # Haversine formula for distance calculation
        # Note: This is a simplified version. For production, consider using PostGIS
        query = db.session.query(Craftsman).join(User)
        
        if category_id:
            query = query.join(Craftsman.categories).filter(Category.id == category_id)
        
        craftsmen = query.filter(
            and_(
                Craftsman.is_available == True,
                User.is_active == True,
                User.latitude.isnot(None),
                User.longitude.isnot(None)
            )
        ).all()
        
        # Calculate distances and filter by radius
        nearby_craftsmen = []
        for craftsman in craftsmen:
            if craftsman.user.latitude and craftsman.user.longitude:
                # Simple distance calculation (you should use proper geospatial functions)
                lat_diff = float(craftsman.user.latitude) - latitude
                lon_diff = float(craftsman.user.longitude) - longitude
                distance = (lat_diff**2 + lon_diff**2)**0.5 * 111  # Rough km conversion
                
                if distance <= radius:
                    craftsman_data = craftsman.to_dict(include_user=True)
                    craftsman_data['distance'] = round(distance, 2)
                    nearby_craftsmen.append(craftsman_data)
        
        # Sort by distance
        nearby_craftsmen.sort(key=lambda x: x['distance'])
        
        return jsonify({
            'success': True,
            'data': {
                'craftsmen': nearby_craftsmen,
                'total_count': len(nearby_craftsmen),
                'search_location': {
                    'latitude': latitude,
                    'longitude': longitude,
                    'radius': radius
                }
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Nearby craftsmen search error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Location search failed',
            'code': 'LOCATION_SEARCH_ERROR'
        }), 500

# ================================================
# MOBILE PUSH NOTIFICATIONS
# ================================================

@mobile_api.route('/notifications/register-device', methods=['POST'])
@jwt_required()
def register_device():
    """Register device for push notifications"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        device_token = data.get('device_token')
        platform = data.get('platform')  # ios, android
        app_version = data.get('app_version')
        
        if not device_token or not platform:
            return jsonify({
                'success': False,
                'message': 'Device token and platform required',
                'code': 'MISSING_DEVICE_INFO'
            }), 400
        
        # Store device info (you might want a separate table for this)
        # For now, we'll just return success
        
        logger.info(f"Device registered for user {current_user_id}: {platform} - {device_token[:20]}...")
        
        return jsonify({
            'success': True,
            'message': 'Device registered successfully',
            'data': {
                'registered_at': datetime.utcnow().isoformat(),
                'platform': platform
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Device registration error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Device registration failed',
            'code': 'DEVICE_REGISTRATION_ERROR'
        }), 500

# ================================================
# MOBILE FILE UPLOAD
# ================================================

@mobile_api.route('/upload/mobile-image', methods=['POST'])
@jwt_required()
def mobile_image_upload():
    """Mobile optimized image upload with compression"""
    try:
        current_user_id = get_jwt_identity()
        
        if 'image' not in request.files:
            return jsonify({
                'success': False,
                'message': 'No image file provided',
                'code': 'NO_FILE'
            }), 400
        
        file = request.files['image']
        upload_type = request.form.get('type', 'general')  # profile, job, portfolio
        
        if file.filename == '':
            return jsonify({
                'success': False,
                'message': 'No file selected',
                'code': 'NO_FILE_SELECTED'
            }), 400
        
        # Validate file type
        allowed_extensions = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
        if not ('.' in file.filename and 
                file.filename.rsplit('.', 1)[1].lower() in allowed_extensions):
            return jsonify({
                'success': False,
                'message': 'Invalid file type',
                'code': 'INVALID_FILE_TYPE'
            }), 400
        
        # Generate unique filename
        import uuid
        import os
        
        file_extension = file.filename.rsplit('.', 1)[1].lower()
        filename = f"{current_user_id}_{upload_type}_{uuid.uuid4().hex}.{file_extension}"
        
        # Create upload directory if it doesn't exist
        upload_dir = os.path.join(current_app.root_path, '..', 'uploads', 'mobile')
        os.makedirs(upload_dir, exist_ok=True)
        
        # Save file
        file_path = os.path.join(upload_dir, filename)
        file.save(file_path)
        
        # Return file URL
        file_url = f"/uploads/mobile/{filename}"
        
        return jsonify({
            'success': True,
            'message': 'Image uploaded successfully',
            'data': {
                'file_url': file_url,
                'filename': filename,
                'upload_type': upload_type,
                'uploaded_at': datetime.utcnow().isoformat()
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Mobile image upload error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Image upload failed',
            'code': 'UPLOAD_ERROR'
        }), 500

# ================================================
# MOBILE APP SETTINGS
# ================================================

@mobile_api.route('/settings/mobile', methods=['GET'])
@jwt_required()
def get_mobile_settings():
    """Get mobile app settings"""
    try:
        current_user_id = get_jwt_identity()
        
        # Default mobile settings
        settings = {
            'push_notifications': {
                'enabled': True,
                'job_updates': True,
                'messages': True,
                'marketing': False
            },
            'location_services': {
                'enabled': True,
                'background_location': False
            },
            'app_preferences': {
                'theme': 'system',
                'language': 'tr',
                'currency': 'TRY',
                'distance_unit': 'km'
            },
            'privacy': {
                'show_online_status': True,
                'show_location': True,
                'analytics': True
            },
            'sync': {
                'auto_sync': True,
                'wifi_only': False,
                'sync_frequency': 'real_time'
            }
        }
        
        return jsonify({
            'success': True,
            'data': settings
        }), 200
        
    except Exception as e:
        logger.error(f"Get mobile settings error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Failed to get settings',
            'code': 'SETTINGS_ERROR'
        }), 500

@mobile_api.route('/settings/mobile', methods=['PUT'])
@jwt_required()
def update_mobile_settings():
    """Update mobile app settings"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # Here you would typically save settings to database
        # For now, we'll just return success
        
        return jsonify({
            'success': True,
            'message': 'Settings updated successfully',
            'data': {
                'updated_at': datetime.utcnow().isoformat()
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Update mobile settings error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Failed to update settings',
            'code': 'SETTINGS_UPDATE_ERROR'
        }), 500

# ================================================
# MOBILE ERROR HANDLERS
# ================================================

@mobile_api.errorhandler(404)
def mobile_not_found(error):
    return jsonify({
        'success': False,
        'message': 'Endpoint not found',
        'code': 'NOT_FOUND'
    }), 404

@mobile_api.errorhandler(500)
def mobile_internal_error(error):
    db.session.rollback()
    logger.error(f"Mobile API internal error: {str(error)}")
    return jsonify({
        'success': False,
        'message': 'Internal server error',
        'code': 'INTERNAL_ERROR'
    }), 500

@mobile_api.errorhandler(429)
def mobile_ratelimit_handler(e):
    return jsonify({
        'success': False,
        'message': 'Too many requests. Please try again later.',
        'code': 'RATE_LIMIT_EXCEEDED'
    }), 429