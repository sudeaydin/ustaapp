# 🔍 ustam APP - DETAYLI DURUM RAPORU VE KRİTİK ÖNERİLER

Appini detaylı inceledim. İşte **gerçek durumuna göre** kritik öneriler ve yapılması gerekenler:

---

## 🚨 **LEVEL 1: HEMEN DÜZELTİLMESİ GEREKEN KRİTİK SORUNLAR**

### 🔴 **1. GÜVENLİK AÇIĞI: CORS TÜM ORIGIN'LERE AÇIK!**

**❌ Şu Anki Durum:**
```python
# backend/app/__init__.py satır 44
CORS(app, origins=['*'],  # ❌ HERKESİN ERİŞİMİNE AÇIK!
     allow_headers=['Content-Type', 'Authorization'],
     methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
     supports_credentials=True)
```

**⚠️ Risk:** Herhangi bir domain'den API'na istek atılabilir! XSS ve CSRF saldırılarına açık!

**✅ Çözüm:**
```python
# Production için MUTLAKA değiştirilmeli
allowed_origins = os.environ.get('CORS_ORIGINS', 'https://ustam.com').split(',')
CORS(app, origins=allowed_origins,  # Sadece kendi domain'in
     allow_headers=['Content-Type', 'Authorization'],
     methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
     supports_credentials=True)
```

**⏱️ Süre:** 5 dakika  
**🎯 Dosya:** `/workspace/backend/app/__init__.py` satır 44-47  
**🚨 Kritiklik:** 10/10 - Bu olmadan production'a ÇIKMA!

---

### 🔴 **2. WEAK SECRET KEYS - DEFAULT DEĞERLER KULLANILIYOR**

**❌ Şu Anki Durum:**
```python
# backend/app/__init__.py satır 25-36
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY') or 'dev-secret-key'
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-key'
```

**⚠️ Risk:** Environment variable yoksa default weak key kullanılıyor!

**✅ Çözüm:**
```python
# Production'da MUTLAKA environment variable olmalı
SECRET_KEY = os.environ.get('SECRET_KEY')
JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY')

if not SECRET_KEY or not JWT_SECRET_KEY:
    if os.environ.get('FLASK_ENV') == 'production':
        raise ValueError("SECRET_KEY and JWT_SECRET_KEY must be set in production!")
    else:
        SECRET_KEY = 'dev-secret-key'
        JWT_SECRET_KEY = 'jwt-secret-key'

app.config['SECRET_KEY'] = SECRET_KEY
app.config['JWT_SECRET_KEY'] = JWT_SECRET_KEY
```

**Strong key oluştur:**
```bash
# Terminal'de çalıştır:
python3 -c "import secrets; print('SECRET_KEY=' + secrets.token_hex(32))"
python3 -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_hex(32))"
```

**⏱️ Süre:** 10 dakika  
**🎯 Dosya:** `/workspace/backend/app/__init__.py` satır 25-36  
**🚨 Kritiklik:** 10/10 - Token'lar crack edilebilir!

---

### 🔴 **3. IN-MEMORY DATABASE - APP ENGINE'DE KULLANILIYOR!**

**❌ Şu Anki Durum:**
```python
# backend/app/__init__.py satır 28-33
if os.environ.get('GAE_ENV', '').startswith('standard'):
    # Production on App Engine - use in-memory SQLite
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'  # ❌ HER RESTART'TA SİLİNİR!
else:
    # Local development
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL') or 'sqlite:///app.db'
```

**⚠️ Risk:** App Engine her instance restart'ta tüm data SİLİNİYOR! Kullanıcılar, işler, ödemeler - HEPSİ GİDİYOR!

**✅ Çözüm: Google Cloud SQL kullan (PostgreSQL)**

```python
# backend/app/__init__.py
import os
import sqlalchemy

# Production: Cloud SQL PostgreSQL
if os.environ.get('GAE_ENV', '').startswith('standard'):
    # Cloud SQL connection
    db_user = os.environ.get('DB_USER', 'postgres')
    db_pass = os.environ.get('DB_PASS', '')
    db_name = os.environ.get('DB_NAME', 'ustam_db')
    db_host = os.environ.get('DB_HOST', '')  # Cloud SQL instance connection name
    
    # Unix socket için
    db_socket_dir = os.environ.get("DB_SOCKET_DIR", "/cloudsql")
    cloud_sql_connection_name = os.environ.get("CLOUD_SQL_CONNECTION_NAME")
    
    if cloud_sql_connection_name:
        db_url = f"postgresql+psycopg2://{db_user}:{db_pass}@/{db_name}?host={db_socket_dir}/{cloud_sql_connection_name}"
    else:
        # Fallback: File-based SQLite (better than in-memory!)
        import tempfile
        db_url = f"sqlite:///{tempfile.gettempdir()}/ustam_app.db"
        
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url
else:
    # Local development
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL') or 'sqlite:///app.db'
```

**Cloud SQL Setup:**
```bash
# 1. Cloud SQL instance oluştur
gcloud sql instances create ustam-db \
    --database-version=POSTGRES_14 \
    --tier=db-f1-micro \
    --region=europe-west3

# 2. Database oluştur
gcloud sql databases create ustam_db --instance=ustam-db

# 3. User oluştur
gcloud sql users create ustam_user \
    --instance=ustam-db \
    --password=STRONG_PASSWORD_HERE

# 4. app.yaml'a ekle:
# env_variables:
#   CLOUD_SQL_CONNECTION_NAME: 'YOUR_PROJECT:europe-west3:ustam-db'
#   DB_USER: 'ustam_user'
#   DB_PASS: 'STRONG_PASSWORD'
#   DB_NAME: 'ustam_db'
```

**⏱️ Süre:** 1 saat  
**🚨 Kritiklik:** 11/10 - ŞUAN DATA KAYBEDİYORSUN!

---

### 🔴 **4. PASSWORD VALIDATION ÇOK ZAYıF**

**❌ Şu Anki Durum:**
```python
# backend/app/routes/auth.py satır 82-87
if len(data['password']) < 6:  # ❌ Sadece 6 karakter yeterli!
    return jsonify({
        'error': True,
        'message': 'Şifre en az 6 karakter olmalıdır',
        'code': 'PASSWORD_TOO_SHORT'
    }), 400
```

**⚠️ Risk:** "123456" kabul ediliyor! Dictionary attack'e çok açık.

**✅ Çözüm:**
```python
import re

def validate_password_strength(password):
    """
    Strong password validation
    - Min 8 karakter
    - En az 1 büyük harf
    - En az 1 küçük harf
    - En az 1 sayı
    - En az 1 özel karakter
    """
    if len(password) < 8:
        return False, 'Şifre en az 8 karakter olmalıdır'
    
    if not re.search(r'[A-Z]', password):
        return False, 'Şifre en az bir büyük harf içermelidir'
    
    if not re.search(r'[a-z]', password):
        return False, 'Şifre en az bir küçük harf içermelidir'
    
    if not re.search(r'\d', password):
        return False, 'Şifre en az bir rakam içermelidir'
    
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        return False, 'Şifre en az bir özel karakter içermelidir (!@#$%^&*...)'
    
    # Common passwords check
    common_passwords = ['12345678', 'password', 'qwerty123', 'abc12345']
    if password.lower() in common_passwords:
        return False, 'Bu şifre çok yaygın kullanılıyor, daha güçlü bir şifre seçin'
    
    return True, None

# Usage in register endpoint:
is_valid, error_msg = validate_password_strength(data['password'])
if not is_valid:
    return jsonify({
        'error': True,
        'message': error_msg,
        'code': 'WEAK_PASSWORD'
    }), 400
```

**⏱️ Süre:** 30 dakika  
**🎯 Dosya:** `/workspace/backend/app/routes/auth.py` satır 82-87  
**🚨 Kritiklik:** 9/10

---

### 🔴 **5. RATE LIMITING YOK (AUTH ENDPOINT'LERINDE)**

**❌ Şu Anki Durum:**
```python
# backend/app/routes/auth.py
@auth_bp.route('/register', methods=['POST'])
def register():  # ❌ Sınırsız register denemesi yapılabilir!
```

**⚠️ Risk:** 
- Brute force attack
- Spam registrations
- DDoS attacks
- API abuse

**✅ Çözüm: Flask-Limiter ekle**

```bash
# requirements.txt'e ekle:
Flask-Limiter==3.5.0
```

```python
# backend/app/__init__.py
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"  # Production'da Redis kullan
)

# backend/app/routes/auth.py
from app import limiter

@auth_bp.route('/login', methods=['POST'])
@limiter.limit("5 per minute")  # Dakikada max 5 deneme
def login():
    # ...

@auth_bp.route('/register', methods=['POST'])
@limiter.limit("3 per hour")  # Saatte max 3 kayıt
def register():
    # ...
```

**Production için Redis:**
```python
# app.yaml'a ekle:
# env_variables:
#   REDIS_URL: 'redis://your-redis-instance:6379'

# __init__.py
import os
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    storage_uri=os.environ.get('REDIS_URL', 'memory://')
)
```

**⏱️ Süre:** 1 saat  
**🚨 Kritiklik:** 9/10

---

### 🔴 **6. ÖDEMELerde gerçek iyzico entegrasyonu yok**

**❌ Şu Anki Durum:**
```python
# backend/app/routes/payment.py satır 36-52
def simulate_iyzico_payment(payment_data):
    """Simulate iyzico payment processing"""
    # Simulate 90% success rate
    success = random.random() > 0.1  # ❌ SAHTE ÖDEME!
    
    if success:
        return {
            'success': True,
            'provider_payment_id': f"iyzico_{random.randint(1000000, 9999999)}",
            'status': PaymentStatus.COMPLETED.value
        }
```

**⚠️ Risk:** PARA ALMIYOR! Simulation kullanılıyor!

**✅ Çözüm: Gerçek İyzico SDK kullan**

```bash
# requirements.txt'e ekle:
iyzipay==1.0.48
```

```python
# backend/app/utils/iyzico_client.py
import iyzipay
import os

class IyzicoClient:
    def __init__(self):
        self.api_key = os.environ.get('IYZICO_API_KEY')
        self.secret_key = os.environ.get('IYZICO_SECRET_KEY')
        self.base_url = os.environ.get('IYZICO_BASE_URL', 'https://api.iyzipay.com')
        
        if not self.api_key or not self.secret_key:
            raise ValueError("İyzico credentials not set!")
        
        self.options = {
            'api_key': self.api_key,
            'secret_key': self.secret_key,
            'base_url': self.base_url
        }
    
    def process_payment(self, payment_data):
        """Process real payment with İyzico"""
        payment_request = {
            'locale': iyzipay.LOCALE_TR,
            'conversationId': payment_data['conversation_id'],
            'price': str(payment_data['amount']),
            'paidPrice': str(payment_data['total_amount']),
            'currency': iyzipay.CURRENCY_TRY,
            'installment': payment_data.get('installment', 1),
            'basketId': payment_data['basket_id'],
            'paymentChannel': iyzipay.PAYMENT_CHANNEL_WEB,
            'paymentGroup': iyzipay.PAYMENT_GROUP_PRODUCT,
            'paymentCard': {
                'cardHolderName': payment_data['card_holder_name'],
                'cardNumber': payment_data['card_number'],
                'expireMonth': payment_data['expiry_month'],
                'expireYear': payment_data['expiry_year'],
                'cvc': payment_data['cvc'],
                'registerCard': 0
            },
            'buyer': payment_data['buyer'],
            'shippingAddress': payment_data['shipping_address'],
            'billingAddress': payment_data['billing_address'],
            'basketItems': payment_data['basket_items']
        }
        
        payment = iyzipay.Payment().create(payment_request, self.options)
        return payment.read().decode('utf-8')

# backend/app/routes/payment.py
from app.utils.iyzico_client import IyzicoClient

iyzico_client = IyzicoClient()

@payment_bp.route('/process', methods=['POST'])
@jwt_required()
def process_payment():
    # ... validation ...
    
    # Gerçek ödeme işlemi
    try:
        result = iyzico_client.process_payment(payment_data)
        # Process result...
    except Exception as e:
        logger.error(f"Payment error: {e}")
        return jsonify({'error': 'Payment failed'}), 500
```

**⏱️ Süre:** 4 saat  
**🚨 Kritiklik:** 10/10 - PARA ALMIYOR!

---

## 🟠 **LEVEL 2: ÖNEMLİ İYİLEŞTİRMELER (İlk hafta içinde)**

### 🟠 **7. JWTToken Expiration Yok**

**❌ Şu Anki Durum:**
```python
# Token süresiz, hiç expire olmuyor!
access_token = create_access_token(identity=str(user.id))
```

**✅ Çözüm:**
```python
# backend/app/__init__.py
from datetime import timedelta

app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=1)
app.config['JWT_REFRESH_TOKEN_EXPIRES'] = timedelta(days=30)

# backend/app/routes/auth.py
from flask_jwt_extended import create_access_token, create_refresh_token

@auth_bp.route('/login', methods=['POST'])
def login():
    # ...
    access_token = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))
    
    return jsonify({
        'access_token': access_token,
        'refresh_token': refresh_token,
        'expires_in': 3600  # 1 hour
    })

@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    """Refresh access token"""
    current_user = get_jwt_identity()
    new_access_token = create_access_token(identity=current_user)
    return jsonify({'access_token': new_access_token})
```

**⏱️ Süre:** 1 saat  
**🚨 Kritiklik:** 8/10

---

### 🟠 **8. ERROR LOGGING VE MONITORING YOK**

**❌ Şu Anki Durum:**
- Exception'lar catch ediliyor ama loglama yok
- Monitoring yok
- Alert sistemi yok

**✅ Çözüm: Google Cloud Logging + Error Reporting**

```python
# backend/app/utils/logger.py
import logging
import os

def setup_logger():
    """Setup Google Cloud Logging"""
    logger = logging.getLogger('ustam')
    
    if os.environ.get('GAE_ENV', '').startswith('standard'):
        # Production: Google Cloud Logging
        try:
            import google.cloud.logging
            client = google.cloud.logging.Client()
            client.setup_logging()
            logger.setLevel(logging.INFO)
        except ImportError:
            logging.basicConfig(level=logging.INFO)
    else:
        # Development: Console logging
        logging.basicConfig(
            level=logging.DEBUG,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
    
    return logger

logger = setup_logger()

# Usage:
from app.utils.logger import logger

@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        # ... code ...
        logger.info(f"User login successful: {user.email}")
    except Exception as e:
        logger.error(f"Login error: {str(e)}", exc_info=True)
        # exc_info=True adds stack trace
```

**Error Reporting:**
```bash
# requirements-gcp.txt'e ekle:
google-cloud-error-reporting>=1.9.0
```

```python
# backend/app/utils/error_reporter.py
import os
from google.cloud import error_reporting

class ErrorReporter:
    def __init__(self):
        if os.environ.get('GAE_ENV', '').startswith('standard'):
            self.client = error_reporting.Client()
        else:
            self.client = None
    
    def report(self, exception):
        """Report error to Google Cloud Error Reporting"""
        if self.client:
            self.client.report_exception()
        else:
            import traceback
            traceback.print_exc()

error_reporter = ErrorReporter()

# Usage:
try:
    # ... code ...
except Exception as e:
    error_reporter.report(e)
    raise
```

**⏱️ Süre:** 2 saat  
**🚨 Kritiklik:** 8/10

---

### 🟠 **9. FILE UPLOAD GÜVENLİK KONTROLÜ ZAYıF**

**❌ Şu Anki Durum:**
```python
# backend/app/routes/auth.py satır 28-29
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
# Sadece extension check var, content validation yok!
```

**✅ Çözüm:**
```python
from PIL import Image
import magic  # python-magic

def validate_image_file(file):
    """Comprehensive image validation"""
    # 1. Check extension
    if not file.filename:
        return False, 'Dosya adı geçersiz'
    
    ext = file.filename.rsplit('.', 1)[1].lower() if '.' in file.filename else ''
    if ext not in ALLOWED_EXTENSIONS:
        return False, f'Sadece şu formatlar kabul edilir: {", ".join(ALLOWED_EXTENSIONS)}'
    
    # 2. Check file size (5MB max)
    file.seek(0, 2)  # Seek to end
    file_size = file.tell()
    file.seek(0)  # Reset
    
    if file_size > 5 * 1024 * 1024:  # 5MB
        return False, 'Dosya boyutu maksimum 5MB olabilir'
    
    # 3. Check MIME type
    try:
        mime = magic.from_buffer(file.read(2048), mime=True)
        file.seek(0)
        
        allowed_mimes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp']
        if mime not in allowed_mimes:
            return False, 'Geçersiz dosya tipi'
    except:
        pass
    
    # 4. Try to open with PIL (validates it's a real image)
    try:
        img = Image.open(file)
        img.verify()
        file.seek(0)
        
        # Check image dimensions (max 4096x4096)
        if img.size[0] > 4096 or img.size[1] > 4096:
            return False, 'Görsel boyutu çok büyük (max 4096x4096)'
            
    except Exception as e:
        return False, 'Geçersiz görsel dosyası'
    
    return True, None

# Usage:
is_valid, error_msg = validate_image_file(file)
if not is_valid:
    return jsonify({'error': error_msg}), 400
```

**⏱️ Süre:** 1 saat  
**🚨 Kritiklik:** 7/10

---

### 🟠 **10. EMAIL VE SMS SERVİSLERİ YOK**

**❌ Şu Anki Durum:**
- Email verification yok
- Password reset yok
- SMS verification yok
- Notification emails yok

**✅ Çözüm: SendGrid (Email) + Twilio/NetGSM (SMS)**

```bash
# requirements.txt'e ekle:
sendgrid==6.11.0
twilio==8.11.0
```

```python
# backend/app/utils/email_service.py
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
import os

class EmailService:
    def __init__(self):
        self.api_key = os.environ.get('SENDGRID_API_KEY')
        self.from_email = os.environ.get('FROM_EMAIL', 'noreply@ustam.com')
        
        if self.api_key:
            self.client = SendGridAPIClient(self.api_key)
        else:
            self.client = None
    
    def send_verification_email(self, to_email, verification_link):
        """Send email verification"""
        message = Mail(
            from_email=self.from_email,
            to_emails=to_email,
            subject='UstanBurada - Email Doğrulama',
            html_content=f'''
                <h2>Hoş Geldiniz!</h2>
                <p>Email adresinizi doğrulamak için aşağıdaki linke tıklayın:</p>
                <a href="{verification_link}">Email Adresimi Doğrula</a>
            '''
        )
        
        if self.client:
            try:
                response = self.client.send(message)
                return True, response.status_code
            except Exception as e:
                return False, str(e)
        return False, 'Email service not configured'
    
    def send_password_reset(self, to_email, reset_link):
        """Send password reset email"""
        # Similar implementation...

# backend/app/utils/sms_service.py
from twilio.rest import Client

class SMSService:
    def __init__(self):
        self.account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
        self.auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
        self.from_number = os.environ.get('TWILIO_PHONE_NUMBER')
        
        if self.account_sid and self.auth_token:
            self.client = Client(self.account_sid, self.auth_token)
        else:
            self.client = None
    
    def send_verification_code(self, to_number, code):
        """Send SMS verification code"""
        message = f"UstanBurada doğrulama kodunuz: {code}"
        
        if self.client:
            try:
                message = self.client.messages.create(
                    body=message,
                    from_=self.from_number,
                    to=to_number
                )
                return True, message.sid
            except Exception as e:
                return False, str(e)
        return False, 'SMS service not configured'
```

**⏱️ Süre:** 4 saat  
**🚨 Kritiklik:** 7/10

---

## 🟡 **LEVEL 3: PERFORMANCE & OPTIMIZATION**

### 🟡 **11. N+1 QUERY PROBLEMI**

**❌ Şu Anki Durum:**
```python
# backend/app/__init__.py satır 273-290
for craftsman in craftsmen.items:
    result.append({
        'name': f"{craftsman.user.first_name}..."  # Her craftsman için ayrı query!
    })
```

**✅ Çözüm:**
```python
# Use joinedload to eager load relationships
from sqlalchemy.orm import joinedload

craftsmen = Craftsman.query\
    .join(User)\
    .options(joinedload(Craftsman.user))\  # Eager load user
    .filter(User.is_active == True)\
    .paginate(page=page, per_page=per_page)
```

**⏱️ Süre:** 2 saat  
**🚨 Kritiklik:** 6/10

---

### 🟡 **12. DATABASE INDEX'LER EKSİK**

**✅ Çözüm:**
```sql
-- Frequently queried columns'a index ekle
CREATE INDEX idx_craftsman_city_district ON craftsmen(city, district);
CREATE INDEX idx_craftsman_rating ON craftsmen(average_rating DESC);
CREATE INDEX idx_job_status_created ON jobs(status, created_at DESC);
CREATE INDEX idx_quote_job_status ON quotes(job_id, status);
```

**⏱️ Süre:** 1 saat  
**🚨 Kritiklik:** 6/10

---

### 🟡 **13. IMAGE OPTIMIZATION YOK**

**✅ Çözüm:**
```python
from PIL import Image
import io

def optimize_image(file, max_size=(1920, 1920), quality=85):
    """Optimize uploaded images"""
    img = Image.open(file)
    
    # Convert to RGB if necessary
    if img.mode in ('RGBA', 'LA', 'P'):
        img = img.convert('RGB')
    
    # Resize if too large
    img.thumbnail(max_size, Image.Resampling.LANCZOS)
    
    # Save optimized
    output = io.BytesIO()
    img.save(output, format='JPEG', quality=quality, optimize=True)
    output.seek(0)
    
    return output
```

**⏱️ Süre:** 2 saat  
**🚨 Kritiklik:** 5/10

---

## 📊 **ÖZET VE ÖNCELIKLER**

### 🎯 **HEMEN YAPILMASI GEREKENLER (1-2 gün)**
1. ✅ **CORS ayarları** - 5 dakika
2. ✅ **Secret keys** - 10 dakika  
3. ✅ **Database: Cloud SQL** - 1 saat
4. ✅ **Password validation** - 30 dakika
5. ✅ **Rate limiting** - 1 saat
6. ✅ **İyzico real integration** - 4 saat

**Toplam: ~7 saat**

### 📅 **İLK HAFTA**
7. JWT token expiration - 1 saat
8. Error logging & monitoring - 2 saat
9. File upload validation - 1 saat
10. Email/SMS services - 4 saat

**Toplam: +8 saat**

### 📆 **İLK AY**
11. N+1 query optimization - 2 saat
12. Database indexes - 1 saat
13. Image optimization - 2 saat

**Toplam: +5 saat**

---

## 🚀 **QUICK START - İLK 1 GÜNDE YAPILACAKLAR**

```bash
# 1. Secret keys oluştur
python3 -c "import secrets; print('SECRET_KEY=' + secrets.token_hex(32))" >> .env.production
python3 -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_hex(32))" >> .env.production

# 2. Cloud SQL kur
gcloud sql instances create ustam-db --database-version=POSTGRES_14 --tier=db-f1-micro --region=europe-west3
gcloud sql databases create ustam_db --instance=ustam-db
gcloud sql users create ustam_user --instance=ustam-db --password=STRONG_PASS

# 3. CORS fix
# app/__init__.py satır 44'ü düzenle

# 4. Rate limiting ekle
pip install Flask-Limiter
# auth.py'a ekle

# 5. Test
python test_production_ready.py

# 6. Deploy
gcloud app deploy
```

---

## 📞 **DESTEK**

Takıldığın yerler olursa bana sor, yardımcı olurum! 🤝

**ÖNEMLI:** Production'a çıkmadan önce MUTLAKA 1-6 numaralı kritik sorunları çöz!
