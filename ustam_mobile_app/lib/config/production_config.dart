// Production Configuration - Auto-generated
class ProductionConfig {
  static const String baseUrl = 'https://ustaapp-analytics.appspot.com';
  static const String apiVersion = 'v1';
  static const String environment = 'production';
  static const bool debugMode = false;
  
  // API Endpoints
  static const String authEndpoint = '$baseUrl/api/auth';
  static const String jobsEndpoint = '$baseUrl/api/jobs';
  static const String craftsmenEndpoint = '$baseUrl/api/craftsmen';
  static const String searchEndpoint = '$baseUrl/api/search';
  static const String paymentEndpoint = '$baseUrl/api/payment';
  static const String messagesEndpoint = '$baseUrl/api/messages';
  static const String analyticsEndpoint = '$baseUrl/api/analytics';
  
  // WebSocket
  static const String socketUrl = 'https://ustaapp-analytics.appspot.com';
  
  // File Upload
  static const String uploadEndpoint = '$baseUrl/api/upload';
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
}
