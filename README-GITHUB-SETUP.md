# 🚀 GitHub Auto-Push & Notification Setup

## 📋 Hızlı Kurulum

### 1. GitHub Repository Oluştur
```bash
# GitHub'da yeni repository oluştur: ustalar-app
# Public olarak ayarla
```

### 2. Auto-Setup Çalıştır
```bash
./scripts/setup-github.sh
```

### 3. İlk Push
```bash
git push -u origin main
```

### 4. Auto-Push Daemon Başlat
```bash
./scripts/auto-push.sh daemon
```

## 🔔 Notification Kurulumu

### Discord Webhook
1. Discord server'ında webhook oluştur
2. GitHub repository > Settings > Secrets and variables > Actions
3. New repository secret:
   - Name: `DISCORD_WEBHOOK_URL`
   - Value: `https://discord.com/api/webhooks/...`

### Email Notification
1. SMTP bilgilerini GitHub Secrets'e ekle:
   - `SMTP_HOST`
   - `SMTP_PORT`
   - `SMTP_USER`
   - `SMTP_PASS`
   - `EMAIL_TO`

## ⚡ Özellikler

### 🔄 Auto-Push
- Her 10 dakikada otomatik commit & push
- Progress hesaplama
- Akıllı commit mesajları

### 📊 Progress Tracking
- Real-time dosya sayısı
- Backend/Frontend ayrımı
- Completion percentage

### 🔔 Notifications
- Discord embed messages
- Email alerts
- GitHub Actions integration

## 🎯 Kullanım

### Manuel Push
```bash
./scripts/auto-push.sh
```

### Daemon Mode (Sürekli)
```bash
./scripts/auto-push.sh daemon
```

### Progress Kontrolü
```bash
cat dashboard/progress.json
```

## 📱 Notification Örnekleri

### Discord Message:
```
🚀 Ustalar App - Auto Push
🔄 Auto-push: Progress 85% - 18:45
📊 Progress: 85%
⏰ Time: 18:45:32
```

### GitHub Actions:
- Her push'da otomatik çalışır
- Progress hesaplar
- Notification gönderir
- Dashboard günceller

## 🛠️ Troubleshooting

### Push Hatası
```bash
git remote -v  # Remote kontrolü
git pull origin main  # Sync
git push origin main  # Tekrar push
```

### Webhook Hatası
- URL'yi kontrol et
- Discord server permissions
- GitHub secrets doğru mu

### Daemon Durdurma
```bash
pkill -f "auto-push.sh daemon"
```

## 🎉 Sonuç

Bu sistem ile:
- ✅ Otomatik GitHub sync
- ✅ Real-time notifications
- ✅ Progress tracking
- ✅ Zero-maintenance

**Artık sadece kod yaz, gerisi otomatik! 🚀**
