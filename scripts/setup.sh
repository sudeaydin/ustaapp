#!/bin/bash

# Ustalar App Setup Script
# Bu script projeyi ilk kez kurarken kullanılır

echo "🚀 Ustalar App kurulumu başlatılıyor..."

# Backend setup
echo "📦 Backend bağımlılıkları yükleniyor..."
cd ../backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Database setup
echo "🗄️  Veritabanı oluşturuluyor..."
export FLASK_APP=app
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

# Web frontend setup
echo "🌐 Web frontend bağımlılıkları yükleniyor..."
cd ../web
npm install

# Mobile app setup
echo "📱 Mobil app bağımlılıkları yükleniyor..."
cd ../mobile
npm install

echo "✅ Kurulum tamamlandı!"
echo ""
echo "🏃‍♂️ Projeyi çalıştırmak için:"
echo "Backend: cd backend && source venv/bin/activate && flask run"
echo "Web: cd web && npm run dev"
echo "Mobile: cd mobile && npm start"
