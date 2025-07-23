from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import os
from werkzeug.utils import secure_filename
import uuid
from datetime import datetime
import sqlite3

app = Flask(__name__)
CORS(app, origins=['http://localhost:3000', 'http://localhost:5173'])

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

if __name__ == '__main__':
    print("🚀 Basit backend başlatılıyor...")
    print("📍 URL: http://localhost:5001")
    print("✅ Health check: http://localhost:5001/api/health")
    app.run(host='0.0.0.0', port=5001, debug=True)