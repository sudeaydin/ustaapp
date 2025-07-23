# 🔨 Ustalar App - Usta Bulma Platformu

Modern, kullanıcı dostu usta bulma ve hizmet talep etme platformu.

## 📱 Özellikler

### Frontend (React)
- ✅ Modern mobil-first tasarım
- ✅ Kullanıcı kayıt/giriş sistemi
- ✅ Kategori bazlı usta arama
- ✅ Usta profil detayları
- ✅ Teklif isteme formu
- ✅ Responsive tasarım
- ✅ Loading states ve animasyonlar

### Backend (Flask)
- ✅ RESTful API
- ✅ JWT Authentication
- ✅ SQLite veritabanı
- ✅ User & Craftsman modelleri
- ✅ Quote & Review sistemi
- ✅ Güvenli API endpoints

## 🚀 Hızlı Başlangıç

### Gereksinimler
- Node.js (v16+)
- Python (3.8+)
- Git

### 1. Projeyi Klonla
```bash
git clone <repository-url>
cd ustalar-app
```

### 2. Backend Kurulumu
```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate
# Mac/Linux
source venv/bin/activate

pip install -r requirements.txt
python create_db.py
python run.py
```

Backend: http://localhost:5000

### 3. Frontend Kurulumu
```bash
cd web
npm install
npm run dev
```

Frontend: http://localhost:5173

## 📁 Proje Yapısı

```
ustalar-app/
├── backend/                 # Flask API
│   ├── app/
│   │   ├── models/         # Veritabanı modelleri
│   │   ├── routes/         # API endpoints
│   │   ├── schemas/        # Validation schemas
│   │   └── services/       # Business logic
│   ├── create_db.py        # Veritabanı kurulumu
│   └── run.py             # Sunucu başlatma
├── web/                    # React Frontend
│   ├── src/
│   │   ├── components/     # React bileşenleri
│   │   ├── pages/         # Sayfa bileşenleri
│   │   └── services/      # API servisleri
│   └── package.json
└── README.md
```

## 🎯 Test Kullanıcıları

### Müşteri
- Email: musteri@test.com
- Şifre: 123456

### Usta
- Email: usta@test.com
- Şifre: 123456

## 🔧 API Endpoints

### Auth
- POST `/api/auth/login` - Giriş yap
- POST `/api/auth/register` - Kayıt ol

### Craftsmen
- GET `/api/craftsman` - Usta listesi
- GET `/api/craftsman/:id` - Usta detayı

### Quotes
- POST `/api/quotes` - Teklif iste
- GET `/api/quotes` - Teklif listesi

## 🛠️ Teknolojiler

### Frontend
- React 18
- React Router 6
- Tailwind CSS
- TanStack Query
- Vite

### Backend
- Flask
- SQLAlchemy
- JWT
- Marshmallow
- SQLite

## 📝 Lisans

MIT License

## 👥 Katkıda Bulunma

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 İletişim

Proje hakkında sorularınız için issue açabilirsiniz.
