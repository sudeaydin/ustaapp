from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_socketio import SocketIO
import os

# Initialize extensions
db = SQLAlchemy()
jwt = JWTManager()
socketio = SocketIO()

def create_app(config_name='default'):
    app = Flask(__name__)
    
    # Configuration
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL') or 'sqlite:///app.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-key'
    
    # Initialize extensions with app
    db.init_app(app)
    jwt.init_app(app)
    socketio.init_app(app, cors_allowed_origins=['http://localhost:5173', 'http://localhost:3000', 'http://localhost:3001'])
    
    # CORS ayarları - Frontend ile backend arasında iletişim için
    CORS(app, origins=['http://localhost:5173', 'http://localhost:3000', 'http://localhost:3001'], 
         allow_headers=['Content-Type', 'Authorization'],
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
    
    # Import models
    from app.models import user, craftsman, customer, category, quote, payment, notification, job
    
    # Register new API blueprints
    from app.routes.profile import profile_bp
    from app.routes.messages import messages_bp
    from app.routes.search import search_bp
    from app.routes.payment import payment_bp
    from app.routes.notification import notification_bp
    from app.routes.analytics import analytics_bp
    from app.routes.job import job_bp
    
    app.register_blueprint(profile_bp, url_prefix='/api/profile')
    app.register_blueprint(messages_bp, url_prefix='/api/messages')
    app.register_blueprint(search_bp, url_prefix='/api/search')
    app.register_blueprint(payment_bp, url_prefix='/api/payment')
    app.register_blueprint(notification_bp, url_prefix='/api/notifications')
    app.register_blueprint(analytics_bp, url_prefix='/api/analytics')
    app.register_blueprint(job_bp, url_prefix='/api/jobs')
    
    # Initialize SocketIO events
    from app.socketio_events import init_socketio_events
    init_socketio_events(socketio)
    
    # Basic endpoints
    @app.route('/api/health')
    def health_check():
        return {'status': 'healthy', 'message': 'API is running'}, 200
    
    @app.route('/')
    def index():
        return {'message': 'Ustalar App API', 'status': 'running'}, 200
    
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
            access_token = create_access_token(identity=user.id)
            
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
            access_token = create_access_token(identity=user.id)
            
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
    
    return app
