# 🚀 ustam - COMPREHENSIVE BIGQUERY ANALYTICS SYSTEM

Bu rehber, ustam uygulaması için kapsamlı BigQuery analytics ve logging sistemini kurmak için hazırlanmıştır.

## 🎯 **SISTEM ÖZETİ**

### **Neler İnşa Ettik:**
- ✅ **16 Analytics Tablosu** (Core + Analytics + Logging)
- ✅ **7 Real-time Dashboard View'ı**
- ✅ **Otomatik Real-time Logging Sistemi**
- ✅ **Performance Monitoring**
- ✅ **Error Tracking**
- ✅ **Business Intelligence Dashboard**
- ✅ **Streaming Data Pipeline**

---

## 📊 **TABLO YAPISI**

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

### **Dashboard Views**
```sql
daily_user_stats     -- Günlük kullanıcı istatistikleri
craftsman_performance -- Usta performans analizi
revenue_dashboard    -- Gelir dashboard'u
search_insights      -- Arama insights
error_summary        -- Hata özeti
platform_comparison  -- Platform karşılaştırması
business_kpis        -- İş KPI'ları
realtime_dashboard   -- Real-time dashboard
hourly_metrics       -- Saatlik metrikler
```

---

## 🚀 **HIZLI KURULUM**

### **1. Tek Komut Kurulum (Windows)**
```powershell
cd backend
.\bigquery_comprehensive_setup.bat
```

### **2. Manuel Kurulum**
```powershell
# Prerequisites
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud services enable bigquery.googleapis.com

# Python dependencies
pip install google-cloud-bigquery google-api-core

# Run setup
python bigquery_comprehensive_setup.py YOUR_PROJECT_ID

# Upload initial data
python bigquery_auto_upload.py YOUR_PROJECT_ID
```

---

## 🔄 **REAL-TIME LOGGING KULLANIMI**

### **Backend'de Aktifleştirme**
```python
# Environment variables
BIGQUERY_LOGGING_ENABLED=true
BIGQUERY_PROJECT_ID=your-project-id

# Otomatik middleware aktif (app/__init__.py'de zaten eklendi)
```

### **Manual Logging Examples**
```python
from app.utils.bigquery_logger import *

# User login logging
log_user_login(user_id=123, success=True)

# Search logging  
log_search(user_id=123, search_query="elektrikçi", search_type="craftsman", 
           results_count=15, response_time_ms=250)

# Payment logging
log_payment({
    'payment_id': 'pay_123',
    'user_id': 123,
    'amount': 500.0,
    'payment_type': 'job_payment',
    'payment_method': 'credit_card',
    'status': 'completed',
    'provider': 'iyzico',
    'platform_fee': 50.0,
    'craftsman_amount': 450.0
})

# Error logging
log_api_error(error_type='API_ERROR', error_message='Database connection failed', 
              endpoint='/api/jobs', user_id=123)
```

### **Decorator ile Otomatik Performance Logging**
```python
from app.utils.bigquery_logger import log_performance

@log_performance
def my_api_endpoint():
    # Your API logic here
    return {"status": "success"}
```

---

## 📈 **DASHBOARD QUERY'LERİ**

### **Real-time Dashboard**
```sql
SELECT * FROM `your-project.ustam_analytics.realtime_dashboard`;
```

### **Saatlik Trend Analizi**
```sql
SELECT * FROM `your-project.ustam_analytics.hourly_metrics`
WHERE hour_tr >= DATETIME_SUB(CURRENT_DATETIME('Europe/Istanbul'), INTERVAL 24 HOUR)
ORDER BY hour_tr DESC;
```

### **Top Performing Craftsmen**
```sql
SELECT * FROM `your-project.ustam_analytics.craftsman_performance`
ORDER BY total_earnings DESC
LIMIT 10;
```

### **Revenue Trends**
```sql
SELECT 
  date,
  SUM(total_amount) as daily_revenue,
  COUNT(*) as transaction_count,
  AVG(avg_transaction_value) as avg_value
FROM `your-project.ustam_analytics.revenue_dashboard`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY date
ORDER BY date DESC;
```

### **Error Analysis**
```sql
SELECT 
  error_type,
  COUNT(*) as error_count,
  COUNT(DISTINCT user_id) as affected_users
FROM `your-project.ustam_analytics.error_logs`
WHERE DATE(timestamp) = CURRENT_DATE()
GROUP BY error_type
ORDER BY error_count DESC;
```

### **Search Performance**
```sql
SELECT
  search_type,
  COUNT(*) as total_searches,
  AVG(results_count) as avg_results,
  AVG(response_time_ms) as avg_response_time,
  COUNT(CASE WHEN clicked_result_id IS NOT NULL THEN 1 END) / COUNT(*) as ctr
FROM `your-project.ustam_analytics.search_analytics`
WHERE DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY search_type;
```

---

## 🎛️ **GOOGLE CLOUD CONSOLE DASHBOARD**

### **1. BigQuery Console**
```
https://console.cloud.google.com/bigquery?project=YOUR_PROJECT_ID
```

### **2. Data Studio Dashboard Oluşturma**
1. **Data Studio'ya Git:** https://datastudio.google.com
2. **Create Report**
3. **Add Data Source** → BigQuery
4. **Select Project:** your-project-id
5. **Select Dataset:** ustam_analytics
6. **Choose View:** realtime_dashboard

### **3. Monitoring & Alerting**
```
Google Cloud Console → Monitoring → Alerting
- BigQuery job failures
- High error rates
- Performance degradation
- Cost alerts
```

---

## 📊 **BUSINESS INTELLIGENCE QUERIES**

### **Daily KPIs**
```sql
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

### **Platform Performance Comparison**
```sql
SELECT
  platform,
  unique_users,
  total_actions,
  avg_action_duration,
  success_rate
FROM `your-project.ustam_analytics.platform_comparison`
ORDER BY unique_users DESC;
```

### **User Funnel Analysis**
```sql
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

### **Cohort Analysis**
```sql
WITH user_cohorts AS (
  SELECT
    user_id,
    DATE_TRUNC(DATE(MIN(timestamp)), MONTH) as cohort_month
  FROM `your-project.ustam_analytics.user_activity_logs`
  WHERE action_type = 'register'
  GROUP BY user_id
),
cohort_activity AS (
  SELECT
    uc.cohort_month,
    DATE_TRUNC(DATE(ual.timestamp), MONTH) as activity_month,
    COUNT(DISTINCT ual.user_id) as active_users
  FROM user_cohorts uc
  JOIN `your-project.ustam_analytics.user_activity_logs` ual ON uc.user_id = ual.user_id
  GROUP BY cohort_month, activity_month
)
SELECT
  cohort_month,
  activity_month,
  DATE_DIFF(activity_month, cohort_month, MONTH) as month_number,
  active_users,
  active_users / FIRST_VALUE(active_users) OVER (
    PARTITION BY cohort_month 
    ORDER BY activity_month
  ) as retention_rate
FROM cohort_activity
ORDER BY cohort_month, activity_month;
```

---

## 🔧 **ADVANCED CONFIGURATION**

### **Streaming Insert Optimization**
```python
# Configure batch size and flush interval
bigquery_logger.batch_size = 100  # Default: 50
bigquery_logger.flush_interval = 60  # Default: 30 seconds
```

### **Custom Metrics**
```python
# Add custom business metrics
def log_custom_metric(metric_name: str, metric_value: float, dimensions: Dict[str, str] = None):
    bigquery_logger.log_user_activity(
        action_type='custom_metric',
        action_category='business',
        success=True,
        action_details={
            'metric_name': metric_name,
            'metric_value': metric_value,
            'dimensions': dimensions or {}
        }
    )

# Usage
log_custom_metric('job_completion_rate', 0.85, {'category': 'electrical', 'city': 'istanbul'})
```

### **Cost Optimization**
```sql
-- Partition tables by date for better performance
ALTER TABLE `your-project.ustam_analytics.user_activity_logs`
SET OPTIONS (
  partition_expiration_days = 90,  -- Auto-delete old partitions
  require_partition_filter = true  -- Force partition filtering
);
```

---

## 🚨 **MONITORING & ALERTS**

### **Error Rate Alert**
```sql
-- Query for monitoring (run every 5 minutes)
SELECT
  COUNT(*) as error_count,
  COUNT(*) / (
    SELECT COUNT(*) 
    FROM `your-project.ustam_analytics.user_activity_logs` 
    WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 5 MINUTE)
  ) as error_rate
FROM `your-project.ustam_analytics.error_logs`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 5 MINUTE)
HAVING error_rate > 0.05;  -- Alert if error rate > 5%
```

### **Performance Degradation Alert**
```sql
-- Query for performance monitoring
SELECT
  AVG(response_time_ms) as avg_response_time
FROM `your-project.ustam_analytics.performance_metrics`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 10 MINUTE)
HAVING avg_response_time > 2000;  -- Alert if avg response time > 2 seconds
```

### **Revenue Drop Alert**
```sql
-- Query for revenue monitoring
WITH today_revenue AS (
  SELECT SUM(amount) as today_total
  FROM `your-project.ustam_analytics.payment_analytics`
  WHERE DATE(created_at) = CURRENT_DATE()
  AND status = 'completed'
),
yesterday_revenue AS (
  SELECT SUM(amount) as yesterday_total
  FROM `your-project.ustam_analytics.payment_analytics`
  WHERE DATE(created_at) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND status = 'completed'
)
SELECT
  tr.today_total,
  yr.yesterday_total,
  (tr.today_total - yr.yesterday_total) / yr.yesterday_total as revenue_change
FROM today_revenue tr
CROSS JOIN yesterday_revenue yr
HAVING revenue_change < -0.20;  -- Alert if revenue drops > 20%
```

---

## 💰 **COST MANAGEMENT**

### **BigQuery Pricing**
- **Storage:** $0.020 per GB/month (first 10 GB free)
- **Queries:** $5.00 per TB processed (first 1 TB free monthly)
- **Streaming Inserts:** $0.010 per 200 MB

### **Cost Optimization Tips**
1. **Partition Tables:** Use date partitioning for time-series data
2. **Cluster Tables:** Cluster frequently filtered columns
3. **Limit Query Scope:** Always use date filters
4. **Avoid SELECT \*:** Select only needed columns
5. **Use Views:** Create materialized views for complex queries

### **Monthly Cost Estimate**
```
Estimated Monthly Costs for ustam App:
- Storage (5 GB): $0.10
- Queries (500 GB): $2.50
- Streaming (50 GB): $2.50
- Total: ~$5-10/month
```

---

## 📞 **TROUBLESHOOTING**

### **Common Issues**

#### **"Streaming insert failed"**
```
✅ Solution: Check table schema matches data structure
✅ Verify BigQuery API is enabled
✅ Check authentication credentials
```

#### **"Query timeout"**
```
✅ Solution: Add date filters to limit data scope
✅ Use clustered/partitioned tables
✅ Break complex queries into smaller parts
```

#### **"High costs"**
```
✅ Solution: Review query patterns
✅ Add date filters to all queries  
✅ Use LIMIT clauses for testing
✅ Set up billing alerts
```

#### **"Data not appearing"**
```
✅ Solution: Check BIGQUERY_LOGGING_ENABLED=true
✅ Verify project ID is correct
✅ Check application logs for errors
✅ Streaming inserts may have 5-10 second delay
```

---

## 🎉 **SUCCESS METRICS**

### **What You Now Have:**
- ✅ **Real-time Analytics:** Live user activity tracking
- ✅ **Business Intelligence:** Revenue, conversion, retention metrics
- ✅ **Performance Monitoring:** Response times, error rates
- ✅ **Error Tracking:** Detailed error logging and analysis
- ✅ **Search Analytics:** User search behavior insights
- ✅ **Payment Analytics:** Transaction success rates, revenue trends
- ✅ **Platform Comparison:** Web vs Mobile performance
- ✅ **Automated Dashboards:** Ready-to-use business views

### **Business Value:**
- 📈 **Data-Driven Decisions:** Make informed business choices
- 🚀 **Performance Optimization:** Identify and fix bottlenecks
- 💰 **Revenue Optimization:** Track and improve conversion funnels
- 🎯 **User Experience:** Monitor and improve user satisfaction
- 🔍 **Market Insights:** Understand user behavior patterns
- ⚡ **Real-time Monitoring:** Instant alerts for critical issues

---

## 🔗 **USEFUL LINKS**

- **BigQuery Console:** https://console.cloud.google.com/bigquery
- **Data Studio:** https://datastudio.google.com
- **Cloud Monitoring:** https://console.cloud.google.com/monitoring
- **BigQuery Documentation:** https://cloud.google.com/bigquery/docs
- **Pricing Calculator:** https://cloud.google.com/products/calculator

---

**🎯 Artık ustam uygulamanız enterprise-level analytics altyapısına sahip!**

**Happy Analytics!** 📊✨