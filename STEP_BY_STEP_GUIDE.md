# 📋 ustam App - Step by Step Kurulum Rehberi

## 🔄 **KOD GÜNCELLEMESİ (Her Zaman İlk Yapılacak)**

```cmd
# Mevcut kod varsa güncelle
cd C:\FlutterProjects\ustaapp
git pull origin main

# İlk kez indiriyorsan
cd C:\FlutterProjects
git clone https://github.com/sudeaydin/ustaapp.git
cd ustaapp
```

---

## 🔧 **BACKEND KURULUMU VE ÇALIŞTIRMA**

### **1. Backend Klasörüne Git:**
```cmd
cd C:\FlutterProjects\ustaapp\backend
```

### **2. Sanal Ortam Oluştur (İsteğe Bağlı Ama Tavsiye Edilir):**
```cmd
python -m venv venv
```

### **3. Sanal Ortamı Aktif Et:**
```cmd
venv\Scripts\activate
```

### **4. Gerekli Python Paketlerini Yükle:**
```cmd
pip install -r requirements.txt
```

### **5. Environment Dosyası Oluştur:**
```cmd
setup_env.bat
```

### **6. Akıllı Database Setup (BigQuery First):**
```cmd
python smart_setup.bat
```
**Otomatik olarak:**
- ✅ BigQuery'de veri varsa oradan çeker
- ✅ BigQuery'de veri yoksa sample data oluşturur

### **7. Backend API'yi Başlat:**
```cmd
python run.py
```

**✅ Backend Hazır:** http://localhost:5000

---

## 📱 **FLUTTER CROSS-PLATFORM (Mobile + Web)**

### **Yeni CMD Penceresi Aç ve:**

### **1. Flutter Klasörüne Git:**
```cmd
cd C:\FlutterProjects\ustaapp\ustam_mobile_app
```

### **2. Flutter Web Support Aktif Et:**
```cmd
flutter config --enable-web
```

### **3. Flutter Dependencies Yükle:**
```cmd
flutter pub get
```

### **4. Web Modunda Çalıştır (Chrome):**
```cmd
flutter run -d chrome --web-port=8080
```

**✅ Flutter Web Hazır:** http://localhost:8080

### **5. Mobile Simulator'de Çalıştır (Ayrı Terminal):**
```cmd
# Yeni CMD penceresi aç
cd C:\FlutterProjects\ustaapp\ustam_mobile_app

# Simulator/device listesi
flutter devices

# Android/iOS çalıştır
flutter run
```

**✅ Flutter Mobile Hazır:** Simulator/Device

---

## 🎯 **ÖZET - TÜM PORTLAR**

Başarılı kurulum sonrası:

- **🔧 Backend API:** http://localhost:5000
- **🌐 Flutter Web:** http://localhost:8080  
- **📱 Flutter Mobile:** Simulator/Device

**❌ React Web yok artık! ❌ Node.js gereksiz!**

---

## 🧪 **TEST HESAPLARI**

```
Müşteri Hesabı:
Email: customer@example.com
Şifre: password123

Usta Hesabı:
Email: craftsman@example.com
Şifre: password123

Admin Hesabı:
Email: admin@example.com
Şifre: admin123
```

---

## ⚡ **HIZLI BAŞLATMA**

### **Her Gün Çalıştırmak İçin:**

```cmd
# 1. Kod güncelle
cd C:\FlutterProjects\ustaapp
git pull origin main

# 2. Flutter + Backend başlat
start_flutter_all.bat
```

### **Veya Tek Tek:**

```cmd
# Terminal 1 - Backend
cd C:\FlutterProjects\ustaapp\backend
venv\Scripts\activate
python run.py

# Terminal 2 - Flutter Web
cd C:\FlutterProjects\ustaapp\ustam_mobile_app
flutter run -d chrome --web-port=8080

# Terminal 3 - Flutter Mobile (İsteğe Bağlı)
cd C:\FlutterProjects\ustaapp\ustam_mobile_app
flutter run
```

---

## 🚨 **SORUN GİDERME**

### **"git pull" Hatası:**
```cmd
# Eğer local değişiklikler varsa
git stash
git pull origin main
git stash pop
```

### **"Backend Başlamıyor":**
```cmd
# Virtual environment aktif mi kontrol et
venv\Scripts\activate
# .env dosyası var mı kontrol et
type .env
# Yoksa oluştur
setup_env.bat
```

### **"Flutter Web Başlamıyor":**
```cmd
# Flutter temizle
flutter clean
flutter pub get
flutter config --enable-web
```

### **"Mobile Başlamıyor":**
```cmd
# Flutter temizle
flutter clean
flutter pub get
```

### **"Port Kullanımda":**
```cmd
# Port'u kullanan process'i bul ve öldür
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

---

## ✅ **BAŞARILI KURULUM KONTROLÜ**

Tüm servisler çalışıyorsa:

1. **Backend:** http://localhost:5000/api/health → `{"status": "healthy"}`
2. **Flutter Web:** http://localhost:8080 → ustam Flutter web uygulaması açılır
3. **Flutter Mobile:** Simulator/Device → ustam Flutter mobile uygulaması açılır

**Happy Coding! 🚀**