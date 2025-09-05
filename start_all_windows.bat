@echo off
echo 🚀 Starting ustam App - All Components
echo ========================================

REM Check if we're in the right directory
if not exist "backend" (
    echo ❌ Backend folder not found. Make sure you're in the ustaapp root directory.
    pause
    exit /b 1
)

if not exist "web" (
    echo ❌ Web folder not found. Make sure you're in the ustaapp root directory.
    pause
    exit /b 1
)

echo 📋 Starting all components...
echo.

REM Start Backend
echo 🔧 Starting Backend (Flask API)...
start "ustam Backend" cmd /k "cd backend && venv\Scripts\activate && python run.py"
timeout /t 3

REM Start Web Frontend  
echo 🌐 Starting Web Frontend (React)...
start "ustam Web" cmd /k "cd web && npm run dev"
timeout /t 3

REM Start Mobile (optional)
echo 📱 Starting Mobile App (Flutter)...
start "ustam Mobile" cmd /k "cd ustam_mobile_app && flutter run"

echo.
echo ✅ All components started!
echo ========================================
echo 🔧 Backend: http://localhost:5000
echo 🌐 Web: http://localhost:5173  
echo 📱 Mobile: Flutter simulator
echo.
echo Press any key to close this window...
pause