# 🔧 UstamApp - Profesyonel Usta Bulucu Platform

UstamApp, müşteriler ile yetenekli ustalar arasında köprü kuran modern bir platform. Elektrikçi, tesisatçı, boyacı ve daha birçok alanda hizmet veren ustaları kolayca bulabilir, teklif alabilir ve güvenli ödeme yapabilirsiniz.

## 🚀 **Özellikler**

### 👥 **Kullanıcı Yönetimi**
- ✅ Müşteri ve Usta hesap tipleri
- ✅ JWT tabanlı güvenli kimlik doğrulama
- ✅ Profil yönetimi ve hesap silme
- ✅ KVKK uyumlu veri işleme

### 🔍 **Arama ve Keşif**
- ✅ Gelişmiş usta arama ve filtreleme
- ✅ Şehir, kategori ve rating bazlı filtreleme
- ✅ Detaylı usta profil sayfaları
- ✅ Portfolio görüntüleme

### 💬 **Teklif Sistemi**
- ✅ Müşteriden ustaya teklif talebi
- ✅ Usta teklif verme, detay isteme, reddetme
- ✅ Müşteri teklif kabul/red/revizyon
- ✅ Gerçek zamanlı mesajlaşma entegrasyonu

### 💳 **Ödeme ve İş Yönetimi**
- ✅ Güvenli ödeme sistemi (iyzico entegrasyonu)
- ✅ İş takibi ve durum güncellemeleri
- ✅ İş geçmişi ve fatura yönetimi

### 📱 **Çoklu Platform**
- ✅ Responsive web uygulaması (PWA)
- ✅ Native mobile app (Flutter)
- ✅ Real-time sync between platforms

## 🏗️ **Teknik Mimari**

### Backend (Flask)
```
backend/
├── app/
│   ├── models/          # Veritabanı modelleri
│   ├── routes/          # API endpoint'leri
│   ├── utils/           # Yardımcı fonksiyonlar
│   └── __init__.py      # Flask app factory
├── tests/               # Test dosyaları
└── requirements.txt     # Python bağımlılıkları
```

### Frontend Web (React + Vite)
```
web/
├── src/
│   ├── components/      # React bileşenleri
│   ├── pages/           # Sayfa bileşenleri
│   ├── hooks/           # Custom React hooks
│   ├── utils/           # Yardımcı fonksiyonlar
│   └── App.jsx          # Ana uygulama
├── public/              # Statik dosyalar
└── package.json         # Dependencies
```

### Mobile App (Flutter)
```
ustam_mobile_app/
├── lib/
│   ├── features/        # Feature-based architecture
│   ├── core/            # Core utilities and themes
│   └── main.dart        # Ana uygulama
├── assets/              # Görseller ve dosyalar
└── pubspec.yaml         # Flutter dependencies
```

## 🛠️ **Kurulum ve Çalıştırma**

### Backend Kurulumu
```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate

pip install -r requirements.txt
python create_db_with_data.py
python run.py
```

### Frontend Web Kurulumu
```bash
cd web
npm install
npm run dev
```

### Mobile App Kurulumu
```bash
cd ustam_mobile_app
flutter pub get
flutter run
```

## 📚 **API Dokümantasyonu**

### Kimlik Doğrulama Endpoints

#### POST `/api/auth/register`
Yeni kullanıcı kaydı oluşturur.

**Request Body:**
```json
{
  "email": "user@example.com",
  "phone": "+905551234567",
  "password": "securepassword",
  "first_name": "Ad",
  "last_name": "Soyad",
  "user_type": "customer|craftsman",
  // Customer için
  "billing_address": "Adres",
  "city": "İstanbul",
  "district": "Kadıköy",
  // Craftsman için
  "business_name": "İşletme Adı",
  "description": "Açıklama",
  "specialties": "Uzmanlık alanları",
  "experience_years": 5,
  "hourly_rate": 150.0
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "jwt_token",
    "user": { ... },
    "profile": { ... }
  }
}
```

#### POST `/api/auth/login`
Kullanıcı girişi yapar.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

### Teklif Sistemi Endpoints

#### POST `/api/quotes/create-request`
Yeni teklif talebi oluşturur.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "craftsman_id": 1,
  "category": "Elektrik",
  "area_type": "salon",
  "square_meters": 50,
  "budget_range": "1000-3000",
  "description": "İş açıklaması",
  "additional_details": "Ek detaylar"
}
```

#### POST `/api/quotes/{quote_id}/respond`
Usta teklif talebine yanıt verir.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "response_type": "give_quote|request_details|reject",
  "quoted_amount": 2500.0,
  "response_details": "Detaylı açıklama",
  "estimated_start_date": "2024-02-01",
  "estimated_end_date": "2024-02-03"
}
```

### Arama Endpoints

#### GET `/api/search/craftsmen`
Usta arama yapar.

**Query Parameters:**
- `query`: Arama terimi
- `city`: Şehir filtresi
- `category`: Kategori filtresi
- `min_rating`: Minimum rating
- `max_rate`: Maksimum saat ücreti
- `page`: Sayfa numarası
- `per_page`: Sayfa başına sonuç

## 🧪 **Test Çalıştırma**

### Backend Testleri
```bash
cd backend
pytest
pytest --cov=app --cov-report=html
```

### Frontend Testleri
```bash
cd web
npm test
npm run test:coverage
```

### Mobile Testleri
```bash
cd ustam_mobile_app
flutter test
```

## 🔒 **Güvenlik**

- **Rate Limiting**: API endpoint'leri için istek sınırlaması
- **Input Sanitization**: XSS ve injection koruması
- **CORS**: Cross-origin güvenlik politikaları
- **JWT Authentication**: Güvenli token tabanlı kimlik doğrulama
- **File Upload Security**: Güvenli dosya yükleme
- **Password Hashing**: PBKDF2 ile güvenli şifre hashleme

## 📊 **Veritabanı**

### Ana Tablolar
- **users**: Kullanıcı bilgileri
- **customers**: Müşteri profilleri
- **craftsmen**: Usta profilleri
- **quotes**: Teklif talepleri ve yanıtları
- **messages**: Mesajlaşma geçmişi
- **jobs**: İş takibi

### İlişkiler
- User → Customer/Craftsman (1:1)
- Customer → Quotes (1:N)
- Craftsman → Quotes (1:N)
- Quote → Messages (1:N)

## 🌐 **Deployment**

### Production Checklist
- [ ] Environment variables ayarları
- [ ] Database migration
- [ ] SSL sertifikası
- [ ] CDN konfigürasyonu
- [ ] Monitoring setup
- [ ] Backup stratejisi

### Environment Variables
```bash
# Backend
FLASK_ENV=production
JWT_SECRET_KEY=your_secret_key
DATABASE_URL=postgresql://...
IYZICO_API_KEY=your_api_key
IYZICO_SECRET_KEY=your_secret_key

# Frontend
VITE_API_BASE_URL=https://api.ustamapp.com
VITE_SOCKET_URL=wss://api.ustamapp.com
```

## 🤝 **Katkıda Bulunma**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 **Lisans**

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakınız.

## 🆘 **Destek**

Herhangi bir sorun yaşarsanız:
- GitHub Issues açın
- Email: support@ustamapp.com
- Telegram: @ustamapp_support

---

**UstamApp Team** 💙