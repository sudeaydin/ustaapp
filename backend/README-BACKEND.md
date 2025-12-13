# Ustalar Backend Kurulum Rehberi

## 1. Gereksinimler
- Python 3.8+
- pip

## 2. Kurulum

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows için: venv\Scripts\activate
pip install -r requirements.txt
```

## 3. Ortam Değişkenleri
`.env` dosyanızı oluşturun (veya `.env.example`'ı kopyalayın):

```bash
cp .env.example .env
```

Gerekirse `DATABASE_URL` ve diğer anahtarları düzenleyin.

## 4. Veritabanı Migrasyonları
```bash
flask db init        # Sadece ilk kez
flask db migrate -m "init"
flask db upgrade
```

## 5. Sunucuyu Başlatma
```bash
flask run
# veya
python -m flask run
```

## 6. Test Kullanıcıları
İlk test için kayıt olabilirsiniz veya seed scripti eklenirse burada belirtilecek.

## 7. API URL
Varsayılan: `http://localhost:5000/api`

## 8. Documentation
For detailed technical documentation, see:
- **[JWT Error Handling](docs/JWT_ERROR_HANDLING.md)** - Complete guide to JWT authentication error handling
- **[Extensions Refactor](docs/REFACTOR_JWT_EXTENSION.md)** - Architecture documentation for the extensions module

---
Sorun yaşarsanız bana bildirin! 