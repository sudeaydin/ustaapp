# 🚀 **ustam - PRODUCTION DEPLOYMENT CHECKLIST**

Bu checklist ile uygulamanızı hızlı ve güvenli bir şekilde canlıya çıkarabilirsiniz.

---

## ✅ **ÖN HAZIRLIK (5 dakika)**

### **1. Google Cloud Setup**
- [ ] Google Cloud hesabı oluşturuldu
- [ ] Billing account aktifleştirildi  
- [ ] Yeni proje oluşturuldu (örn: `ustam-production`)
- [ ] gcloud CLI kuruldu ve auth yapıldı
```bash
gcloud auth login
gcloud config set project ustam-production
```

### **2. Domain Hazırlığı (Opsiyonel)**
- [ ] Domain satın alındı (örn: `ustam.com`)
- [ ] DNS yönetim paneline erişim sağlandı
- [ ] SSL sertifikası hazırlığı yapıldı

---

## 🔧 **HIZLI DEPLOYMENT (10 dakika)**

### **Tek Komut Deployment:**
```bash
# Windows
deploy_production_quick.bat ustam-production

# Linux/Mac
./deploy_production_quick.sh ustam-production
```

### **Manuel Deployment Adımları:**

#### **1. Backend Deployment**
```bash
cd backend

# Dependencies
pip install -r requirements.txt

# Analytics Setup
python production_analytics_setup.py ustam-production --environment production

# Database Setup
python create_db_with_data.py

# Deploy to App Engine
gcloud app deploy
```

#### **2. Mobile App Update**
```bash
# Update API URLs
python update_mobile_urls_production.py ustam-production

# Build mobile app
cd ustam_mobile_app
flutter clean && flutter pub get
flutter build apk --release
```

---

## 📊 **ANALYTICS & MONITORING SETUP (5 dakika)**

### **BigQuery Analytics**
- [ ] BigQuery dataset oluşturuldu: `ustam_analytics`
- [ ] 16 analytics tablosu oluşturuldu
- [ ] Real-time streaming aktifleştirildi
- [ ] Dashboard view'ları oluşturuldu

### **Monitoring Setup**
```bash
# Analytics Dashboard
cd backend
streamlit run enhanced_analytics_dashboard.py
```

### **Verification**
- [ ] Analytics health check: `https://YOUR-PROJECT.appspot.com/api/analytics/v2/health`
- [ ] BigQuery console: `https://console.cloud.google.com/bigquery?project=YOUR-PROJECT`
- [ ] Real-time dashboard çalışıyor

---

## 🔒 **SECURITY & CONFIGURATION**

### **Environment Variables**
- [ ] `.env.production` dosyası oluşturuldu
- [ ] Secret keys güncellendi (production values)
- [ ] CORS origins production domain'e ayarlandı
- [ ] Database URL production'a ayarlandı

### **Security Checklist**
- [ ] JWT secret keys değiştirildi
- [ ] Admin kullanıcı şifreleri güncellendi
- [ ] API rate limiting aktifleştirildi
- [ ] HTTPS zorunlu hale getirildi
- [ ] Security headers eklendi

---

## 🌐 **DOMAIN & SSL SETUP (Opsiyonel)**

### **Custom Domain Configuration**
```bash
# Add custom domain
gcloud app domain-mappings create yourdomain.com

# Verify domain ownership
gcloud app domain-mappings list
```

### **DNS Configuration**
```
A Record: @ → GAE IP (gcloud app describe'dan alın)
CNAME: www → gae-app-url.appspot.com
```

### **SSL Certificate**
- [ ] Google managed SSL certificate otomatik oluşturuldu
- [ ] HTTPS redirect aktifleştirildi
- [ ] Mixed content uyarıları düzeltildi

---

## 📱 **MOBILE APP DEPLOYMENT**

### **Android**
```bash
cd ustam_mobile_app

# Production build
flutter build apk --release

# Upload to Play Store
# - APK: build/app/outputs/flutter-apk/app-release.apk
# - Store listing hazırlandı
# - Screenshots eklendi
```

### **iOS (Opsiyonel)**
```bash
# iOS build (Mac gerekli)
flutter build ios --release

# Upload to App Store
# - Xcode ile archive
# - App Store Connect'e upload
```

---

## 🧪 **TESTING & VERIFICATION**

### **Backend API Testing**
- [ ] Health check: `GET /api/health`
- [ ] Auth endpoints: `POST /api/auth/login`
- [ ] Craftsmen list: `GET /api/craftsmen`
- [ ] Job creation: `POST /api/jobs`
- [ ] Search functionality: `GET /api/search/craftsmen`

### **Analytics Testing**
- [ ] Real-time dashboard loading
- [ ] User activity logging çalışıyor
- [ ] Error tracking aktif
- [ ] Performance metrics toplanıyor

### **Mobile App Testing**
- [ ] API connection çalışıyor
- [ ] Login/Register işlemleri
- [ ] Job creation ve listing
- [ ] Search functionality
- [ ] Real-time messaging

### **Load Testing (Opsiyonel)**
```bash
# Simple load test
curl -X GET https://YOUR-PROJECT.appspot.com/api/health

# Advanced load testing
# - Use tools like Apache Bench, JMeter
# - Test concurrent users
# - Monitor response times
```

---

## 📈 **POST-DEPLOYMENT MONITORING**

### **Immediate Checks (İlk 24 saat)**
- [ ] Application logs kontrol edildi
- [ ] Error rates normal seviyede
- [ ] Response times kabul edilebilir
- [ ] User registrations çalışıyor
- [ ] Payment system test edildi

### **Analytics Monitoring**
- [ ] Real-time user activity görünüyor
- [ ] Conversion funnels çalışıyor  
- [ ] Revenue tracking aktif
- [ ] Error analytics çalışıyor

### **Performance Monitoring**
```bash
# Check app performance
gcloud app logs tail -s default

# Monitor BigQuery costs
# BigQuery Console > Job History > Check costs
```

---

## 🚨 **TROUBLESHOOTING**

### **Common Issues & Solutions**

#### **"Application Error" on App Engine**
```bash
# Check logs
gcloud app logs tail -s default

# Common fixes:
# 1. Check requirements.txt dependencies
# 2. Verify app.yaml configuration  
# 3. Check environment variables
# 4. Verify database initialization
```

#### **BigQuery Connection Failed**
```bash
# Verify setup
python -c "from app.utils.bigquery_logger import bigquery_logger; print('Status:', 'OK' if bigquery_logger.client else 'FAILED')"

# Common fixes:
# 1. Check project ID in environment
# 2. Verify BigQuery API enabled
# 3. Check service account permissions
```

#### **Mobile App Can't Connect**
```bash
# Verify API URLs updated
python update_mobile_urls_production.py YOUR-PROJECT-ID

# Common fixes:
# 1. Update API base URL in Flutter app
# 2. Check CORS configuration
# 3. Verify HTTPS certificate
# 4. Test API endpoints manually
```

#### **Analytics Dashboard Not Loading**
```bash
# Install dependencies
pip install streamlit plotly pandas

# Run dashboard
streamlit run backend/enhanced_analytics_dashboard.py

# Common fixes:
# 1. Check BigQuery credentials
# 2. Verify project permissions
# 3. Check internet connection
```

---

## 📋 **FINAL CHECKLIST**

### **Pre-Launch Verification**
- [ ] ✅ Backend deployed and accessible
- [ ] ✅ Database initialized with sample data
- [ ] ✅ Analytics pipeline working
- [ ] ✅ Mobile app updated and tested
- [ ] ✅ Custom domain configured (if applicable)
- [ ] ✅ SSL certificate active
- [ ] ✅ Monitoring and alerts setup
- [ ] ✅ Error tracking functional
- [ ] ✅ Performance metrics collecting

### **Launch Readiness**
- [ ] ✅ All critical features tested
- [ ] ✅ User registration/login working
- [ ] ✅ Job posting and search functional
- [ ] ✅ Payment system operational
- [ ] ✅ Real-time messaging active
- [ ] ✅ Admin panel accessible
- [ ] ✅ Analytics dashboard running
- [ ] ✅ Mobile app ready for store submission

### **Post-Launch Monitoring**
- [ ] ✅ Real-time monitoring active
- [ ] ✅ Error alerts configured
- [ ] ✅ Performance baselines established
- [ ] ✅ User feedback collection setup
- [ ] ✅ Analytics reporting scheduled
- [ ] ✅ Backup and recovery tested

---

## 🎯 **SUCCESS METRICS**

### **Technical Metrics**
- **Uptime:** > 99.9%
- **Response Time:** < 2 seconds
- **Error Rate:** < 1%
- **Mobile App Rating:** > 4.0 stars

### **Business Metrics**
- **User Registrations:** Track daily signups
- **Job Postings:** Monitor job creation rate
- **Successful Matches:** Track completed jobs
- **Revenue:** Monitor payment transactions

---

## 🔗 **USEFUL LINKS**

- **Production App:** https://YOUR-PROJECT.appspot.com
- **Analytics Dashboard:** http://localhost:8501 (Streamlit)
- **BigQuery Console:** https://console.cloud.google.com/bigquery?project=YOUR-PROJECT
- **App Engine Console:** https://console.cloud.google.com/appengine?project=YOUR-PROJECT
- **Monitoring:** https://console.cloud.google.com/monitoring?project=YOUR-PROJECT

---

## 📞 **SUPPORT & MAINTENANCE**

### **Regular Maintenance Tasks**
- **Weekly:** Check error logs and performance metrics
- **Monthly:** Review analytics data and user feedback
- **Quarterly:** Update dependencies and security patches
- **Yearly:** Renew domain and SSL certificates

### **Emergency Contacts**
- **Technical Issues:** Check GitHub issues
- **Analytics Problems:** Review BigQuery logs
- **Performance Issues:** Monitor App Engine metrics

---

**🎉 Tebrikler! ustam uygulamanız artık canlıda ve kullanıma hazır!**

**📊 Analytics ile veriye dayalı kararlar alabilir, kullanıcı davranışlarını takip edebilir ve işinizi büyütebilirsiniz.**