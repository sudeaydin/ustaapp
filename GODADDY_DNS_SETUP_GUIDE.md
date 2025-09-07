# 🌐 GoDaddy DNS Setup Guide - ustancepte.com

## 📋 **OVERVIEW**
Bu rehber GoDaddy'de `ustancepte.com` domain'ini Google App Engine'e yönlendirmek için DNS ayarlarını açıklar.

---

## 🔧 **STEP-BY-STEP DNS CONFIGURATION**

### **1. GoDaddy Account'a Giriş**
1. https://godaddy.com adresine git
2. Account'una giriş yap
3. "My Products" → "All Products and Services" tıkla
4. "Domains" bölümünde `ustancepte.com` domaini bul
5. "DNS" butonuna tıkla

### **2. Mevcut DNS Kayıtlarını Temizle**
**⚠️ DİKKAT: Önce mevcut kayıtları yedekle!**

Silmemiz gereken kayıtlar:
- A Records (@ işaretli olanlar)
- CNAME Records (www işaretli olanlar)
- Parked domain yönlendirmeleri

### **3. Yeni DNS Kayıtları Ekle**

#### **A Records (IPv4 Adresleri)**
| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 216.239.32.21 | 600 |
| A | @ | 216.239.34.21 | 600 |
| A | @ | 216.239.36.21 | 600 |
| A | @ | 216.239.38.21 | 600 |

#### **CNAME Record (www subdomain)**
| Type | Name | Value | TTL |
|------|------|-------|-----|
| CNAME | www | ghs.googlehosted.com | 600 |

---

## 🖥️ **GoDaddy INTERFACE INSTRUCTIONS**

### **DNS Management Panel'de:**

1. **"ADD" butonuna tıkla**
2. **Type**: "A" seç
3. **Name**: "@" yaz (root domain için)
4. **Value**: İlk IP adresini gir (216.239.32.21)
5. **TTL**: 600 seç
6. **Save** tıkla

**Bu işlemi 4 A record için tekrarla!**

### **CNAME Record için:**
1. **"ADD" butonuna tıkla**
2. **Type**: "CNAME" seç  
3. **Name**: "www" yaz
4. **Value**: "ghs.googlehosted.com" yaz
5. **TTL**: 600 seç
6. **Save** tıkla

---

## ⏱️ **PROPAGATION TIME**

### **DNS Yayılma Süreleri:**
- **Minimum**: 15-30 dakika
- **Ortalama**: 2-4 saat
- **Maksimum**: 24-48 saat

### **Test Etmek için:**
```bash
# DNS propagation kontrolü
nslookup ustancepte.com
nslookup www.ustancepte.com

# Online tool
https://www.whatsmydns.net/
```

---

## 🔍 **TROUBLESHOOTING**

### **Sık Karşılaşılan Sorunlar:**

#### **1. "Domain not verified" Hatası**
- **Sebep**: DNS henüz yayılmamış
- **Çözüm**: 2-4 saat bekle, tekrar dene

#### **2. "SSL Certificate Error"**
- **Sebep**: Google henüz SSL sertifikası oluşturmamış
- **Çözüm**: Domain mapping tamamlandıktan sonra 15-30 dakika bekle

#### **3. "502 Bad Gateway"**
- **Sebep**: DNS doğru ama backend çalışmıyor
- **Çözüm**: App Engine deployment'ını kontrol et

---

## 📊 **VERIFICATION STEPS**

### **1. DNS Kontrolü**
```bash
# Windows CMD/PowerShell
nslookup ustancepte.com
nslookup www.ustancepte.com

# Beklenen sonuç:
# ustancepte.com → 216.239.32.21 (veya diğer IP'ler)
# www.ustancepte.com → ghs.googlehosted.com
```

### **2. Online DNS Checker**
- https://www.whatsmydns.net/
- Domain: `ustancepte.com`
- Type: `A`
- Dünya genelinde yeşil tik görmeli

### **3. SSL Certificate Kontrolü**
- https://www.ssllabs.com/ssltest/
- Domain: `ustancepte.com`
- Grade A+ almalı

---

## 🚨 **IMPORTANT NOTES**

### **⚠️ Dikkat Edilecekler:**
1. **Backup**: Mevcut DNS kayıtlarını yedekle
2. **Email**: MX records'ları silme (email çalışmaz)
3. **Subdomains**: Diğer subdomain'ler etkilenebilir
4. **TTL**: Düşük TTL (600) seç, değişiklik kolay olur

### **✅ Doğru Yapıldığında:**
- `ustancepte.com` → App Engine'e yönlendirilir
- `www.ustancepte.com` → App Engine'e yönlendirilir  
- SSL sertifikası otomatik oluşturulur
- HTTPS zorunlu olur

---

## 📱 **MOBILE APP IMPACT**

### **API Endpoint Değişikliği:**
- **Şu an**: https://ustaapp-analytics.uc.r.appspot.com
- **Domain sonrası**: https://ustancepte.com (opsiyonel)

### **Güncelleme Gerekmez:**
- Mevcut App Engine URL çalışmaya devam eder
- Custom domain sadek ek bir seçenek

---

## 🎯 **SUCCESS CRITERIA**

### **DNS Başarı Kontrolleri:**
- ✅ `ustancepte.com` → Google IP'lere resolve oluyor
- ✅ `www.ustancepte.com` → `ghs.googlehosted.com` resolve oluyor
- ✅ SSL sertifikası aktif
- ✅ Backend API'ler çalışıyor

### **Final Test:**
```
https://ustancepte.com/api/health
```
Sonuç:
```json
{
  "status": "healthy",
  "service": "ustam-api", 
  "version": "1.0.0",
  "environment": "standard",
  "database": "in-memory SQLite"
}
```

---

## 🆘 **NEED HELP?**

### **GoDaddy Support:**
- Phone: 1-480-505-8877
- Chat: GoDaddy website
- Help: https://godaddy.com/help

### **Google Cloud Support:**
- Console: https://console.cloud.google.com/support
- Docs: https://cloud.google.com/appengine/docs/standard/mapping-custom-domains

---

**🚀 DNS ayarlarını yaptıktan sonra bana haber ver, Google Cloud tarafını halledelim!**