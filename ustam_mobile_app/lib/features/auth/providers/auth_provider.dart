import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/app_config.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/providers/app_providers.dart';

// Auth state model
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.user,
    this.error,
  });

  // Getter for userType for compatibility
  String? get userType => user?['user_type'];
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;

  AuthNotifier(this._prefs) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 500));
    
    final token = _prefs.getString('authToken');
    final userJson = _prefs.getString('user');
    
    if (token != null && userJson != null && userJson != '{}') {
      try {
        // Parse user data and validate token
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: userData,
          isLoading: false,
        );
      } catch (e) {
        print('Error parsing user body: $e');
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  Future<bool> login(String email, String password, {String? userType}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sanitizedEmail = email.trim();
      final sanitizedPassword = password.trim();

      if (AppConfig.allowMockAuthentication) {
        final mockUser = _resolveMockUser(sanitizedEmail, sanitizedPassword);
        if (mockUser != null) {
          if (userType != null && mockUser['user_type'] != userType) {
            final errorMessage = userType == 'customer'
                ? 'Bu hesap bireysel kullanıcı hesabı değil'
                : 'Bu hesap usta/zanaatkar hesabı değil';

            state = state.copyWith(
              isLoading: false,
              error: errorMessage,
            );
            return false;
          }

          const mockToken = 'mock_jwt_token_12345';
          await _prefs.setString('authToken', mockToken);
          await _prefs.setString('user', jsonEncode(mockUser));
          await _prefs.setString('user_type', mockUser['user_type']);

          state = state.copyWith(
            isAuthenticated: true,
            token: mockToken,
            user: mockUser,
            isLoading: false,
          );

          return true;
        }
      }

      final apiResponse = await ApiService().login(sanitizedEmail, sanitizedPassword);

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data!;
        final token = data['data']['access_token'];
        final user = data['data']['user'];

        if (userType != null && user['user_type'] != userType) {
          final errorMessage = userType == 'customer'
              ? 'Bu hesap bireysel kullanıcı hesabı değil'
              : 'Bu hesap usta/zanaatkar hesabı değil';

          state = state.copyWith(
            isLoading: false,
            error: errorMessage,
          );
          return false;
        }

        await _prefs.setString('authToken', token);
        await _prefs.setString('user', jsonEncode(user));
        await _prefs.setString('user_type', user['user_type']);

        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: user,
          isLoading: false,
        );

        return true;
      }

      final errorMessage = apiResponse.error?.userFriendlyMessage ?? 'Geçersiz email veya şifre';
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      return false;
    } catch (e) {
      final error = e is AppError ? e : AppError.fromException(e);
      state = state.copyWith(
        error: error.userFriendlyMessage,
        isLoading: false,
      );
      return false;
    }
  }

  Map<String, dynamic>? _resolveMockUser(String email, String password) {
    final normalizedEmail = email.toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedEmail == 'customer@test.com' && normalizedPassword == '123456') {
      return {
        'id': '1',
        'first_name': 'Test',
        'last_name': 'Customer',
        'email': normalizedEmail,
        'user_type': 'customer',
        'phone': '+90 555 123 4567',
        'created_at': DateTime.now().toIso8601String(),
      };
    }

    if (normalizedEmail == 'ahmet@test.com' && normalizedPassword == '123456') {
      return {
        'id': '2',
        'first_name': 'Ahmet',
        'last_name': 'Usta',
        'email': normalizedEmail,
        'user_type': 'craftsman',
        'phone': '+90 555 987 6543',
        'business_name': 'Ahmet Elektrik',
        'category': 'Elektrikçi',
        'created_at': DateTime.now().toIso8601String(),
      };
    }

    return null;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String userType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual register API call
      await Future.delayed(const Duration(seconds: 1));
      
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      final user = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'email': email,
        'phone': phone,
        'user_type': userType,
        'first_name': firstName,
        'last_name': lastName,
      };
      
      await _prefs.setString('authToken', token);
      await _prefs.setString('user', jsonEncode(user)); // JSON encode user data
      await _prefs.setString('user_type', userType); // Store user_type separately
      
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        user: user,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Kayıt olurken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle({required String userType}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final googleAccount = await GoogleAuthService.signIn();
      if (googleAccount == null) {
        state = state.copyWith(
          error: 'Google ile giriş iptal edildi',
          isLoading: false,
        );
        return false;
      }

      // Get Google user info
      final userInfo = await GoogleAuthService.getUserInfo();
      if (userInfo == null) {
        state = state.copyWith(
          error: 'Google kullanıcı bilgileri alınamadı',
          isLoading: false,
        );
        return false;
      }

      // Send to backend for registration/login
      final idToken = await GoogleAuthService.getIdToken();
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'user_type': userType,
          'google_id': userInfo['id'],
          'email': userInfo['email'],
          'display_name': userInfo['displayName'],
          'photo_url': userInfo['photoUrl'],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['data']['token'];
        final user = responseData['data']['user'];
        
        await _prefs.setString('authToken', token);
        await _prefs.setString('user', jsonEncode(user));
        await _prefs.setString('user_type', userType);
        
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: user,
          isLoading: false,
        );
        
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        state = state.copyWith(
          error: errorData['message'] ?? 'Google ile giriş başarısız',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Google ile giriş sırasında hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove('authToken');
    await _prefs.remove('user');
    await _prefs.remove('user_type');
    
    // Sign out from Google as well
    await GoogleAuthService.signOut();
    
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});