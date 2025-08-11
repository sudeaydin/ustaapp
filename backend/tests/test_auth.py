import pytest
import json
from app.models.user import User, UserType

class TestAuth:
    """Test authentication endpoints"""
    
    def test_register_customer_success(self, client):
        """Test successful customer registration"""
        data = {
            'email': 'newuser@test.com',
            'phone': '+905551111111',
            'password': 'securepass123',
            'first_name': 'Yeni',
            'last_name': 'Kullanıcı',
            'user_type': 'customer',
            'billing_address': 'Test Adres',
            'city': 'İstanbul',
            'district': 'Beşiktaş'
        }
        
        response = client.post('/api/auth/register', 
                             data=json.dumps(data),
                             content_type='application/json')
        
        assert response.status_code == 201
        result = json.loads(response.data)
        assert result['success'] is True
        assert 'access_token' in result['data']
        assert result['data']['user']['email'] == data['email']
    
    def test_register_craftsman_success(self, client):
        """Test successful craftsman registration"""
        data = {
            'email': 'newcraftsman@test.com',
            'phone': '+905552222222',
            'password': 'securepass123',
            'first_name': 'Yeni',
            'last_name': 'Usta',
            'user_type': 'craftsman',
            'business_name': 'Yeni Usta İşleri',
            'description': 'Kaliteli hizmet',
            'specialties': 'Boyacılık',
            'experience_years': 5,
            'hourly_rate': 120.0,
            'city': 'Ankara',
            'district': 'Çankaya'
        }
        
        response = client.post('/api/auth/register', 
                             data=json.dumps(data),
                             content_type='application/json')
        
        assert response.status_code == 201
        result = json.loads(response.data)
        assert result['success'] is True
        assert 'access_token' in result['data']
    
    def test_register_duplicate_email(self, client, test_user):
        """Test registration with duplicate email"""
        data = {
            'email': test_user.email,
            'phone': '+905553333333',
            'password': 'securepass123',
            'first_name': 'Duplicate',
            'last_name': 'User',
            'user_type': 'customer'
        }
        
        response = client.post('/api/auth/register', 
                             data=json.dumps(data),
                             content_type='application/json')
        
        assert response.status_code == 400
        result = json.loads(response.data)
        assert result['success'] is False
        assert 'email' in result['message'].lower()
    
    def test_login_success(self, client, test_user):
        """Test successful login"""
        data = {
            'email': test_user.email,
            'password': 'testpassword123'
        }
        
        response = client.post('/api/auth/login', 
                             data=json.dumps(data),
                             content_type='application/json')
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert 'access_token' in result['data']
        assert result['data']['user']['email'] == test_user.email
    
    def test_login_wrong_password(self, client, test_user):
        """Test login with wrong password"""
        data = {
            'email': test_user.email,
            'password': 'wrongpassword'
        }
        
        response = client.post('/api/auth/login', 
                             data=json.dumps(data),
                             content_type='application/json')
        
        assert response.status_code == 401
        result = json.loads(response.data)
        assert result['success'] is False
    
    def test_login_nonexistent_user(self, client):
        """Test login with non-existent user"""
        data = {
            'email': 'nonexistent@test.com',
            'password': 'somepassword'
        }
        
        response = client.post('/api/auth/login', 
                             data=json.dumps(data),
                             content_type='application/json')
        
        assert response.status_code == 401
        result = json.loads(response.data)
        assert result['success'] is False
    
    def test_get_profile_success(self, client, test_user, auth_headers):
        """Test successful profile retrieval"""
        response = client.get('/api/auth/profile', headers=auth_headers)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert result['data']['user']['email'] == test_user.email
    
    def test_get_profile_unauthorized(self, client):
        """Test profile retrieval without auth"""
        response = client.get('/api/auth/profile')
        
        assert response.status_code == 422  # JWT error
    
    def test_delete_account_success(self, client, test_user, auth_headers):
        """Test successful account deletion"""
        response = client.delete('/api/auth/delete-account', headers=auth_headers)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        
        # Verify user is deleted
        user = User.query.get(test_user.id)
        assert user is None