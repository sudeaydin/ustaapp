"""
Production Configuration
Settings for production deployment
"""

import os
from datetime import timedelta

class ProductionConfig:
    """Production configuration settings"""
    
    # Basic Flask settings
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'your-super-secret-production-key-change-this'
    DEBUG = False
    TESTING = False
    
    # Database settings
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///production.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_timeout': 20,
        'pool_recycle': -1,
        'pool_pre_ping': True
    }
    
    # JWT settings
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-production-secret-key-change-this'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    JWT_BLACKLIST_ENABLED = True
    JWT_BLACKLIST_TOKEN_CHECKS = ['access', 'refresh']
    
    # CORS settings
    CORS_ORIGINS = [
        'https://ustam.com',
        'https://www.ustam.com',
        'https://app.ustam.com',
        'https://admin.ustam.com'
    ]
    
    # File upload settings
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB max file size
    UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf', 'doc', 'docx'}
    
    # Email settings
    MAIL_SERVER = os.environ.get('MAIL_SERVER', 'smtp.gmail.com')
    MAIL_PORT = int(os.environ.get('MAIL_PORT', '587'))
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS', 'true').lower() in ['true', 'on', '1']
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    MAIL_DEFAULT_SENDER = os.environ.get('MAIL_DEFAULT_SENDER', 'noreply@ustam.com')
    
    # SMS settings
    SMS_API_KEY = os.environ.get('SMS_API_KEY')
    SMS_API_SECRET = os.environ.get('SMS_API_SECRET')
    SMS_SENDER = os.environ.get('SMS_SENDER', 'ustam')
    
    # Payment settings
    IYZICO_API_KEY = os.environ.get('IYZICO_API_KEY')
    IYZICO_SECRET_KEY = os.environ.get('IYZICO_SECRET_KEY')
    IYZICO_BASE_URL = os.environ.get('IYZICO_BASE_URL', 'https://api.iyzipay.com')
    PAYMENT_TEST_MODE = os.environ.get('PAYMENT_TEST_MODE', 'false').lower() in ['true', 'on', '1']
    
    # Google Maps settings
    GOOGLE_MAPS_API_KEY = os.environ.get('GOOGLE_MAPS_API_KEY')
    
    # Firebase settings for push notifications
    FIREBASE_SERVER_KEY = os.environ.get('FIREBASE_SERVER_KEY')
    FIREBASE_CREDENTIALS_PATH = os.environ.get('FIREBASE_CREDENTIALS_PATH')
    
    # Redis settings for caching and sessions
    REDIS_URL = os.environ.get('REDIS_URL', 'redis://localhost:6379/0')
    SESSION_TYPE = 'redis'
    SESSION_REDIS = None  # Will be set during app initialization
    SESSION_PERMANENT = False
    SESSION_USE_SIGNER = True
    SESSION_KEY_PREFIX = 'ustam:'
    
    # Celery settings for background tasks
    CELERY_BROKER_URL = os.environ.get('CELERY_BROKER_URL', 'redis://localhost:6379/1')
    CELERY_RESULT_BACKEND = os.environ.get('CELERY_RESULT_BACKEND', 'redis://localhost:6379/2')
    
    # Logging settings
    LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
    LOG_FILE = os.environ.get('LOG_FILE', 'logs/ustam.log')
    
    # Security settings
    WTF_CSRF_ENABLED = True
    WTF_CSRF_TIME_LIMIT = 3600
    BCRYPT_LOG_ROUNDS = 12
    
    # Rate limiting
    RATELIMIT_STORAGE_URL = os.environ.get('REDIS_URL', 'redis://localhost:6379/3')
    RATELIMIT_DEFAULT = "100 per hour"
    RATELIMIT_HEADERS_ENABLED = True
    
    # Application settings
    LANGUAGES = ['tr', 'en']
    BABEL_DEFAULT_LOCALE = 'tr'
    BABEL_DEFAULT_TIMEZONE = 'Europe/Istanbul'
    
    # Platform settings
    PLATFORM_FEE_RATE = float(os.environ.get('PLATFORM_FEE_RATE', '0.05'))  # 5%
    MIN_JOB_PRICE = float(os.environ.get('MIN_JOB_PRICE', '50.00'))
    MAX_JOB_PRICE = float(os.environ.get('MAX_JOB_PRICE', '50000.00'))
    CURRENCY = os.environ.get('CURRENCY', 'TRY')
    
    # Monitoring and analytics
    SENTRY_DSN = os.environ.get('SENTRY_DSN')
    GOOGLE_ANALYTICS_ID = os.environ.get('GOOGLE_ANALYTICS_ID')
    
    @staticmethod
    def init_app(app):
        """Initialize application with production settings"""
        
        # Create upload folder if it doesn't exist
        upload_folder = ProductionConfig.UPLOAD_FOLDER
        if not os.path.exists(upload_folder):
            os.makedirs(upload_folder)
        
        # Set up logging
        import logging
        from logging.handlers import RotatingFileHandler
        
        if not app.debug:
            # Create logs directory
            log_dir = os.path.dirname(ProductionConfig.LOG_FILE)
            if not os.path.exists(log_dir):
                os.makedirs(log_dir)
            
            # Set up file handler
            file_handler = RotatingFileHandler(
                ProductionConfig.LOG_FILE,
                maxBytes=10240000,  # 10MB
                backupCount=10
            )
            file_handler.setFormatter(logging.Formatter(
                '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
            ))
            file_handler.setLevel(getattr(logging, ProductionConfig.LOG_LEVEL))
            app.logger.addHandler(file_handler)
            
            app.logger.setLevel(getattr(logging, ProductionConfig.LOG_LEVEL))
            app.logger.info('ustam application startup')

# Environment variables template for production
PRODUCTION_ENV_TEMPLATE = """
# Production Environment Variables for ustam App
# Copy this to .env file and fill in the actual values

# Basic Settings
SECRET_KEY=your-super-secret-production-key-change-this
JWT_SECRET_KEY=jwt-production-secret-key-change-this
DEBUG=False

# Database
DATABASE_URL=sqlite:///production.db
# For PostgreSQL: postgresql://username:password@localhost/ustam_production
# For MySQL: mysql://username:password@localhost/ustam_production

# Email Configuration
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_DEFAULT_SENDER=noreply@ustam.com

# SMS Configuration
SMS_API_KEY=your-sms-api-key
SMS_API_SECRET=your-sms-api-secret
SMS_SENDER=ustam

# Payment Gateway (Iyzico)
IYZICO_API_KEY=your-iyzico-api-key
IYZICO_SECRET_KEY=your-iyzico-secret-key
IYZICO_BASE_URL=https://api.iyzipay.com
PAYMENT_TEST_MODE=False

# Google Services
GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# Firebase (Push Notifications)
FIREBASE_SERVER_KEY=your-firebase-server-key
FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json

# Redis (Optional - for caching and sessions)
REDIS_URL=redis://localhost:6379/0

# Celery (Optional - for background tasks)
CELERY_BROKER_URL=redis://localhost:6379/1
CELERY_RESULT_BACKEND=redis://localhost:6379/2

# Monitoring (Optional)
SENTRY_DSN=your-sentry-dsn
GOOGLE_ANALYTICS_ID=your-ga-id

# Platform Settings
PLATFORM_FEE_RATE=0.05
MIN_JOB_PRICE=50.00
MAX_JOB_PRICE=50000.00
CURRENCY=TRY

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/ustam.log
"""