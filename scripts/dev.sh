#!/bin/bash

# Development server starter script
# Tüm servisleri paralel olarak başlatır

echo "🚀 Ustalar App geliştirme sunucuları başlatılıyor..."

# Terminal session'ları oluştur
gnome-terminal --tab --title="Backend" -- bash -c "cd ../backend && source venv/bin/activate && flask run; exec bash" 2>/dev/null || \
terminal --tab --title="Backend" -- bash -c "cd ../backend && source venv/bin/activate && flask run; exec bash" 2>/dev/null || \
echo "Backend sunucusunu manuel olarak başlatın: cd backend && source venv/bin/activate && flask run"

gnome-terminal --tab --title="Web" -- bash -c "cd ../web && npm run dev; exec bash" 2>/dev/null || \
terminal --tab --title="Web" -- bash -c "cd ../web && npm run dev; exec bash" 2>/dev/null || \
echo "Web sunucusunu manuel olarak başlatın: cd web && npm run dev"

gnome-terminal --tab --title="Mobile" -- bash -c "cd ../mobile && npm start; exec bash" 2>/dev/null || \
terminal --tab --title="Mobile" -- bash -c "cd ../mobile && npm start; exec bash" 2>/dev/null || \
echo "Mobil sunucusunu manuel olarak başlatın: cd mobile && npm start"

echo "✅ Sunucular başlatıldı!"
echo ""
echo "🌐 Web: http://localhost:3000"
echo "📱 Mobile: Expo Go ile QR kod tarayın"
echo "🔗 API: http://localhost:5000"
