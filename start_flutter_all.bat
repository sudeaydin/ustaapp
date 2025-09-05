@echo off
echo 🚀 Starting ustam App - Flutter Cross-Platform
echo ===============================================

REM Check if we're in the right directory
if not exist "ustam_mobile_app" (
    echo ❌ ustam_mobile_app folder not found. Make sure you're in the ustaapp root directory.
    pause
    exit /b 1
)

if not exist "backend" (
    echo ❌ Backend folder not found. Make sure you're in the ustaapp root directory.
    pause
    exit /b 1
)

echo 📋 Starting Flutter cross-platform app...
echo.

REM Start Backend
echo 🔧 Starting Backend (Python Flask API)...
start "ustam Backend API" cmd /k "cd backend && venv\Scripts\activate && python run.py"
timeout /t 3

REM Start Flutter Web
echo 🌐 Starting Flutter Web...
start "ustam Flutter Web" cmd /k "cd ustam_mobile_app && flutter run -d chrome --web-port=8080"
timeout /t 3

REM Start Flutter Mobile (optional)
echo 📱 Starting Flutter Mobile...
start "ustam Flutter Mobile" cmd /k "cd ustam_mobile_app && flutter run"

echo.
echo ✅ All components started!
echo ========================================
echo 🔧 Backend API: http://localhost:5000
echo 🌐 Flutter Web: http://localhost:8080
echo 📱 Flutter Mobile: Simulator/Device
echo.
echo 🎯 Artık tek Flutter kod base!
echo    - Mobile: Native Android/iOS
echo    - Web: Flutter Web (Chrome)
echo    - Backend: Python API
echo.
echo Press any key to close this window...
pause