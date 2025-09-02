@echo off
echo 🔧 Setting up .env file for ustam BigQuery integration...

if exist .env (
    echo ✅ .env file already exists
    echo Current content:
    type .env
    echo.
    set /p OVERWRITE="Overwrite existing .env file? (y/N): "
    if /i not "%OVERWRITE%"=="y" (
        echo Setup cancelled
        pause
        exit /b 0
    )
)

echo 📝 Creating .env file...
echo # BigQuery Configuration > .env
echo BIGQUERY_LOGGING_ENABLED=true >> .env
echo BIGQUERY_PROJECT_ID=ustaapp-analytics >> .env
echo. >> .env
echo # Flask Configuration >> .env
echo FLASK_ENV=development >> .env
echo SECRET_KEY=dev-secret-key-%RANDOM%-%RANDOM% >> .env
echo JWT_SECRET_KEY=jwt-secret-key-%RANDOM%-%RANDOM% >> .env
echo. >> .env
echo # Database >> .env
echo DATABASE_URL=sqlite:///app.db >> .env

echo ✅ .env file created successfully!
echo.
echo 📋 Content:
type .env
echo.
echo 🚀 You can now run: python test_bigquery_integration.py
echo.
pause