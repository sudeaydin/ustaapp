# 🚀 **ustam - CANLIYA ÇIKMA REHBERİ**

**Project:** `ustaapp-analytics`  
**Deployment URL:** `https://ustaapp-analytics.appspot.com`

---

## ⚡ **HIZLI DEPLOYMENT (10 Dakika)**

### **Önkoşullar:**
1. **Google Cloud CLI** kurulu olmalı
   ```bash
   # CLI kurulumu kontrolü
   gcloud --version
   
   # Kurulu değilse: https://cloud.google.com/sdk/docs/install
   ```

2. **Authentication** yapılmış olmalı
   ```bash
   gcloud auth login
   gcloud config set project ustaapp-analytics
   ```

### **Tek Komut Deployment:**
```bash
# Windows
quick_deploy_ustaapp.bat

# Linux/Mac
./quick_deploy_ustaapp.sh
```

---

## 📋 **MANUEL DEPLOYMENT ADIMLARI**

### **1. Proje Hazırlığı**
```bash
cd /workspace
git pull origin main  # Son değişiklikleri al
```

### **2. Google Cloud Setup**
```bash
gcloud config set project ustaapp-analytics
gcloud services enable appengine.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### **3. Backend Dependencies**
```bash
cd backend
pip install -r requirements.txt
```

### **4. BigQuery Analytics Setup**
```bash
python production_analytics_setup.py ustaapp-analytics --environment production
```

### **5. Database Initialization**
```bash
python create_db_with_data.py
```

### **6. App Engine Deployment**
```bash
gcloud app deploy --quiet
```

---

## 📱 **MOBILE APP GÜNCELLEME**

### **Production URL Update (Zaten Yapıldı ✅)**
```bash
python3 update_mobile_urls_production.py ustaapp-analytics
```

### **Flutter Build**
```bash
cd ustam_mobile_app
flutter clean
flutter pub get
flutter build apk --release
```

**APK Lokasyonu:** `ustam_mobile_app/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔍 **DEPLOYMENT VERIFICATION**

### **1. Backend Health Check**
```bash
curl https://ustaapp-analytics.appspot.com/api/health
```

**Beklenen Response:**
```json
{
  "status": "healthy",
  "service": "ustam-api",
  "version": "1.0.0",
  "environment": "standard",
  "database": "in-memory SQLite"
}
```

### **2. Analytics Health Check**
```bash
curl https://ustaapp-analytics.appspot.com/api/analytics/v2/health
```

### **3. API Endpoints Test**
```bash
# Craftsmen listing
curl https://ustaapp-analytics.appspot.com/api/craftsmen

# Categories
curl https://ustaapp-analytics.appspot.com/api/categories
```

---

## 📊 **ANALYTICS DASHBOARD**

### **Local Dashboard (Development)**
```bash
cd backend
pip install streamlit plotly pandas
streamlit run enhanced_analytics_dashboard.py
```

**Dashboard URL:** http://localhost:8501

### **BigQuery Console**
**URL:** https://console.cloud.google.com/bigquery?project=ustaapp-analytics

**Dataset:** `ustam_analytics`  
**Tables:** 16 analytics tablosu

---

## 🌐 **PRODUCTION URLs**

### **Backend API**
- **Base URL:** https://ustaapp-analytics.appspot.com
- **Health Check:** https://ustaapp-analytics.appspot.com/api/health
- **Analytics:** https://ustaapp-analytics.appspot.com/api/analytics/v2/health
- **API Docs:** https://ustaapp-analytics.appspot.com/api/

### **Google Cloud Console**
- **App Engine:** https://console.cloud.google.com/appengine?project=ustaapp-analytics
- **BigQuery:** https://console.cloud.google.com/bigquery?project=ustaapp-analytics
- **Monitoring:** https://console.cloud.google.com/monitoring?project=ustaapp-analytics
- **Logs:** https://console.cloud.google.com/logs?project=ustaapp-analytics

---

## 🧪 **TEST SCENARIOS**

### **1. User Registration Test**
```bash
curl -X POST https://ustaapp-analytics.appspot.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123",
    "first_name": "Test",
    "last_name": "User",
    "phone": "05551234567",
    "user_type": "customer"
  }'
```

### **2. Login Test**
```bash
curl -X POST https://ustaapp-analytics.appspot.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'
```

### **3. Mobile App Test**
1. Install APK: `ustam_mobile_app/build/app/outputs/flutter-apk/app-release.apk`
2. Test registration/login
3. Test craftsmen listing
4. Test job creation

---

## 📈 **MONITORING & ANALYTICS**

### **Real-time Metrics**
- **Active Users:** BigQuery `user_activity_logs` tablosu
- **API Performance:** `performance_metrics` tablosu
- **Error Tracking:** `error_logs` tablosu
- **Revenue Analytics:** `payment_analytics` tablosu

### **Key Dashboards**
1. **Real-time Dashboard:** Canlı kullanıcı metrikleri
2. **Business KPIs:** Gelir, conversion, retention
3. **Platform Performance:** Web vs Mobile
4. **Error Analysis:** Hata takibi ve çözüm

### **Alerting**
- **High Error Rate:** > 5%
- **Slow Response Time:** > 2 seconds
- **BigQuery Costs:** > $50/day
- **Revenue Drop:** > 20% decrease

---

## 🔧 **TROUBLESHOOTING**

### **Common Issues**

#### **"Application Error" on App Engine**
```bash
# Check logs
gcloud app logs tail -s default

# Common solutions:
# 1. Check requirements.txt
# 2. Verify environment variables in app.yaml
# 3. Check database initialization
```

#### **BigQuery Connection Failed**
```bash
# Verify project setup
gcloud config get-value project

# Check BigQuery API
gcloud services list --enabled | grep bigquery

# Test connection
python -c "from google.cloud import bigquery; client = bigquery.Client(); print('Connected!')"
```

#### **Mobile App Connection Issues**
```bash
# Verify URLs updated
grep -r "ustaapp-analytics" ustam_mobile_app/lib/

# Check CORS settings in backend
# Verify HTTPS certificate
```

---

## 🚀 **POST-DEPLOYMENT TASKS**

### **Immediate (Bugün)**
- [ ] ✅ Backend deployed and tested
- [ ] ✅ Mobile app URLs updated
- [ ] ✅ Analytics pipeline active
- [ ] ✅ Health checks passing
- [ ] 📱 Mobile app APK built
- [ ] 📊 Analytics dashboard running

### **This Week**
- [ ] 🏪 Upload mobile app to Play Store
- [ ] 🌐 Setup custom domain (optional)
- [ ] 👥 Invite beta testers
- [ ] 📈 Monitor user analytics
- [ ] 🔍 Test all user flows

### **Next Steps**
- [ ] 📱 iOS app build (if needed)
- [ ] 🎨 UI/UX improvements based on feedback
- [ ] 🚀 Marketing campaign
- [ ] 📊 Advanced analytics features
- [ ] 🤖 AI/ML features (recommendations, etc.)

---

## 💰 **COST MONITORING**

### **Expected Monthly Costs**
- **App Engine:** $0-20 (depending on usage)
- **BigQuery:** $5-15 (analytics data)
- **Cloud Storage:** $1-5 (file uploads)
- **Total:** ~$10-40/month

### **Cost Optimization**
- ✅ **Auto-scaling:** Min 1, Max 10 instances
- ✅ **BigQuery partitioning:** Date-based partitions
- ✅ **Data retention:** 365 days production, 90 days logs
- ✅ **Query optimization:** Efficient SQL patterns

---

## 📞 **SUPPORT CONTACTS**

### **Technical Issues**
- **GitHub Issues:** https://github.com/sudeaydin/ustaapp/issues
- **Google Cloud Support:** https://cloud.google.com/support
- **Documentation:** `/docs` folder in project

### **Monitoring**
- **App Engine Logs:** Real-time error tracking
- **BigQuery Monitoring:** Cost and query performance
- **Analytics Dashboard:** Business metrics

---

## 🎉 **SUCCESS CHECKLIST**

### **Deployment Complete ✅**
- [x] Backend deployed to App Engine
- [x] BigQuery analytics active
- [x] Mobile app URLs updated
- [x] Health checks passing
- [x] Analytics dashboard working

### **Ready for Users 🚀**
- [ ] Mobile app tested on real devices
- [ ] User registration/login working
- [ ] Job posting and search functional
- [ ] Real-time messaging active
- [ ] Payment system tested
- [ ] Analytics collecting data

---

**🎯 ustam uygulaması artık canlıda ve kullanıma hazır!**

**📊 Analytics ile veriye dayalı büyüme başlasın! 🚀**

---

## 🔗 **QUICK LINKS**

- **Production App:** https://ustaapp-analytics.appspot.com
- **Health Check:** https://ustaapp-analytics.appspot.com/api/health
- **Analytics API:** https://ustaapp-analytics.appspot.com/api/analytics/v2/health
- **BigQuery Console:** https://console.cloud.google.com/bigquery?project=ustaapp-analytics
- **App Engine Console:** https://console.cloud.google.com/appengine?project=ustaapp-analytics