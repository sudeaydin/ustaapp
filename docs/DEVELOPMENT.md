# Ustalar App - Geliştirme Kılavuzu

## Proje Yapısı

```
ustalar-app/
├── backend/          # Python Flask API
│   ├── app/
│   │   ├── models/   # Veritabanı modelleri
│   │   ├── routes/   # API endpoint'leri
│   │   ├── services/ # İş mantığı
│   │   ├── schemas/  # Veri doğrulama
│   │   └── utils/    # Yardımcı fonksiyonlar
│   ├── config/       # Konfigürasyon
│   ├── migrations/   # Veritabanı migrasyonları
│   └── tests/        # Test dosyaları
├── web/              # React web uygulaması
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── utils/
│   └── public/
├── mobile/           # React Native mobil app
│   ├── app/          # Expo Router
│   ├── components/
│   ├── services/
│   └── utils/
├── shared/           # Ortak kod ve tipler
│   ├── types/
│   ├── constants/
│   ├── utils/
│   └── api/
└── docs/             # Dokümantasyon
```

## Geliştirme Ortamı Kurulumu

### Backend (Python Flask)

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Veritabanını başlat
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

# Geliştirme sunucusunu çalıştır
flask run
```

### Web Frontend (React)

```bash
cd web
npm install
npm run dev
```

### Mobile App (React Native + Expo)

```bash
cd mobile
npm install
npm start
```

## Teknoloji Stack

### Backend
- **Framework**: Flask 3.0
- **Database**: SQLAlchemy + SQLite (geliştirme), PostgreSQL (production)
- **Authentication**: JWT
- **API Documentation**: Swagger/OpenAPI
- **Testing**: pytest

### Frontend (Web)
- **Framework**: React 18
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **State Management**: TanStack Query
- **Routing**: React Router
- **HTTP Client**: Axios

### Mobile
- **Framework**: React Native + Expo
- **Navigation**: Expo Router
- **State Management**: TanStack Query
- **Icons**: React Native Vector Icons

## API Endpoints

### Authentication
- `POST /api/auth/register` - Kullanıcı kaydı
- `POST /api/auth/login` - Giriş
- `POST /api/auth/logout` - Çıkış
- `POST /api/auth/refresh` - Token yenileme

### Craftsman (Usta)
- `GET /api/craftsman/profile` - Profil bilgisi
- `PUT /api/craftsman/profile` - Profil güncelleme
- `GET /api/craftsman/services` - Hizmetler listesi
- `POST /api/craftsman/services` - Yeni hizmet ekleme

### Customer (Müşteri)
- `GET /api/customer/profile` - Profil bilgisi
- `PUT /api/customer/profile` - Profil güncelleme
- `POST /api/quotes` - Teklif talebi
- `GET /api/quotes` - Teklifler listesi

### Services
- `GET /api/services` - Hizmetler arama
- `GET /api/services/:id` - Hizmet detayı
- `GET /api/categories` - Kategoriler

## Veritabanı Modelleri

### User (Temel Kullanıcı)
- id, email, phone, password_hash
- user_type (customer/craftsman/admin)
- first_name, last_name, profile_image
- is_active, is_verified, phone_verified

### Category (Hizmet Kategorisi)
- id, name, description, icon, color
- is_active, sort_order

### Service (Hizmet)
- id, craftsman_id, category_id
- title, description, price_min, price_max
- price_unit, is_active

### Quote (Teklif)
- id, customer_id, craftsman_id, service_id
- status, description, price, notes

## Önemli Özellikler

### 1. Kullanıcı Yetkilendirme
- JWT tabanlı authentication
- Role-based access control
- SMS ile telefon doğrulama

### 2. Teklif Sistemi
- Müşteri teklif talebi gönderir
- Usta karşı teklif verebilir
- Anlaşma sonrası chat aktif olur

### 3. Abonelik Sistemi
- Sadece ustalardan aylık abonelik ücreti
- Farklı abonelik paketleri

### 4. Ödeme Entegrasyonu
- İyzico ile güvenli ödeme
- Abonelik otomatik yenileme

### 5. Sertifika Sistemi
- Vergi levhası doğrulama
- Meslek sertifikaları

## Güvenlik

- CORS politikaları
- Rate limiting
- Input validation
- SQL injection koruması
- XSS koruması
- HTTPS zorunluluğu (production)

## Testing

### Backend
```bash
cd backend
source venv/bin/activate
pytest
```

### Frontend
```bash
cd web
npm test
```

## Deployment

### Backend (Production)
- Gunicorn + Nginx
- PostgreSQL veritabanı
- Redis cache
- SSL sertifikası

### Frontend
- Vercel/Netlify (web)
- Expo EAS Build (mobile)

## Geliştirme Süreci

1. Feature branch oluştur
2. Kod yaz ve test et
3. Pull request aç
4. Code review
5. Main branch'e merge

## Ortam Değişkenleri

### Backend (.env)
```
FLASK_ENV=development
DATABASE_URL=sqlite:///ustalar.db
JWT_SECRET_KEY=your-secret-key
TWILIO_ACCOUNT_SID=your-twilio-sid
IYZICO_API_KEY=your-iyzico-key
```

### Frontend (.env.local)
```
VITE_API_URL=http://localhost:5000
VITE_APP_NAME=Ustalar
```

## İletişim

- **Backend API**: http://localhost:5000
- **Web App**: http://localhost:3000
- **Mobile**: Expo Go uygulaması ile
