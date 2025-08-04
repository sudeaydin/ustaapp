@echo off
echo 🚀 ustam - FIXED AUTOMATIC BIGQUERY UPLOAD
echo This script will find Google Cloud SDK automatically
echo ==================================================
echo.

REM Check if Python is available
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Python not found!
    echo Please install Python 3.8+ from: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo ✅ Python found
echo.

REM Get project ID from user
set /p PROJECT_ID="📊 Enter your Google Cloud Project ID: "
if "%PROJECT_ID%"=="" (
    echo ❌ Project ID is required
    echo.
    pause
    exit /b 1
)

echo 📊 Using Project ID: %PROJECT_ID%
echo.

REM Run the fixed automatic upload
echo 🚀 Starting fixed automatic upload...
echo This will automatically search for Google Cloud SDK...
echo.

python bigquery_auto_upload_fix.py %PROJECT_ID%

echo.
echo 🔧 If upload failed, please check the troubleshooting guide above
echo 📞 Common solutions:
echo    1. Install Google Cloud SDK as Administrator
echo    2. Restart Command Prompt after installation
echo    3. Run: gcloud auth login
echo    4. Make sure billing is enabled on your project
echo.
pause