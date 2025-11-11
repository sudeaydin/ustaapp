#!/bin/bash
# 🚀 Flutter Telefon Önizleme - Tek Komutla Başlatma

echo "🔄 Git'ten son değişiklikleri çekiyorum..."
cd /workspace
git pull origin main

echo "📱 Flutter projesini hazırlıyorum..."
cd /workspace/ustam_mobile_app
flutter clean
flutter pub get

echo "🔍 Mevcut emülatörleri kontrol ediyorum..."
flutter emulators

echo ""
echo "📲 Emülatör seçimi:"
echo "1) Chrome (Web - Hızlı)"
echo "2) Android Emülatör (İlk seçeneği kullan)"
read -p "Seçiminiz (1 veya 2): " choice

if [ "$choice" = "1" ]; then
    echo "🌐 Chrome'da başlatılıyor..."
    flutter run -d chrome
elif [ "$choice" = "2" ]; then
    echo "📱 Android emülatörü başlatılıyor..."
    # İlk emülatörü al
    EMULATOR=$(flutter emulators | grep -o "Pixel.*" | head -1 | awk '{print $1}')
    
    if [ -z "$EMULATOR" ]; then
        echo "❌ Emülatör bulunamadı! Android Studio'da emülatör oluştur."
        exit 1
    fi
    
    echo "🚀 $EMULATOR başlatılıyor..."
    flutter emulators --launch $EMULATOR &
    
    echo "⏳ Emülatör açılana kadar 30 saniye bekliyorum..."
    sleep 30
    
    echo "🎯 Uygulamayı başlatıyorum..."
    flutter run
else
    echo "❌ Geçersiz seçim!"
    exit 1
fi
