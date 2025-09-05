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

### **6. Veritabanını ve Test Verisini Oluştur:**
```cmd
python create_db_with_data.py
```

### **7. Backend API'yi Başlat:**
```cmd
python run.py
```

**✅ Backend Hazır:** http://localhost:5000

---

## 🌐 **WEB FRONTEND KURULUMU VE ÇALIŞTIRMA**

### **Yeni CMD Penceresi Aç ve:**

### **1. Web Klasörüne Git:**
```cmd
cd C:\FlutterProjects\ustaapp\web
```

### **2. Node.js Dependencies Yükle:**
```cmd
npm install
```

### **3. Development Server Başlat:**
```cmd
npm run dev
```

**✅ Web App Hazır:** http://localhost:5173

---

## 📱 **FLUTTER MOBİL UYGULAMA KURULUMU VE ÇALIŞTIRMA**

### **Yeni CMD Penceresi Aç ve:**

### **1. Mobile Klasörüne Git:**
```cmd
cd C:\FlutterProjects\ustaapp\ustam_mobile_app
```

### **2. Flutter Dependencies Yükle:**
```cmd
flutter pub get
```

### **3. Web Modunda Çalıştır (Chrome):**
```cmd
flutter run -d chrome --web-port=8080
```

**✅ Mobile App Hazır:** http://localhost:8080

### **4. Android/iOS Simulator'de Çalıştır:**
```cmd
# Simulator/device listesi
flutter devices

# Belirli device'da çalıştır
flutter run -d <device_id>

# Veya sadece
flutter run
```

---

## 🎯 **ÖZET - TÜM PORTLAR**

Başarılı kurulum sonrası:

- **🔧 Backend API:** http://localhost:5000
- **🌐 Web App:** http://localhost:5173  
- **📱 Mobile Web:** http://localhost:8080
- **📱 Mobile Native:** Simulator/Device

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

# 2. Hepsini başlat
start_all_windows.bat
```

### **Veya Tek Tek:**

```cmd
# Terminal 1 - Backend
cd C:\FlutterProjects\ustaapp\backend
venv\Scripts\activate
python run.py

# Terminal 2 - Web  
cd C:\FlutterProjects\ustaapp\web
npm run dev

# Terminal 3 - Mobile
cd C:\FlutterProjects\ustaapp\ustam_mobile_app
flutter run -d chrome --web-port=8080
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

### **"Web Başlamıyor":**
```cmd
# Node modules temizle
rm -rf node_modules
npm install
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
2. **Web:** http://localhost:5173 → ustam web sayfası açılır
3. **Mobile:** http://localhost:8080 → ustam mobile web versiyonu açılır

**Happy Coding! 🚀**