@echo off
echo 🚀 ustam App - Quick Setup
echo ============================

REM Check prerequisites
echo 📋 Checking prerequisites...

python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found. Please install Python 3.8+
    echo Download: https://www.python.org/downloads/
    pause
    exit /b 1
)

node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found. Please install Node.js 16+
    echo Download: https://nodejs.org/
    pause
    exit /b 1
)

flutter --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️ Flutter not found. Mobile app won't work.
    echo Download: https://flutter.dev/docs/get-started/install
)

echo ✅ Prerequisites check complete
echo.

REM Setup Backend
echo 🔧 Setting up Backend...
cd backend
if not exist "venv" (
    python -m venv venv
)
call venv\Scripts\activate
pip install -r requirements.txt
call setup_env.bat
call smart_setup.bat
cd ..

REM Setup Flutter Web
echo 📱 Setting up Flutter Cross-Platform...
cd ustam_mobile_app
flutter config --enable-web
flutter pub get
cd ..


echo.
echo ✅ Setup Complete!
echo ==================
echo.
echo 🚀 To start all components:
echo    start_flutter_all.bat
echo.
echo 🔧 Individual components:
echo    Backend:      cd backend ^&^& venv\Scripts\activate ^&^& python run.py
echo    Flutter Web:  cd ustam_mobile_app ^&^& flutter run -d chrome --web-port=8080
echo    Flutter Mobile: cd ustam_mobile_app ^&^& flutter run
echo.
echo 🌐 URLs after starting:
echo    Backend API: http://localhost:5000
echo    Flutter Web: http://localhost:8080
echo    Flutter Mobile: Simulator/Device
echo.
pause