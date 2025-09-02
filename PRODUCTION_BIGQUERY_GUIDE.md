# 🚀 ustam - PRODUCTION BIGQUERY DEPLOYMENT GUIDE

Bu rehber ustam uygulamasını production'da BigQuery ile nasıl çalıştıracağını açıklar.

## 📊 **PRODUCTION ARCHITECTURE**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web App       │    │   Backend        │    │   BigQuery      │
│   (Frontend)    │───▶│   (Flask API)    │───▶│   Analytics     │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │                          ▲
                              ▼                          │
                       ┌──────────────────┐             │
                       │   SQLite/        │             │
                       │   PostgreSQL     │─────────────┘
                       │   (Main DB)      │   Daily Sync
                       └──────────────────┘
```

## 🎯 **DEPLOYMENT OPTIONS**

### **Option 1: Shared Hosting (En Kolay)**
- ✅ **Maliyet:** $5-20/ay
- ✅ **Kurulum:** Kolay
- ✅ **BigQuery:** Ek maliyet yok
- ✅ **Maintenance:** Az

### **Option 2: VPS (Recommended)**  
- ✅ **Maliyet:** $10-50/ay
- ✅ **Kurulum:** Orta
- ✅ **Kontrol:** Tam
- ✅ **Scalability:** İyi

### **Option 3: Google Cloud (Advanced)**
- ✅ **Maliyet:** $20-100/ay  
- ✅ **Integration:** Mükemmel
- ✅ **Scalability:** Sınırsız
- ✅ **BigQuery:** Native

## 🚀 **STEP-BY-STEP PRODUCTION SETUP**

### **STEP 1: Google Cloud Project Setup**

1. **BigQuery API'yi Aktif Et:**
```bash
gcloud services enable bigquery.googleapis.com
```

2. **Service Account Oluştur:**
```bash
gcloud iam service-accounts create ustam-bigquery \
    --display-name="ustam BigQuery Service Account"
```

3. **Permissions Ver:**
```bash
gcloud projects add-iam-policy-binding ustaapp-analytics \
    --member="serviceAccount:ustam-bigquery@ustaapp-analytics.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding ustaapp-analytics \
    --member="serviceAccount:ustam-bigquery@ustaapp-analytics.iam.gserviceaccount.com" \
    --role="roles/bigquery.jobUser"
```

4. **Service Account Key İndir:**
```bash
gcloud iam service-accounts keys create ustam-bigquery-key.json \
    --iam-account=ustam-bigquery@ustaapp-analytics.iam.gserviceaccount.com
```

### **STEP 2: Production Server Setup**

#### **A. VPS/Server Requirements:**
- **OS:** Ubuntu 20.04+ / CentOS 8+
- **RAM:** Minimum 2GB
- **Storage:** 20GB+
- **Python:** 3.8+

#### **B. Server Kurulumu:**
```bash
# 1. Python ve dependencies
sudo apt update
sudo apt install python3 python3-pip python3-venv nginx

# 2. Project klonla
git clone https://github.com/sudeaydin/ustaapp.git
cd ustaapp/backend

# 3. Virtual environment
python3 -m venv venv
source venv/bin/activate

# 4. Dependencies yükle
pip install -r requirements.txt
pip install gunicorn

# 5. Service account key kopyala
# ustam-bigquery-key.json dosyasını server'a yükle
```

#### **C. Environment Configuration:**
```bash
# .env dosyası oluştur
cat > .env << EOF
# Production BigQuery Configuration
BIGQUERY_LOGGING_ENABLED=true
BIGQUERY_PROJECT_ID=ustaapp-analytics
GOOGLE_APPLICATION_CREDENTIALS=/path/to/ustam-bigquery-key.json

# Flask Production Configuration
FLASK_ENV=production
SECRET_KEY=$(openssl rand -base64 32)
JWT_SECRET_KEY=$(openssl rand -base64 32)

# Database (PostgreSQL recommended for production)
DATABASE_URL=postgresql://user:password@localhost:5432/ustam_db

# Security
FORCE_HTTPS=true
SESSION_COOKIE_SECURE=true
SESSION_COOKIE_HTTPONLY=true
EOF
```

### **STEP 3: BigQuery Tables Setup**

```bash
# BigQuery tablolarını oluştur
python bigquery_comprehensive_setup.py ustaapp-analytics
```

### **STEP 4: Daily Sync Setup**

#### **A. Linux Cron Job (VPS):**
```bash
# Crontab edit
crontab -e

# Add this line (daily at 2 AM):
0 2 * * * cd /path/to/ustaapp/backend && /path/to/venv/bin/python production_bigquery_sync.py ustaapp-analytics >> /var/log/bigquery_sync.log 2>&1
```

#### **B. Windows Task Scheduler (Local):**
```batch
# Run setup script
setup_daily_sync.bat
```

### **STEP 5: Flask App Production Setup**

#### **A. Gunicorn Service:**
```bash
# Create systemd service
sudo tee /etc/systemd/system/ustam.service > /dev/null <<EOF
[Unit]
Description=ustam Flask App
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/ustaapp/backend
Environment="PATH=/path/to/ustaapp/backend/venv/bin"
ExecStart=/path/to/ustaapp/backend/venv/bin/gunicorn --workers 3 --bind unix:ustam.sock -m 007 run:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start service
sudo systemctl daemon-reload
sudo systemctl start ustam
sudo systemctl enable ustam
```

#### **B. Nginx Configuration:**
```nginx
# /etc/nginx/sites-available/ustam
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        include proxy_params;
        proxy_pass http://unix:/path/to/ustaapp/backend/ustam.sock;
    }

    location /static {
        alias /path/to/ustaapp/web/dist;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/ustam /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl reload nginx
```

## 📊 **BIGQUERY COSTS & MONITORING**

### **Expected Monthly Costs:**
```
Storage (10 GB):           $0.20
Queries (100 GB/month):    $5.00  
Streaming (50 GB):         $2.50
Total BigQuery:            ~$8/month
```

### **Cost Optimization:**
1. **Partition Tables:** Date-based partitioning
2. **Cluster Tables:** Frequently queried columns
3. **Query Optimization:** Use date filters
4. **Data Lifecycle:** Auto-delete old data

### **Monitoring Setup:**
```bash
# Create monitoring script
cat > monitor_bigquery.py << EOF
#!/usr/bin/env python3
import os
from google.cloud import bigquery
from datetime import datetime, timedelta

def check_daily_sync():
    client = bigquery.Client()
    
    # Check if yesterday's data exists
    yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    
    query = f"""
    SELECT COUNT(*) as count
    FROM \`ustaapp-analytics.ustam_analytics.business_metrics\`
    WHERE DATE(created_at) = '{yesterday}'
    """
    
    result = list(client.query(query))
    if result[0].count == 0:
        print(f"⚠️ No data synced for {yesterday}")
        return False
    else:
        print(f"✅ Data synced for {yesterday}: {result[0].count} records")
        return True

if __name__ == '__main__':
    check_daily_sync()
EOF

# Add to cron (daily check at 3 AM)
# 0 3 * * * /path/to/venv/bin/python /path/to/monitor_bigquery.py
```

## 🔒 **SECURITY CHECKLIST**

- ✅ **Service Account:** Minimum permissions
- ✅ **API Keys:** Environment variables only
- ✅ **HTTPS:** Force SSL/TLS
- ✅ **Firewall:** Restrict BigQuery access
- ✅ **Logging:** Monitor all API calls
- ✅ **Backup:** Regular database backups

## 🎯 **TESTING PRODUCTION SETUP**

### **1. Local Test:**
```bash
# Test BigQuery connection
python -c "
from google.cloud import bigquery
client = bigquery.Client(project='ustaapp-analytics')
print('✅ BigQuery connection successful')
"

# Test daily sync
python production_bigquery_sync.py ustaapp-analytics
```

### **2. Production Test:**
```bash
# Test Flask app
curl -X GET http://yourdomain.com/api/health

# Test BigQuery data
# Check BigQuery console for new data
```

### **3. End-to-End Test:**
1. **Frontend:** Create account, make search
2. **Backend:** Check logs
3. **BigQuery:** Verify data in console
4. **Sync:** Wait for daily sync, check results

## 📈 **ANALYTICS DASHBOARDS**

### **Google Data Studio:**
1. Go to: https://datastudio.google.com
2. Create new report
3. Add BigQuery data source
4. Connect to: `ustaapp-analytics.ustam_analytics`
5. Create charts from your tables

### **Custom Dashboard:**
- Use BigQuery views for pre-aggregated data
- Create REST API endpoints for dashboard data
- Build custom React/Vue dashboard

## 🚨 **TROUBLESHOOTING**

### **Common Issues:**

#### **"Authentication Error"**
```bash
# Check service account key
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
python -c "from google.cloud import bigquery; bigquery.Client()"
```

#### **"Permission Denied"**
```bash
# Check IAM roles
gcloud projects get-iam-policy ustaapp-analytics
```

#### **"Daily Sync Failed"**
```bash
# Check logs
tail -f bigquery_sync.log
tail -f sync.log
```

#### **"High Costs"**
```bash
# Check query costs in BigQuery console
# Add LIMIT clauses to expensive queries
# Use date partitioning filters
```

## 🎉 **SUCCESS METRICS**

After successful deployment, you'll have:

- ✅ **Real-time Analytics:** Live business metrics
- ✅ **Daily Reports:** Automated data pipeline  
- ✅ **Cost Effective:** ~$8-15/month total
- ✅ **Scalable:** Handles growth automatically
- ✅ **Reliable:** Google Cloud infrastructure
- ✅ **Secure:** Enterprise-grade security

## 📞 **SUPPORT**

For issues:
1. Check logs first
2. Verify BigQuery console
3. Test authentication
4. Review IAM permissions

**Production BigQuery setup complete! 🚀📊**