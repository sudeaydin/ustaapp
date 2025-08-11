import pytest
import tempfile
import os
from app import create_app, db
from app.models.user import User, UserType
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from flask_jwt_extended import create_access_token

@pytest.fixture
def app():
    """Create application for testing"""
    # Create temporary database
    db_fd, db_path = tempfile.mkstemp()
    
    app = create_app()
    app.config.update({
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': f'sqlite:///{db_path}',
        'SQLALCHEMY_TRACK_MODIFICATIONS': False,
        'JWT_SECRET_KEY': 'test-secret-key',
        'WTF_CSRF_ENABLED': False,
    })
    
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()
    
    os.close(db_fd)
    os.unlink(db_path)

@pytest.fixture
def client(app):
    """Create test client"""
    return app.test_client()

@pytest.fixture
def runner(app):
    """Create test runner"""
    return app.test_cli_runner()

@pytest.fixture
def test_user(app):
    """Create test user"""
    with app.app_context():
        user = User(
            email='test@example.com',
            phone='+905551234567',
            first_name='Test',
            last_name='User',
            user_type=UserType.CUSTOMER,
            is_active=True
        )
        user.set_password('testpassword123')
        db.session.add(user)
        
        customer = Customer(
            user=user,
            billing_address='Test Address',
            city='İstanbul',
            district='Kadıköy'
        )
        db.session.add(customer)
        db.session.commit()
        
        return user

@pytest.fixture
def test_craftsman(app):
    """Create test craftsman"""
    with app.app_context():
        user = User(
            email='craftsman@example.com',
            phone='+905559876543',
            first_name='Ahmet',
            last_name='Usta',
            user_type=UserType.CRAFTSMAN,
            is_active=True
        )
        user.set_password('craftsmanpass123')
        db.session.add(user)
        
        craftsman = Craftsman(
            user=user,
            business_name='Ahmet Elektrik',
            description='Profesyonel elektrik hizmetleri',
            specialties='Elektrik, Aydınlatma',
            experience_years=10,
            hourly_rate=150.0,
            city='İstanbul',
            district='Şişli',
            is_available=True,
            is_verified=True,
            average_rating=4.5,
            total_jobs=25
        )
        db.session.add(craftsman)
        db.session.commit()
        
        return user

@pytest.fixture
def auth_headers(app, test_user):
    """Create authentication headers"""
    with app.app_context():
        access_token = create_access_token(identity=test_user.id)
        return {'Authorization': f'Bearer {access_token}'}

@pytest.fixture
def craftsman_auth_headers(app, test_craftsman):
    """Create craftsman authentication headers"""
    with app.app_context():
        access_token = create_access_token(identity=test_craftsman.id)
        return {'Authorization': f'Bearer {access_token}'}

@pytest.fixture
def sample_quote_data():
    """Sample quote request data"""
    return {
        'category': 'Elektrik',
        'area_type': 'salon',
        'square_meters': 50,
        'budget_range': '1000-3000',
        'description': 'Salon elektrik tesisatı yenilenmesi',
        'additional_details': 'Acil durum'
    }