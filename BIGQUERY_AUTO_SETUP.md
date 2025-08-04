# 🚀 ustam - OTOMATİK BIGQUERY SETUP REHBERİ

Bu rehber ile BigQuery'ye veri yükleme işlemini **tamamen otomatik** hale getirebilirsiniz!

## 📋 **ÖN GEREKSINIMLER**

### **1. Google Cloud SDK Kurulumu**
```
https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
```
- İndirin ve kurun
- "Add gcloud to my PATH" ✅ işaretleyin
- Command Prompt'u yeniden başlatın

### **2. Authentication**
```powershell
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### **3. BigQuery API Aktif Et**
```powershell
gcloud services enable bigquery.googleapis.com
```

---

## 🤖 **OTOMATİK UPLOAD KULLANIMI**

### **Yöntem 1: Windows Batch Script (En Kolay)**

```powershell
# Backend klasöründe
.\bigquery_upload.bat
```

Script şunları yapacak:
1. ✅ Prerequisites kontrol
2. 📊 Project ID sor
3. 📤 SQLite'dan veri export et
4. ⬆️  BigQuery'ye otomatik yükle
5. 📊 Analytics view'ları oluştur

### **Yöntem 2: Python Script (Gelişmiş)**

```powershell
# Kendi project ID'nizle
python bigquery_auto_upload.py your-project-id
```

### **Yöntem 3: Tek Komut (Hızlı)**

```powershell
python -c "
from bigquery_auto_upload import AutoBigQueryUploader
uploader = AutoBigQueryUploader()
uploader.project_id = 'your-project-id'
uploader.full_upload()
"
```

---

## 📊 **BEKLENEN ÇIKTI**

Başarılı upload şöyle görünür:

```
🚀 ustam - AUTOMATIC BIGQUERY UPLOAD
==================================================
🔍 Checking prerequisites...
INFO:__main__:✅ Google Cloud authentication verified
INFO:__main__:✅ BigQuery API is enabled

📤 Exporting data from SQLite...
INFO:__main__:Users data exported: 3 records
INFO:__main__:Categories data exported: 10 records
INFO:__main__:Customers data exported: 1 records
INFO:__main__:Craftsmen data exported: 1 records

📊 Setting up BigQuery dataset...
INFO:__main__:✅ Dataset ustam_analytics already exists

⬆️  Uploading tables to BigQuery...
INFO:__main__:📤 Uploading users (3 records)...
INFO:__main__:✅ users uploaded successfully (3 records)
INFO:__main__:📤 Uploading categories (10 records)...
INFO:__main__:✅ categories uploaded successfully (10 records)
INFO:__main__:📤 Uploading customers (1 records)...
INFO:__main__:✅ customers uploaded successfully (1 records)
INFO:__main__:📤 Uploading craftsmen (1 records)...
INFO:__main__:✅ craftsmen uploaded successfully (1 records)

📊 Creating analytics views...
INFO:__main__:✅ View user_activity created successfully
INFO:__main__:✅ View job_analytics created successfully
INFO:__main__:✅ View revenue_analytics created successfully

✅ UPLOAD COMPLETE!
==================================================
📊 Tables uploaded: 4/4
🌐 BigQuery Console: https://console.cloud.google.com/bigquery?project=your-project
📈 Dataset: your-project.ustam_analytics

🔍 Sample Queries:
-- View all users
SELECT * FROM `your-project.ustam_analytics.users`;

-- User statistics
SELECT user_type, COUNT(*) as count FROM `your-project.ustam_analytics.users` GROUP BY user_type;
```

---

## 📊 **BIGQUERY'DE VERİLERİ GÖRME**

### **1. Web Console'a Git**
```
https://console.cloud.google.com/bigquery?project=YOUR_PROJECT_ID
```

### **2. Dataset'i Bul**
- Sol panelde project'inizi genişletin
- `ustam_analytics` dataset'ini görün
- Tabloları keşfedin

### **3. Hazır Query'ler**

#### **Kullanıcı İstatistikleri:**
```sql
SELECT 
  user_type,
  COUNT(*) as total_users,
  SUM(CASE WHEN is_active THEN 1 ELSE 0 END) as active_users,
  SUM(CASE WHEN is_verified THEN 1 ELSE 0 END) as verified_users
FROM `your-project.ustam_analytics.users`
GROUP BY user_type;
```

#### **Kategori Analizi:**
```sql
SELECT 
  name,
  total_jobs,
  total_craftsmen,
  is_featured,
  sort_order
FROM `your-project.ustam_analytics.categories`
ORDER BY sort_order;
```

#### **Usta Profilleri:**
```sql
SELECT 
  u.first_name,
  u.last_name,
  c.business_name,
  c.average_rating,
  c.total_jobs,
  c.is_verified,
  u.city
FROM `your-project.ustam_analytics.craftsmen` c
JOIN `your-project.ustam_analytics.users` u ON c.user_id = u.user_id
ORDER BY c.average_rating DESC;
```

#### **Analytics View'ları:**
```sql
-- User activity summary
SELECT * FROM `your-project.ustam_analytics.user_activity`;

-- Job analytics (boş olabilir)
SELECT * FROM `your-project.ustam_analytics.job_analytics`;

-- Revenue analytics (boş olabilir)
SELECT * FROM `your-project.ustam_analytics.revenue_analytics`;
```

---

## 🔄 **GÜNCELLEMELER İÇİN**

### **Yeni Veri Eklendikçe:**

```powershell
# 1. Uygulamada yeni veri ekle (web/mobile app ile)
# 2. Otomatik upload çalıştır
.\bigquery_upload.bat
```

### **Scheduled Updates (Gelişmiş):**

#### **Windows Task Scheduler:**
```
1. Task Scheduler açın
2. "Create Basic Task" tıklayın
3. Name: "ustam BigQuery Update"
4. Trigger: Daily (günlük)
5. Action: Start a program
6. Program: C:\path\to\backend\bigquery_upload.bat
```

#### **Cron Job (Linux/Mac):**
```bash
# Daily at 2 AM
0 2 * * * cd /path/to/backend && python bigquery_auto_upload.py your-project-id
```

---

## 🚨 **SORUN GİDERME**

### **"gcloud command not found"**
```
✅ Çözüm: Google Cloud SDK'yı yeniden kurun
https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
```

### **"No active authentication"**
```
✅ Çözüm: 
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### **"BigQuery API not enabled"**
```
✅ Çözüm:
gcloud services enable bigquery.googleapis.com
```

### **"Permission denied"**
```
✅ Çözüm: Project owner/editor olduğunuzdan emin olun
Google Cloud Console → IAM → Permissions kontrol
```

### **"Table already exists"**
```
✅ Normal: Script --replace flag kullanır, eski veriyi günceller
```

### **"Empty file"**
```
✅ Normal: Boş tablolar (jobs, messages) skip edilir
```

---

## 💰 **MALIYET KONTROLÜ**

### **Ücretsiz Tier Limitleri:**
- **Storage:** 10 GB/ay (sizin verileriniz ~1 MB)
- **Query:** 1 TB/ay (sizin query'leriniz ~1 MB)
- **Slots:** 100 concurrent

### **Maliyet İzleme:**
```
Google Cloud Console → Billing → Budgets & alerts
Budget: $5
Alerts: 50%, 90%, 100%
```

### **Query Maliyeti Görme:**
```sql
-- Query cost preview (BigQuery console'da)
-- Estimated cost: $0.00 (free tier)
SELECT COUNT(*) FROM `your-project.ustam_analytics.users`;
```

---

## 🎯 **ÖZET KOMUTLAR**

### **İlk Kurulum:**
```powershell
# 1. Google Cloud SDK kur
# 2. Authentication
gcloud auth login
gcloud config set project your-project-id
gcloud services enable bigquery.googleapis.com

# 3. Otomatik upload
.\bigquery_upload.bat
```

### **Günlük Kullanım:**
```powershell
# Tek komut - her şeyi yapar
.\bigquery_upload.bat
```

### **Veri Görüntüleme:**
```
https://console.cloud.google.com/bigquery?project=your-project-id
```

---

## 🎉 **BAŞARI!**

Artık BigQuery entegrasyonunuz tamamen otomatik! 

- ✅ Tek tıkla veri export + upload
- ✅ Otomatik tablo oluşturma
- ✅ Analytics view'ları hazır
- ✅ Maliyet kontrolü
- ✅ Scheduled updates

**Tek yapmanız gereken `.\bigquery_upload.bat` çalıştırmak!** 🚀

---

## 📞 **DESTEK**

Sorun yaşarsanız:
1. Error mesajını kontrol edin
2. Prerequisites'leri doğrulayın
3. Google Cloud Console'da permissions kontrol edin
4. Billing account'un aktif olduğundan emin olun

**Happy Analytics!** 📊✨