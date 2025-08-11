import pytest
import json
from app.models.quote import Quote, QuoteStatus

class TestQuotes:
    """Test quote request system"""
    
    def test_create_quote_request_success(self, client, test_user, test_craftsman, auth_headers, sample_quote_data):
        """Test successful quote request creation"""
        # Add craftsman_id to the data
        quote_data = sample_quote_data.copy()
        quote_data['craftsman_id'] = test_craftsman.craftsman.id
        
        response = client.post('/api/quotes/create-request',
                             data=json.dumps(quote_data),
                             content_type='application/json',
                             headers=auth_headers)
        
        assert response.status_code == 201
        result = json.loads(response.data)
        assert result['success'] is True
        assert result['data']['quote']['status'] == 'PENDING'
        assert result['data']['quote']['customer_id'] == test_user.customer.id
    
    def test_create_quote_request_unauthorized(self, client, sample_quote_data):
        """Test quote request creation without auth"""
        response = client.post('/api/quotes/create-request',
                             data=json.dumps(sample_quote_data),
                             content_type='application/json')
        
        assert response.status_code == 422  # JWT error
    
    def test_create_quote_request_invalid_data(self, client, auth_headers):
        """Test quote request with invalid data"""
        invalid_data = {
            'category': '',  # Empty category
            'craftsman_id': 999999  # Non-existent craftsman
        }
        
        response = client.post('/api/quotes/create-request',
                             data=json.dumps(invalid_data),
                             content_type='application/json',
                             headers=auth_headers)
        
        assert response.status_code == 400
        result = json.loads(response.data)
        assert result['success'] is False
    
    def test_respond_to_quote_give_quote(self, client, test_user, test_craftsman, craftsman_auth_headers):
        """Test craftsman giving a quote"""
        # First create a quote request
        with client.application.app_context():
            quote = Quote(
                customer_id=test_user.customer.id,
                craftsman_id=test_craftsman.craftsman.id,
                category='Elektrik',
                area_type='salon',
                budget_range='1000-3000',
                description='Test job',
                status=QuoteStatus.PENDING
            )
            from app import db
            db.session.add(quote)
            db.session.commit()
            quote_id = quote.id
        
        response_data = {
            'response_type': 'give_quote',
            'quoted_amount': 2500.0,
            'response_details': 'Detaylı elektrik çalışması',
            'estimated_start_date': '2024-02-01',
            'estimated_end_date': '2024-02-03'
        }
        
        response = client.post(f'/api/quotes/{quote_id}/respond',
                             data=json.dumps(response_data),
                             content_type='application/json',
                             headers=craftsman_auth_headers)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert result['data']['quote']['status'] == 'QUOTED'
        assert result['data']['quote']['quoted_amount'] == 2500.0
    
    def test_respond_to_quote_request_details(self, client, test_user, test_craftsman, craftsman_auth_headers):
        """Test craftsman requesting more details"""
        # First create a quote request
        with client.application.app_context():
            quote = Quote(
                customer_id=test_user.customer.id,
                craftsman_id=test_craftsman.craftsman.id,
                category='Elektrik',
                area_type='salon',
                budget_range='1000-3000',
                description='Test job',
                status=QuoteStatus.PENDING
            )
            from app import db
            db.session.add(quote)
            db.session.commit()
            quote_id = quote.id
        
        response_data = {
            'response_type': 'request_details',
            'response_details': 'Daha fazla detay gerekli'
        }
        
        response = client.post(f'/api/quotes/{quote_id}/respond',
                             data=json.dumps(response_data),
                             content_type='application/json',
                             headers=craftsman_auth_headers)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert result['data']['quote']['status'] == 'DETAILS_REQUESTED'
    
    def test_customer_quote_decision_accept(self, client, test_user, test_craftsman, auth_headers):
        """Test customer accepting a quote"""
        # Create a quoted quote
        with client.application.app_context():
            quote = Quote(
                customer_id=test_user.customer.id,
                craftsman_id=test_craftsman.craftsman.id,
                category='Elektrik',
                area_type='salon',
                budget_range='1000-3000',
                description='Test job',
                status=QuoteStatus.QUOTED,
                quoted_amount=2500.0
            )
            from app import db
            db.session.add(quote)
            db.session.commit()
            quote_id = quote.id
        
        decision_data = {
            'decision': 'accept'
        }
        
        response = client.post(f'/api/quotes/{quote_id}/decision',
                             data=json.dumps(decision_data),
                             content_type='application/json',
                             headers=auth_headers)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert result['data']['quote']['status'] == 'ACCEPTED'
    
    def test_get_my_quotes_customer(self, client, test_user, auth_headers):
        """Test customer getting their quotes"""
        response = client.get('/api/quotes/my-quotes', headers=auth_headers)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert 'quotes' in result['data']
    
    def test_get_budget_ranges(self, client):
        """Test getting budget ranges"""
        response = client.get('/api/quotes/budget-ranges')
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert len(result['data']['budget_ranges']) > 0
    
    def test_get_area_types(self, client):
        """Test getting area types"""
        response = client.get('/api/quotes/area-types')
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert len(result['data']['area_types']) > 0