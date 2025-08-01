# 🚀 USTAM - PRODUCTION DEPLOYMENT GUIDE

Bu rehber, Ustam uygulamasını production ortamında nasıl deploy edeceğinizi adım adım açıklar.

## 📋 İçindekiler

1. [Sistem Gereksinimleri](#sistem-gereksinimleri)
2. [Veritabanı Kurulumu](#veritabanı-kurulumu)
3. [Backend Deployment](#backend-deployment)
4. [Frontend Deployment](#frontend-deployment)
5. [Nginx Konfigürasyonu](#nginx-konfigürasyonu)
6. [SSL Sertifikası](#ssl-sertifikası)
7. [Sistem Servisleri](#sistem-servisleri)
8. [Veritabanı Yönetimi](#veritabanı-yönetimi)
9. [Monitoring ve Logging](#monitoring-ve-logging)
10. [Backup Stratejisi](#backup-stratejisi)

## 🖥️ Sistem Gereksinimleri

### Minimum Sistem Gereksinimleri
- **OS:** Ubuntu 20.04+ / CentOS 8+ / Debian 11+
- **RAM:** 2GB (4GB önerilen)
- **Disk:** 20GB (SSD önerilen)
- **CPU:** 2 Core (4 Core önerilen)

### Yazılım Gereksinimleri
```bash
# Ubuntu/Debian için
sudo apt update
sudo apt install -y python3 python3-pip python3-venv nodejs npm nginx git sqlite3 ufw

# CentOS/RHEL için
sudo yum install -y python3 python3-pip nodejs npm nginx git sqlite

# Node.js 16+ gerekli
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## 🗄️ Veritabanı Kurulumu

### 1. Production Veritabanını Oluşturun

```bash
cd /path/to/ustaapp/backend
python3 production_db_setup.py
```

### 2. Veritabanı Yedeklemesi

```bash
# Mevcut veritabanını yedekle
cp app.db app_backup_$(date +%Y%m%d_%H%M%S).db
```

### 3. Veritabanı Görüntüleyici

Veritabanını web üzerinden görüntülemek için:

```bash
python3 database_viewer.py
# http://localhost:5001 adresinden erişin
```

## 🐍 Backend Deployment

### 1. Virtual Environment Oluşturun

```bash
cd /var/www/ustam/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn
```

### 2. Environment Variables

`.env` dosyası oluşturun:

```bash
# Production Environment Variables
SECRET_KEY=your-super-secret-production-key
JWT_SECRET_KEY=jwt-production-secret-key
DEBUG=False
FLASK_ENV=production

# Database
DATABASE_URL=sqlite:///production.db

# Email Configuration
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_DEFAULT_SENDER=noreply@ustam.com

# SMS Configuration
SMS_API_KEY=your-sms-api-key
SMS_API_SECRET=your-sms-api-secret

# Payment Gateway (Iyzico)
IYZICO_API_KEY=your-iyzico-api-key
IYZICO_SECRET_KEY=your-iyzico-secret-key
PAYMENT_TEST_MODE=False

# Google Services
GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# Firebase (Push Notifications)
FIREBASE_SERVER_KEY=your-firebase-server-key
```

### 3. Gunicorn Konfigürasyonu

`gunicorn.conf.py` oluşturun:

```python
bind = "127.0.0.1:5000"
workers = 4
worker_class = "gevent"
worker_connections = 1000
timeout = 120
keepalive = 2
max_requests = 1000
max_requests_jitter = 100
preload_app = True
```

## 🌐 Frontend Deployment

### 1. Frontend Build

```bash
cd /var/www/ustam/web
npm ci --only=production
npm run build
```

### 2. Static Files

```bash
sudo mkdir -p /var/www/html/ustam
sudo cp -r dist/* /var/www/html/ustam/
sudo chown -R www-data:www-data /var/www/html/ustam
```

## ⚙️ Nginx Konfigürasyonu

### 1. Nginx Konfigürasyon Dosyası

`/etc/nginx/sites-available/ustam` oluşturun:

```nginx
server {
    listen 80;
    server_name ustam.com www.ustam.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ustam.com www.ustam.com;
    
    # SSL Configuration
    ssl_certificate /etc/ssl/certs/ustam.com.crt;
    ssl_certificate_key /etc/ssl/private/ustam.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # Frontend static files
    location / {
        root /var/www/html/ustam;
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API endpoints
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # File uploads
    location /uploads/ {
        alias /var/www/ustam/backend/uploads/;
        expires 1y;
        add_header Cache-Control "public";
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
```

### 2. Nginx'i Aktifleştirin

```bash
sudo ln -s /etc/nginx/sites-available/ustam /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 🔒 SSL Sertifikası

### Let's Encrypt ile Ücretsiz SSL

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d ustam.com -d www.ustam.com
```

### SSL Sertifikası Yenileme

```bash
# Otomatik yenileme için crontab
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

## 🔧 Sistem Servisleri

### 1. Systemd Service

`/etc/systemd/system/ustam.service` oluşturun:

```ini
[Unit]
Description=Ustam Flask Application
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/var/www/ustam/backend
Environment=PATH=/var/www/ustam/backend/venv/bin
Environment=FLASK_ENV=production
ExecStart=/var/www/ustam/backend/venv/bin/gunicorn --config gunicorn.conf.py run:app
ExecReload=/bin/kill -s HUP $MAINPID
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 2. Servisi Başlatın

```bash
sudo systemctl daemon-reload
sudo systemctl enable ustam
sudo systemctl start ustam
sudo systemctl status ustam
```

## 📊 Veritabanı Yönetimi

### 1. Veritabanı Şeması

Tüm tablolar ve ilişkiler:

- **users** - Kullanıcı bilgileri
- **customers** - Müşteri profilleri  
- **craftsmen** - Usta profilleri
- **categories** - Hizmet kategorileri
- **jobs** - İş talepleri
- **quotes** - Teklifler
- **messages** - Mesajlar
- **reviews** - Değerlendirmeler
- **payments** - Ödemeler
- **notifications** - Bildirimler
- **system_settings** - Sistem ayarları
- **audit_logs** - İşlem logları

### 2. Veritabanı Görüntüleme

```bash
# Web arayüzü ile
python3 database_viewer.py
# http://localhost:5001

# SQLite komut satırı ile
sqlite3 app.db
.tables
.schema users
SELECT * FROM users LIMIT 10;
```

### 3. Veritabanı Yedekleme

```bash
# Otomatik yedekleme scripti
#!/bin/bash
BACKUP_DIR="/var/backups/ustam"
DB_PATH="/var/www/ustam/backend/app.db"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
cp $DB_PATH $BACKUP_DIR/ustam_backup_$DATE.db
find $BACKUP_DIR -name "*.db" -mtime +30 -delete
```

## 📈 Monitoring ve Logging

### 1. Log Dosyaları

```bash
# Uygulama logları
tail -f /var/log/ustam/app.log

# Nginx logları
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# Systemd service logları
sudo journalctl -u ustam -f
```

### 2. Log Rotation

`/etc/logrotate.d/ustam` oluşturun:

```
/var/log/ustam/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0644 www-data www-data
    postrotate
        systemctl reload ustam
    endscript
}
```

### 3. Sistem Monitoring

```bash
# Sistem kaynaklarını izle
htop
iostat -x 1
df -h
free -h

# Uygulama durumu
systemctl status ustam
systemctl status nginx
```

## 💾 Backup Stratejisi

### 1. Otomatik Yedekleme

```bash
#!/bin/bash
# /usr/local/bin/ustam-backup.sh

BACKUP_DIR="/var/backups/ustam"
APP_DIR="/var/www/ustam"
DATE=$(date +%Y%m%d_%H%M%S)

# Veritabanı yedekleme
cp $APP_DIR/backend/app.db $BACKUP_DIR/db_backup_$DATE.db

# Dosya yedekleme
tar -czf $BACKUP_DIR/files_backup_$DATE.tar.gz $APP_DIR/backend/uploads/

# Eski yedekleri temizle (30 gün)
find $BACKUP_DIR -name "*backup*" -mtime +30 -delete

# Yedekleme logla
echo "$(date): Backup completed" >> /var/log/ustam/backup.log
```

### 2. Crontab ile Otomatik Çalıştırma

```bash
# Her gün 02:00'da yedekleme
0 2 * * * /usr/local/bin/ustam-backup.sh
```

## 🔥 Firewall Konfigürasyonu

```bash
# UFW ile firewall ayarları
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status
```

## 🚨 Güvenlik Önlemleri

### 1. Sistem Güvenliği

```bash
# Sistem güncellemeleri
sudo apt update && sudo apt upgrade -y

# Fail2ban kurulumu
sudo apt install fail2ban
sudo systemctl enable fail2ban
```

### 2. Uygulama Güvenliği

- JWT token'ları düzenli olarak rotate edin
- API rate limiting uygulayın
- Input validation'ı kontrol edin
- HTTPS kullanımını zorunlu kılın
- Veritabanı yedeklerini şifreleyin

## 🔧 Troubleshooting

### Yaygın Sorunlar ve Çözümler

1. **Service başlamıyor:**
```bash
sudo systemctl status ustam
sudo journalctl -u ustam -n 50
```

2. **Nginx 502 Bad Gateway:**
```bash
# Backend servisinin çalıştığını kontrol edin
curl http://localhost:5000/api/categories
```

3. **Database bağlantı hatası:**
```bash
# Dosya izinlerini kontrol edin
ls -la app.db
sudo chown www-data:www-data app.db
```

4. **SSL sertifika hatası:**
```bash
sudo certbot certificates
sudo certbot renew --dry-run
```

## 📞 Destek ve İletişim

- **Email:** admin@ustam.com
- **GitHub Issues:** https://github.com/sudeaydin/ustaapp/issues
- **Documentation:** https://docs.ustam.com

## 🎉 Production Checklist

- [ ] Sistem gereksinimleri karşılandı
- [ ] Veritabanı oluşturuldu ve test edildi
- [ ] Backend servisi çalışıyor
- [ ] Frontend build edildi ve deploy edildi
- [ ] Nginx konfigürasyonu tamamlandı
- [ ] SSL sertifikası kuruldu
- [ ] Firewall ayarları yapıldı
- [ ] Monitoring ve logging aktif
- [ ] Backup stratejisi uygulandı
- [ ] Güvenlik önlemleri alındı
- [ ] Performance testleri yapıldı
- [ ] Kullanıcı kabul testleri tamamlandı

---

🔨 **Ustam Production Deployment Guide v1.0**

Bu rehber ile uygulamanız production ortamında güvenli ve stabil bir şekilde çalışacaktır.