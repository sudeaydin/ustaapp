import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

// Core providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// App state providers
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

// App state model
class AppState {
  final bool isOnboardingCompleted;
  final bool isDarkMode;
  final String? selectedLanguage;
  final bool isFirstLaunch;

  const AppState({
    this.isOnboardingCompleted = false,
    this.isDarkMode = false,
    this.selectedLanguage,
    this.isFirstLaunch = true,
  });

  AppState copyWith({
    bool? isOnboardingCompleted,
    bool? isDarkMode,
    String? selectedLanguage,
    bool? isFirstLaunch,
  }) {
    return AppState(
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

// App state notifier
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      state = state.copyWith(
        isOnboardingCompleted: prefs.getBool('onboarding_completed') ?? false,
        isDarkMode: prefs.getBool('dark_mode') ?? false,
        selectedLanguage: prefs.getString('selected_language') ?? 'tr',
        isFirstLaunch: prefs.getBool('first_launch') ?? true,
      );
    } catch (e) {
      // Handle error silently for app state
      debugPrint('Error loading app state: $e');
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setBool('first_launch', false);
      
      state = state.copyWith(
        isOnboardingCompleted: true,
        isFirstLaunch: false,
      );
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newDarkMode = !state.isDarkMode;
      await prefs.setBool('dark_mode', newDarkMode);
      
      state = state.copyWith(isDarkMode: newDarkMode);
    } catch (e) {
      debugPrint('Error toggling dark mode: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', language);
      
      state = state.copyWith(selectedLanguage: language);
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }
}

// Network connectivity provider
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityState {
  final bool isConnected;
  final bool isChecking;

  const ConnectivityState({
    this.isConnected = true,
    this.isChecking = false,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    bool? isChecking,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(const ConnectivityState()) {
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    state = state.copyWith(isChecking: true);
    
    try {
      // Simple connectivity check
      final apiService = ApiService();
      final response = await apiService.get('/api/health');
      
      state = state.copyWith(
        isConnected: response.success,
        isChecking: false,
      );
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isChecking: false,
      );
    }
  }

  Future<void> checkConnectivity() => _checkConnectivity();
}