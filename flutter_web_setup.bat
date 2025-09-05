@echo off
echo 🚀 Flutter Web Setup - Tek Kod Base
echo ====================================

echo 📱 Flutter Mobile App zaten var
echo 🌐 Flutter Web'i aktif ediyoruz...

cd ustam_mobile_app

REM Flutter web support aktif et
echo 🔧 Enabling Flutter web support...
flutter config --enable-web

REM Web dependencies ekle
echo 📦 Adding web dependencies...
flutter pub get

REM Web için build
echo 🏗️ Building for web...
flutter build web

echo ✅ Flutter Web Setup Complete!
echo ================================
echo.
echo 🚀 Çalıştırma komutları:
echo.
echo 📱 Mobile (Android/iOS):
echo    cd ustam_mobile_app
echo    flutter run
echo.
echo 🌐 Web Browser:
echo    cd ustam_mobile_app  
echo    flutter run -d chrome --web-port=8080
echo.
echo 🔧 Backend API:
echo    cd backend
echo    python run.py
echo.
echo 🎯 URLs:
echo    Backend: http://localhost:5000
echo    Flutter Web: http://localhost:8080
echo.
echo ✅ Artık tek kod base ile hem mobile hem web!
echo.
pause