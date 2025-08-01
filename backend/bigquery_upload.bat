@echo off
echo 🚀 USTAM - AUTOMATIC BIGQUERY UPLOAD
echo ==================================================
echo.

REM Check if Google Cloud SDK is installed
where gcloud >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Google Cloud SDK not found!
    echo Please install from: https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
    pause
    exit /b 1
)

REM Check if Python is available
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Python not found!
    echo Please install Python 3.8+
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed
echo.

REM Get project ID from user
set /p PROJECT_ID="Enter your Google Cloud Project ID (e.g., ustam-analytics): "
if "%PROJECT_ID%"=="" (
    echo ❌ Project ID is required
    pause
    exit /b 1
)

echo 📊 Using Project ID: %PROJECT_ID%
echo.

REM Run the automatic upload
echo 🚀 Starting automatic upload...
python bigquery_auto_upload.py %PROJECT_ID%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Upload completed successfully!
    echo 🌐 View your data at: https://console.cloud.google.com/bigquery?project=%PROJECT_ID%
) else (
    echo.
    echo ❌ Upload failed. Please check the error messages above.
)

echo.
pause