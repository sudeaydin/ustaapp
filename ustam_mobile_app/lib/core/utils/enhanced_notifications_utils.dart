import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import '../services/api_service.dart';

/// Notification types
enum NotificationType {
  quoteUpdate,
  jobUpdate,
  message,
  reminder,
  emergency,
  system
}

/// Notification priorities
enum NotificationPriority {
  low,
  normal,
  high,
  urgent
}

/// Delivery channels
enum DeliveryChannel {
  push,
  email,
  sms,
  inApp
}

/// Device token model
class DeviceToken {
  final String token;
  final String deviceType;
  final Map<String, dynamic> deviceInfo;
  final DateTime createdAt;

  DeviceToken({
    required this.token,
    required this.deviceType,
    required this.deviceInfo,
    required this.createdAt,
  });

  factory DeviceToken.fromJson(Map<String, dynamic> json) {
    return DeviceToken(
      token: json['token'] ?? '',
      deviceType: json['device_type'] ?? '',
      deviceInfo: Map<String, dynamic>.from(json['device_info'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'device_type': deviceType,
      'device_info': deviceInfo,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Notification preferences model
class NotificationPreferences {
  final Map<String, bool> types;
  final Map<String, bool> channels;
  final Map<String, String> quietHours;
  final bool weekendNotifications;
  final String language;
  final String timezone;

  NotificationPreferences({
    required this.types,
    required this.channels,
    required this.quietHours,
    required this.weekendNotifications,
    required this.language,
    required this.timezone,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      types: Map<String, bool>.from(json['types'] ?? {}),
      channels: Map<String, bool>.from(json['channels'] ?? {}),
      quietHours: Map<String, String>.from(json['quiet_hours'] ?? {}),
      weekendNotifications: json['weekend_notifications'] ?? true,
      language: json['language'] ?? 'tr',
      timezone: json['timezone'] ?? 'Europe/Istanbul',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'types': types,
      'channels': channels,
      'quiet_hours': quietHours,
      'weekend_notifications': weekendNotifications,
      'language': language,
      'timezone': timezone,
    };
  }
}

/// Location share model
class LocationShare {
  final int id;
  final double latitude;
  final double longitude;
  final String purpose;
  final List<int> allowedUsers;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final DateTime? lastUpdate;

  LocationShare({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.purpose,
    required this.allowedUsers,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    this.lastUpdate,
  });

  factory LocationShare.fromJson(Map<String, dynamic> json) {
    return LocationShare(
      id: json['id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      purpose: json['purpose'] ?? '',
      allowedUsers: List<int>.from(json['allowed_users'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isActive: json['is_active'] ?? false,
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  Duration get remainingTime {
    if (isExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }
}

/// Calendar event model
class CalendarEvent {
  final String eventId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final List<String> attendees;

  CalendarEvent({
    required this.eventId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.attendees,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['event_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      location: json['location'],
      attendees: List<String>.from(json['attendees'] ?? []),
    );
  }
}

/// Notification analytics model
class NotificationAnalytics {
  final int totalSent;
  final int delivered;
  final int opened;
  final int clicked;
  final Map<String, dynamic> byChannel;
  final Map<String, dynamic> byType;
  final Map<String, int> byDay;

  NotificationAnalytics({
    required this.totalSent,
    required this.delivered,
    required this.opened,
    required this.clicked,
    required this.byChannel,
    required this.byType,
    required this.byDay,
  });

  factory NotificationAnalytics.fromJson(Map<String, dynamic> json) {
    return NotificationAnalytics(
      totalSent: json['total_sent'] ?? 0,
      delivered: json['delivered'] ?? 0,
      opened: json['opened'] ?? 0,
      clicked: json['clicked'] ?? 0,
      byChannel: Map<String, dynamic>.from(json['by_channel'] ?? {}),
      byType: Map<String, dynamic>.from(json['by_type'] ?? {}),
      byDay: Map<String, int>.from(json['by_day'] ?? {}),
    );
  }

  double get deliveryRate => totalSent > 0 ? (delivered / totalSent) * 100 : 0;
  double get openRate => delivered > 0 ? (opened / delivered) * 100 : 0;
  double get clickRate => opened > 0 ? (clicked / opened) * 100 : 0;
}

/// Enhanced notifications service
class EnhancedNotificationsService {
  static final EnhancedNotificationsService _instance = EnhancedNotificationsService._internal();
  factory EnhancedNotificationsService() => _instance;
  EnhancedNotificationsService._internal();

  final ApiService _apiService = ApiService();

  /// Register device token for push notifications
  Future<bool> registerDeviceToken(String token, {Map<String, dynamic>? deviceInfo}) async {
    try {
      final response = await _apiService.postWithOptions(
        '/api/notifications/enhanced/device-token',
        body: {
          'token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'device_info': deviceInfo ?? await _getDeviceInfo(),
        },
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error registering device token: $e');
      return false;
    }
  }

  /// Get notification preferences
  Future<NotificationPreferences?> getNotificationPreferences() async {
    try {
      final response = await _apiService.request(
        'GET',
        '/api/notifications/enhanced/preferences',
      );
      if (response.isSuccess && response.data != null) {
        return NotificationPreferences.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
    }
    return null;
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences(NotificationPreferences preferences) async {
    try {
      final response = await _apiService.request(
        'PUT',
        '/api/notifications/enhanced/preferences',
        data: preferences.toJson(),
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
      return false;
    }
  }

  /// Create location share
  Future<LocationShare?> createLocationShare({
    required double latitude,
    required double longitude,
    required int durationMinutes,
    required String purpose,
    List<int>? allowedUsers,
  }) async {
    try {
      final response = await _apiService.request(
        'POST',
        '/api/notifications/enhanced/location/share',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'duration_minutes': durationMinutes,
          'purpose': purpose,
          'allowed_users': allowedUsers ?? [],
        },
      );
      if (response.isSuccess && response.data != null) {
        return LocationShare.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error creating location share: $e');
    }
    return null;
  }

  /// Update location
  Future<bool> updateLocation(int shareId, double latitude, double longitude) async {
    try {
      final response = await _apiService.request(
        'PUT',
        '/api/notifications/enhanced/location/share/$shareId/update',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error updating location: $e');
      return false;
    }
  }

  /// Stop location sharing
  Future<bool> stopLocationShare(int shareId) async {
    try {
      final response = await _apiService.request(
        'DELETE',
        '/api/notifications/enhanced/location/share/$shareId/stop',
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error stopping location share: $e');
      return false;
    }
  }

  /// Get active location shares
  Future<List<LocationShare>> getLocationShares() async {
    try {
      final response = await _apiService.request(
        'GET',
        '/api/notifications/enhanced/location/shares',
      );
      if (response.isSuccess && response.data != null) {
        return (response.data as List)
            .map((item) => LocationShare.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting location shares: $e');
    }
    return [];
  }

  /// Create calendar event
  Future<CalendarEvent?> createCalendarEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    List<String>? attendees,
  }) async {
    try {
      final response = await _apiService.request(
        'POST',
        '/api/notifications/enhanced/calendar/event',
        data: {
          'title': title,
          'description': description,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'location': location,
          'attendees': attendees ?? [],
        },
      );
      if (response.isSuccess && response.data != null) {
        return CalendarEvent.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error creating calendar event: $e');
    }
    return null;
  }

  /// Broadcast emergency notification
  Future<bool> broadcastEmergency({
    required String title,
    required String message,
    required double latitude,
    required double longitude,
    double maxDistance = 50.0,
    String severity = 'high',
  }) async {
    try {
      final response = await _apiService.request(
        'POST',
        '/api/notifications/enhanced/emergency/broadcast',
        data: {
          'title': title,
          'message': message,
          'latitude': latitude,
          'longitude': longitude,
          'max_distance': maxDistance,
          'severity': severity,
        },
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error broadcasting emergency: $e');
      return false;
    }
  }

  /// Get notification analytics
  Future<NotificationAnalytics?> getNotificationAnalytics({int days = 30}) async {
    try {
      final response = await _apiService.request(
        'GET',
        '/api/notifications/enhanced/analytics',
        queryParameters: {'days': days.toString()},
      );
      if (response.isSuccess && response.data != null) {
        return NotificationAnalytics.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error getting notification analytics: $e');
    }
    return null;
  }

  /// Track notification interaction
  Future<bool> trackNotificationInteraction(String notificationId, String action) async {
    try {
      final response = await _apiService.request(
        'POST',
        '/api/notifications/enhanced/interaction',
        data: {
          'notification_id': notificationId,
          'action': action,
        },
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error tracking notification interaction: $e');
      return false;
    }
  }

  /// Schedule notification
  Future<bool> scheduleNotification({
    required String title,
    required String message,
    required DateTime scheduledFor,
    NotificationType type = NotificationType.reminder,
    NotificationPriority priority = NotificationPriority.normal,
    List<DeliveryChannel> channels = const [DeliveryChannel.push],
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _apiService.request(
        'POST',
        '/api/notifications/enhanced/schedule',
        data: {
          'title': title,
          'message': message,
          'scheduled_for': scheduledFor.toIso8601String(),
          'type': type.name,
          'priority': priority.name,
          'channels': channels.map((c) => c.name).toList(),
          'data': data,
        },
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return false;
    }
  }

  /// Send test notification
  Future<bool> sendTestNotification({
    String title = 'Test Bildirimi',
    String message = 'Bu bir test bildirimidir',
    List<DeliveryChannel> channels = const [DeliveryChannel.push],
  }) async {
    try {
      final response = await _apiService.request(
        'POST',
        '/api/notifications/enhanced/test',
        data: {
          'title': title,
          'message': message,
          'type': 'info',
          'channels': channels.map((c) => c.name).toList(),
        },
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      return false;
    }
  }

  /// Subscribe to FCM topic
  Future<bool> subscribeToTopic(String topic) async {
    try {
      final response = await _apiService.request(
        'POST',
        '/api/notifications/enhanced/topics/subscribe',
        data: {'topic': topic},
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
      return false;
    }
  }

  /// Unsubscribe from FCM topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      final response = await _apiService.request(
        'POST',
        '/api/notifications/enhanced/topics/unsubscribe',
        data: {'topic': topic},
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
      return false;
    }
  }

  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfo = <String, dynamic>{
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
      };

      // Add additional device info if available
      if (Platform.isAndroid) {
        deviceInfo['manufacturer'] = 'Android Device';
      } else if (Platform.isIOS) {
        deviceInfo['manufacturer'] = 'Apple';
      }

      return deviceInfo;
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {};
    }
  }
}

/// Enhanced notifications manager
class EnhancedNotificationsManager {
  static final EnhancedNotificationsManager _instance = EnhancedNotificationsManager._internal();
  factory EnhancedNotificationsManager() => _instance;
  EnhancedNotificationsManager._internal();

  final EnhancedNotificationsService _service = EnhancedNotificationsService();
  NotificationPreferences? _preferences;
  List<LocationShare> _activeShares = [];

  /// Initialize notifications
  Future<void> initialize() async {
    await _loadPreferences();
    await _loadLocationShares();
  }

  /// Load user preferences
  Future<void> _loadPreferences() async {
    _preferences = await _service.getNotificationPreferences();
  }

  /// Load active location shares
  Future<void> _loadLocationShares() async {
    _activeShares = await _service.getLocationShares();
  }

  /// Check if notification should be sent based on preferences
  bool shouldSendNotification(NotificationType type, {DateTime? scheduledTime}) {
    if (_preferences == null) return true;

    // Check if notification type is enabled
    if (_preferences!.types[type.name] == false) return false;

    // Check quiet hours
    if (scheduledTime != null) {
      final now = scheduledTime;
      final quietStart = _preferences!.quietHours['start'];
      final quietEnd = _preferences!.quietHours['end'];
      
      if (quietStart != null && quietEnd != null) {
        final startHour = int.parse(quietStart.split(':')[0]);
        final endHour = int.parse(quietEnd.split(':')[0]);
        final currentHour = now.hour;
        
        // Handle overnight quiet hours (e.g., 22:00 to 08:00)
        if (startHour > endHour) {
          if (currentHour >= startHour || currentHour < endHour) {
            return false;
          }
        } else if (currentHour >= startHour && currentHour < endHour) {
          return false;
        }
      }

      // Check weekend notifications
      if (!_preferences!.weekendNotifications && (now.weekday == 6 || now.weekday == 7)) {
        return false;
      }
    }

    return true;
  }

  /// Get current preferences
  NotificationPreferences? get preferences => _preferences;

  /// Get active location shares
  List<LocationShare> get activeLocationShares => _activeShares;

  /// Refresh data
  Future<void> refresh() async {
    await _loadPreferences();
    await _loadLocationShares();
  }
}

/// Notification helper functions
class NotificationHelpers {
  /// Get notification type display name
  static String getNotificationTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.quoteUpdate:
        return 'Teklif Güncellemeleri';
      case NotificationType.jobUpdate:
        return 'İş Güncellemeleri';
      case NotificationType.message:
        return 'Mesajlar';
      case NotificationType.reminder:
        return 'Hatırlatmalar';
      case NotificationType.emergency:
        return 'Acil Durumlar';
      case NotificationType.system:
        return 'Sistem Bildirimleri';
    }
  }

  /// Get notification priority color
  static Color getNotificationPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  /// Get notification priority icon
  static IconData getNotificationPriorityIcon(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Icons.info_outline;
      case NotificationPriority.normal:
        return Icons.notifications_outlined;
      case NotificationPriority.high:
        return Icons.priority_high;
      case NotificationPriority.urgent:
        return Icons.warning_outlined;
    }
  }

  /// Get delivery channel icon
  static IconData getDeliveryChannelIcon(DeliveryChannel channel) {
    switch (channel) {
      case DeliveryChannel.push:
        return Icons.phone_android;
      case DeliveryChannel.email:
        return Icons.email_outlined;
      case DeliveryChannel.sms:
        return Icons.sms_outlined;
      case DeliveryChannel.inApp:
        return Icons.app_registration;
    }
  }

  /// Format notification time
  static String formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// Enhanced notifications constants
class EnhancedNotificationsConstants {
  static const Map<String, String> notificationSounds = {
    'default': 'default',
    'gentle': 'gentle_notification.mp3',
    'urgent': 'urgent_notification.mp3',
    'custom': 'custom_notification.mp3',
  };

  static const Map<String, Color> priorityColors = {
    'low': Colors.green,
    'normal': Colors.blue,
    'high': Colors.orange,
    'urgent': Colors.red,
  };

  static const List<String> emergencyCategories = [
    'water_leak',
    'electrical_emergency',
    'gas_leak',
    'security_issue',
    'structural_damage',
    'heating_failure',
    'other',
  ];

  static const Map<String, String> emergencyCategoryNames = {
    'water_leak': 'Su Kaçağı',
    'electrical_emergency': 'Elektrik Arızası',
    'gas_leak': 'Gaz Kaçağı',
    'security_issue': 'Güvenlik Sorunu',
    'structural_damage': 'Yapısal Hasar',
    'heating_failure': 'Isıtma Arızası',
    'other': 'Diğer',
  };

  static const Map<String, int> defaultQuietHours = {
    'start_hour': 22,
    'end_hour': 8,
  };

  static const List<String> supportedLanguages = [
    'tr',
    'en',
  ];

  static const Map<String, String> languageNames = {
    'tr': 'Türkçe',
    'en': 'English',
  };
}