# 🚀 Ustam App - Production Deployment Guide (ustancepte.com)

## 📋 **DEPLOYMENT ÖZET**

### **🎯 Hedef Yapı:**
```
ustancepte.com → Flutter Web (Ana site)
ustancepte.com/api → Flask Backend (API)
BigQuery → Analytics (ustaapp-analytics project)
Mobile Apps → Production API kullanır
```

### **💰 Maliyet:**
- **Google Cloud:** $0-20/ay (bedava tier + az kullanım)
- **Domain:** Zaten var (ustancepte.com)
- **Total:** ~$0-20/ay

---

## 🚀 **DEPLOYMENT KOMUTLARI**

### **1. Ana Deployment (Tek Komut):**
```cmd
cd C:\FlutterProjects\ustaapp
deploy_production_ustancepte.bat
```

### **2. Mobile App URL Update:**
```cmd
update_mobile_api_urls.bat
```

---

## 📊 **SONUÇ URL'LER**

### **🌐 Web Siteleri:**
- **Ana Site:** https://ustancepte.com
- **WWW:** https://www.ustancepte.com
- **Backend API:** https://ustaapp-analytics.appspot.com/api

### **📱 Mobile App API:**
- **Production:** https://ustaapp-analytics.appspot.com/api
- **Development:** http://localhost:5000/api (otomatik switch)

### **📊 Analytics:**
- **BigQuery Console:** https://console.cloud.google.com/bigquery?project=ustaapp-analytics
- **App Engine Console:** https://console.cloud.google.com/appengine?project=ustaapp-analytics

---

## 🧪 **TEST KOMUTLARI**

### **Backend API Test:**
```bash
curl https://ustaapp-analytics.appspot.com/api/health
curl https://ustaapp-analytics.appspot.com/api/legal/documents/all
curl https://ustaapp-analytics.appspot.com/api/craftsmen
```

### **Frontend Test:**
```
https://ustancepte.com → Ana sayfa açılmalı
https://ustancepte.com/login → Login sayfası
https://ustancepte.com/legal → Legal belgeler
```

---

## 🔧 **DEPLOYMENT SONRASI YAPILANLAR**

### **✅ Backend (App Engine):**
- Flask API deployed
- BigQuery logging aktif
- Production environment variables
- HTTPS otomatik
- Auto-scaling aktif

### **✅ Frontend (Static Hosting):**
- Flutter Web build
- Static file hosting
- Custom domain mapping
- HTTPS certificate

### **✅ BigQuery Analytics:**
- All tables created
- Daily sync scheduled (2 AM Istanbul time)
- Real-time logging active
- Business metrics automated

### **✅ Domain Configuration:**
- ustancepte.com → Web app
- www.ustancepte.com → Web app
- SSL certificates automatic

---

## 📱 **MOBILE APP STORE DEPLOYMENT**

### **Android (Google Play):**
```cmd
cd ustam_mobile_app
flutter build apk --release
# APK file: build/app/outputs/flutter-apk/app-release.apk
```

### **iOS (App Store):**
```cmd
cd ustam_mobile_app
flutter build ios --release
# Open Xcode and archive for App Store
```

---

## 🔄 **GÜNCELLEMELER**

### **Code Update:**
```cmd
# Code değişikliği sonrası
git push origin main
deploy_production_ustancepte.bat  # Yeniden deploy
```

### **Domain Değiştirme:**
```cmd
# Yeni domain için
gcloud app domain-mappings create yenidomain.com --certificate-management=automatic
```

### **Mobile App Update:**
```cmd
# API URL değiştirme
update_mobile_api_urls.bat
flutter build apk --release  # Yeni APK build
```

---

## 📊 **MONITORING & ANALYTICS**

### **App Engine Monitoring:**
```
https://console.cloud.google.com/appengine/instances?project=ustaapp-analytics
```

### **BigQuery Analytics:**
```sql
-- Daily user stats
SELECT * FROM `ustaapp-analytics.ustam_analytics.business_metrics` 
ORDER BY date DESC LIMIT 30;

-- Real-time activity
SELECT * FROM `ustaapp-analytics.ustam_analytics.user_activity_logs` 
WHERE DATE(timestamp) = CURRENT_DATE()
ORDER BY timestamp DESC LIMIT 100;
```

### **Error Monitoring:**
```
Google Cloud Console → Error Reporting
```

---

## 🚨 **TROUBLESHOOTING**

### **"Deployment failed"**
```bash
# Check authentication
gcloud auth list
gcloud auth login

# Check project permissions
gcloud projects get-iam-policy ustaapp-analytics
```

### **"Domain not working"**
```bash
# Check domain mapping
gcloud app domain-mappings list

# Check DNS (wait 24-48 hours for propagation)
nslookup ustancepte.com
```

### **"API not responding"**
```bash
# Check App Engine logs
gcloud app logs tail -s default

# Check instance status
gcloud app instances list
```

---

## 🎉 **SUCCESS CHECKLIST**

After successful deployment:

- [ ] **https://ustancepte.com** loads Flutter web app
- [ ] **Backend API** responds at `/api/health`
- [ ] **Legal documents** accessible at `/api/legal/documents/all`
- [ ] **BigQuery** tables created and data syncing
- [ ] **Mobile app** connects to production API
- [ ] **Custom domain** working with HTTPS
- [ ] **Analytics** data flowing to BigQuery

---

**🎯 Ready for production! Your ustam app is now live on ustancepte.com!** 🚀