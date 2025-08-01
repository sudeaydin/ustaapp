import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This will be overridden in main.dart with actual SharedPreferences instance
  throw UnimplementedError('SharedPreferences not initialized');
});

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
        print('Error parsing user data: $e');
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
      // TODO: Implement actual login API call
      // For now, simulate login
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock users - validate userType matches
      Map<String, dynamic>? user;
      
      if (email == 'customer@test.com' && password == '123456') {
        if (userType == null || userType == 'customer') {
          user = {
            'id': 1,
            'email': email,
            'user_type': 'customer',
            'first_name': 'Ahmet',
            'last_name': 'Müşteri',
          };
        }
      } else if (email == 'ahmet@test.com' && password == '123456') {
        if (userType == null || userType == 'craftsman') {
          user = {
            'id': 2,
            'email': email,
            'user_type': 'craftsman',
            'first_name': 'Ahmet',
            'last_name': 'Usta',
            'specialty': 'Elektrikçi',
          };
        }
      } else if (email == 'admin@example.com' && password == 'admin123') {
        if (userType == null || userType == 'admin') {
          user = {
            'id': 3,
            'email': email,
            'user_type': 'admin',
            'first_name': 'Admin',
            'last_name': 'User',
          };
        }
      }
      
      // Additional validation for userType mismatch
      if (user == null && userType != null) {
        String errorMessage = userType == 'customer' 
          ? 'Bu hesap bireysel kullanıcı hesabı değil'
          : 'Bu hesap usta/zanaatkar hesabı değil';
        
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
        return false;
      }
      
      if (user != null) {
        final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        
        await _prefs.setString('authToken', token);
        await _prefs.setString('user', jsonEncode(user)); // JSON encode user data
        await _prefs.setString('user_type', user['user_type']); // Store user_type separately
        
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: user,
          isLoading: false,
        );
        
        return true;
      } else {
        state = state.copyWith(
          error: 'Geçersiz email veya şifre',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Giriş yapılırken hata oluştu',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
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

  Future<void> logout() async {
    await _prefs.remove('authToken');
    await _prefs.remove('user');
    await _prefs.remove('user_type');
    
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