import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/error_handler.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

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

      return response;
    } on SocketException {
      throw AppError(
        type: ErrorType.noInternet,
        message: 'İnternet bağlantınızı kontrol edin',
      );
    } on TimeoutException {
      throw AppError(
        type: ErrorType.timeout,
        message: 'İstek zaman aşımına uğradı',
      );
    } catch (e) {
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
    bool requiresAuth = false,
  }) async {
    try {
      String url = '${AppConfig.baseUrl}$endpoint';
      
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParams).toString();
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
          message: data['message'],
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
      body: {'email': email, 'password': password},
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
    return post<Map<String, dynamic>>(
      ApiEndpoints.quoteRequest,
      body: quoteData,
      requiresAuth: true,
    );
  }
}