/// Secure storage utility for sensitive data
/// 
/// This replaces SharedPreferences for storing sensitive information
/// like tokens, user credentials, etc.
/// 
/// Usage:
/// ```dart
/// final storage = SecureStorage();
/// await storage.write('jwt_token', token);
/// final token = await storage.read('jwt_token');
/// ```
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize secure storage
  /// Call this before using any storage methods
  Future<void> init() async {
    if (_initialized) return;

    // TODO: Install flutter_secure_storage package
    // Add to pubspec.yaml:
    // dependencies:
    //   flutter_secure_storage: ^9.0.0
    
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Write sensitive data securely
  Future<void> writeSecure(String key, String value) async {
    await _ensureInitialized();
    await _secureStorage.write(key: key, value: value);
  }

  /// Read sensitive data
  Future<String?> readSecure(String key) async {
    await _ensureInitialized();
    return await _secureStorage.read(key: key);
  }

  /// Delete sensitive data
  Future<void> deleteSecure(String key) async {
    await _ensureInitialized();
    await _secureStorage.delete(key: key);
  }

  /// Delete all secure data
  Future<void> deleteAllSecure() async {
    await _ensureInitialized();
    await _secureStorage.deleteAll();
  }

  /// Write non-sensitive data (uses SharedPreferences)
  Future<void> write(String key, String value) async {
    await _ensureInitialized();
    await _prefs.setString(key, value);
  }

  /// Read non-sensitive data
  String? read(String key) {
    return _prefs.getString(key);
  }

  /// Delete non-sensitive data
  Future<void> delete(String key) async {
    await _ensureInitialized();
    await _prefs.remove(key);
  }

  /// Clear all non-sensitive data
  Future<void> clear() async {
    await _ensureInitialized();
    await _prefs.clear();
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  // Secure keys (should be stored in secure storage)
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyPassword = 'password'; // Only if remember me is checked
  
  // Non-secure keys (can be stored in SharedPreferences)
  static const String keyUserType = 'user_type';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
}

/// Helper methods for common operations
extension SecureStorageHelpers on SecureStorage {
  /// Save authentication token securely
  Future<void> saveAuthToken(String token) async {
    await writeSecure(SecureStorage.keyAuthToken, token);
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    return await readSecure(SecureStorage.keyAuthToken);
  }

  /// Clear authentication data
  Future<void> clearAuth() async {
    await deleteSecure(SecureStorage.keyAuthToken);
    await deleteSecure(SecureStorage.keyRefreshToken);
    await deleteSecure(SecureStorage.keyUserId);
    await delete(SecureStorage.keyUserType);
    await delete(SecureStorage.keyUserEmail);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
