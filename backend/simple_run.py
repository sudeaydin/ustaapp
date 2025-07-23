from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from flask_socketio import SocketIO, emit, join_room, leave_room
import os
from werkzeug.utils import secure_filename
import uuid
from datetime import datetime
import sqlite3

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'
CORS(app, origins=['http://localhost:3000', 'http://localhost:5173'])

# Initialize SocketIO
socketio = SocketIO(app, cors_allowed_origins=['http://localhost:3000', 'http://localhost:5173'])

# Store active users and their rooms
active_users = {}
user_rooms = {}

# File upload configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

# Create upload directory if it doesn't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(os.path.join(UPLOAD_FOLDER, 'profiles'), exist_ok=True)
os.makedirs(os.path.join(UPLOAD_FOLDER, 'projects'), exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

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

# Register endpoint
@app.route('/api/auth/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        
        # Required fields validation
        required_fields = ['email', 'password', 'first_name', 'last_name', 'phone', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
        
        # Email validation
        email = data.get('email')
        if '@' not in email or '.' not in email:
            return jsonify({'success': False, 'message': 'Geçerli bir email adresi girin'}), 400
        
        # Password validation
        password = data.get('password')
        if len(password) < 6:
            return jsonify({'success': False, 'message': 'Şifre en az 6 karakter olmalıdır'}), 400
        
        # User type validation
        user_type = data.get('user_type')
        if user_type not in ['customer', 'craftsman']:
            return jsonify({'success': False, 'message': 'Kullanıcı tipi customer veya craftsman olmalıdır'}), 400
        
        # Mock user creation (normally would save to database)
        user_id = 100 + hash(email) % 1000  # Simple ID generation
        
        # Create mock user data
        user_data = {
            'id': user_id,
            'email': email,
            'first_name': data.get('first_name'),
            'last_name': data.get('last_name'),
            'phone': data.get('phone'),
            'user_type': user_type,
            'created_at': '2025-01-23T10:30:00Z'
        }
        
        # Generate access token
        access_token = f'token_{user_id}_{hash(email)}'
        
        return jsonify({
            'success': True,
            'message': 'Kayıt başarılı! Hoş geldiniz!',
            'data': {
                'access_token': access_token,
                'user': user_data
            }
        }), 201
        
    except Exception as e:
        return jsonify({'success': False, 'message': f'Kayıt sırasında hata: {str(e)}'}), 500

# Login endpoint
@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        
        # Test kullanıcıları
        test_users = {
            'customer@test.com': {
                'id': 1,
                'password': '123456',
                'first_name': 'Ahmet',
                'last_name': 'Müşteri',
                'user_type': 'customer'
            },
            'craftsman@test.com': {
                'id': 2,
                'password': '123456',
                'first_name': 'Mehmet',
                'last_name': 'Usta',
                'user_type': 'craftsman'
            },
            'test@test.com': {
                'id': 3,
                'password': '123456',
                'first_name': 'Test',
                'last_name': 'User',
                'user_type': 'customer'
            }
        }
        
        # Test login
        if email in test_users and test_users[email]['password'] == password:
            user = test_users[email]
            return jsonify({
                'success': True,
                'message': 'Giriş başarılı',
                'data': {
                    'access_token': f'test-token-{user["id"]}',
                    'user': {
                        'id': user['id'],
                        'email': email,
                        'first_name': user['first_name'],
                        'last_name': user['last_name'],
                        'user_type': user['user_type']
                    }
                }
            }), 200
        else:
            return jsonify({'success': False, 'message': 'Geçersiz bilgiler'}), 401
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Message endpoints
@app.route('/api/messages', methods=['GET'])
def get_messages():
    try:
        # Mock conversation data
        messages = [
            {
                'id': 1,
                'sender_id': 1,
                'sender_name': 'Ahmet Yılmaz',
                'sender_type': 'craftsman',
                'receiver_id': 2,
                'receiver_name': 'Müşteri',
                'receiver_type': 'customer',
                'message': 'Merhaba, elektrik işiniz için yardımcı olabilirim.',
                'timestamp': '2025-01-23T10:30:00Z',
                'is_read': False
            },
            {
                'id': 2,
                'sender_id': 2,
                'sender_name': 'Müşteri',
                'sender_type': 'customer',
                'receiver_id': 1,
                'receiver_name': 'Ahmet Yılmaz',
                'receiver_type': 'craftsman',
                'message': 'Merhaba, evimde elektrik sorunu var. Ne zaman müsaitsiniz?',
                'timestamp': '2025-01-23T10:35:00Z',
                'is_read': True
            },
            {
                'id': 3,
                'sender_id': 1,
                'sender_name': 'Ahmet Yılmaz',
                'sender_type': 'craftsman',
                'receiver_id': 2,
                'receiver_name': 'Müşteri',
                'receiver_type': 'customer',
                'message': 'Yarın sabah 09:00\'da müsait miyim?',
                'timestamp': '2025-01-23T10:40:00Z',
                'is_read': False
            }
        ]
        
        return jsonify({
            'success': True,
            'data': {'messages': messages}
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/messages/send', methods=['POST'])
def send_message():
    try:
        data = request.get_json()
        
        # Required fields
        required_fields = ['receiver_id', 'message']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
        
        # Mock message creation
        new_message = {
            'id': 100 + hash(data.get('message')) % 1000,
            'sender_id': data.get('sender_id', 1),
            'sender_name': 'Gönderen',
            'sender_type': 'customer',
            'receiver_id': data.get('receiver_id'),
            'receiver_name': 'Alıcı',
            'receiver_type': 'craftsman',
            'message': data.get('message'),
            'timestamp': '2025-01-23T10:45:00Z',
            'is_read': False
        }
        
        return jsonify({
            'success': True,
            'message': 'Mesaj gönderildi',
            'data': new_message
        }), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/messages/conversations', methods=['GET'])
def get_conversations():
    try:
        # Mock conversations data
        conversations = [
            {
                'id': 1,
                'other_user': {
                    'id': 1,
                    'name': 'Ahmet Yılmaz',
                    'user_type': 'craftsman',
                    'business_name': 'Yılmaz Elektrik'
                },
                'last_message': {
                    'message': 'Yarın sabah 09:00\'da müsait miyim?',
                    'timestamp': '2025-01-23T10:40:00Z',
                    'is_read': False
                },
                'unread_count': 2
            },
            {
                'id': 2,
                'other_user': {
                    'id': 2,
                    'name': 'Mehmet Demir',
                    'user_type': 'craftsman',
                    'business_name': 'Demir Tesisatçılık'
                },
                'last_message': {
                    'message': 'Teklifi hazırladım, inceleyebilirsiniz.',
                    'timestamp': '2025-01-23T09:30:00Z',
                    'is_read': True
                },
                'unread_count': 0
            }
        ]
        
        return jsonify({
            'success': True,
            'data': {'conversations': conversations}
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/messages/unread-count', methods=['GET'])
def get_unread_count():
    try:
        # Mock unread count
        unread_count = 3
        
        return jsonify({
            'success': True,
            'data': {'unread_count': unread_count}
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Quote endpoints
@app.route('/api/quotes', methods=['GET'])
def get_quotes():
    try:
        # Mock quotes data
        quotes = [
            {
                'id': 1,
                'customer_id': 2,
                'customer_name': 'Müşteri',
                'craftsman_id': 1,
                'craftsman_name': 'Ahmet Yılmaz',
                'craftsman_business': 'Yılmaz Elektrik',
                'service_category': 'Elektrikçi',
                'title': 'Ev elektrik tesisatı',
                'description': 'Evimde elektrik tesisatı yenilenmesi gerekiyor. 3+1 daire, yaklaşık 120m2.',
                'location': 'İstanbul, Kadıköy',
                'budget_min': 2000,
                'budget_max': 3500,
                'status': 'pending',
                'created_at': '2025-01-23T10:00:00Z',
                'deadline': '2025-01-30T00:00:00Z'
            },
            {
                'id': 2,
                'customer_id': 3,
                'customer_name': 'Ali Veli',
                'craftsman_id': 1,
                'craftsman_name': 'Ahmet Yılmaz',
                'craftsman_business': 'Yılmaz Elektrik',
                'service_category': 'Elektrikçi',
                'title': 'Ofis aydınlatma',
                'description': 'Ofiste LED aydınlatma sistemi kurulumu.',
                'location': 'İstanbul, Beşiktaş',
                'budget_min': 1500,
                'budget_max': 2500,
                'status': 'quoted',
                'created_at': '2025-01-22T14:30:00Z',
                'deadline': '2025-01-28T00:00:00Z',
                'quote_price': 2000,
                'quote_description': 'LED panel ve spot aydınlatma kurulumu, malzeme dahil.',
                'quoted_at': '2025-01-22T16:00:00Z'
            }
        ]
        
        return jsonify({
            'success': True,
            'data': {'quotes': quotes}
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/quotes/request', methods=['POST'])
def request_quote():
    try:
        data = request.get_json()
        
        # Required fields
        required_fields = ['craftsman_id', 'title', 'description', 'location']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
        
        # Mock quote request creation
        new_quote = {
            'id': 100 + hash(data.get('title')) % 1000,
            'customer_id': data.get('customer_id', 2),
            'customer_name': 'Müşteri',
            'craftsman_id': data.get('craftsman_id'),
            'craftsman_name': 'Usta',
            'craftsman_business': 'İşletme',
            'service_category': data.get('service_category', 'Genel'),
            'title': data.get('title'),
            'description': data.get('description'),
            'location': data.get('location'),
            'budget_min': data.get('budget_min'),
            'budget_max': data.get('budget_max'),
            'status': 'pending',
            'created_at': '2025-01-23T10:45:00Z',
            'deadline': data.get('deadline', '2025-01-30T00:00:00Z')
        }
        
        return jsonify({
            'success': True,
            'message': 'Teklif talebi başarıyla gönderildi',
            'data': new_quote
        }), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/quotes/<int:quote_id>/respond', methods=['POST'])
def respond_to_quote(quote_id):
    try:
        data = request.get_json()
        
        # Required fields
        required_fields = ['quote_price', 'quote_description']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
        
        # Validate price
        try:
            price = float(data.get('quote_price'))
            if price <= 0:
                return jsonify({'success': False, 'message': 'Fiyat 0\'dan büyük olmalıdır'}), 400
        except (ValueError, TypeError):
            return jsonify({'success': False, 'message': 'Geçerli bir fiyat girin'}), 400
        
        # Mock quote response
        quote_response = {
            'id': quote_id,
            'status': 'quoted',
            'quote_price': price,
            'quote_description': data.get('quote_description'),
            'quoted_at': '2025-01-23T10:50:00Z',
            'estimated_duration': data.get('estimated_duration'),
            'materials_included': data.get('materials_included', True)
        }
        
        return jsonify({
            'success': True,
            'message': 'Teklif başarıyla gönderildi',
            'data': quote_response
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/quotes/<int:quote_id>/accept', methods=['POST'])
def accept_quote(quote_id):
    try:
        # Mock quote acceptance
        accepted_quote = {
            'id': quote_id,
            'status': 'accepted',
            'accepted_at': '2025-01-23T11:00:00Z',
            'message': 'Teklif kabul edildi! Usta ile iletişime geçebilirsiniz.'
        }
        
        return jsonify({
            'success': True,
            'message': 'Teklif kabul edildi',
            'data': accepted_quote
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/quotes/<int:quote_id>/reject', methods=['POST'])
def reject_quote(quote_id):
    try:
        data = request.get_json()
        
        # Mock quote rejection
        rejected_quote = {
            'id': quote_id,
            'status': 'rejected',
            'rejected_at': '2025-01-23T11:00:00Z',
            'rejection_reason': data.get('reason', 'Müşteri teklifi reddetti')
        }
        
        return jsonify({
            'success': True,
            'message': 'Teklif reddedildi',
            'data': rejected_quote
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# File upload endpoints
@app.route('/api/upload/profile', methods=['POST'])
def upload_profile_image():
    try:
        if 'file' not in request.files:
            return jsonify({'success': False, 'message': 'Dosya seçilmedi'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'success': False, 'message': 'Dosya seçilmedi'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'success': False, 'message': 'Geçersiz dosya formatı. PNG, JPG, JPEG, GIF, WEBP desteklenir'}), 400
        
        # Generate unique filename
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4()}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], 'profiles', unique_filename)
        
        # Save file
        file.save(filepath)
        
        # Generate URL
        file_url = f"/api/uploads/profiles/{unique_filename}"
        
        return jsonify({
            'success': True,
            'message': 'Profil fotoğrafı başarıyla yüklendi',
            'data': {
                'filename': unique_filename,
                'url': file_url,
                'uploaded_at': datetime.now().isoformat()
            }
        }), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/upload/project', methods=['POST'])
def upload_project_image():
    try:
        if 'file' not in request.files:
            return jsonify({'success': False, 'message': 'Dosya seçilmedi'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'success': False, 'message': 'Dosya seçilmedi'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'success': False, 'message': 'Geçersiz dosya formatı. PNG, JPG, JPEG, GIF, WEBP desteklenir'}), 400
        
        # Generate unique filename
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4()}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], 'projects', unique_filename)
        
        # Save file
        file.save(filepath)
        
        # Generate URL
        file_url = f"/api/uploads/projects/{unique_filename}"
        
        return jsonify({
            'success': True,
            'message': 'Proje fotoğrafı başarıyla yüklendi',
            'data': {
                'filename': unique_filename,
                'url': file_url,
                'uploaded_at': datetime.now().isoformat()
            }
        }), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/uploads/<folder>/<filename>')
def serve_uploaded_file(folder, filename):
    try:
        if folder not in ['profiles', 'projects']:
            return jsonify({'success': False, 'message': 'Geçersiz klasör'}), 404
        
        return send_from_directory(
            os.path.join(app.config['UPLOAD_FOLDER'], folder), 
            filename
        )
    except Exception as e:
        return jsonify({'success': False, 'message': 'Dosya bulunamadı'}), 404

@app.route('/api/upload/multiple', methods=['POST'])
def upload_multiple_images():
    try:
        if 'files' not in request.files:
            return jsonify({'success': False, 'message': 'Dosya seçilmedi'}), 400
        
        files = request.files.getlist('files')
        upload_type = request.form.get('type', 'project')  # 'profile' or 'project'
        
        if not files or all(f.filename == '' for f in files):
            return jsonify({'success': False, 'message': 'Dosya seçilmedi'}), 400
        
        uploaded_files = []
        errors = []
        
        for file in files:
            if file.filename == '':
                continue
                
            if not allowed_file(file.filename):
                errors.append(f"{file.filename}: Geçersiz dosya formatı")
                continue
            
            try:
                # Generate unique filename
                filename = secure_filename(file.filename)
                unique_filename = f"{uuid.uuid4()}_{filename}"
                folder = 'profiles' if upload_type == 'profile' else 'projects'
                filepath = os.path.join(app.config['UPLOAD_FOLDER'], folder, unique_filename)
                
                # Save file
                file.save(filepath)
                
                # Generate URL
                file_url = f"/api/uploads/{folder}/{unique_filename}"
                
                uploaded_files.append({
                    'original_name': filename,
                    'filename': unique_filename,
                    'url': file_url,
                    'uploaded_at': datetime.now().isoformat()
                })
            except Exception as e:
                errors.append(f"{file.filename}: {str(e)}")
        
        return jsonify({
            'success': True,
            'message': f'{len(uploaded_files)} dosya başarıyla yüklendi',
            'data': {
                'uploaded_files': uploaded_files,
                'errors': errors
            }
        }), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Profile management endpoints
@app.route('/api/profile', methods=['GET'])
def get_profile():
    try:
        # Mock user profile data
        profile = {
            'id': 1,
            'username': 'test_user',
            'email': 'test@example.com',
            'first_name': 'Test',
            'last_name': 'User',
            'phone': '+90 555 123 4567',
            'address': 'Test Mahallesi, Test Sokak No:1',
            'city': 'İstanbul',
            'district': 'Kadıköy',
            'profile_image': '/api/uploads/profiles/default_profile.png',
            'user_type': 'customer', # 'customer' or 'craftsman'
            'created_at': '2025-01-01T00:00:00Z',
            'updated_at': '2025-01-23T10:00:00Z',
            # Craftsman specific fields
            'business_name': 'Test İşletmesi',
            'description': 'Profesyonel hizmet veren deneyimli usta',
            'category': 'Elektrikçi',
            'hourly_rate': 150,
            'experience_years': 5,
            'is_available': True,
            'rating': 4.8,
            'total_jobs': 127,
            'skills': ['Elektrik tesisatı', 'LED aydınlatma', 'Pano montajı'],
            'certifications': ['Elektrik Ustalık Belgesi', 'İSG Sertifikası'],
            'work_areas': ['İstanbul', 'Kadıköy', 'Üsküdar', 'Beşiktaş']
        }
        
        return jsonify({
            'success': True,
            'data': profile
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/profile', methods=['PUT'])
def update_profile():
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data:
            return jsonify({'success': False, 'message': 'Veri gönderilmedi'}), 400
        
        # Mock profile update
        updated_profile = {
            'id': 1,
            'username': data.get('username', 'test_user'),
            'email': data.get('email', 'test@example.com'),
            'first_name': data.get('first_name', 'Test'),
            'last_name': data.get('last_name', 'User'),
            'phone': data.get('phone', '+90 555 123 4567'),
            'address': data.get('address', ''),
            'city': data.get('city', ''),
            'district': data.get('district', ''),
            'profile_image': data.get('profile_image', '/api/uploads/profiles/default_profile.png'),
            'user_type': data.get('user_type', 'customer'),
            'updated_at': '2025-01-23T11:00:00Z',
            # Craftsman fields
            'business_name': data.get('business_name', ''),
            'description': data.get('description', ''),
            'category': data.get('category', ''),
            'hourly_rate': data.get('hourly_rate', 0),
            'experience_years': data.get('experience_years', 0),
            'is_available': data.get('is_available', True),
            'skills': data.get('skills', []),
            'certifications': data.get('certifications', []),
            'work_areas': data.get('work_areas', [])
        }
        
        return jsonify({
            'success': True,
            'message': 'Profil başarıyla güncellendi',
            'data': updated_profile
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/profile/password', methods=['PUT'])
def change_password():
    try:
        data = request.get_json()
        
        # Required fields
        required_fields = ['current_password', 'new_password']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} alanı zorunludur'}), 400
        
        current_password = data.get('current_password')
        new_password = data.get('new_password')
        confirm_password = data.get('confirm_password')
        
        # Validate current password (mock)
        if current_password != 'test123':
            return jsonify({'success': False, 'message': 'Mevcut şifre yanlış'}), 400
        
        # Validate new password
        if len(new_password) < 6:
            return jsonify({'success': False, 'message': 'Yeni şifre en az 6 karakter olmalıdır'}), 400
        
        # Validate password confirmation
        if confirm_password and new_password != confirm_password:
            return jsonify({'success': False, 'message': 'Şifreler eşleşmiyor'}), 400
        
        # Mock password change
        return jsonify({
            'success': True,
            'message': 'Şifre başarıyla değiştirildi'
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/profile/avatar', methods=['PUT'])
def update_avatar():
    try:
        data = request.get_json()
        
        if not data.get('profile_image'):
            return jsonify({'success': False, 'message': 'Profil fotoğrafı URL\'si gerekli'}), 400
        
        # Mock avatar update
        updated_profile = {
            'id': 1,
            'profile_image': data.get('profile_image'),
            'updated_at': '2025-01-23T11:00:00Z'
        }
        
        return jsonify({
            'success': True,
            'message': 'Profil fotoğrafı başarıyla güncellendi',
            'data': updated_profile
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/profile/skills', methods=['PUT'])
def update_skills():
    try:
        data = request.get_json()
        
        skills = data.get('skills', [])
        if not isinstance(skills, list):
            return jsonify({'success': False, 'message': 'Yetenekler liste formatında olmalıdır'}), 400
        
        # Mock skills update
        return jsonify({
            'success': True,
            'message': 'Yetenekler başarıyla güncellendi',
            'data': {
                'skills': skills,
                'updated_at': '2025-01-23T11:00:00Z'
            }
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/profile/availability', methods=['PUT'])
def update_availability():
    try:
        data = request.get_json()
        
        is_available = data.get('is_available')
        if is_available is None:
            return jsonify({'success': False, 'message': 'Müsaitlik durumu belirtilmedi'}), 400
        
        # Mock availability update
        return jsonify({
            'success': True,
            'message': f'Müsaitlik durumu {"açık" if is_available else "kapalı"} olarak güncellendi',
            'data': {
                'is_available': is_available,
                'updated_at': '2025-01-23T11:00:00Z'
            }
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# Socket.IO Event Handlers
@socketio.on('connect')
def handle_connect():
    print(f'Client connected: {request.sid}')
    emit('connected', {'message': 'Successfully connected to chat server'})

@socketio.on('disconnect')
def handle_disconnect():
    print(f'Client disconnected: {request.sid}')
    # Remove user from active users
    user_id = None
    for uid, sid in active_users.items():
        if sid == request.sid:
            user_id = uid
            break
    
    if user_id:
        del active_users[user_id]
        if user_id in user_rooms:
            del user_rooms[user_id]
        
        # Notify other users that this user went offline
        emit('user_offline', {'user_id': user_id}, broadcast=True)

@socketio.on('join_chat')
def handle_join_chat(data):
    try:
        user_id = data.get('user_id')
        username = data.get('username', f'User{user_id}')
        
        if not user_id:
            emit('error', {'message': 'User ID is required'})
            return
        
        # Store user info
        active_users[user_id] = request.sid
        
        print(f'User {username} (ID: {user_id}) joined chat')
        
        # Notify user of successful join
        emit('joined_chat', {
            'user_id': user_id,
            'username': username,
            'message': 'Successfully joined chat'
        })
        
        # Notify other users that this user is online
        emit('user_online', {
            'user_id': user_id,
            'username': username
        }, broadcast=True, include_self=False)
        
    except Exception as e:
        print(f'Join chat error: {e}')
        emit('error', {'message': 'Failed to join chat'})

@socketio.on('join_conversation')
def handle_join_conversation(data):
    try:
        user_id = data.get('user_id')
        partner_id = data.get('partner_id')
        
        if not user_id or not partner_id:
            emit('error', {'message': 'User ID and Partner ID are required'})
            return
        
        # Create room name (consistent for both users)
        room_name = f"chat_{min(user_id, partner_id)}_{max(user_id, partner_id)}"
        
        # Join the room
        join_room(room_name)
        
        # Store user's current room
        user_rooms[user_id] = room_name
        
        print(f'User {user_id} joined conversation room: {room_name}')
        
        emit('joined_conversation', {
            'room': room_name,
            'partner_id': partner_id,
            'message': 'Joined conversation'
        })
        
    except Exception as e:
        print(f'Join conversation error: {e}')
        emit('error', {'message': 'Failed to join conversation'})

@socketio.on('leave_conversation')
def handle_leave_conversation(data):
    try:
        user_id = data.get('user_id')
        
        if user_id in user_rooms:
            room_name = user_rooms[user_id]
            leave_room(room_name)
            del user_rooms[user_id]
            
            print(f'User {user_id} left conversation room: {room_name}')
            
            emit('left_conversation', {
                'room': room_name,
                'message': 'Left conversation'
            })
        
    except Exception as e:
        print(f'Leave conversation error: {e}')
        emit('error', {'message': 'Failed to leave conversation'})

@socketio.on('send_message')
def handle_send_message(data):
    try:
        user_id = data.get('user_id')
        partner_id = data.get('partner_id')
        message = data.get('message')
        username = data.get('username', f'User{user_id}')
        
        if not all([user_id, partner_id, message]):
            emit('error', {'message': 'User ID, Partner ID, and message are required'})
            return
        
        # Create room name
        room_name = f"chat_{min(user_id, partner_id)}_{max(user_id, partner_id)}"
        
        # Create message object
        message_data = {
            'id': str(uuid.uuid4()),
            'sender_id': user_id,
            'sender_name': username,
            'receiver_id': partner_id,
            'message': message,
            'timestamp': datetime.now().isoformat(),
            'room': room_name
        }
        
        print(f'Message from {username} to {partner_id}: {message}')
        
        # Send message to room (both users)
        emit('new_message', message_data, room=room_name)
        
        # Also send to partner if they're online but not in room
        if partner_id in active_users:
            partner_sid = active_users[partner_id]
            emit('message_notification', {
                'sender_id': user_id,
                'sender_name': username,
                'message': message,
                'timestamp': message_data['timestamp']
            }, room=partner_sid)
        
    except Exception as e:
        print(f'Send message error: {e}')
        emit('error', {'message': 'Failed to send message'})

@socketio.on('typing_start')
def handle_typing_start(data):
    try:
        user_id = data.get('user_id')
        partner_id = data.get('partner_id')
        username = data.get('username', f'User{user_id}')
        
        if not all([user_id, partner_id]):
            return
        
        room_name = f"chat_{min(user_id, partner_id)}_{max(user_id, partner_id)}"
        
        # Notify partner that user is typing
        emit('user_typing', {
            'user_id': user_id,
            'username': username,
            'typing': True
        }, room=room_name, include_self=False)
        
    except Exception as e:
        print(f'Typing start error: {e}')

@socketio.on('typing_stop')
def handle_typing_stop(data):
    try:
        user_id = data.get('user_id')
        partner_id = data.get('partner_id')
        username = data.get('username', f'User{user_id}')
        
        if not all([user_id, partner_id]):
            return
        
        room_name = f"chat_{min(user_id, partner_id)}_{max(user_id, partner_id)}"
        
        # Notify partner that user stopped typing
        emit('user_typing', {
            'user_id': user_id,
            'username': username,
            'typing': False
        }, room=room_name, include_self=False)
        
    except Exception as e:
        print(f'Typing stop error: {e}')

@socketio.on('get_online_users')
def handle_get_online_users():
    try:
        online_user_ids = list(active_users.keys())
        emit('online_users', {'users': online_user_ids})
    except Exception as e:
        print(f'Get online users error: {e}')
        emit('error', {'message': 'Failed to get online users'})

# Skill Management Endpoints
@app.route('/api/skills/categories', methods=['GET'])
def get_skill_categories():
    """Get all skill categories with their skills"""
    categories = [
        {
            'id': 1,
            'name': 'Elektrikçi',
            'icon': '⚡',
            'description': 'Elektrik tesisatı ve aydınlatma hizmetleri',
            'skills': [
                {'id': 101, 'name': 'Elektrik Tesisatı', 'description': 'Ev ve işyeri elektrik tesisatı kurulumu ve onarımı'},
                {'id': 102, 'name': 'LED Aydınlatma', 'description': 'LED aydınlatma sistemleri ve spot montajı'},
                {'id': 103, 'name': 'Ev Otomasyonu', 'description': 'Akıllı ev sistemleri ve sensör kurulumu'},
                {'id': 104, 'name': 'Panel Montajı', 'description': 'Elektrik panosu montajı ve bakımı'},
                {'id': 105, 'name': 'Arıza Onarımı', 'description': 'Elektrik arızalarının tespiti ve onarımı'},
                {'id': 106, 'name': 'Şalt Tesisatı', 'description': 'Şalt ve kumanda tesisatı kurulumu'}
            ]
        },
        {
            'id': 2,
            'name': 'Tesisatçı',
            'icon': '🔧',
            'description': 'Su, doğalgaz ve ısıtma sistemleri',
            'skills': [
                {'id': 201, 'name': 'Su Tesisatı', 'description': 'Temiz su ve atık su tesisatı kurulumu'},
                {'id': 202, 'name': 'Doğalgaz Tesisatı', 'description': 'Doğalgaz boru tesisatı ve bağlantıları'},
                {'id': 203, 'name': 'Kalorifer Sistemi', 'description': 'Merkezi ısıtma ve kalorifer sistemleri'},
                {'id': 204, 'name': 'Klima Montajı', 'description': 'Split ve VRF klima sistemleri montajı'},
                {'id': 205, 'name': 'Sıhhi Tesisat', 'description': 'Banyo ve mutfak sıhhi tesisat işleri'},
                {'id': 206, 'name': 'Tıkanıklık Açma', 'description': 'Lavabo, tuvalet ve pis su tıkanıklığı açma'}
            ]
        },
        {
            'id': 3,
            'name': 'Boyacı',
            'icon': '🎨',
            'description': 'İç ve dış mekan boyama hizmetleri',
            'skills': [
                {'id': 301, 'name': 'İç Boyama', 'description': 'Ev ve ofis iç mekan boyama işleri'},
                {'id': 302, 'name': 'Dış Boyama', 'description': 'Bina dış cephesi ve balkon boyama'},
                {'id': 303, 'name': 'Dekoratif Boyama', 'description': 'Özel teknikler ve dekoratif boyama'},
                {'id': 304, 'name': 'Alçı Boyama', 'description': 'Alçı ve sıva üzeri boyama işleri'},
                {'id': 305, 'name': 'Ahşap Boyama', 'description': 'Ahşap yüzey boyama ve vernik işleri'},
                {'id': 306, 'name': 'Metal Boyama', 'description': 'Demir ve metal yüzey boyama'}
            ]
        },
        {
            'id': 4,
            'name': 'Marangoz',
            'icon': '🪚',
            'description': 'Ahşap işleri ve mobilya hizmetleri',
            'skills': [
                {'id': 401, 'name': 'Mobilya Yapımı', 'description': 'Özel tasarım mobilya üretimi'},
                {'id': 402, 'name': 'Kapı-Pencere', 'description': 'Ahşap kapı ve pencere montajı'},
                {'id': 403, 'name': 'Dekorasyon', 'description': 'Ahşap dekoratif ürünler ve lambri'},
                {'id': 404, 'name': 'Mutfak Dolabı', 'description': 'Mutfak dolabı yapımı ve montajı'},
                {'id': 405, 'name': 'Parke Döşeme', 'description': 'Laminat ve masif parke döşeme'},
                {'id': 406, 'name': 'Tadilat', 'description': 'Ahşap yapıların onarımı ve tadilat'}
            ]
        },
        {
            'id': 5,
            'name': 'Temizlikçi',
            'icon': '🧹',
            'description': 'Ev ve işyeri temizlik hizmetleri',
            'skills': [
                {'id': 501, 'name': 'Ev Temizliği', 'description': 'Genel ev temizliği ve düzenleme'},
                {'id': 502, 'name': 'Ofis Temizliği', 'description': 'İşyeri ve ofis temizlik hizmetleri'},
                {'id': 503, 'name': 'Cam Temizliği', 'description': 'Pencere ve cam yüzey temizliği'},
                {'id': 504, 'name': 'Halı Yıkama', 'description': 'Halı ve koltuk yıkama hizmetleri'},
                {'id': 505, 'name': 'Taşınma Temizliği', 'description': 'Taşınma öncesi/sonrası derin temizlik'},
                {'id': 506, 'name': 'İnşaat Temizliği', 'description': 'İnşaat sonrası temizlik hizmetleri'}
            ]
        },
        {
            'id': 6,
            'name': 'Bahçıvan',
            'icon': '🌱',
            'description': 'Bahçe düzenleme ve peyzaj hizmetleri',
            'skills': [
                {'id': 601, 'name': 'Bahçe Düzenleme', 'description': 'Bahçe tasarımı ve düzenleme işleri'},
                {'id': 602, 'name': 'Çim Ekimi', 'description': 'Çim ekimi ve bakım hizmetleri'},
                {'id': 603, 'name': 'Ağaç Budama', 'description': 'Meyve ve süs ağaçları budama'},
                {'id': 604, 'name': 'Peyzaj Mimarlığı', 'description': 'Profesyonel peyzaj tasarımı'},
                {'id': 605, 'name': 'Sulama Sistemi', 'description': 'Otomatik sulama sistemleri kurulumu'},
                {'id': 606, 'name': 'Bitki Bakımı', 'description': 'İç ve dış mekan bitki bakımı'}
            ]
        },
        {
            'id': 7,
            'name': 'Teknisyen',
            'icon': '🔌',
            'description': 'Elektronik cihaz onarım hizmetleri',
            'skills': [
                {'id': 701, 'name': 'Beyaz Eşya Tamiri', 'description': 'Buzdolabı, çamaşır makinesi tamiri'},
                {'id': 702, 'name': 'TV-Elektronik', 'description': 'Televizyon ve elektronik cihaz tamiri'},
                {'id': 703, 'name': 'Bilgisayar Tamiri', 'description': 'PC ve laptop donanım tamiri'},
                {'id': 704, 'name': 'Telefon Tamiri', 'description': 'Akıllı telefon ekran ve donanım tamiri'},
                {'id': 705, 'name': 'Klima Servisi', 'description': 'Klima bakım ve gaz dolum hizmetleri'},
                {'id': 706, 'name': 'Anten-Uydu', 'description': 'Anten ve uydu sistemleri kurulum'}
            ]
        },
        {
            'id': 8,
            'name': 'Nakliyeci',
            'icon': '🚚',
            'description': 'Taşıma ve nakliye hizmetleri',
            'skills': [
                {'id': 801, 'name': 'Ev Taşıma', 'description': 'Evden eve nakliye hizmetleri'},
                {'id': 802, 'name': 'Ofis Taşıma', 'description': 'Ofis ve işyeri taşıma hizmetleri'},
                {'id': 803, 'name': 'Eşya Taşıma', 'description': 'Tek eşya ve küçük taşıma işleri'},
                {'id': 804, 'name': 'Piyano Taşıma', 'description': 'Piyano ve hassas eşya taşıma'},
                {'id': 805, 'name': 'Şehirlerarası', 'description': 'Şehirlerarası nakliye hizmetleri'},
                {'id': 806, 'name': 'Ambar Hizmeti', 'description': 'Eşya depolama ve ambar hizmetleri'}
            ]
        }
    ]
    return jsonify(categories)

@app.route('/api/profile', methods=['GET'])
def get_profile():
    """Get user profile"""
    # Mock profile data
    profile = {
        'id': 1,
        'name': 'Ahmet Yılmaz',
        'business_name': 'Yılmaz Elektrik',
        'email': 'ahmet@yilmazelektrik.com',
        'phone': '+90 555 123 4567',
        'city': 'İstanbul',
        'district': 'Kadıköy',
        'address': 'Kadıköy Merkez, İstanbul',
        'description': '8 yıllık deneyimim ile profesyonel hizmet veriyorum.',
        'hourly_rate': 150,
        'experience_years': 8,
        'website': 'www.yilmazelektrik.com',
        'service_areas': ['Kadıköy', 'Üsküdar', 'Ataşehir', 'Maltepe', 'Kartal'],
        'working_hours': {
            'monday': '09:00-18:00',
            'tuesday': '09:00-18:00',
            'wednesday': '09:00-18:00',
            'thursday': '09:00-18:00',
            'friday': '09:00-18:00',
            'saturday': '09:00-15:00',
            'sunday': 'Kapalı'
        },
        'skills': [101, 102, 103, 104],  # Skill IDs
        'certifications': [
            'Elektrik Tesisatı Yeterlilik Belgesi',
            'LED Aydınlatma Uzmanı Sertifikası',
            'Akıllı Ev Sistemleri Eğitimi'
        ]
    }
    return jsonify(profile)

@app.route('/api/profile', methods=['PUT'])
def update_profile():
    """Update user profile"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['name', 'email', 'phone', 'city', 'district']
        for field in required_fields:
            if field not in data or not data[field]:
                return jsonify({'error': f'{field} is required'}), 400
        
        # Mock update - in real app, save to database
        print(f"Updating profile: {data}")
        
        # Return success response
        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'data': data
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("🚀 Real-time backend başlatılıyor...")
    print("📍 URL: http://localhost:5001")
    print("✅ Health check: http://localhost:5001/api/health")
    print("💬 Socket.IO: ws://localhost:5001")
    socketio.run(app, host='0.0.0.0', port=5001, debug=True)