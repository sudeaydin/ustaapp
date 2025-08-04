# 🌐 ustam - CROSS-PLATFORM API GUIDE

Bu rehber, ustam uygulamasının Web, React Native, Flutter ve BigQuery entegrasyonu için API kullanımını açıklar.

## 📱 Platform Desteği

### ✅ Desteklenen Platformlar
- **Web**: React.js (Vite)
- **Mobile**: React Native (Expo)
- **Flutter**: iOS & Android
- **Analytics**: BigQuery Integration

### 🔗 API Endpoints

#### **Web API** - `/api/`
- Standart web uygulaması için
- Session tabanlı authentication
- CORS desteği

#### **Mobile API** - `/api/mobile/`
- React Native ve Flutter için optimize edilmiş
- JWT token (30 gün geçerlilik)
- Offline sync desteği
- Push notification entegrasyonu
- Location-based services

#### **Production API** - `/api/v2/`
- Production ortamı için optimize edilmiş
- Enhanced security
- Rate limiting
- Advanced analytics

## 🔐 Authentication

### Web Authentication
```javascript
// Web Login
const response = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});
```

### Mobile Authentication
```javascript
// Mobile Login
const response = await fetch('/api/mobile/auth/mobile-login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123',
    device_info: {
      platform: 'ios', // or 'android'
      app_version: '1.0.0',
      device_model: 'iPhone 14'
    }
  })
});

// Response
{
  "success": true,
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": { /* user data */ },
    "mobile_settings": { /* mobile-specific settings */ },
    "server_time": "2024-01-01T12:00:00Z",
    "api_version": "2.0"
  }
}
```

### Social Login (Mobile)
```javascript
// Google/Facebook/Apple Login
const response = await fetch('/api/mobile/auth/social-login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    provider: 'google', // google, facebook, apple
    social_id: 'google_user_id',
    email: 'user@gmail.com',
    name: 'John Doe'
  })
});
```

## 📊 Data Synchronization

### Full Sync (App Initialization)
```javascript
const response = await fetch('/api/mobile/sync/full', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

// Response includes:
{
  "success": true,
  "data": {
    "user": { /* user profile */ },
    "categories": [ /* service categories */ ],
    "recent_jobs": [ /* user's recent jobs */ ],
    "unread_messages": 5,
    "notifications": [ /* recent notifications */ ],
    "sync_timestamp": "2024-01-01T12:00:00Z"
  }
}
```

### Incremental Sync
```javascript
const response = await fetch('/api/mobile/sync/incremental', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    last_sync: '2024-01-01T10:00:00Z'
  })
});

// Returns only data updated since last_sync
```

## 📍 Location Services

### Nearby Craftsmen Search
```javascript
const response = await fetch('/api/mobile/location/nearby-craftsmen', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    latitude: 41.0082,
    longitude: 28.9784,
    radius: 10, // km
    category_id: 1 // optional
  })
});

// Response
{
  "success": true,
  "data": {
    "craftsmen": [
      {
        "id": 1,
        "business_name": "Ahmet Elektrik",
        "distance": 2.5, // km
        "average_rating": 4.8,
        "user": { /* user details */ }
      }
    ],
    "total_count": 15,
    "search_location": {
      "latitude": 41.0082,
      "longitude": 28.9784,
      "radius": 10
    }
  }
}
```

## 🔔 Push Notifications

### Register Device
```javascript
const response = await fetch('/api/mobile/notifications/register-device', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    device_token: 'fcm_device_token_here',
    platform: 'ios', // or 'android'
    app_version: '1.0.0'
  })
});
```

## 📁 File Upload

### Mobile Image Upload
```javascript
const formData = new FormData();
formData.append('image', imageFile);
formData.append('type', 'profile'); // profile, job, portfolio

const response = await fetch('/api/mobile/upload/mobile-image', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

// Response
{
  "success": true,
  "data": {
    "file_url": "/uploads/mobile/user_123_profile_abc123.jpg",
    "filename": "user_123_profile_abc123.jpg",
    "upload_type": "profile",
    "uploaded_at": "2024-01-01T12:00:00Z"
  }
}
```

## ⚙️ Mobile Settings

### Get Mobile Settings
```javascript
const response = await fetch('/api/mobile/settings/mobile', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

// Response
{
  "success": true,
  "data": {
    "push_notifications": {
      "enabled": true,
      "job_updates": true,
      "messages": true,
      "marketing": false
    },
    "location_services": {
      "enabled": true,
      "background_location": false
    },
    "app_preferences": {
      "theme": "system",
      "language": "tr",
      "currency": "TRY",
      "distance_unit": "km"
    }
  }
}
```

## 🎯 Flutter Integration

### Flutter HTTP Client Setup
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ustamApiClient {
  static const String baseUrl = 'https://api.ustam.com';
  static const String mobileApiUrl = '$baseUrl/api/mobile';
  
  String? _token;
  
  // Set authentication token
  void setToken(String token) {
    _token = token;
  }
  
  // Get headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
  
  // Mobile login
  Future<Map<String, dynamic>> mobileLogin({
    required String email,
    required String password,
    Map<String, dynamic>? deviceInfo,
  }) async {
    final response = await http.post(
      Uri.parse('$mobileApiUrl/auth/mobile-login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_info': deviceInfo ?? {
          'platform': 'flutter',
          'app_version': '1.0.0',
        },
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Get nearby craftsmen
  Future<Map<String, dynamic>> getNearbyRaftsmen({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int? categoryId,
  }) async {
    final response = await http.post(
      Uri.parse('$mobileApiUrl/location/nearby-craftsmen'),
      headers: _headers,
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        if (categoryId != null) 'category_id': categoryId,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Full data sync
  Future<Map<String, dynamic>> fullSync() async {
    final response = await http.get(
      Uri.parse('$mobileApiUrl/sync/full'),
      headers: _headers,
    );
    
    return jsonDecode(response.body);
  }
}
```

### Flutter Usage Example
```dart
class _HomePageState extends State<HomePage> {
  final ustamApiClient _apiClient = ustamApiClient();
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Login
    final loginResult = await _apiClient.mobileLogin(
      email: 'user@example.com',
      password: 'password123',
    );
    
    if (loginResult['success']) {
      _apiClient.setToken(loginResult['data']['access_token']);
      
      // Full sync
      final syncResult = await _apiClient.fullSync();
      if (syncResult['success']) {
        // Update UI with synced data
        setState(() {
          // Update your app state
        });
      }
    }
  }
}
```

## 📊 BigQuery Analytics Integration

### Data Export
```bash
# Export data to BigQuery
cd backend
python3 bigquery_integration.py
```

### BigQuery Setup
```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Authenticate
gcloud auth login

# Create BigQuery dataset
bq mk --dataset --location=US ustam_analytics

# Load users data
bq load --source_format=NEWLINE_DELIMITED_JSON \
  ustam_analytics.users \
  bigquery_exports/users_*.json \
  bigquery_exports/schemas/users_schema.json

# Load jobs data
bq load --source_format=NEWLINE_DELIMITED_JSON \
  ustam_analytics.jobs \
  bigquery_exports/jobs_*.json \
  bigquery_exports/schemas/jobs_schema.json
```

### BigQuery Analytics Queries

#### User Activity Analysis
```sql
SELECT 
  user_type,
  city,
  activity_status,
  COUNT(*) as user_count,
  AVG(total_jobs) as avg_jobs_per_user
FROM `ustam_analytics.user_activity`
GROUP BY user_type, city, activity_status
ORDER BY user_count DESC;
```

#### Revenue Analytics
```sql
SELECT 
  year,
  month,
  SUM(total_revenue) as monthly_revenue,
  SUM(platform_revenue) as platform_revenue,
  COUNT(transaction_count) as total_transactions
FROM `ustam_analytics.revenue_analytics`
GROUP BY year, month
ORDER BY year DESC, month DESC;
```

#### Job Success Rate by Category
```sql
SELECT 
  category_name,
  job_outcome,
  COUNT(*) as job_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY category_name), 2) as percentage
FROM `ustam_analytics.job_analytics`
GROUP BY category_name, job_outcome
ORDER BY category_name, job_count DESC;
```

## 🔧 Database Viewer Tools

### Web-based Database Viewer
```bash
cd backend
python3 database_viewer.py
# Access: http://localhost:5001
```

### SQLite Command Line
```bash
sqlite3 backend/app.db

# Useful commands:
.tables                    # List all tables
.schema users             # Show table schema
SELECT COUNT(*) FROM users; # Count records
.mode column              # Better formatting
.headers on               # Show column headers
```

### BigQuery Web Console
- Access: https://console.cloud.google.com/bigquery
- Dataset: `ustam_analytics`
- Tables: users, jobs, payments, etc.

## 🚀 Performance Optimization

### Mobile App Optimization
- **Offline Support**: Cache critical data locally
- **Image Compression**: Compress images before upload
- **Lazy Loading**: Load data as needed
- **Background Sync**: Sync data in background

### API Optimization
- **Pagination**: Use pagination for large datasets
- **Caching**: Implement Redis caching
- **Rate Limiting**: Prevent API abuse
- **Compression**: Use gzip compression

## 🔒 Security Best Practices

### Mobile Security
- **Token Storage**: Store tokens securely (Keychain/Keystore)
- **Certificate Pinning**: Pin SSL certificates
- **Obfuscation**: Obfuscate sensitive code
- **Root/Jailbreak Detection**: Detect compromised devices

### API Security
- **JWT Validation**: Validate all JWT tokens
- **Input Sanitization**: Sanitize all inputs
- **Rate Limiting**: Implement rate limiting
- **HTTPS Only**: Force HTTPS connections

## 📱 Platform-Specific Features

### React Native
```javascript
// Push notifications
import PushNotification from 'react-native-push-notification';

// Location services
import Geolocation from '@react-native-community/geolocation';

// Camera/Gallery
import ImagePicker from 'react-native-image-picker';
```

### Flutter
```dart
// Push notifications
import 'package:firebase_messaging/firebase_messaging.dart';

// Location services
import 'package:geolocator/geolocator.dart';

// Camera/Gallery
import 'package:image_picker/image_picker.dart';
```

## 🔄 Offline Support

### Data Caching Strategy
```javascript
// React Native with AsyncStorage
import AsyncStorage from '@react-native-async-storage/async-storage';

class OfflineManager {
  static async cacheData(key, data) {
    await AsyncStorage.setItem(key, JSON.stringify(data));
  }
  
  static async getCachedData(key) {
    const data = await AsyncStorage.getItem(key);
    return data ? JSON.parse(data) : null;
  }
  
  static async syncWhenOnline() {
    // Implement sync logic when connection is restored
  }
}
```

## 📊 Analytics Integration

### Track User Events
```javascript
// Mobile analytics
const trackEvent = async (eventName, parameters) => {
  await fetch('/api/mobile/analytics/track', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      event: eventName,
      parameters: parameters,
      timestamp: new Date().toISOString(),
      platform: 'mobile'
    })
  });
};

// Usage
trackEvent('job_created', {
  category_id: 1,
  budget_range: '100-500',
  location: 'Istanbul'
});
```

## 🎯 Next Steps

1. **Mobile App Development**
   - Implement React Native app
   - Develop Flutter app
   - Add platform-specific features

2. **BigQuery Setup**
   - Configure Google Cloud project
   - Set up automated data export
   - Create analytics dashboards

3. **Testing**
   - Unit tests for APIs
   - Integration tests
   - Mobile app testing

4. **Deployment**
   - App Store deployment
   - Google Play deployment
   - API monitoring setup

---

🔨 **ustam Cross-Platform API Guide v2.0**

Bu rehber ile web, mobile ve analytics entegrasyonunuz sorunsuz çalışacaktır!