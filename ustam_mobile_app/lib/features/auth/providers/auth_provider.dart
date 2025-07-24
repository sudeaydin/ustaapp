import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
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
    
    final token = _prefs.getString('authToken');
    final userJson = _prefs.getString('user');
    
    if (token != null && userJson != null) {
      // Parse user data and validate token
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        // user: jsonDecode(userJson),
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual login API call
      // For now, simulate login
      await Future.delayed(const Duration(seconds: 1));
      
      if (email == 'customer@example.com' && password == 'password123') {
        final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        final user = {
          'id': 1,
          'email': email,
          'user_type': 'customer',
          'first_name': 'Test',
          'last_name': 'User',
        };
        
        await _prefs.setString('authToken', token);
        await _prefs.setString('user', '{}'); // JSON encode user data
        
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
      await _prefs.setString('user', '{}'); // JSON encode user data
      
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