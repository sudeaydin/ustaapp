@echo off
echo ========================================
echo        UstamApp Setup & Run Script
echo ========================================
echo.

:: Change to project directory
echo [1/8] Changing to project directory...
cd /d C:\FlutterProjects\ustam_mobile_app
if %errorlevel% neq 0 (
    echo ERROR: Could not find project directory!
    echo Please make sure the project is at C:\FlutterProjects\ustam_mobile_app
    pause
    exit /b 1
)

:: Pull latest changes
echo [2/8] Pulling latest changes from Git...
git pull origin main
if %errorlevel% neq 0 (
    echo WARNING: Git pull failed. Continuing anyway...
)

:: Setup Backend
echo.
echo [3/8] Setting up Backend...
cd backend
if not exist venv (
    echo Creating Python virtual environment...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo ERROR: Failed to create virtual environment!
        pause
        exit /b 1
    )
)

echo Activating virtual environment...
call venv\Scripts\activate
if %errorlevel% neq 0 (
    echo ERROR: Failed to activate virtual environment!
    pause
    exit /b 1
)

echo [4/8] Installing Python dependencies...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: Failed to install Python dependencies!
    pause
    exit /b 1
)

echo [5/8] Creating database with sample data...
python create_db_with_data.py
if %errorlevel% neq 0 (
    echo ERROR: Failed to create database!
    pause
    exit /b 1
)

:: Setup Flutter
echo.
echo [6/8] Setting up Flutter...
cd ..\ustam_mobile_app
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

:: Start Backend Server
echo.
echo [7/8] Starting Backend Server...
cd ..\backend
start "Backend Server" cmd /k "call venv\Scripts\activate && python run.py"
echo Backend server started in new window...
echo Waiting 5 seconds for server to start...
timeout /t 5 /nobreak > nul

:: Start Flutter App
echo.
echo [8/8] Starting Flutter App...
cd ..\ustam_mobile_app
echo.
echo ========================================
echo     Setup Complete! Starting App...
echo ========================================
echo.
echo Backend Server: http://localhost:5000
echo Flutter App: Starting now...
echo.
echo Press Ctrl+C to stop the Flutter app
echo Backend server is running in separate window
echo.
flutter run

echo.
echo ========================================
echo          App Stopped
echo ========================================
echo.
echo Backend server is still running in separate window.
echo Close the backend window manually if needed.
pause