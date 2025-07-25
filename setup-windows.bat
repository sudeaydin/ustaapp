@echo off
echo 🏗️  USTAM PROJECT SETUP (Windows)
echo ===================================
echo.

REM Check if we're in the right directory
if not exist "setup-windows.bat" (
    echo ❌ Please run this script from the Ustam project root directory
    pause
    exit /b 1
)

REM Setup Backend
echo 🔧 Setting up Backend...
cd backend
call setup-windows.bat
cd ..

echo.
echo ========================
echo.

REM Setup Frontend
echo 🌐 Setting up Frontend...
cd web
call setup-windows.bat
cd ..

echo.
echo 🎉 USTAM PROJECT SETUP COMPLETE!
echo ================================
echo.
echo 🚀 To start the application:
echo.
echo 1. Start Backend (Terminal 1):
echo    cd backend
echo    venv\Scripts\activate
echo    python run.py
echo.
echo 2. Start Frontend (Terminal 2):
echo    cd web
echo    npm start
echo.
echo 3. Open browser:
echo    http://localhost:5173
echo.
echo 📝 Test Users:
echo    Customer: customer@example.com / password123
echo    Craftsman: craftsman@example.com / password123
echo    Admin: admin@example.com / admin123
echo.
pause