from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_marshmallow import Marshmallow
from config.config import config

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
ma = Marshmallow()

def create_app(config_name='default'):
    """Application factory pattern"""
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(config[config_name])
    
    # Initialize extensions with app
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    ma.init_app(app)
    
    # Configure CORS
    CORS(app, resources={
        r"/api/*": {
            "origins": ["http://localhost:3000", "http://localhost:3001"],
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })
    
    # Import models (for migration discovery)
    from app.models import user, craftsman, customer, category, service, quote, message, review
    
    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.craftsman import craftsman_bp
    from app.routes.customer import customer_bp
    from app.routes.service import service_bp
    from app.routes.quote import quote_bp
    from app.routes.message import message_bp
    from app.routes.review import review_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(craftsman_bp, url_prefix='/api/craftsman')
    app.register_blueprint(customer_bp, url_prefix='/api/customer')
    app.register_blueprint(service_bp, url_prefix='/api/services')
    app.register_blueprint(quote_bp, url_prefix='/api/quotes')
    app.register_blueprint(message_bp, url_prefix='/api/messages')
    app.register_blueprint(review_bp, url_prefix='/api/reviews')
    
    # Health check endpoint
    @app.route('/api/health')
    def health_check():
        return {'status': 'ok', 'message': 'Ustalar API is running'}
    
    return app
