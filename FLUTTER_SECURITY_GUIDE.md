# 📱 Flutter App Security Guide

## Overview
This guide covers security implementations for the Flutter mobile application.

## ✅ Implemented Security Features

### 1. Environment-Based Configuration
**File**: `lib/core/config/app_config.dart`

```dart
// Use environment variables instead of hardcoded URLs
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:5000',
);
```

**Usage**:
```bash
# Development
flutter run

# Production
flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com

# Build for production
flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com
flutter build ios --dart-define=API_BASE_URL=https://api.yourdomain.com
```

### 2. Secure Storage
**File**: `lib/core/utils/secure_storage.dart`

**Installation**:
```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

**Usage**:
```dart
final storage = SecureStorage();
await storage.init();

// Save auth token securely
await storage.saveAuthToken(token);

// Get auth token
final token = await storage.getAuthToken();

// Clear auth data on logout
await storage.clearAuth();
```

## 🔒 TODO: Additional Security Features

### 3. SSL Certificate Pinning
Prevents man-in-the-middle attacks by validating server certificates.

**Installation**:
```yaml
dependencies:
  http_certificate_pinning: ^2.0.0
```

**Implementation**:
```dart
// lib/core/services/http_client.dart
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class SecureHttpClient {
  static Future<http.Response> get(String url) async {
    return await HttpCertificatePinning.get(
      url,
      headers: {...},
      pins: {
        'api.yourdomain.com': [
          'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        ],
      },
    );
  }
}
```

### 4. Code Obfuscation
Protect source code from reverse engineering.

**Build Commands**:
```bash
# Android
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols

# iOS
flutter build ios --obfuscate --split-debug-info=build/ios/outputs/symbols
```

**ProGuard Rules** (`android/app/proguard-rules.pro`):
```proguard
# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }

# Keep your model classes
-keep class com.yourapp.models.** { *; }

# Keep Gson classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
```

**Update** `android/app/build.gradle`:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 5. Root/Jailbreak Detection
Detect compromised devices.

**Installation**:
```yaml
dependencies:
  flutter_jailbreak_detection: ^1.10.0
```

**Implementation**:
```dart
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class SecurityChecker {
  static Future<bool> isDeviceSecure() async {
    try {
      bool jailbroken = await FlutterJailbreakDetection.jailbroken;
      bool developerMode = await FlutterJailbreakDetection.developerMode;
      
      if (jailbroken || developerMode) {
        // Show warning or block app
        return false;
      }
      
      return true;
    } catch (e) {
      // If detection fails, allow but log
      return true;
    }
  }
}
```

### 6. Biometric Authentication
Add fingerprint/face ID for sensitive operations.

**Installation**:
```yaml
dependencies:
  local_auth: ^2.1.7
```

**Implementation**:
```dart
import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool canAuthenticate = 
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      
      if (!canAuthenticate) {
        return false;
      }

      return await auth.authenticate(
        localizedReason: 'Lütfen kimliğinizi doğrulayın',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

### 7. Network Security Configuration
Configure secure network settings.

**Android** (`android/app/src/main/res/xml/network_security_config.xml`):
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Production -->
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.yourdomain.com</domain>
        <pin-set>
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
            <!-- Backup pin -->
            <pin digest="SHA-256">BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=</pin>
        </pin-set>
    </domain-config>
    
    <!-- Development only -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```

**Update** `AndroidManifest.xml`:
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
</application>
```

### 8. API Key Security
Store API keys securely using environment variables.

**Create** `lib/core/config/secrets.dart`:
```dart
class Secrets {
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  
  static const String analyticsKey = String.fromEnvironment(
    'ANALYTICS_KEY',
    defaultValue: '',
  );
}
```

**Build with keys**:
```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=GOOGLE_MAPS_API_KEY=your_key_here \
  --dart-define=ANALYTICS_KEY=your_key_here
```

### 9. Screenshot Prevention (for sensitive screens)
**Android** (`MainActivity.kt`):
```kotlin
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onResume() {
        super.onResume()
        // Prevent screenshots for sensitive screens
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
```

**iOS** (`AppDelegate.swift`):
```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Prevent screenshots
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScreenCapture),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @objc func handleScreenCapture() {
    // Log or alert when screenshot is taken
  }
}
```

### 10. Input Validation
Always validate user input.

```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }
    
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Geçerli bir telefon numarası girin';
    }
    
    return null;
  }
}
```

## 📋 Security Checklist

### Before Production Release

- [ ] Install flutter_secure_storage package
- [ ] Implement SecureStorage for tokens
- [ ] Add SSL certificate pinning
- [ ] Enable code obfuscation
- [ ] Add ProGuard rules (Android)
- [ ] Configure network security (Android)
- [ ] Add root/jailbreak detection
- [ ] Implement biometric authentication
- [ ] Use environment variables for all secrets
- [ ] Remove all hardcoded API keys
- [ ] Add screenshot prevention for sensitive screens
- [ ] Implement proper input validation
- [ ] Test on rooted/jailbroken devices
- [ ] Test SSL pinning
- [ ] Test with Charles Proxy (should fail)
- [ ] Review all permissions in AndroidManifest.xml
- [ ] Review all permissions in Info.plist
- [ ] Remove all console.log/print statements
- [ ] Test app on various Android/iOS versions
- [ ] Perform penetration testing
- [ ] Review third-party package security

### Build Commands for Production

**Android**:
```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=GOOGLE_MAPS_API_KEY=your_key
```

**iOS**:
```bash
flutter build ipa \
  --release \
  --obfuscate \
  --split-debug-info=build/ios/outputs/symbols \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=GOOGLE_MAPS_API_KEY=your_key
```

## 🔐 Security Best Practices

1. **Never commit sensitive data** to git
2. **Always use HTTPS** in production
3. **Validate all user input** before sending to API
4. **Use secure storage** for tokens and passwords
5. **Implement SSL pinning** to prevent MITM attacks
6. **Obfuscate code** to prevent reverse engineering
7. **Detect rooted/jailbroken devices**
8. **Use biometric authentication** for sensitive operations
9. **Implement proper session management**
10. **Keep dependencies updated**

## 📞 Security Contacts

- **Security Team**: security@yourdomain.com
- **Emergency**: +90 xxx xxx xxxx

---

**Last Updated**: 2025-01-13  
**Version**: 1.0.0
