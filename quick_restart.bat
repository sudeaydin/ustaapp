@echo off
echo ========================================
echo       UstamApp Quick Restart
echo ========================================
echo.

:: Change to project directory
cd /d C:\FlutterProjects\ustam_mobile_app
if %errorlevel% neq 0 (
    echo ERROR: Could not find project directory!
    pause
    exit /b 1
)

:: Kill any existing processes
echo [1/3] Stopping existing processes...
taskkill /f /im python.exe 2>nul
taskkill /f /im flutter.exe 2>nul

:: Start Backend
echo [2/3] Starting Backend Server...
cd backend
start "Backend Server" cmd /k "call venv\Scripts\activate && python run.py"
echo Backend server started in new window...
echo Waiting 3 seconds for server to start...
timeout /t 3 /nobreak > nul

:: Start Flutter
echo [3/3] Starting Flutter App...
cd ..\ustam_mobile_app
echo.
echo ========================================
echo          Quick Restart Complete!
echo ========================================
echo.
echo Backend Server: http://localhost:5000
echo Flutter App: Starting now...
echo.
flutter run

echo.
echo App stopped. Backend server is still running in separate window.
pause