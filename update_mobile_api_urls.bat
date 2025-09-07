@echo off
echo 📱 Updating Mobile App API URLs for Production
echo ===============================================

set PRODUCTION_URL=https://ustaapp-analytics.appspot.com

echo 🔧 Updating Flutter app configuration...
cd ustam_mobile_app

REM Update API base URL in config
echo Updating API configuration...

REM Create production config
(
echo class ProductionConfig {
echo   static const String apiBaseUrl = '%PRODUCTION_URL%';
echo   static const String environment = 'production';
echo   static const bool enableAnalytics = true;
echo   static const bool enableCrashReporting = true;
echo }
) > lib\core\config\production_config.dart

REM Update main config to use production
(
echo import 'package:flutter/foundation.dart';
echo import 'production_config.dart';
echo 
echo class AppConfig {
echo   static String get baseUrl {
echo     return kDebugMode 
echo         ? 'http://localhost:5000'  // Development
echo         : ProductionConfig.apiBaseUrl;  // Production
echo   }
echo   
echo   static String get environment {
echo     return kDebugMode ? 'development' : 'production';
echo   }
echo   
echo   static bool get enableAnalytics {
echo     return !kDebugMode;
echo   }
echo }
) > lib\core\config\app_config.dart

echo ✅ Mobile app configuration updated!
echo.
echo 📱 Production URLs:
echo    API: %PRODUCTION_URL%/api
echo    Web: https://ustancepte.com
echo.
echo 🚀 To build mobile apps:
echo    Android: flutter build apk --release
echo    iOS: flutter build ios --release
echo.
echo 📊 Mobile app will automatically use production API when built in release mode
cd ..
pause