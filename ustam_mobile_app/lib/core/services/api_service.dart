import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/error_handler.dart';
import 'analytics_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // Singleton getter for compatibility
  static ApiService getInstance() => _instance;

  // HTTP client with timeout
  final http.Client _client = http.Client();
  
  // Headers
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    final headers = Map<String, String>.from(_baseHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Generic request method with retry logic
  Future<http.Response> _makeRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
    int retryCount = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final requestHeaders = requiresAuth 
          ? await _getAuthHeaders()
          : headers ?? _baseHeaders;

      final uri = Uri.parse(url);
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: requestHeaders)
              .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: requestHeaders)
              .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      // Handle authentication errors
      if (response.statusCode == 401) {
        await _handleAuthError();
        throw AppError(
          type: ErrorType.authentication,
          message: 'Oturum süreniz dolmuş',
          statusCode: response.statusCode,
        );
      }

      // Retry on server errors
      if (response.statusCode >= 500 && retryCount < AppConfig.maxRetryAttempts) {
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        return _makeRequest(
          method,
          url,
          body: body,
          headers: headers,
          requiresAuth: requiresAuth,
          retryCount: retryCount + 1,
        );
      }

      // Track API call performance
      stopwatch.stop();
      _trackApiCall(url, method, response.statusCode, stopwatch.elapsedMilliseconds);
      
      return response;
    } on SocketException {
      stopwatch.stop();
      _trackApiCall(url, method, 0, stopwatch.elapsedMilliseconds);
      throw AppError(
        type: ErrorType.noInternet,
        message: 'İnternet bağlantınızı kontrol edin',
      );
    } on TimeoutException {
      stopwatch.stop();
      _trackApiCall(url, method, 408, stopwatch.elapsedMilliseconds);
      throw AppError(
        type: ErrorType.timeout,
        message: 'İstek zaman aşımına uğradı',
      );
    } catch (e) {
      stopwatch.stop();
      _trackApiCall(url, method, 0, stopwatch.elapsedMilliseconds);
      if (e is AppError) rethrow;
      throw AppError.fromException(e);
    }
  }

  // Handle authentication errors
  Future<void> _handleAuthError() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userType');
    await prefs.remove('userId');
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? params, // Alias for queryParams
    bool requiresAuth = false,
  }) async {
    try {
      String url = '${AppConfig.baseUrl}$endpoint';
      
      // Use params if provided, otherwise use queryParams
      final finalParams = params?.map((k, v) => MapEntry(k, v.toString())) ?? queryParams;
      
      if (finalParams != null && finalParams.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: finalParams).toString();
      }

      final response = await _makeRequest('GET', url, requiresAuth: requiresAuth);
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      if (e is AppError) {
        return ApiResponse<T>.error(e);
      }
      return ApiResponse<T>.error(AppError.fromException(e));
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, [
    Map<String, dynamic>? body, // Positional parameter for compatibility
  ]) async {
    return postWithOptions<T>(endpoint, body: body, requiresAuth: false);
  }
  
  // POST request with options
  Future<ApiResponse<T>> postWithOptions<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final url = '${AppConfig.baseUrl}$endpoint';
      final response = await _makeRequest(
        'POST',
        url,
        body: body,
        requiresAuth: requiresAuth,
      );
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      if (e is AppError) {
        return ApiResponse<T>.error(e);
      }
      return ApiResponse<T>.error(AppError.fromException(e));
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, [
    Map<String, dynamic>? body, // Positional parameter for compatibility
  ]) async {
    return putWithOptions<T>(endpoint, body: body, requiresAuth: false);
  }
  
  // PUT request with options
  Future<ApiResponse<T>> putWithOptions<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final url = '${AppConfig.baseUrl}$endpoint';
      final response = await _makeRequest(
        'PUT',
        url,
        body: body,
        requiresAuth: requiresAuth,
      );
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      if (e is AppError) {
        return ApiResponse<T>.error(e);
      }
      return ApiResponse<T>.error(AppError.fromException(e));
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = '${AppConfig.baseUrl}$endpoint';
      final response = await _makeRequest('DELETE', url, requiresAuth: requiresAuth);
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      if (e is AppError) {
        return ApiResponse<T>.error(e);
      }
      return ApiResponse<T>.error(AppError.fromException(e));
    }
  }

  // File upload with progress
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool requiresAuth = true,
    Function(double)? onProgress,
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _baseHeaders;
      headers.remove('Content-Type'); // Let http set multipart content type
      
      final request = http.MultipartRequest('POST', Uri.parse('${AppConfig.baseUrl}$endpoint'));
      request.headers.addAll(headers);
      
      // Add file
      final multipartFile = await http.MultipartFile.fromPath(fieldName, file.path);
      request.files.add(multipartFile);
      
      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send()
          .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds * 2)); // Longer timeout for uploads
      
      final response = await http.Response.fromStream(streamedResponse);
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      if (e is AppError) {
        return ApiResponse<T>.error(e);
      }
      return ApiResponse<T>.error(AppError.fromException(e));
    }
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final AppError? error;
  final String? message;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(AppError error) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: error.statusCode,
    );
  }

  factory ApiResponse.fromResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.success(
          data as T,
          message: data is Map<String, dynamic> ? data['message'] : null,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>.error(AppError.fromHttpResponse(response));
      }
    } catch (e) {
      return ApiResponse<T>.error(
        AppError(
          type: ErrorType.server,
          message: 'Yanıt işlenirken hata oluştu',
          statusCode: response.statusCode,
          originalError: e,
        ),
      );
    }
  }

  // Helper methods
  bool get isSuccess => success && error == null;
  bool get isError => !success || error != null;
  bool get hasData => data != null;
}

// API endpoints organized by feature
class ApiEndpoints {
  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String profile = '/api/auth/profile';
  static const String deleteAccount = '/api/auth/delete-account';
  static const String uploadPortfolio = '/api/auth/upload-portfolio-image';
  static const String deletePortfolio = '/api/auth/delete-portfolio-image';
  
  // Search endpoints
  static const String searchCategories = '/api/search/categories';
  static const String searchLocations = '/api/search/locations';
  static const String searchCraftsmen = '/api/search/craftsmen';
  
  // Quote endpoints
  static const String quoteRequest = '/api/quote-requests/request';
  static const String quoteResponse = '/api/quote-requests/respond';
  static const String quoteDecision = '/api/quote-requests/decision';
  static const String myQuotes = '/api/quote-requests/my-quotes';
  
  // Message endpoints
  static const String conversations = '/api/messages/conversations';
  static const String messages = '/api/messages';
  
  // Notification endpoints
  static const String notifications = '/api/notifications';
}

// Convenience methods for common API calls
extension ApiServiceExtensions on ApiService {
  // Auth methods
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) {
    return post<Map<String, dynamic>>(
      ApiEndpoints.login,
      {'email': email, 'password': password},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProfile() {
    return get<Map<String, dynamic>>(
      ApiEndpoints.profile,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() {
    return delete<Map<String, dynamic>>(
      ApiEndpoints.deleteAccount,
      requiresAuth: true,
    );
  }

  // Search methods
  Future<ApiResponse<List<dynamic>>> searchCraftsmen({
    String? query,
    String? category,
    String? city,
    String? sortBy,
  }) {
    final queryParams = <String, String>{};
    if (query != null && query.isNotEmpty) queryParams['q'] = query;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (sortBy != null) queryParams['sort_by'] = sortBy;

    return get<List<dynamic>>(
      ApiEndpoints.searchCraftsmen,
      queryParams: queryParams,
    );
  }

  Future<ApiResponse<List<dynamic>>> getCategories() {
    return get<List<dynamic>>(ApiEndpoints.searchCategories);
  }

  Future<ApiResponse<List<dynamic>>> getLocations() {
    return get<List<dynamic>>(ApiEndpoints.searchLocations);
  }

  // Quote methods
  Future<ApiResponse<Map<String, dynamic>>> createQuoteRequest(Map<String, dynamic> quoteData) {
    return postWithOptions<Map<String, dynamic>>(
      ApiEndpoints.quoteRequest,
      body: quoteData,
      requiresAuth: true,
    );
  }

  // Legal compliance methods
  Future<ApiResponse<Map<String, dynamic>>> getLegalDocument(String documentType) {
    return get<Map<String, dynamic>>(
      '${AppConfig.apiBaseUrl}/legal/documents/$documentType',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> recordConsent(String consentType, bool granted, String version) {
    return postWithOptions<Map<String, dynamic>>(
      '${AppConfig.apiBaseUrl}/legal/consent',
      body: {
        'consent_type': consentType,
        'granted': granted,
        'version': version,
      },
      requiresAuth: true,
    );
  }

  Future<ApiResponse<List<dynamic>>> getUserConsents() {
    return get<List<dynamic>>(
      '${AppConfig.apiBaseUrl}/legal/consents',
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> requestDataExport() {
    return post<Map<String, dynamic>>(
      '${AppConfig.apiBaseUrl}/legal/data-export',
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> requestAccountDeletion() {
    return post<Map<String, dynamic>>(
      '${AppConfig.apiBaseUrl}/legal/delete-account',
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> validateAge(DateTime birthDate) {
    return post<Map<String, dynamic>>(
      '${AppConfig.apiBaseUrl}/legal/validate-age',
      {
        'birth_date': birthDate.toIso8601String(),
      },
    );
  }

  // Track API call performance
  void _trackApiCall(String url, String method, int statusCode, int duration) {
    try {
      // Extract endpoint from full URL
      final uri = Uri.parse(url);
      final endpoint = uri.path;
      
      // Track asynchronously to avoid blocking
      AnalyticsService.getInstance().trackApiCall(endpoint, method, statusCode, duration);
    } catch (e) {
      // Silently fail to avoid disrupting API calls
      print('Failed to track API call: $e');
    }
  }
  
  // Generic request method for compatibility
  Future<ApiResponse<T>> request<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final url = '${AppConfig.baseUrl}$endpoint';
      final response = await _makeRequest(
        method,
        url,
        body: body,
        headers: headers,
        requiresAuth: requiresAuth,
      );
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      if (e is AppError) {
        return ApiResponse<T>.error(e);
      }
      return ApiResponse<T>.error(AppError.fromException(e));
    }
  }
}