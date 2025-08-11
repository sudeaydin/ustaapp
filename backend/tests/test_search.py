import pytest
import json

class TestSearch:
    """Test search functionality"""
    
    def test_search_craftsmen_success(self, client, test_craftsman):
        """Test successful craftsman search"""
        params = {
            'query': 'elektrik',
            'city': 'İstanbul',
            'page': 1,
            'per_page': 10
        }
        
        response = client.get('/api/search/craftsmen', query_string=params)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert 'craftsmen' in result['data']
        assert 'pagination' in result['data']
    
    def test_search_craftsmen_no_results(self, client):
        """Test search with no results"""
        params = {
            'query': 'nonexistentservice',
            'city': 'Nonexistentcity'
        }
        
        response = client.get('/api/search/craftsmen', query_string=params)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert len(result['data']['craftsmen']) == 0
    
    def test_search_craftsmen_pagination(self, client):
        """Test search pagination"""
        params = {
            'page': 1,
            'per_page': 5
        }
        
        response = client.get('/api/search/craftsmen', query_string=params)
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        pagination = result['data']['pagination']
        assert pagination['page'] == 1
        assert pagination['per_page'] == 5
        assert 'total' in pagination
        assert 'pages' in pagination
    
    def test_get_categories_success(self, client):
        """Test getting categories"""
        response = client.get('/api/search/categories')
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert 'categories' in result['data']
        assert len(result['data']['categories']) > 0
    
    def test_get_locations_success(self, client):
        """Test getting locations"""
        response = client.get('/api/search/locations')
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert 'locations' in result['data']
        assert len(result['data']['locations']) > 0
    
    def test_get_craftsman_detail_success(self, client, test_craftsman):
        """Test getting craftsman detail"""
        response = client.get(f'/api/search/craftsmen/{test_craftsman.craftsman.id}')
        
        assert response.status_code == 200
        result = json.loads(response.data)
        assert result['success'] is True
        assert result['data']['craftsman']['business_name'] == test_craftsman.craftsman.business_name
    
    def test_get_craftsman_detail_not_found(self, client):
        """Test getting non-existent craftsman detail"""
        response = client.get('/api/search/craftsmen/999999')
        
        assert response.status_code == 404
        result = json.loads(response.data)
        assert result['success'] is False