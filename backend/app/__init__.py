from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_socketio import SocketIO
import os
import json

# Initialize extensions
db = SQLAlchemy()
jwt = JWTManager()
socketio = SocketIO()

def create_app(config_name='default'):
    # Configure Flask for App Engine (no instance folder)
    if os.environ.get('GAE_ENV', '').startswith('standard'):
        app = Flask(__name__, instance_relative_config=False)
    else:
        app = Flask(__name__)
    
    # Disable strict slashes to prevent redirect issues
    app.url_map.strict_slashes = False
    
    # Configuration
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    
    # Database configuration - App Engine compatible
    if os.environ.get('GAE_ENV', '').startswith('standard'):
        # Production on App Engine - use in-memory SQLite
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    else:
        # Local development
        app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL') or 'sqlite:///app.db'
    
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-key'
    
    # Initialize extensions with app
    db.init_app(app)
    jwt.init_app(app)
    socketio.init_app(app, cors_allowed_origins=['*'])
    
    # CORS ayarları - Frontend ile backend arasında iletişim için
    CORS(app, origins=['*'], 
         allow_headers=['Content-Type', 'Authorization'],
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
         supports_credentials=True)
    
    # Initialize security and analytics middleware
    from app.utils.security import init_security_middleware
    from app.utils.analytics import init_analytics_middleware
    from app.utils.bigquery_logger import init_bigquery_middleware
    from app.middleware.analytics_middleware import analytics_middleware
    
    init_security_middleware(app)
    init_analytics_middleware(app)
    init_bigquery_middleware(app)
    analytics_middleware.init_app(app)
    
    # Import models
    from app.models import user, craftsman, customer, category, quote, payment, notification, job, message, review, support_ticket, appointment
    # Payment model imported but payment routes temporarily disabled
    
    # Register new API blueprints
    from app.routes.profile import profile_bp
    from app.routes.messages import messages_bp
    from app.routes.search import search_bp
    # Payment routes temporarily disabled for security
    # from app.routes.payment import payment_bp
    from app.routes.notification import notification_bp
    from app.routes.analytics_simple import analytics_bp
    from app.routes.job import job_bp
    from app.routes.production_api import production_api
    from app.routes.mobile_api import mobile_api
    from app.routes.quotes import quotes_bp
    from app.routes.notifications import notifications_bp
    from app.routes.quote_request import quote_request_bp
    from app.routes.auth_simple import auth_bp
    from app.routes.seo import seo_bp
    from app.routes.accessibility import accessibility_bp
    from app.routes.legal import legal_bp
    from app.routes.job_management import job_management_bp
    from app.routes.enhanced_notifications import enhanced_notifications_bp
    from app.routes.analytics_dashboard import analytics_dashboard_bp
    from app.routes.support import support_bp
    from app.routes.review import review_bp
    from app.routes.calendar import calendar_bp
    from app.routes.airbnb_api import airbnb_api
    from app.routes.marketplace import marketplace_bp
    from app.routes.cloud_scheduler import scheduler_bp
    # from app.routes.enhanced_analytics import enhanced_analytics_bp
    
    app.register_blueprint(profile_bp, url_prefix='/api/profile')
    app.register_blueprint(messages_bp, url_prefix='/api/messages')
    app.register_blueprint(search_bp, url_prefix='/api/search')
    # Payment blueprint temporarily disabled - online payment system under development
    # app.register_blueprint(payment_bp, url_prefix='/api/payment')
    app.register_blueprint(notification_bp, url_prefix='/api/notification')
    app.register_blueprint(analytics_bp, url_prefix='/api/analytics')
    app.register_blueprint(job_bp, url_prefix='/api/jobs')
    app.register_blueprint(quotes_bp, url_prefix='/api/quotes')
    app.register_blueprint(notifications_bp, url_prefix='/api/notifications')
    app.register_blueprint(quote_request_bp, url_prefix='/api/quote-requests')
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(seo_bp)
    app.register_blueprint(accessibility_bp, url_prefix='/api/accessibility')
    app.register_blueprint(legal_bp, url_prefix='/api/legal')
    app.register_blueprint(job_management_bp, url_prefix='/api/job-management')
    app.register_blueprint(enhanced_notifications_bp, url_prefix='/api/notifications/enhanced')
    app.register_blueprint(analytics_dashboard_bp, url_prefix='/api/analytics-dashboard')
    app.register_blueprint(support_bp, url_prefix='/api/support')
    app.register_blueprint(review_bp, url_prefix='/api/reviews')
    app.register_blueprint(calendar_bp, url_prefix='/api/calendar')
    app.register_blueprint(airbnb_api, url_prefix='/api/airbnb')
    app.register_blueprint(marketplace_bp, url_prefix='/api/marketplace')
    app.register_blueprint(scheduler_bp)  # No prefix - direct /cron/ endpoints
    # app.register_blueprint(enhanced_analytics_bp)  # Enhanced analytics API (temporarily disabled)
    
    # Production and Mobile APIs
    app.register_blueprint(production_api, url_prefix='/api/v2')
    app.register_blueprint(mobile_api, url_prefix='/api/mobile')
    
    # Initialize SocketIO events
    from app.utils.socketio_events import init_socketio_events
    init_socketio_events(socketio)
    
    # Basic endpoints (health_check moved to main.py)
    
    @app.route('/')
    def index():
        return {'message': 'Ustalar App API', 'status': 'running'}, 200
    
    # Static file serving for uploaded images
    @app.route('/uploads/<path:filename>')
    def uploaded_file(filename):
        return send_from_directory('uploads', filename)
    
    # Auth endpoints - Basit login/register
    @app.route('/api/auth/login', methods=['POST'])
    def login():
        from flask import request, jsonify
        from app.models.user import User
        from flask_jwt_extended import create_access_token
        
        try:
            data = request.get_json()
            email = data.get('email')
            password = data.get('password')
            
            if not email or not password:
                return jsonify({'success': False, 'message': 'Email ve şifre gerekli'}), 400
            
            # Find user
            user = User.query.filter_by(email=email).first()
            if not user or not user.check_password(password):
                return jsonify({'success': False, 'message': 'Geçersiz email veya şifre'}), 401
            
            # Create token
            access_token = create_access_token(identity=str(user.id))
            
            return jsonify({
                'success': True,
                'message': 'Giriş başarılı',
                'data': {
                    'access_token': access_token,
                    'user': {
                        'id': user.id,
                        'email': user.email,
                        'first_name': user.first_name,
                        'last_name': user.last_name,
                        'user_type': user.user_type
                    }
                }
            }), 200
            
        except Exception as e:
            return jsonify({'success': False, 'message': 'Bir hata oluştu'}), 500
    
    @app.route('/api/auth/register', methods=['POST'])
    def register():
        from flask import request, jsonify
        from app.models.user import User
        from app.models.customer import Customer
        from app.models.craftsman import Craftsman
        from flask_jwt_extended import create_access_token
        from werkzeug.security import generate_password_hash
        from datetime import datetime
        
        try:
            data = request.get_json()
            
            # Required fields
            required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 'user_type']
            for field in required_fields:
                if not data.get(field):
                    return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
            
            # Check if user exists
            if User.query.filter_by(email=data['email']).first():
                return jsonify({'success': False, 'message': 'Bu email zaten kayıtlı'}), 400
            
            # Create user
            user = User(
                email=data['email'],
                password_hash=generate_password_hash(data['password']),
                first_name=data['first_name'],
                last_name=data['last_name'],
                phone=data['phone'],
                user_type=data['user_type'],
                is_active=True,
                created_at=datetime.now()
            )
            
            db.session.add(user)
            db.session.commit()
            
            # Create profile based on user type
            if data['user_type'] == 'customer':
                profile = Customer(
                    user_id=user.id,
                    address=data.get('address', ''),
                    created_at=datetime.now()
                )
                db.session.add(profile)
            elif data['user_type'] == 'craftsman':
                profile = Craftsman(
                    user_id=user.id,
                    business_name=data.get('business_name', ''),
                    description=data.get('description', ''),
                    city=data.get('city', ''),
                    district=data.get('district', ''),
                    is_available=True,
                    created_at=datetime.now()
                )
                db.session.add(profile)
            
            db.session.commit()
            
            # Create token
            access_token = create_access_token(identity=str(user.id))
            
            return jsonify({
                'success': True,
                'message': 'Kayıt başarılı',
                'data': {
                    'access_token': access_token,
                    'user': {
                        'id': user.id,
                        'email': user.email,
                        'first_name': user.first_name,
                        'last_name': user.last_name,
                        'user_type': user.user_type
                    }
                }
            }), 201
            
        except Exception as e:
            db.session.rollback()
            return jsonify({'success': False, 'message': 'Bir hata oluştu'}), 500
    
    # Profile endpoint is handled by auth blueprint
    # Get all craftsmen endpoint (for CraftsmanListPage)
    @app.route('/api/craftsmen', methods=['GET'])
    def get_craftsmen():
        from app.models.craftsman import Craftsman
        from app.models.user import User
        
        try:
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            
            craftsmen = Craftsman.query.join(User).filter(User.is_active == True).paginate(
                page=page, per_page=per_page, error_out=False
            )
            
            result = []
            for craftsman in craftsmen.items:
                result.append({
                    'id': craftsman.id,
                    'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
                    'business_name': craftsman.business_name,
                    'description': craftsman.description,
                    'city': craftsman.city,
                    'district': craftsman.district,
                    'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                    'average_rating': craftsman.average_rating,
                    'total_reviews': craftsman.total_reviews,
                    'is_available': craftsman.is_available,
                    'user': {
                        'email': craftsman.user.email,
                        'phone': craftsman.user.phone
                    }
                })
            
            return jsonify({
                'success': True,
                'data': {
                    'craftsmen': result,
                    'pagination': {
                        'page': craftsmen.page,
                        'pages': craftsmen.pages,
                        'per_page': craftsmen.per_page,
                        'total': craftsmen.total
                    }
                }
            }), 200
            
        except Exception as e:
            return jsonify({
                'success': False,
                'message': 'Bir hata oluştu'
            }), 500
    
    # Get single craftsman endpoint
    @app.route('/api/craftsmen/<int:craftsman_id>', methods=['GET'])
    def get_craftsman(craftsman_id):
        from app.models.craftsman import Craftsman
        
        try:
            craftsman = Craftsman.query.get(craftsman_id)
            
            if not craftsman:
                return jsonify({
                    'success': False,
                    'message': 'Usta bulunamadı'
                }), 404
            
            result = {
                'id': craftsman.id,
                'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
                'business_name': craftsman.business_name,
                'description': craftsman.description,
                'address': craftsman.address,
                'city': craftsman.city,
                'district': craftsman.district,
                'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                'average_rating': craftsman.average_rating,
                'total_reviews': craftsman.total_reviews,
                'is_available': craftsman.is_available,
                'is_verified': craftsman.is_verified,
                'created_at': craftsman.created_at.isoformat() if craftsman.created_at else None,
                'user': {
                    'email': craftsman.user.email,
                    'phone': craftsman.user.phone
                }
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
    
    # Get craftsman business profile with completed jobs and portfolio
    @app.route('/api/craftsmen/<int:craftsman_id>/business-profile', methods=['GET'])
    def get_craftsman_business_profile(craftsman_id):
        from app.models.craftsman import Craftsman
        from app.models.job import Job, JobStatus
        from app.models.review import Review
        
        try:
            craftsman = Craftsman.query.get(craftsman_id)
            
            if not craftsman:
                return jsonify({
                    'success': False,
                    'message': 'Usta bulunamadı'
                }), 404
            
            # Get completed jobs
            completed_jobs = Job.query.filter_by(
                assigned_craftsman_id=craftsman.id,
                status=JobStatus.COMPLETED.value
            ).order_by(Job.completed_at.desc()).limit(10).all()
            
            # Get reviews
            reviews = Review.query.filter_by(craftsman_id=craftsman.id).order_by(Review.created_at.desc()).limit(10).all()
            
            # Parse portfolio images
            portfolio_images = json.loads(craftsman.portfolio_images) if craftsman.portfolio_images else []
            
            result = {
                'id': craftsman.id,
                'name': f"{craftsman.user.first_name} {craftsman.user.last_name}",
                'business_name': craftsman.business_name,
                'description': craftsman.description,
                'address': craftsman.address,
                'city': craftsman.city,
                'district': craftsman.district,
                'hourly_rate': str(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                'experience_years': craftsman.experience_years,
                'average_rating': craftsman.average_rating,
                'total_reviews': craftsman.total_reviews,
                'is_available': craftsman.is_available,
                'is_verified': craftsman.is_verified,
                'avatar': craftsman.avatar,
                'website': craftsman.website,
                'working_hours': craftsman.working_hours,
                'service_areas': craftsman.service_areas,
                'skills': craftsman.skills,
                'certifications': craftsman.certifications,
                'response_time': craftsman.response_time,
                'portfolio_images': portfolio_images,
                'completed_jobs': [
                    {
                        'id': job.id,
                        'title': job.title,
                        'description': job.description,
                        'category': job.category,
                        'completed_at': job.completed_at.isoformat() if job.completed_at else None,
                        'location': job.location
                    } for job in completed_jobs
                ],
                'recent_reviews': [
                    {
                        'id': review.id,
                        'customer_name': f"{review.customer.user.first_name} {review.customer.user.last_name[0]}." if review.customer and review.customer.user else "Anonim",
                        'rating': review.rating,
                        'comment': review.comment,
                        'created_at': review.created_at.isoformat() if review.created_at else None
                    } for review in reviews
                ],
                'user': {
                    'email': craftsman.user.email,
                    'phone': craftsman.user.phone
                }
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
    
    return app
