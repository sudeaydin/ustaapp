@echo off
REM 🚀 Flutter Telefon Önizleme - Tek Komutla Başlatma (Windows)

echo 🔄 Git'ten son değişiklikleri çekiyorum...
cd /d %~dp0
git pull origin main

echo 📱 Flutter projesini hazırlıyorum...
cd ustam_mobile_app
flutter clean
flutter pub get

echo 🔍 Mevcut emülatörleri kontrol ediyorum...
flutter emulators

echo.
echo 📲 Emülatör seçimi:
echo 1) Chrome (Web - Hızlı)
echo 2) Android Emülatör
set /p choice="Seçiminiz (1 veya 2): "

if "%choice%"=="1" (
    echo 🌐 Chrome'da başlatılıyor...
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo 📱 Android emülatörü başlatılıyor...
    
    REM İlk emülatörü bul
    for /f "tokens=1" %%i in ('flutter emulators ^| findstr "Pixel"') do (
        set EMULATOR=%%i
        goto :found
    )
    
    :found
    if "%EMULATOR%"=="" (
        echo ❌ Emülatör bulunamadı! Android Studio'da emülatör oluştur.
        pause
        exit /b 1
    )
    
    echo 🚀 %EMULATOR% başlatılıyor...
    start /b flutter emulators --launch %EMULATOR%
    
    echo ⏳ Emülatör açılana kadar 30 saniye bekliyorum...
    timeout /t 30 /nobreak
    
    echo 🎯 Uygulamayı başlatıyorum...
    flutter run
) else (
    echo ❌ Geçersiz seçim!
    pause
    exit /b 1
)

pause
