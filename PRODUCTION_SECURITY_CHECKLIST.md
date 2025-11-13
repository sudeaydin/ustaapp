# 🔒 Production Güvenlik ve Hazırlık Kontrol Listesi

## ⚠️ KRİTİK GÜVENLİK SORUNLARI

### 1. 🔐 Kimlik Doğrulama ve Şifre Güvenliği

#### Mevcut Sorunlar:
- ❌ Test kullanıcılarının şifreleri çok basit (`123456`, `test123`)
- ❌ Minimum şifre karmaşıklığı kontrolü yok
- ❌ Şifre sıfırlama mekanizması tam değil
- ❌ 2FA (İki Faktörlü Kimlik Doğrulama) yok
- ❌ Hesap kilitleme mekanizması yok (brute force saldırılarına karşı)

#### Yapılması Gerekenler:
```python
# backend/app/utils/password_validator.py
- Minimum 8 karakter
- En az 1 büyük harf
- En az 1 küçük harf
- En az 1 rakam
- En az 1 özel karakter
- Yaygın şifreler listesi kontrolü
```

- [ ] Şifre karmaşıklığı kontrolü ekle
- [ ] Rate limiting ekle (Flask-Limiter)
- [ ] 5 başarısız giriş sonrası hesap geçici kilitle
- [ ] Şifre sıfırlama email doğrulaması ekle
- [ ] Session timeout ayarla (30 dakika)
- [ ] JWT token refresh mekanizması düzelt

---

### 2. 🔑 API Güvenliği

#### Mevcut Sorunlar:
- ❌ CORS ayarları çok gevşek (`allow_all_origins`)
- ❌ Rate limiting yok
- ❌ API key'ler kod içinde hardcoded
- ❌ SQL injection koruması eksik yerlerde
- ❌ XSS (Cross-Site Scripting) koruması zayıf

#### Yapılması Gerekenler:
```python
# backend/app/__init__.py
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

# CORS - Sadece belirli domain'lere izin ver
CORS(app, resources={
    r"/api/*": {
        "origins": ["https://yourdomain.com", "https://app.yourdomain.com"],
        "methods": ["GET", "POST", "PUT", "DELETE"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})
```

- [ ] Rate limiting ekle (her endpoint için)
- [ ] CORS'u sadece production domain'e sınırla
- [ ] API key'leri environment variable'a taşı
- [ ] Input validation tüm endpoint'lerde
- [ ] SQL parametrize query kullan (SQLAlchemy ORM yeterli ama raw query'leri kontrol et)
- [ ] Content Security Policy (CSP) header'ları ekle

---

### 3. 🗄️ Veritabase Güvenliği

#### Mevcut Sorunlar:
- ❌ Database credential'ları kod içinde
- ❌ Backup mekanizması yok
- ❌ Database connection pool limiti yok
- ❌ Sensitive data encryption yok

#### Yapılması Gerekenler:
```python
# .env (GIT'E EKLEME!)
DATABASE_URL=postgresql://user:pass@host:5432/dbname
DATABASE_POOL_SIZE=10
DATABASE_MAX_OVERFLOW=20
```

- [ ] Database credential'larını environment variable'a taşı
- [ ] Kredi kartı bilgileri şifrelensin (PCI DSS compliance)
- [ ] Kişisel veriler KVKK uyumlu saklanmalı
- [ ] Otomatik günlük backup ayarla
- [ ] Database connection pooling ayarla
- [ ] Read-only kullanıcı oluştur (raporlama için)

---

### 4. 💳 Ödeme Güvenliği

#### Mevcut Sorunlar:
- ❌ Test mode production'da çalışmamalı
- ❌ Webhook secret'lar hardcoded
- ❌ PCI DSS compliance kontrol edilmeli
- ❌ Ödeme logları hassas veri içerebilir

#### Yapılması Gerekenler:
```python
# backend/config/production.py
STRIPE_API_KEY = os.getenv('STRIPE_LIVE_API_KEY')
STRIPE_WEBHOOK_SECRET = os.getenv('STRIPE_WEBHOOK_SECRET')
STRIPE_TEST_MODE = False
```

- [ ] Stripe test key'leri production'dan kaldır
- [ ] Webhook signature doğrulaması ekle
- [ ] Ödeme loglarında kredi kartı numarası loglanmamalı
- [ ] HTTPS zorunlu kıl
- [ ] SSL sertifikası yükle ve auto-renew ayarla

---

### 5. 📁 Dosya Yükleme Güvenliği

#### Mevcut Sorunlar:
- ❌ Dosya tipi kontrolü yetersiz
- ❌ Dosya boyutu limiti yok
- ❌ Dosya adı sanitization yok
- ❌ Zararlı dosya taraması yok

#### Yapılması Gerekenler:
```python
# backend/app/utils/file_validator.py
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf'}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

def validate_file(file):
    # Dosya uzantısı kontrolü
    # Magic number kontrolü (gerçek dosya tipi)
    # Dosya boyutu kontrolü
    # Virus scan (ClamAV)
    # Dosya adı sanitization
```

- [ ] Sadece izin verilen dosya tiplerini kabul et
- [ ] Magic number ile gerçek dosya tipini kontrol et
- [ ] Maksimum dosya boyutu koy (5MB)
- [ ] Dosya adlarını sanitize et
- [ ] Yüklenen dosyaları web root dışında sakla
- [ ] Virus scanning ekle (opsiyonel ama önerilen)

---

### 6. 🔒 HTTPS ve SSL/TLS

#### Yapılması Gerekenler:
- [ ] SSL sertifikası al (Let's Encrypt ücretsiz)
- [ ] HTTPS'i zorunlu kıl
- [ ] HSTS header ekle
- [ ] TLS 1.2+ kullan
- [ ] Mixed content uyarılarını düzelt

```nginx
# nginx.conf
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

---

### 7. 🔍 Loglama ve Monitoring

#### Mevcut Sorunlar:
- ❌ Hassas veriler loglara yazılabilir
- ❌ Error tracking yok
- ❌ Performance monitoring yok
- ❌ Security event logging eksik

#### Yapılması Gerekenler:
```python
# backend/app/utils/logger.py
import logging
from logging.handlers import RotatingFileHandler

# Hassas verileri loglardan filtrele
class SensitiveDataFilter(logging.Filter):
    def filter(self, record):
        # Şifre, kredi kartı, token'ları loglama
        record.msg = re.sub(r'password["\']:\s*["\'][^"\']+["\']', 
                           'password":"***"', str(record.msg))
        return True
```

- [ ] Şifre, token, kredi kartı loglanmamalı
- [ ] Error tracking ekle (Sentry)
- [ ] Access log tut
- [ ] Failed login attempts logla
- [ ] Performance monitoring (New Relic, DataDog)
- [ ] Log retention policy belirle (90 gün)

---

### 8. 🌐 Environment Configuration

#### Yapılması Gerekenler:
```bash
# .env.production (GIT'E EKLEME!)
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=<çok-güçlü-random-key>
JWT_SECRET_KEY=<başka-çok-güçlü-random-key>

DATABASE_URL=postgresql://...
REDIS_URL=redis://...

STRIPE_LIVE_API_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

GOOGLE_MAPS_API_KEY=...
SENDGRID_API_KEY=...

ALLOWED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

- [ ] `.env` dosyasını `.gitignore`'a ekle
- [ ] Production environment variable'ları ayarla
- [ ] `DEBUG=False` ayarla
- [ ] Secret key'leri güçlü random string'lerle değiştir
- [ ] Test data'yı production'dan temizle
- [ ] Development endpoint'leri kapat

---

### 9. 👤 Kullanıcı Yetkilendirme

#### Mevcut Sorunlar:
- ❌ RBAC (Role-Based Access Control) eksik
- ❌ Permission checking zayıf
- ❌ Admin panel herkese açık olabilir

#### Yapılması Gerekenler:
```python
# backend/app/decorators/auth.py
from functools import wraps
from flask import jsonify

def require_role(*roles):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            current_user = get_current_user()
            if not current_user or current_user.role not in roles:
                return jsonify({'error': 'Unauthorized'}), 403
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/admin/users')
@require_role('admin', 'super_admin')
def admin_users():
    pass
```

- [ ] Role-based access control (RBAC) ekle
- [ ] Her endpoint için yetki kontrolü
- [ ] Admin panel'e özel koruma
- [ ] User'ın sadece kendi verisine erişmesini sağla
- [ ] IDOR (Insecure Direct Object Reference) koruması

---

### 10. 📱 Mobile App Güvenliği

#### Flutter App Sorunları:
- ❌ API URL'leri hardcoded
- ❌ API key'ler kodda görünür
- ❌ SSL pinning yok
- ❌ Jailbreak/Root detection yok
- ❌ Local storage şifrelenmemiş

#### Yapılması Gerekenler:
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.yourdomain.com'
  );
  
  // flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com
}

// Secure storage kullan
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'jwt_token', value: token);
```

- [ ] API URL'leri environment variable'dan al
- [ ] Secure Storage kullan (SharedPreferences yerine)
- [ ] SSL Certificate Pinning ekle
- [ ] Code obfuscation aktifleştir
- [ ] ProGuard rules ekle (Android)
- [ ] Jailbreak/Root detection ekle

---

## 🚀 PRODUCTION DEPLOYMENT CHECKLIST

### Pre-Deploy Checklist:
- [ ] Tüm test kullanıcılarını sil
- [ ] Test data'yı temizle
- [ ] Database migration'ları test et
- [ ] Backup al
- [ ] Environment variable'ları ayarla
- [ ] SSL sertifikası yükle
- [ ] Domain DNS ayarlarını yap
- [ ] Email servisini ayarla (SendGrid, AWS SES)
- [ ] SMS servisini ayarla (Twilio)
- [ ] Error tracking ayarla (Sentry)
- [ ] Performance monitoring ayarla
- [ ] CDN ayarla (CloudFlare)

### Post-Deploy Checklist:
- [ ] Health check endpoint test et
- [ ] Login/Logout test et
- [ ] Payment flow test et
- [ ] Email gönderimi test et
- [ ] SMS gönderimi test et
- [ ] Error tracking çalışıyor mu kontrol et
- [ ] SSL sertifikası çalışıyor mu
- [ ] HTTPS redirect çalışıyor mu
- [ ] API rate limiting çalışıyor mu
- [ ] Database backup çalışıyor mu

---

## 🔐 KVKK ve Yasal Gereklilikler

### KVKK (Kişisel Verilerin Korunması Kanunu):
- [ ] Kullanıcı onay metni (consent)
- [ ] Gizlilik politikası
- [ ] Kullanım şartları
- [ ] Çerez politikası
- [ ] Veri sahibi başvuru formu
- [ ] Kişisel verilerin silinmesi talebi
- [ ] KVKK aydınlatma metni
- [ ] Veri işleme envanteri

### E-Ticaret Yasal Gereklilikler:
- [ ] Ticari elektronik ileti izni
- [ ] Mesafeli satış sözleşmesi
- [ ] Ön bilgilendirme formu
- [ ] Cayma hakkı bildirimi
- [ ] Şirket bilgileri (unvan, adres, vergi no)
- [ ] İletişim bilgileri
- [ ] İade ve değişim politikası

---

## 🛡️ GÜVENLİK TARAMALARı

### Yapılması Gereken Taramalar:
```bash
# Dependency vulnerability scan
pip install safety
safety check --json

# OWASP ZAP - Web security scanner
docker run -t owasp/zap2docker-stable zap-baseline.py \
    -t https://yourdomain.com

# Bandit - Python security linter
pip install bandit
bandit -r backend/

# NPM audit (Node.js dependencies)
npm audit fix

# Trivy - Container vulnerability scanner
trivy image your-docker-image:latest
```

- [ ] OWASP ZAP security scan
- [ ] Dependency vulnerability scan (safety, npm audit)
- [ ] Penetration testing
- [ ] Load testing
- [ ] SQL injection testing
- [ ] XSS testing
- [ ] CSRF testing

---

## 📊 MONITORING VE ALERTING

### Kurulması Gerekenler:
- [ ] Uptime monitoring (UptimeRobot, Pingdom)
- [ ] Error tracking (Sentry)
- [ ] Performance monitoring (New Relic, DataDog)
- [ ] Log aggregation (ELK Stack, CloudWatch)
- [ ] Database monitoring
- [ ] API endpoint monitoring
- [ ] Mobile app crash reporting (Firebase Crashlytics)

### Alert Kuralları:
- [ ] API response time > 2 saniye
- [ ] Error rate > 1%
- [ ] Server CPU > 80%
- [ ] Database connection pool > 80%
- [ ] Disk space < 20%
- [ ] Failed login attempts > 10/dakika
- [ ] Payment failure > 5%

---

## 🔧 PERFORMANS OPTİMİZASYONU

### Backend Optimizations:
- [ ] Redis cache ekle
- [ ] Database indexleri optimize et
- [ ] N+1 query problemlerini çöz
- [ ] Connection pooling ayarla
- [ ] Gzip compression aktifleştir
- [ ] Image optimization (WebP, lazy loading)
- [ ] CDN kullan (CloudFlare, AWS CloudFront)

### Mobile App Optimizations:
- [ ] Image caching
- [ ] API response caching
- [ ] Lazy loading
- [ ] Code splitting
- [ ] Bundle size optimization
- [ ] Remove unused packages

---

## 📝 DOKÜMANTASYON

### Hazırlanması Gerekenler:
- [ ] API Documentation (Swagger/OpenAPI)
- [ ] Database schema documentation
- [ ] Deployment guide
- [ ] Troubleshooting guide
- [ ] User manual
- [ ] Admin manual
- [ ] Developer onboarding guide
- [ ] Incident response plan

---

## 🆘 INCIDENT RESPONSE PLAN

### Acil Durum Planı:
1. **Security Breach Detection**
   - İlk tespit zamanı kaydet
   - Etkilenen sistemleri belirle
   - Hasarı değerlendir

2. **Containment**
   - Etkilenen servisleri izole et
   - Şüpheli hesapları dondur
   - Access log'ları sakla

3. **Eradication**
   - Güvenlik açığını kapat
   - Zararlı kod/data temizle
   - Şifreleri sıfırla

4. **Recovery**
   - Backup'tan geri yükle
   - Sistemleri test et
   - Servisleri yavaşça aç

5. **Post-Incident**
   - Rapor hazırla
   - Kullanıcıları bilgilendir
   - Önlemler al

---

## ⚡ HIZLI KONTROL LİSTESİ

### Minimum Güvenlik Gereksinimleri (Production'a çıkmadan önce):
- [ ] ✅ DEBUG=False
- [ ] ✅ SECRET_KEY değiştirildi
- [ ] ✅ Test kullanıcıları silindi
- [ ] ✅ HTTPS aktif
- [ ] ✅ CORS düzgün ayarlı
- [ ] ✅ Rate limiting aktif
- [ ] ✅ Database backup aktif
- [ ] ✅ Error tracking aktif
- [ ] ✅ Güvenlik header'ları eklendi
- [ ] ✅ Input validation tüm endpoint'lerde

### Kritik Test Senaryoları:
- [ ] Yeni kullanıcı kaydı
- [ ] Login/Logout
- [ ] Şifre sıfırlama
- [ ] Profil güncelleme
- [ ] Ödeme işlemi
- [ ] Teklif gönderme/alma
- [ ] Mesajlaşma
- [ ] Dosya yükleme
- [ ] Admin panel erişimi

---

## 📞 İLETİŞİM BİLGİLERİ

**Acil Durum İletişim:**
- DevOps Lead: [isim] - [telefon]
- Security Lead: [isim] - [telefon]
- CTO/Tech Lead: [isim] - [telefon]

**Servis Sağlayıcılar:**
- Hosting: [provider] - [support email/phone]
- Database: [provider] - [support email/phone]
- Email: [provider] - [support email/phone]
- Payment: Stripe - [support email]

---

## 📅 DÜZENLI BAKIM

### Günlük:
- [ ] Error log kontrolü
- [ ] Performance metrikleri
- [ ] Backup kontrolü

### Haftalık:
- [ ] Security scan
- [ ] Database optimization
- [ ] Disk space kontrolü
- [ ] SSL sertifika kontrolü

### Aylık:
- [ ] Dependency update
- [ ] Security patch
- [ ] Performance audit
- [ ] Cost optimization

### 3 Aylık:
- [ ] Full security audit
- [ ] Penetration testing
- [ ] Disaster recovery test
- [ ] Documentation update

---

## 🎯 ÖNCELİK SIRASI

### P0 - Kritik (Hemen yapılmalı):
1. DEBUG=False yap
2. SECRET_KEY değiştir
3. HTTPS aktifleştir
4. Test kullanıcılarını sil
5. CORS'u düzelt

### P1 - Yüksek (1 hafta içinde):
1. Rate limiting ekle
2. Input validation
3. Error tracking
4. Database backup
5. Security headers

### P2 - Orta (1 ay içinde):
1. 2FA ekle
2. RBAC sistemini tamamla
3. Performance monitoring
4. CDN kurulumu
5. Load testing

### P3 - Düşük (İlerleyen dönemde):
1. Advanced monitoring
2. Machine learning fraud detection
3. Advanced caching strategies
4. Microservices migration

---

Bu doküman düzenli olarak güncellenmelidir.
Son güncelleme: 2025-11-13
