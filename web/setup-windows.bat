@echo off
echo 🌐 ustam Frontend Setup (Windows)
echo =================================

REM Install dependencies
echo 📥 Installing dependencies...
npm install

REM Check for security vulnerabilities
echo 🔒 Checking for security issues...
npm audit --audit-level moderate

echo.
echo 🎉 Frontend setup complete!
echo To start the development server:
echo   npm start
echo.
echo To build for production:
echo   npm run build
echo.
pause