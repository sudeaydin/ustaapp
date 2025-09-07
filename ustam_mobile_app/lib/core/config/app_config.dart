import 'package:flutter/foundation.dart';

class AppConfig {
  // API Configuration
  static const String _devBaseUrl = 'http://localhost:5000';
  static const String _prodBaseUrl = 'https://ustaapp-analytics.uc.r.appspot.com'; // Production URL
  
  static String get baseUrl {
    return kDebugMode ? _devBaseUrl : _prodBaseUrl;
  }
  
  // API Endpoints
  static String get apiUrl => '$baseUrl/api';
  
  // Auth Endpoints
  static String get loginUrl => '$apiUrl/auth/login';
  static String get registerUrl => '$apiUrl/auth/register';
  static String get profileUrl => '$apiUrl/auth/profile';
  static String get deleteAccountUrl => '$apiUrl/auth/delete-account';
  static String get uploadPortfolioUrl => '$apiUrl/auth/upload-portfolio-image';
  static String get deletePortfolioUrl => '$apiUrl/auth/delete-portfolio-image';
  
  // Search Endpoints
  static String get searchCategoriesUrl => '$apiUrl/search/categories';
  static String get searchLocationsUrl => '$apiUrl/search/locations';
  static String get searchCraftsmenUrl => '$apiUrl/search/craftsmen';
  
  // Quote Endpoints
  static String get quoteRequestUrl => '$apiUrl/quote-requests/request';
  static String get quoteResponseUrl => '$apiUrl/quote-requests/respond';
  static String get quoteDecisionUrl => '$apiUrl/quote-requests/decision';
  
  // App Configuration
  static const String appName = 'UstanBurada';
  static const String appVersion = '1.0.0';
  static const String version = appVersion; // Alias for compatibility
  static String get apiBaseUrl => baseUrl; // Alias for compatibility
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // Image Configuration
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  
  // UI Configuration
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxMessageLength = 500;
  static const int maxDescriptionLength = 1000;
}