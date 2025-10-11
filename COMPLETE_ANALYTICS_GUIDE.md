# 🚀 ustam - COMPLETE ANALYTICS & DATA PIPELINE GUIDE

Bu rehber, ustam uygulaması için **uçtan uca veri analitik sistemi**nin kurulumu ve kullanımını kapsar.

## 📊 **SYSTEM OVERVIEW**

### **Neler İnşa Ettik:**
- ✅ **Real-time BigQuery Integration** - Canlı veri akışı
- ✅ **16 Analytics Tablosu** - Kapsamlı veri modeli  
- ✅ **7 Dashboard View'ı** - Hazır analitik görünümler
- ✅ **Enhanced API Endpoints** - Gelişmiş analitik API'ları
- ✅ **Streamlit Dashboard** - İnteraktif veri görselleştirme
- ✅ **Automated Middleware** - Otomatik veri toplama
- ✅ **Production Setup Scripts** - Tek tıkla production kurulumu
- ✅ **Cost Controls & Monitoring** - Maliyet kontrolü ve izleme

---

## 🎯 **QUICK START**

### **1. Production Setup (Tek Komut)**
```bash
cd backend
python production_analytics_setup.py YOUR_PROJECT_ID --environment production
```

### **2. Development Setup**
```bash
cd backend
python production_analytics_setup.py YOUR_PROJECT_ID --environment development
```

### **3. Start Analytics Dashboard**
```bash
cd backend
pip install streamlit plotly pandas
streamlit run enhanced_analytics_dashboard.py
```

---

## 📈 **DATA FLOW ARCHITECTURE**

```
🌐 Frontend (Flutter/Web)
    ↓ User Actions
🔧 Backend (Flask API)
    ↓ Auto Middleware Capture
📊 BigQuery (Real-time Streaming)
    ↓ Analytics Processing
📈 Streamlit Dashboard (Visualization)
    ↓ Business Intelligence
💼 Decision Making
```

### **Veri Akışı Detayları:**

1. **Frontend Events** → Kullanıcı etkileşimleri
2. **API Middleware** → Otomatik veri yakalama
3. **BigQuery Streaming** → Real-time veri akışı
4. **Analytics Processing** → Veri işleme ve analiz
5. **Dashboard Visualization** → Görsel raporlama

---

## 🗂️ **DATABASE SCHEMA**

### **Core Tables (Mevcut Veriler)**
```sql
users                 -- Kullanıcı bilgileri
categories           -- İş kategorileri  
customers            -- Müşteri profilleri
craftsmen            -- Usta profilleri
jobs                 -- İş ilanları
messages             -- Mesajlaşma
notifications        -- Bildirimler
payments             -- Ödeme işlemleri
quotes               -- Fiyat teklifleri
reviews              -- Değerlendirmeler
```

### **Analytics Tables (Yeni)**
```sql
user_activity_logs   -- Kullanıcı aktivite logları
business_metrics     -- İş metrikleri (günlük/haftalık/aylık)
error_logs           -- Hata logları
performance_metrics  -- Performans metrikleri
search_analytics     -- Arama analitikleri
payment_analytics    -- Ödeme analitikleri
```

### **Dashboard Views (Hazır Raporlar)**
```sql
realtime_dashboard   -- Real-time dashboard
hourly_metrics       -- Saatlik metrikler
daily_user_stats     -- Günlük kullanıcı istatistikleri
craftsman_performance -- Usta performans analizi
revenue_dashboard    -- Gelir dashboard'u
search_insights      -- Arama insights
error_summary        -- Hata özeti
platform_comparison  -- Platform karşılaştırması
business_kpis        -- İş KPI'ları
```

---

## 🔧 **API ENDPOINTS**

### **Enhanced Analytics API (v2)**
```
GET  /api/analytics/v2/dashboard/realtime     -- Real-time dashboard
GET  /api/analytics/v2/kpis                   -- Business KPIs
GET  /api/analytics/v2/trends/hourly          -- Saatlik trendler
GET  /api/analytics/v2/funnel                 -- Kullanıcı funnel analizi
GET  /api/analytics/v2/platform-performance  -- Platform karşılaştırması
GET  /api/analytics/v2/revenue/trends         -- Gelir trendleri
GET  /api/analytics/v2/search/insights        -- Arama insights
GET  /api/analytics/v2/errors/analysis        -- Hata analizi
GET  /api/analytics/v2/craftsmen/top          -- Top ustalar
POST /api/analytics/v2/export/csv             -- CSV export
GET  /api/analytics/v2/health                 -- Health check
```

### **Example API Usage:**
```javascript
// Real-time dashboard data
const dashboard = await fetch('/api/analytics/v2/dashboard/realtime');

// Business KPIs for last 30 days
const kpis = await fetch('/api/analytics/v2/kpis?days=30');

// Hourly trends for last 24 hours
const trends = await fetch('/api/analytics/v2/trends/hourly?hours=24');
```

---

## 📊 **STREAMLIT DASHBOARD**

### **Dashboard Features:**
- 📈 **Real-time Metrics** - Canlı kullanıcı sayısı, gelir, başarı oranı
- 📊 **Hourly Trends** - Saatlik trend analizi
- 💰 **Revenue Analysis** - Gelir analizi ve trendleri
- 📱 **Platform Comparison** - Web vs Mobile performans
- 🎯 **User Funnel** - Conversion funnel analizi
- 🚨 **Error Monitoring** - Hata takibi ve analizi
- ⭐ **Top Craftsmen** - En başarılı ustalar

### **Dashboard Kullanımı:**
```bash
# Dashboard'u başlat
streamlit run backend/enhanced_analytics_dashboard.py

# Browser'da aç
http://localhost:8501
```

---

## 🔄 **REAL-TIME LOGGING**

### **Automatic Middleware Logging:**
Middleware otomatik olarak şunları yakalar:
- 👤 **User Actions** - Login, register, page views
- 🔍 **Search Events** - Arama sorguları ve sonuçları
- 💳 **Payment Events** - Ödeme işlemleri
- 📱 **API Calls** - Tüm API çağrıları
- 🚨 **Errors** - Uygulama hataları
- ⚡ **Performance** - Response time, success rate

### **Manual Logging Examples:**
```python
from app.middleware.analytics_middleware import track_search_event, track_payment_event

# Search event logging
track_search_event(
    search_query="elektrikçi istanbul",
    search_type="craftsman",
    results_count=15,
    response_time_ms=250
)

# Payment event logging
track_payment_event({
    'payment_id': 'pay_123',
    'user_id': 123,
    'amount': 500.0,
    'payment_type': 'job_payment',
    'status': 'completed'
})
```

### **Decorator Usage:**
```python
from app.middleware.analytics_middleware import track_job_creation, track_user_registration

@track_job_creation
def create_job():
    # Job creation logic
    pass

@track_user_registration  
def register_user():
    # User registration logic
    pass
```

---

## 📈 **BUSINESS INTELLIGENCE QUERIES**

### **Key Performance Indicators:**
```sql
-- Daily KPIs
SELECT
  date,
  total_users,
  active_users,
  new_users,
  total_revenue,
  platform_fees,
  average_rating,
  conversion_rate
FROM `your-project.ustam_analytics.business_metrics`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
ORDER BY date DESC;
```

### **User Funnel Analysis:**
```sql
-- Conversion funnel
WITH user_funnel AS (
  SELECT
    user_id,
    MIN(CASE WHEN action_type = 'register' THEN timestamp END) as registered_at,
    MIN(CASE WHEN action_type = 'search' THEN timestamp END) as first_search_at,
    MIN(CASE WHEN action_type = 'job_create' THEN timestamp END) as first_job_at,
    MIN(CASE WHEN action_category = 'payment' THEN timestamp END) as first_payment_at
  FROM `your-project.ustam_analytics.user_activity_logs`
  GROUP BY user_id
)
SELECT
  COUNT(*) as total_registered,
  COUNT(first_search_at) as searched_users,
  COUNT(first_job_at) as job_creators,
  COUNT(first_payment_at) as paying_users,
  COUNT(first_search_at) / COUNT(*) as search_conversion,
  COUNT(first_job_at) / COUNT(*) as job_conversion,
  COUNT(first_payment_at) / COUNT(*) as payment_conversion
FROM user_funnel;
```

### **Revenue Analysis:**
```sql
-- Revenue trends
SELECT
  DATE(created_at) as date,
  SUM(amount) as daily_revenue,
  COUNT(*) as transaction_count,
  AVG(amount) as avg_transaction_value,
  SUM(platform_fee) as platform_fees
FROM `your-project.ustam_analytics.payment_analytics`
WHERE DATE(created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND status = 'completed'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### **Platform Performance:**
```sql
-- Platform comparison
SELECT
  platform,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(*) as total_actions,
  AVG(duration_ms) as avg_response_time,
  SUM(CASE WHEN success = true THEN 1 ELSE 0 END) / COUNT(*) as success_rate
FROM `your-project.ustam_analytics.user_activity_logs`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY platform
ORDER BY unique_users DESC;
```

---

## 🚨 **MONITORING & ALERTS**

### **Automated Monitoring:**
- 📊 **Error Rate** - 5% üzeri hata oranında alert
- ⚡ **Response Time** - 2 saniye üzeri response time'da alert  
- 💰 **Cost Control** - Günlük $50 üzeri BigQuery maliyetinde alert
- 📈 **Revenue Drop** - %20 üzeri gelir düşüşünde alert

### **Health Check Endpoints:**
```bash
# Analytics service health
curl /api/analytics/v2/health

# BigQuery connection test
curl /api/health
```

### **Error Analysis:**
```sql
-- Daily error analysis
SELECT
  DATE(timestamp) as date,
  error_type,
  COUNT(*) as error_count,
  COUNT(DISTINCT user_id) as affected_users
FROM `your-project.ustam_analytics.error_logs`
WHERE DATE(timestamp) = CURRENT_DATE()
GROUP BY DATE(timestamp), error_type
ORDER BY error_count DESC;
```

---

## 💰 **COST MANAGEMENT**

### **BigQuery Pricing:**
- **Storage:** $0.020 per GB/month (first 10 GB free)
- **Queries:** $5.00 per TB processed (first 1 TB free monthly)
- **Streaming Inserts:** $0.010 per 200 MB

### **Cost Optimization:**
- ✅ **Partitioned Tables** - Date-based partitioning
- ✅ **Clustered Tables** - Optimized queries
- ✅ **Data Retention** - Automatic old data cleanup
- ✅ **Query Optimization** - Efficient query patterns

### **Monthly Cost Estimate:**
```
Estimated Monthly Costs for ustam App:
- Storage (10 GB): $0.20
- Queries (1 TB): $5.00
- Streaming (100 GB): $5.00
- Total: ~$10-15/month
```

---

## 🔧 **PRODUCTION DEPLOYMENT**

### **Environment Setup:**
```bash
# Production environment
python production_analytics_setup.py YOUR_PROJECT_ID --environment production

# Staging environment  
python production_analytics_setup.py YOUR_PROJECT_ID --environment staging

# Development environment
python production_analytics_setup.py YOUR_PROJECT_ID --environment development
```

### **Environment Variables:**
```bash
# .env.production
BIGQUERY_PROJECT_ID=your-project-id
BIGQUERY_DATASET_ID=ustam_analytics
BIGQUERY_LOGGING_ENABLED=true
ANALYTICS_ENVIRONMENT=production
DATA_RETENTION_DAYS=365
MONITORING_ENABLED=true
COST_CONTROLS_ENABLED=true
```

### **Application Integration:**
```python
# app/__init__.py
from app.middleware.analytics_middleware import analytics_middleware

def create_app():
    app = Flask(__name__)
    
    # Initialize analytics middleware
    analytics_middleware.init_app(app)
    
    return app
```

---

## 📱 **MOBILE APP INTEGRATION**

### **Flutter Integration:**
```dart
// lib/services/analytics_service.dart
class AnalyticsService {
  static Future<void> trackEvent(String eventType, Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/analytics/v2/events'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'event_type': eventType,
        'event_data': data,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }
}

// Usage
AnalyticsService.trackEvent('job_view', {
  'job_id': jobId,
  'category': category,
  'user_type': 'customer'
});
```

### **Web Integration:**
```javascript
// web/src/services/analytics.js
class AnalyticsService {
  static async trackEvent(eventType, eventData) {
    await fetch('/api/analytics/v2/events', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        event_type: eventType,
        event_data: eventData,
        timestamp: new Date().toISOString()
      })
    });
  }
}

// Usage
AnalyticsService.trackEvent('search_performed', {
  query: searchQuery,
  filters: appliedFilters,
  results_count: results.length
});
```

---

## 📊 **DASHBOARD EXAMPLES**

### **Real-time Dashboard:**
- 👥 **Active Users (24h):** 1,234
- 💰 **Today's Revenue:** ₺15,678
- ✅ **Success Rate:** 98.5%
- 🚨 **Error Rate:** 1.2%

### **Business KPIs:**
- 📈 **Monthly Revenue:** ₺456,789
- 👤 **New Users:** +234 this week
- ⭐ **Average Rating:** 4.8/5
- 🎯 **Conversion Rate:** 12.5%

### **Platform Performance:**
- 🌐 **Web:** 60% users, 2.1s avg response
- 📱 **Mobile:** 35% users, 1.8s avg response  
- 🖥️ **Desktop:** 5% users, 2.3s avg response

---

## 🔗 **USEFUL LINKS**

- **BigQuery Console:** https://console.cloud.google.com/bigquery
- **Analytics Dashboard:** http://localhost:8501 (Streamlit)
- **API Documentation:** /api/analytics/v2/
- **Monitoring:** https://console.cloud.google.com/monitoring
- **Cost Management:** https://console.cloud.google.com/billing

---

## 🆘 **TROUBLESHOOTING**

### **Common Issues:**

#### **"BigQuery connection failed"**
```bash
✅ Check: gcloud auth login
✅ Check: Project ID is correct
✅ Check: BigQuery API is enabled
✅ Check: Service account permissions
```

#### **"Streaming insert failed"**
```bash
✅ Check: Table schema matches data
✅ Check: BIGQUERY_LOGGING_ENABLED=true
✅ Check: Network connectivity
✅ Check: Quotas and limits
```

#### **"Dashboard not loading"**
```bash
✅ Check: Streamlit installation
✅ Check: Dependencies (plotly, pandas)
✅ Check: BigQuery credentials
✅ Check: Project permissions
```

#### **"High costs"**
```bash
✅ Check: Query patterns
✅ Check: Data retention settings
✅ Check: Streaming volume
✅ Set up billing alerts
```

---

## 🎉 **SUCCESS METRICS**

### **What You Now Have:**
- ✅ **Real-time Analytics** - Canlı kullanıcı aktivite takibi
- ✅ **Business Intelligence** - Gelir, conversion, retention metrikleri
- ✅ **Performance Monitoring** - Response time, error rate takibi
- ✅ **Error Tracking** - Detaylı hata loglama ve analizi
- ✅ **Search Analytics** - Kullanıcı arama davranış insights'ı
- ✅ **Payment Analytics** - İşlem başarı oranları, gelir trendleri
- ✅ **Platform Comparison** - Web vs Mobile performans karşılaştırması
- ✅ **Automated Dashboards** - Kullanıma hazır business view'ları

### **Business Value:**
- 📈 **Data-Driven Decisions** - Veriye dayalı iş kararları
- 🚀 **Performance Optimization** - Darboğazları tespit et ve düzelt
- 💰 **Revenue Optimization** - Conversion funnel'ları takip et ve iyileştir
- 🎯 **User Experience** - Kullanıcı memnuniyetini izle ve artır
- 🔍 **Market Insights** - Kullanıcı davranış kalıplarını anla
- ⚡ **Real-time Monitoring** - Kritik sorunlar için anında alert

---

## 🚀 **NEXT STEPS**

### **Immediate Actions:**
1. **Setup Production Analytics:** `python production_analytics_setup.py YOUR_PROJECT_ID`
2. **Deploy Application:** Environment variables ile deploy et
3. **Start Dashboard:** Streamlit dashboard'u başlat
4. **Test Pipeline:** Sample data ile test et
5. **Setup Monitoring:** Alerts ve monitoring kur

### **Advanced Features:**
1. **Machine Learning Models** - Predictive analytics
2. **Custom Dashboards** - Business-specific görünümler
3. **Automated Reports** - Scheduled email reports
4. **A/B Testing Framework** - Feature testing infrastructure
5. **Data Export APIs** - Third-party integrations

---

**🎯 Artık ustam uygulamanız enterprise-level analytics altyapısına sahip!**

**Happy Analytics!** 📊✨