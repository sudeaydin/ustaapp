from flask import Flask, jsonify, request
from flask_cors import CORS
import sqlite3

app = Flask(__name__)
CORS(app, origins=['http://localhost:5173', 'http://localhost:3000'])

# Health check
@app.route('/api/health')
def health():
    return jsonify({'status': 'healthy', 'message': 'API is running'}), 200

# Get craftsmen
@app.route('/api/craftsmen', methods=['GET'])
def get_craftsmen():
    try:
        # Basit test verisi
        craftsmen = [
            {
                'id': 1,
                'name': 'Ahmet Yılmaz',
                'business_name': 'Yılmaz Elektrik',
                'description': 'Profesyonel elektrik işleri',
                'city': 'İstanbul',
                'district': 'Kadıköy',
                'hourly_rate': '150',
                'average_rating': 4.5,
                'total_reviews': 12,
                'is_available': True
            },
            {
                'id': 2,
                'name': 'Mehmet Demir',
                'business_name': 'Demir Tesisatçılık',
                'description': 'Tesisatçılık ve su kaçağı tamiri',
                'city': 'İstanbul',
                'district': 'Beşiktaş',
                'hourly_rate': '120',
                'average_rating': 4.8,
                'total_reviews': 25,
                'is_available': True
            }
        ]
        
        return jsonify({
            'success': True,
            'data': {
                'craftsmen': craftsmen,
                'pagination': {
                    'page': 1,
                    'pages': 1,
                    'per_page': 10,
                    'total': len(craftsmen)
                }
            }
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Categories endpoint
@app.route('/api/search/categories', methods=['GET'])
def get_categories():
    try:
        categories = [
            {'id': 1, 'name': 'Elektrikçi', 'icon': '⚡', 'color': 'bg-yellow-100'},
            {'id': 2, 'name': 'Tesisatçı', 'icon': '🔧', 'color': 'bg-blue-100'},
            {'id': 3, 'name': 'Boyacı', 'icon': '🎨', 'color': 'bg-green-100'},
            {'id': 4, 'name': 'Temizlik', 'icon': '🧽', 'color': 'bg-purple-100'},
            {'id': 5, 'name': 'Marangoz', 'icon': '🔨', 'color': 'bg-orange-100'},
            {'id': 6, 'name': 'Bahçıvan', 'icon': '🌱', 'color': 'bg-green-100'}
        ]
        return jsonify({'success': True, 'data': categories}), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Popular craftsmen endpoint
@app.route('/api/search/popular', methods=['GET'])
def get_popular():
    try:
        popular_craftsmen = [
            {
                'id': 1,
                'name': 'Ahmet Yılmaz',
                'business_name': 'Yılmaz Elektrik',
                'category': 'Elektrikçi',
                'average_rating': 4.8,
                'total_reviews': 25,
                'city': 'İstanbul'
            },
            {
                'id': 2,
                'name': 'Mehmet Demir',
                'business_name': 'Demir Tesisatçılık',
                'category': 'Tesisatçı',
                'average_rating': 4.9,
                'total_reviews': 32,
                'city': 'İstanbul'
            }
        ]
        return jsonify({
            'success': True, 
            'data': {'top_craftsmen': popular_craftsmen}
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Login endpoint
@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        
        # Basit test login
        if email == 'test@test.com' and password == '123456':
            return jsonify({
                'success': True,
                'message': 'Giriş başarılı',
                'data': {
                    'access_token': 'test-token-123',
                    'user': {
                        'id': 1,
                        'email': email,
                        'first_name': 'Test',
                        'last_name': 'User',
                        'user_type': 'customer'
                    }
                }
            }), 200
        else:
            return jsonify({'success': False, 'message': 'Geçersiz bilgiler'}), 401
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

if __name__ == '__main__':
    print("🚀 Basit backend başlatılıyor...")
    print("📍 URL: http://localhost:5001")
    print("✅ Health check: http://localhost:5001/api/health")
    app.run(host='0.0.0.0', port=5001, debug=True)