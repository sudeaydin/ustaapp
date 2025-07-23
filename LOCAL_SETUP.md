# 🏠 Local Geliştirme Ortamı Kurulumu

Bu rehber, projeyi kendi bilgisayarınızda VS Code ile çalıştırmanız için hazırlanmıştır.

## 📋 Gereksinimler

- **Node.js** v16+ ([nodejs.org](https://nodejs.org/))
- **Python** 3.8+ ([python.org](https://www.python.org/))
- **Git** ([git-scm.com](https://git-scm.com/))
- **VS Code** ([code.visualstudio.com](https://code.visualstudio.com/))

## 🚀 Hızlı Başlangıç

### 1. Projeyi Klonlayın
```bash
git clone <your-github-repo-url>
cd ustalar-app
```

### 2. Backend Kurulumu (Terminal 1)

```bash
# Backend klasörüne gidin
cd backend

# Python sanal ortamı oluşturun
python -m venv venv

# Sanal ortamı aktif edin
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# Bağımlılıkları yükleyin
pip install -r requirements.txt

# Veritabanını test verileriyle oluşturun
python create_db_with_data.py

# Sunucuyu başlatın
python run.py
```

✅ Backend: http://localhost:5000

### 3. Frontend Kurulumu (Terminal 2)

```bash
# Frontend klasörüne gidin
cd web

# Node.js bağımlılıklarını yükleyin
npm install

# Development sunucusunu başlatın
npm run dev
```

✅ Frontend: http://localhost:5173

## 🧪 Test Kullanıcıları

### 👤 Müşteri Hesabı
- **Email:** musteri@test.com
- **Şifre:** 123456

### 🔨 Usta Hesabı
- **Email:** usta@test.com
- **Şifre:** 123456

### 📝 Diğer Test Hesapları
- mehmet@test.com / 123456 (Elektrikçi)
- fatma@test.com / 123456 (Temizlikçi)
- kemal@test.com / 123456 (Boyacı)

## 🛠️ VS Code Önerilen Eklentiler

Aşağıdaki eklentileri VS Code'a yükleyerek geliştirme deneyiminizi iyileştirebilirsiniz:

### Frontend (React)
- ES7+ React/Redux/React-Native snippets
- Auto Rename Tag
- Bracket Pair Colorizer
- Prettier - Code formatter
- Tailwind CSS IntelliSense

### Backend (Python)
- Python
- Python Docstring Generator
- autoDocstring
- Python Type Hint

### Genel
- GitLens
- Live Server
- Thunder Client (API testi için)

## 📁 Proje Yapısı

```
ustalar-app/
├── 📂 backend/              # Flask API
│   ├── 📂 app/
│   │   ├── 📂 models/       # Veritabanı modelleri
│   │   ├── 📂 routes/       # API endpoints
│   │   └── 📂 services/     # Business logic
│   ├── 📄 create_db_with_data.py  # Test verili DB kurulum
│   ├── 📄 run.py           # Sunucu başlatma
│   └── 📄 requirements.txt # Python bağımlılıkları
├── 📂 web/                 # React Frontend
│   ├── 📂 src/
│   │   ├── 📂 components/  # React bileşenleri
│   │   ├── 📂 pages/      # Sayfa bileşenleri
│   │   ├── 📂 services/   # API servisleri
│   │   └── 📂 context/    # React Context
│   ├── 📄 package.json    # Node.js bağımlılıkları
│   └── 📄 vite.config.js  # Vite konfigürasyonu
└── 📄 README.md           # Proje dokümantasyonu
```

## 🔧 API Endpoints

### 🔐 Authentication
```
POST /api/auth/login        # Giriş yap
POST /api/auth/register     # Kayıt ol
GET  /api/auth/profile      # Profil bilgisi
PUT  /api/auth/profile      # Profil güncelle
```

### 👷 Craftsmen
```
GET  /api/craftsmen/        # Usta listesi (filtreleme destekli)
GET  /api/craftsmen/:id     # Usta detayı
GET  /api/craftsmen/categories  # Kategori listesi
```

### 💬 Quotes
```
POST /api/quotes/           # Teklif talebi oluştur
GET  /api/quotes/           # Kullanıcının teklifleri
GET  /api/quotes/:id        # Teklif detayı
```

## 🧪 API Test Etme

### Thunder Client ile Test
1. VS Code'da Thunder Client eklentisini yükleyin
2. Aşağıdaki örnekleri kullanın:

#### Kayıt Ol
```json
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "123456",
  "confirm_password": "123456",
  "first_name": "Test",
  "last_name": "User",
  "phone": "05551234567",
  "user_type": "customer"
}
```

#### Giriş Yap
```json
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "musteri@test.com",
  "password": "123456"
}
```

#### Usta Listesi
```json
GET http://localhost:5000/api/craftsmen/
```

## 🐛 Sorun Giderme

### Backend Sorunları

**Hata:** `ModuleNotFoundError: No module named 'flask'`
```bash
# Sanal ortamın aktif olduğundan emin olun
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows

# Bağımlılıkları tekrar yükleyin
pip install -r requirements.txt
```

**Hata:** `Database is locked`
```bash
# Veritabanını sıfırlayın
rm -f app.db  # Mac/Linux
del app.db    # Windows
python create_db_with_data.py
```

### Frontend Sorunları

**Hata:** `npm ERR! code ENOENT`
```bash
# Node.js'in doğru versiyonunu kontrol edin
node --version  # v16+ olmalı

# npm cache'i temizleyin
npm cache clean --force
npm install
```

**Hata:** `CORS Error`
- Backend'in çalıştığından emin olun (http://localhost:5000)
- Browser console'da hata detaylarını kontrol edin

## 📱 Geliştirme İpuçları

### Hot Reload
- Frontend değişiklikler otomatik yenilenir
- Backend değişiklikleri için sunucuyu yeniden başlatın

### Debug Modu
```bash
# Backend debug modu
export FLASK_ENV=development  # Mac/Linux
set FLASK_ENV=development     # Windows
python run.py
```

### Database İnceleme
```bash
# SQLite veritabanını görüntülemek için
pip install sqlite-web
sqlite_web app.db
```

## 🚀 Production Build

### Frontend Build
```bash
cd web
npm run build
# dist/ klasöründe production dosyaları oluşur
```

### Backend Production
```bash
cd backend
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 run:app
```

## 🆘 Yardım

Sorun yaşıyorsanız:
1. Terminal'deki hata mesajlarını kontrol edin
2. Browser console'ı (F12) kontrol edin
3. GitHub Issues'da sorun bildirin
4. README.md dosyasını tekrar okuyun

## 📚 Faydalı Linkler

- [React Dokümantasyonu](https://reactjs.org/)
- [Flask Dokümantasyonu](https://flask.palletsprojects.com/)
- [Tailwind CSS](https://tailwindcss.com/)
- [SQLAlchemy](https://sqlalchemy.org/)

---

Mutlu kodlamalar! 🎉