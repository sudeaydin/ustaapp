# 🔨 Ustam - Güvenilir Usta Bulma Platformu

Modern, güvenilir ve kullanıcı dostu usta bulma platformu. React.js frontend ve Flask backend ile geliştirilmiştir.

## 🚀 Hızlı Başlangıç

### Otomatik Kurulum (Önerilen)
```bash
# Projeyi klonla
git clone https://github.com/sudeaydin/ustaapp.git
cd ustaapp

# Otomatik kurulum
chmod +x setup.sh
./setup.sh
```

### Manuel Kurulum

#### Backend Kurulumu
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python create_db_with_data.py
python run.py
```

#### Frontend Kurulumu
```bash
cd web
npm install
npm start
```

## 📱 Özellikler

### 🏠 Ana Özellikler
- **Modern Web Arayüzü:** Responsive, PWA desteği
- **Usta Arama:** Gelişmiş filtreleme ve arama
- **İş Yönetimi:** Talep oluşturma, takip, tamamlama
- **Mesajlaşma:** Real-time chat sistemi
- **Ödeme Sistemi:** iyzico entegrasyonu
- **Bildirimler:** Real-time bildirim sistemi
- **Analitik Dashboard:** İstatistikler ve raporlar

### 👥 Kullanıcı Tipleri
- **Müşteriler:** İş talebi oluşturma, usta arama
- **Ustalar:** İş teklifleri, portföy yönetimi
- **Admin:** Sistem yönetimi, analitikler

## 🛠️ Teknoloji Stack

### Frontend
- **React.js 18** - UI framework
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **React Router** - Navigation
- **Socket.io Client** - Real-time communication
- **React Query** - Data fetching

### Backend
- **Flask** - Web framework
- **SQLAlchemy** - ORM
- **Flask-SocketIO** - WebSocket support
- **Flask-JWT-Extended** - Authentication
- **SQLite** - Database

## 🌐 API Endpoints

### Kimlik Doğrulama
- `POST /api/auth/login` - Giriş
- `POST /api/auth/register` - Kayıt
- `POST /api/auth/logout` - Çıkış

### Usta İşlemleri
- `GET /api/search/craftsmen` - Usta arama
- `GET /api/craftsmen/:id` - Usta detayı
- `GET /api/categories` - Kategoriler

### İş Yönetimi
- `GET /api/jobs` - İş listesi
- `POST /api/jobs` - İş oluştur
- `PUT /api/jobs/:id` - İş güncelle
- `DELETE /api/jobs/:id` - İş sil

### Ödeme
- `POST /api/payment/process` - Ödeme işle
- `GET /api/payment/history` - Ödeme geçmişi

## 🧪 Test Kullanıcıları

```
Müşteri:
Email: customer@example.com
Şifre: password123

Usta:
Email: craftsman@example.com  
Şifre: password123

Admin:
Email: admin@example.com
Şifre: admin123
```

## 📦 Proje Yapısı

```
ustam/
├── backend/                # Flask backend
│   ├── app/
│   │   ├── models/        # Database models
│   │   ├── routes/        # API endpoints
│   │   └── utils/         # Utility functions
│   ├── config/            # Configuration
│   └── requirements.txt   # Python dependencies
├── web/                   # React frontend
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── pages/         # Page components
│   │   ├── context/       # React contexts
│   │   ├── services/      # API services
│   │   └── utils/         # Utility functions
│   ├── public/            # Static assets
│   └── package.json       # Node dependencies
└── setup.sh              # Otomatik kurulum scripti
```

## 🔧 Geliştirme

### Frontend Geliştirme
```bash
cd web
npm run dev    # Development server
npm run build  # Production build
npm run lint   # Code linting
```

### Backend Geliştirme
```bash
cd backend
source venv/bin/activate
python run.py              # Development server
python create_db_with_data.py  # Reset database
```

## 🚀 Production Deployment

### Frontend Build
```bash
cd web
npm run build
# dist/ klasörü static hosting'e deploy edilebilir
```

### Backend Production
```bash
cd backend
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 run:app
```

## 📱 PWA Özellikleri

- **Offline çalışma** (Service Worker)
- **Ana ekrana ekleme** (Add to Home Screen)
- **Push notifications** (Bildirimler)
- **Responsive design** (Mobil uyumlu)

## 🔒 Güvenlik

- JWT token authentication
- CORS protection
- Input validation
- SQL injection protection
- XSS protection

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Commit yapın (`git commit -m 'Yeni özellik eklendi'`)
4. Push yapın (`git push origin feature/yeni-ozellik`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

- **Geliştirici:** Sude Aydın
- **GitHub:** https://github.com/sudeaydin/ustaapp
- **Email:** info@ustam.com

---

⭐ Bu projeyi beğendiyseniz star vermeyi unutmayın!
