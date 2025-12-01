from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_socketio import SocketIO
import os
import json

from config.config import config as app_config

# Initialize extensions
db = SQLAlchemy(session_options={'expire_on_commit': False})
jwt = JWTManager()
socketio = SocketIO()

def create_app(config_name='default'):
    gae_env = os.environ.get('GAE_ENV', '').startswith('standard')
    inferred_config = 'production' if gae_env else 'default'
    config_name = config_name or os.environ.get('FLASK_CONFIG') or os.environ.get('APP_ENV') or inferred_config

    # Configure Flask for App Engine (no instance folder)
    if gae_env:
        app = Flask(__name__, instance_relative_config=False)
    else:
        app = Flask(__name__)

    # Disable strict slashes to prevent redirect issues
    app.url_map.strict_slashes = False

    configuration = app_config.get(config_name, app_config['default'])
    app.config.from_object(configuration)
    app.config['ACTIVE_CONFIG_NAME'] = config_name

    # Initialize extensions with app
    db.init_app(app)
    jwt.init_app(app)

    @jwt.unauthorized_loader
    def _missing_jwt_callback(error):
        return jsonify({'success': False, 'message': error}), 422

    @jwt.invalid_token_loader
    def _invalid_token_callback(error):
        return jsonify({'success': False, 'message': error}), 422

    @jwt.user_identity_loader
    def _user_identity_lookup(identity):
        return str(identity) if identity is not None else identity
    cors_origins = app.config.get('CORS_ALLOWED_ORIGINS') or app.config.get('CORS_ORIGINS') or ['*']
    if isinstance(cors_origins, str):
        cors_origins = [origin.strip() for origin in cors_origins.split(',') if origin.strip()]
    if not cors_origins:
        cors_origins = ['*']
    socketio.init_app(app, cors_allowed_origins=cors_origins)

    # CORS ayarları - Frontend ile backend arasında iletişim için
    CORS(app, origins=cors_origins,
         allow_headers=['Content-Type', 'Authorization'],
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
         supports_credentials=True)
    
    # Initialize security and analytics middleware
    from app.utils.security import init_security_middleware, rate_limit
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
    from app.routes.craftsman_simple import craftsman_bp as craftsman_public_bp
    from app.routes.production_api import production_api
    from app.routes.mobile_api import mobile_api
    from app.routes.quotes import quotes_bp
    from app.routes.notifications import notifications_bp
    from app.routes.quote_request import quote_request_bp
    from app.routes.auth import auth_bp
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
    app.register_blueprint(craftsman_public_bp, url_prefix='/api/craftsmen')
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

    # Prevent middleware noise on missing favicon requests
    @app.route('/favicon.ico')
    def favicon():
        return '', 204
    
    # Static file serving for uploaded images
    @app.route('/uploads/<path:filename>')
    def uploaded_file(filename):
        return send_from_directory('uploads', filename)
    
    return app
