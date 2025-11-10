// TODO: This file needs to be refactored to use ApiService.get() instead of request()
// Temporarily disabled until API methods are migrated

// import 'package:flutter/foundation.dart';
// import '../services/api_service.dart';

/// Analytics Dashboard Service - DISABLED
/// This service needs refactoring to use proper API methods
class AnalyticsDashboardService {
  static final AnalyticsDashboardService _instance = AnalyticsDashboardService._internal();
  factory AnalyticsDashboardService() => _instance;
  AnalyticsDashboardService._internal();

  // All methods temporarily disabled - return null
  Future<Map<String, dynamic>?> getDashboardData({int days = 30, String? userType}) async => null;
  Future<Map<String, dynamic>?> getCraftsmanOverview(int craftsmanId, {int days = 30}) async => null;
  Future<Map<String, dynamic>?> getCustomerOverview(int customerId, {int days = 30}) async => null;
}
