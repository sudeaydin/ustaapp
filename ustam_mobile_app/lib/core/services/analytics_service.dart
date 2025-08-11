import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'api_service.dart';

/// Analytics service for tracking user behavior and performance
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService getInstance() {
    _instance ??= AnalyticsService._internal();
    return _instance!;
  }

  AnalyticsService._internal();

  bool _isInitialized = false;
  String? _userId;
  String? _sessionId;
  final List<Map<String, dynamic>> _pendingEvents = [];
  Timer? _flushTimer;

  /// Initialize analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Generate session ID
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Get user ID from preferences if available
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id');
      
      // Start periodic flush of events
      _startPeriodicFlush();
      
      // Track app start
      await trackEvent('app_start', {
        'platform': Platform.operatingSystem,
        'version': AppConfig.version,
        'session_id': _sessionId,
      });
      
      _isInitialized = true;
      debugPrint('Analytics service initialized');
    } catch (e) {
      debugPrint('Error initializing analytics: $e');
    }
  }

  /// Set user ID for tracking
  void setUserId(String userId) {
    _userId = userId;
  }

  /// Track a custom event
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties) async {
    if (!_isInitialized) return;
    
    try {
      final event = {
        'event_name': eventName,
        'user_id': _userId,
        'session_id': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': 'mobile',
        'properties': properties,
      };
      
      _pendingEvents.add(event);
      
      // Flush immediately for critical events
      if (_isCriticalEvent(eventName)) {
        await _flushEvents();
      }
    } catch (e) {
      debugPrint('Error tracking event: $e');
    }
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName, {Map<String, dynamic>? properties}) async {
    await trackEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?properties,
    });
  }

  /// Track user interaction
  Future<void> trackInteraction(String action, String element, {Map<String, dynamic>? properties}) async {
    await trackEvent('user_interaction', {
      'action': action,
      'element': element,
      'timestamp': DateTime.now().toIso8601String(),
      ...?properties,
    });
  }

  /// Track business event
  Future<void> trackBusinessEvent(String eventType, Map<String, dynamic> data) async {
    await trackEvent('business_event', {
      'event_type': eventType,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track performance metrics
  Future<void> trackPerformance(String operation, int duration, {Map<String, dynamic>? metadata}) async {
    await trackEvent('performance', {
      'operation': operation,
      'duration_ms': duration,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    });
  }

  /// Track API call performance
  Future<void> trackApiCall(String endpoint, String method, int statusCode, int duration) async {
    await trackEvent('api_call', {
      'endpoint': endpoint,
      'method': method,
      'status_code': statusCode,
      'duration_ms': duration,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track error
  Future<void> trackError(String error, String? stackTrace, {Map<String, dynamic>? context}) async {
    await trackEvent('error', {
      'error': error,
      'stack_trace': stackTrace,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track conversion funnel step
  Future<void> trackFunnelStep(String funnelName, String step, {Map<String, dynamic>? properties}) async {
    await trackEvent('funnel_step', {
      'funnel_name': funnelName,
      'step': step,
      'timestamp': DateTime.now().toIso8601String(),
      ...?properties,
    });
  }

  /// Start periodic flush of events
  void _startPeriodicFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _flushEvents();
    });
  }

  /// Flush pending events to backend
  Future<void> _flushEvents() async {
    if (_pendingEvents.isEmpty) return;
    
    try {
      final eventsToSend = List<Map<String, dynamic>>.from(_pendingEvents);
      _pendingEvents.clear();
      
      final response = await ApiService.getInstance().post('/analytics/track', {
        'events': eventsToSend,
      });
      
      if (!response.success) {
        // Re-add events if sending failed
        _pendingEvents.addAll(eventsToSend);
      }
    } catch (e) {
      debugPrint('Error flushing analytics events: $e');
      // Re-add events if sending failed
      _pendingEvents.addAll(_pendingEvents);
    }
  }

  /// Check if event is critical and should be sent immediately
  bool _isCriticalEvent(String eventName) {
    return [
      'app_crash',
      'payment_completed',
      'quote_accepted',
      'user_registered',
      'user_login',
    ].contains(eventName);
  }

  /// Dispose analytics service
  void dispose() {
    _flushTimer?.cancel();
    _flushEvents();
  }
}

/// Navigator observer to track screen changes
class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRouteChange(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRouteChange(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRouteChange(newRoute);
    }
  }

  void _trackRouteChange(Route<dynamic> route) {
    final routeName = route.settings.name ?? 'unknown';
    AnalyticsService.getInstance().trackScreenView(routeName);
  }
}

/// Mixin for widgets to easily track analytics
mixin AnalyticsMixin<T extends StatefulWidget> on State<T> {
  late final AnalyticsService _analytics;
  late final Stopwatch _screenTimer;

  @override
  void initState() {
    super.initState();
    _analytics = AnalyticsService.getInstance();
    _screenTimer = Stopwatch()..start();
    
    // Track screen enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analytics.trackScreenView(widget.runtimeType.toString());
    });
  }

  @override
  void dispose() {
    // Track screen duration
    _screenTimer.stop();
    _analytics.trackPerformance(
      'screen_duration',
      _screenTimer.elapsedMilliseconds.toDouble(),
    );
    super.dispose();
  }

  /// Track button tap
  void trackButtonTap(String buttonName, {Map<String, dynamic>? properties}) {
    _analytics.trackInteraction('tap', buttonName, properties: properties);
  }

  /// Track form submission
  void trackFormSubmit(String formName, {Map<String, dynamic>? properties}) {
    _analytics.trackInteraction('form_submit', formName, properties: properties);
  }

  /// Track search
  void trackSearch(String query, {Map<String, dynamic>? properties}) {
    _analytics.trackBusinessEvent('search', {
      'query': query,
      ...?properties,
    });
  }
  
  /// Track error (compatible signature)
  void trackError(String errorName, String errorMessage, [Map<String, dynamic>? properties]) {
    _analytics.trackBusinessEvent('error', {
      'error_name': errorName,
      'error_message': errorMessage,
      ...?properties,
    });
  }
  
  /// Track screen view (compatible signature)
  void trackScreenView(String screenName, [Map<String, dynamic>? properties]) {
    _analytics.trackBusinessEvent('screen_view', {
      'screen_name': screenName,
      ...?properties,
    });
  }
  
  /// Track performance (compatible signature)
  void trackPerformance(String metricName, double value) {
    _analytics.trackBusinessEvent('performance', {
      'metric_name': metricName,
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// Extension for easy analytics tracking on any widget
extension AnalyticsExtension on BuildContext {
  AnalyticsService get analytics => AnalyticsService.getInstance();
}