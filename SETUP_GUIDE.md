# 🚀 UstamApp Setup Guide

Bu projede otomatik setup ve çalıştırma script'leri bulunmaktadır.

## 📁 Proje Yapısı

```
C:\FlutterProjects\ustam_mobile_app\
├── backend/                 # Flask Backend
├── ustam_mobile_app/        # Flutter Mobile App
├── web/                     # React Web App
├── setup_and_run.bat        # Windows Otomatik Setup
├── setup_and_run.sh         # macOS/Linux Otomatik Setup
├── quick_restart.bat        # Windows Hızlı Restart
└── SETUP_GUIDE.md          # Bu dosya
```

## 🖥️ Windows Kullanıcıları

### İlk Kurulum (Tam Setup)
```bash
# Projeyi indirin
git clone https://github.com/sudeaydin/ustaapp.git C:\FlutterProjects\ustam_mobile_app

# Setup script'ini çalıştırın
setup_and_run.bat
```

### Hızlı Restart (Proje zaten kurulu)
```bash
quick_restart.bat
```

## 🍎 macOS/Linux Kullanıcıları

### İlk Kurulum (Tam Setup)
```bash
# Projeyi indirin
git clone https://github.com/sudeaydin/ustaapp.git ~/FlutterProjects/ustam_mobile_app

# Script'i executable yapın ve çalıştırın
chmod +x setup_and_run.sh
./setup_and_run.sh
```

## 📋 Script'lerin Yaptığı İşlemler

### `setup_and_run.bat/sh` (Tam Setup)
1. ✅ Git pull (son değişiklikleri çeker)
2. ✅ Python virtual environment oluşturur
3. ✅ Python dependencies yükler
4. ✅ Database oluşturur + sample data ekler
5. ✅ Flutter dependencies yükler
6. ✅ Backend server'ı başlatır (ayrı pencerede)
7. ✅ Flutter app'i başlatır
8. ✅ Ctrl+C ile temizlik yapar

### `quick_restart.bat` (Hızlı Restart)
1. ✅ Mevcut process'leri durdurur
2. ✅ Backend'i restart eder
3. ✅ Flutter'ı restart eder

## 🎯 Özellikler

- **Otomatik Error Handling**: Her adımda error kontrolü
- **Renkli Output**: macOS/Linux'ta renkli çıktı
- **Background Backend**: Backend ayrı pencerede çalışır
- **Cleanup**: Ctrl+C ile otomatik temizlik
- **Flexible Path**: Farklı dizinlerde çalışabilir

## 🔧 Manuel Çalıştırma (Gerekirse)

### Backend
```bash
cd backend
python -m venv venv
venv\Scripts\activate          # Windows
source venv/bin/activate       # macOS/Linux
pip install -r requirements.txt
python create_db_with_data.py
python run.py
```

### Flutter
```bash
cd ustam_mobile_app
flutter pub get
flutter run
```

## 🚨 Troubleshooting

### Backend Çalışmıyor
- Port 5000 boş olduğundan emin olun
- Python 3.8+ yüklü olduğundan emin olun

### Flutter Çalışmıyor
- Flutter SDK yüklü olduğundan emin olun
- Chrome browser yüklü olduğundan emin olun

### Script Çalışmıyor
- Windows'ta: "Run as Administrator" deneyin
- macOS/Linux'ta: `chmod +x setup_and_run.sh` çalıştırın

## 🎉 Test Senaryoları

Script çalıştıktan sonra:

1. **Login**: `customer@test.com` / `password123`
2. **Tutorial**: Otomatik başlayacak - butonlar glow yapacak! ✨
3. **Usta Ara**: 4 usta göreceksiniz
4. **Mesajlar**: Chat sistemi çalışacak

---

**🚀 Tek tıkla tüm sistem hazır!** 💪✨