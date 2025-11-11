import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../theme/design_tokens.dart';

/// Dashboard overview model
class DashboardOverview {
  final int totalQuotes;
  final int acceptedQuotes;
  final int completedJobs;
  final double acceptanceRate;
  final double totalRevenue;
  final double avgQuoteValue;
  final double avgResponseTimeHours;
  final double avgRating;
  final int periodDays;
  
  // Customer-specific fields
  final int? totalRequests;
  final double? totalSpent;
  final double? avgJobValue;
  final double? avgRatingGiven;

  DashboardOverview({
    required this.totalQuotes,
    required this.acceptedQuotes,
    required this.completedJobs,
    required this.acceptanceRate,
    required this.totalRevenue,
    required this.avgQuoteValue,
    required this.avgResponseTimeHours,
    required this.avgRating,
    required this.periodDays,
    this.totalRequests,
    this.totalSpent,
    this.avgJobValue,
    this.avgRatingGiven,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalQuotes: json['total_quotes'] ?? json['total_requests'] ?? 0,
      acceptedQuotes: json['accepted_quotes'] ?? 0,
      completedJobs: json['completed_jobs'] ?? 0,
      acceptanceRate: (json['acceptance_rate'] ?? 0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? json['total_spent'] ?? 0).toDouble(),
      avgQuoteValue: (json['avg_quote_value'] ?? json['avg_job_value'] ?? 0).toDouble(),
      avgResponseTimeHours: (json['avg_response_time_hours'] ?? 0).toDouble(),
      avgRating: (json['avg_rating'] ?? json['avg_rating_given'] ?? 0).toDouble(),
      periodDays: json['period_days'] ?? 30,
      totalRequests: json['total_requests'],
      totalSpent: json['total_spent']?.toDouble(),
      avgJobValue: json['avg_job_value']?.toDouble(),
      avgRatingGiven: json['avg_rating_given']?.toDouble(),
    );
  }
}

/// Performance trends model
class PerformanceTrends {
  final List<String> dates;
  final List<int> quotes;
  final List<int> acceptedQuotes;
  final List<double> dailyRevenue;
  
  // Customer-specific fields
  final List<String>? months;
  final List<double>? spending;
  final List<int>? jobCounts;

  PerformanceTrends({
    required this.dates,
    required this.quotes,
    required this.acceptedQuotes,
    required this.dailyRevenue,
    this.months,
    this.spending,
    this.jobCounts,
  });

  factory PerformanceTrends.fromJson(Map<String, dynamic> json) {
    return PerformanceTrends(
      dates: List<String>.from(json['dates'] ?? json['months'] ?? []),
      quotes: List<int>.from(json['quotes'] ?? json['job_counts'] ?? []),
      acceptedQuotes: List<int>.from(json['accepted_quotes'] ?? []),
      dailyRevenue: List<double>.from((json['daily_revenue'] ?? json['spending'] ?? []).map((x) => x.toDouble())),
      months: json['months'] != null ? List<String>.from(json['months']) : null,
      spending: json['spending'] != null ? List<double>.from(json['spending'].map((x) => x.toDouble())) : null,
      jobCounts: json['job_counts'] != null ? List<int>.from(json['job_counts']) : null,
    );
  }
}

/// Category performance model
class CategoryPerformance {
  final String category;
  final int totalQuotes;
  final int acceptedQuotes;
  final double revenue;
  final double avgPrice;
  final double acceptanceRate;
  
  // Customer-specific fields
  final int? totalRequests;
  final int? acceptedRequests;
  final double? totalSpent;
  final double? avgSpent;

  CategoryPerformance({
    required this.category,
    required this.totalQuotes,
    required this.acceptedQuotes,
    required this.revenue,
    required this.avgPrice,
    required this.acceptanceRate,
    this.totalRequests,
    this.acceptedRequests,
    this.totalSpent,
    this.avgSpent,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      category: json['category'] ?? '',
      totalQuotes: json['total_quotes'] ?? json['total_requests'] ?? 0,
      acceptedQuotes: json['accepted_quotes'] ?? json['accepted_requests'] ?? 0,
      revenue: (json['revenue'] ?? json['total_spent'] ?? 0).toDouble(),
      avgPrice: (json['avg_price'] ?? json['avg_spent'] ?? 0).toDouble(),
      acceptanceRate: (json['acceptance_rate'] ?? 0).toDouble(),
      totalRequests: json['total_requests'],
      acceptedRequests: json['accepted_requests'],
      totalSpent: json['total_spent']?.toDouble(),
      avgSpent: json['avg_spent']?.toDouble(),
    );
  }
}

/// Recent activity model
class RecentActivity {
  final String type;
  final int id;
  final String title;
  final String description;
  final String status;
  final double amount;
  final DateTime date;
  final String customerName;

  RecentActivity({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.amount,
    required this.date,
    required this.customerName,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
      customerName: json['customer_name'] ?? '',
    );
  }

  IconData get typeIcon {
    switch (type) {
      case 'quote':
        return Icons.description;
      case 'job':
        return Icons.work;
      case 'message':
        return Icons.message;
      default:
        return Icons.info;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return DesignTokens.primaryCoral;
      case 'accepted':
        return DesignTokens.primaryCoral;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return DesignTokens.primaryCoral;
      case 'in_progress':
        return DesignTokens.primaryCoral;
      default:
        return Colors.grey;
    }
  }
}

/// Cost calculation model
class CostCalculation {
  final CostBreakdown breakdown;
  final CalculationFactors factors;
  final EstimationQuality estimationQuality;
  final PriceRange priceRange;

  CostCalculation({
    required this.breakdown,
    required this.factors,
    required this.estimationQuality,
    required this.priceRange,
  });

  factory CostCalculation.fromJson(Map<String, dynamic> json) {
    return CostCalculation(
      breakdown: CostBreakdown.fromJson(json['breakdown']),
      factors: CalculationFactors.fromJson(json['factors']),
      estimationQuality: EstimationQuality.fromJson(json['estimation_quality']),
      priceRange: PriceRange.fromJson(json['price_range']),
    );
  }
}

/// Cost breakdown model
class CostBreakdown {
  final double laborCost;
  final double materialsCost;
  final double travelCost;
  final double overheadCost;
  final double subtotal;
  final double taxAmount;
  final double totalCost;

  CostBreakdown({
    required this.laborCost,
    required this.materialsCost,
    required this.travelCost,
    required this.overheadCost,
    required this.subtotal,
    required this.taxAmount,
    required this.totalCost,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      laborCost: (json['labor_cost'] ?? 0).toDouble(),
      materialsCost: (json['materials_cost'] ?? 0).toDouble(),
      travelCost: (json['travel_cost'] ?? 0).toDouble(),
      overheadCost: (json['overhead_cost'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      totalCost: (json['total_cost'] ?? 0).toDouble(),
    );
  }
}

/// Calculation factors model
class CalculationFactors {
  final double baseHourlyRate;
  final double adjustedHourlyRate;
  final double areaFactor;
  final double urgencyMultiplier;
  final double complexityFactor;
  final double experienceFactor;
  final double locationFactor;
  final double materialsMarkup;

  CalculationFactors({
    required this.baseHourlyRate,
    required this.adjustedHourlyRate,
    required this.areaFactor,
    required this.urgencyMultiplier,
    required this.complexityFactor,
    required this.experienceFactor,
    required this.locationFactor,
    required this.materialsMarkup,
  });

  factory CalculationFactors.fromJson(Map<String, dynamic> json) {
    return CalculationFactors(
      baseHourlyRate: (json['base_hourly_rate'] ?? 0).toDouble(),
      adjustedHourlyRate: (json['adjusted_hourly_rate'] ?? 0).toDouble(),
      areaFactor: (json['area_factor'] ?? 1.0).toDouble(),
      urgencyMultiplier: (json['urgency_multiplier'] ?? 1.0).toDouble(),
      complexityFactor: (json['complexity_factor'] ?? 1.0).toDouble(),
      experienceFactor: (json['experience_factor'] ?? 1.0).toDouble(),
      locationFactor: (json['location_factor'] ?? 1.0).toDouble(),
      materialsMarkup: (json['materials_markup'] ?? 1.0).toDouble(),
    );
  }
}

/// Estimation quality model
class EstimationQuality {
  final double confidenceScore;
  final double estimatedHours;
  final int complexityScore;

  EstimationQuality({
    required this.confidenceScore,
    required this.estimatedHours,
    required this.complexityScore,
  });

  factory EstimationQuality.fromJson(Map<String, dynamic> json) {
    return EstimationQuality(
      confidenceScore: (json['confidence_score'] ?? 0).toDouble(),
      estimatedHours: (json['estimated_hours'] ?? 0).toDouble(),
      complexityScore: json['complexity_score'] ?? 0,
    );
  }

  Color get confidenceColor {
    if (confidenceScore >= 90) return DesignTokens.primaryCoral;
    if (confidenceScore >= 75) return DesignTokens.primaryCoral;
    return Colors.red;
  }
}

/// Price range model
class PriceRange {
  final double minPrice;
  final double maxPrice;
  final double mostLikely;

  PriceRange({
    required this.minPrice,
    required this.maxPrice,
    required this.mostLikely,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      minPrice: (json['min_price'] ?? 0).toDouble(),
      maxPrice: (json['max_price'] ?? 0).toDouble(),
      mostLikely: (json['most_likely'] ?? 0).toDouble(),
    );
  }
}

/// Market comparison model
class MarketComparison {
  final String category;
  final String? city;
  final int periodDays;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;
  final double medianPrice;
  final int sampleSize;

  MarketComparison({
    required this.category,
    this.city,
    required this.periodDays,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.medianPrice,
    required this.sampleSize,
  });

  factory MarketComparison.fromJson(Map<String, dynamic> json) {
    return MarketComparison(
      category: json['category'] ?? '',
      city: json['city'],
      periodDays: json['period_days'] ?? 0,
      avgPrice: (json['avg_price'] ?? 0).toDouble(),
      minPrice: (json['min_price'] ?? 0).toDouble(),
      maxPrice: (json['max_price'] ?? 0).toDouble(),
      medianPrice: (json['median_price'] ?? 0).toDouble(),
      sampleSize: json['sample_size'] ?? 0,
    );
  }
}

/// Realtime metrics model
class RealtimeMetrics {
  final Map<String, int> metrics;
  final DateTime timestamp;
  final String userType;

  RealtimeMetrics({
    required this.metrics,
    required this.timestamp,
    required this.userType,
  });

  factory RealtimeMetrics.fromJson(Map<String, dynamic> json) {
    return RealtimeMetrics(
      metrics: Map<String, int>.from(json['metrics'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      userType: json['user_type'] ?? '',
    );
  }
}

/// Analytics dashboard service
class AnalyticsDashboardService {
  static final AnalyticsDashboardService _instance = AnalyticsDashboardService._internal();
  factory AnalyticsDashboardService() => _instance;
  AnalyticsDashboardService._internal();

  final ApiService _apiService = ApiService();

  /// Get dashboard data
  Future<Map<String, dynamic>?> getDashboardData({int days = 30, String? userType}) async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/dashboard',
        params: {
          'days': days.toString(),
          if (userType != null) 'user_type': userType,
        },
      );
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error getting dashboard body: $e');
    }
    return null;
  }

  /// Get craftsman overview
  Future<Map<String, dynamic>?> getCraftsmanOverview(int craftsmanId, {int days = 30}) async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/craftsman/$craftsmanId/overview',
        params: {'days': days.toString()},
      );
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error getting craftsman overview: $e');
    }
    return null;
  }

  /// Get customer history
  Future<Map<String, dynamic>?> getCustomerHistory(int customerId, {int days = 30}) async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/customer/$customerId/history',
        params: {'days': days.toString()},
      );
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error getting customer history: $e');
    }
    return null;
  }

  /// Calculate job cost
  Future<CostCalculation?> calculateJobCost({
    required String category,
    required double estimatedHours,
    double materialsCost = 0,
    String areaType = 'other',
    String urgency = 'normal',
    int complexityScore = 5,
    double locationFactor = 1.0,
    int craftsmanExperience = 1,
  }) async {
    try {
      final response = await _apiService.postWithOptions(
        '/api/analytics-dashboard/cost-calculator',
        body: {
          'category': category,
          'estimated_hours': estimatedHours,
          'materials_cost': materialsCost,
          'area_type': areaType,
          'urgency': urgency,
          'complexity_score': complexityScore,
          'location_factor': locationFactor,
          'craftsman_experience': craftsmanExperience,
        },
      );
      if (response.success && response.data != null) {
        return CostCalculation.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error calculating job cost: $e');
    }
    return null;
  }

  /// Get market comparison
  Future<MarketComparison?> getMarketComparison({
    required String category,
    String? city,
    int days = 90,
  }) async {
    try {
      final response = await _apiService.postWithOptions(
        '/api/analytics-dashboard/cost-calculator/market-comparison',
        body: {
          'category': category,
          if (city != null) 'city': city,
          'days': days,
        },
      );
      if (response.success && response.data != null) {
        return MarketComparison.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error getting market comparison: $e');
    }
    return null;
  }

  /// Get pricing recommendations
  Future<Map<String, dynamic>?> getPricingRecommendations(int craftsmanId, String category) async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/cost-calculator/pricing-recommendations/$craftsmanId',
        params: {'category': category},
      );
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error getting pricing recommendations: $e');
    }
    return null;
  }

  /// Get category trends
  Future<List<CategoryPerformance>> getCategoryTrends({int days = 30}) async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/trends/categories',
        params: {'days': days.toString()},
      );
      if (response.success && response.data != null) {
        return (response.data as List)
            .map((item) => CategoryPerformance.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting category trends: $e');
    }
    return [];
  }

  /// Get recent activity
  Future<List<RecentActivity>> getRecentActivity({int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/activity/recent',
        params: {'limit': limit.toString()},
      );
      if (response.success && response.data != null) {
        return (response.data as List)
            .map((item) => RecentActivity.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting recent activity: $e');
    }
    return [];
  }

  /// Get realtime metrics
  Future<RealtimeMetrics?> getRealtimeMetrics() async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/realtime/metrics',
      );
      if (response.success && response.data != null) {
        return RealtimeMetrics.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error getting realtime metrics: $e');
    }
    return null;
  }

  /// Get analytics constants
  Future<Map<String, dynamic>?> getAnalyticsConstants() async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/constants',
      );
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error getting analytics constants: $e');
    }
    return null;
  }

  /// Generate custom report
  Future<Map<String, dynamic>?> generateCustomReport({
    required DateTime startDate,
    required DateTime endDate,
    List<String> metrics = const [],
    String exportFormat = 'json',
  }) async {
    try {
      final response = await _apiService.postWithOptions(
        '/api/analytics-dashboard/reports/custom',
        body: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'metrics': metrics,
          'export_format': exportFormat,
        },
      );
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error generating custom report: $e');
    }
    return null;
  }

  /// Compare performance
  Future<Map<String, dynamic>?> comparePerformance({
    int days = 30,
    String? category,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/analytics-dashboard/performance/compare',
        params: {
          'days': days.toString(),
          if (category != null) 'category': category,
        },
      );
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error comparing performance: $e');
    }
    return null;
  }
}

/// Analytics dashboard manager
class AnalyticsDashboardManager {
  static final AnalyticsDashboardManager _instance = AnalyticsDashboardManager._internal();
  factory AnalyticsDashboardManager() => _instance;
  AnalyticsDashboardManager._internal();

  final AnalyticsDashboardService _service = AnalyticsDashboardService();
  Map<String, dynamic>? _constants;
  Map<String, dynamic>? _dashboardData;
  RealtimeMetrics? _realtimeMetrics;

  /// Initialize analytics dashboard
  Future<void> initialize() async {
    await _loadConstants();
  }

  /// Load constants
  Future<void> _loadConstants() async {
    _constants = await _service.getAnalyticsConstants();
  }

  /// Get constants
  Map<String, dynamic>? get constants => _constants;

  /// Get dashboard data
  Map<String, dynamic>? get dashboardData => _dashboardData;

  /// Get realtime metrics
  RealtimeMetrics? get realtimeMetrics => _realtimeMetrics;

  /// Refresh dashboard data
  Future<void> refreshDashboard({int days = 30, String? userType}) async {
    _dashboardData = await _service.getDashboardData(days: days, userType: userType);
  }

  /// Refresh realtime metrics
  Future<void> refreshRealtimeMetrics() async {
    _realtimeMetrics = await _service.getRealtimeMetrics();
  }

  /// Format currency
  String formatCurrency(double amount) {
    return '₺${amount.toStringAsFixed(2)}';
  }

  /// Format percentage
  String formatPercentage(double percentage) {
    return '%${percentage.toStringAsFixed(1)}';
  }

  /// Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return DesignTokens.primaryCoral;
      case 'accepted':
        return DesignTokens.primaryCoral;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return DesignTokens.primaryCoral;
      case 'in_progress':
        return DesignTokens.primaryCoral;
      default:
        return Colors.grey;
    }
  }

  /// Get status text
  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Bekliyor';
      case 'accepted':
        return 'Kabul Edildi';
      case 'rejected':
        return 'Reddedildi';
      case 'completed':
        return 'Tamamlandı';
      case 'in_progress':
        return 'Devam Ediyor';
      default:
        return status;
    }
  }

  /// Get category display name
  String getCategoryDisplayName(String category) {
    const categoryNames = {
      'elektrik': 'Elektrik',
      'tesisatçı': 'Tesisatçı',
      'boyacı': 'Boyacı',
      'marangoz': 'Marangoz',
      'tadilat': 'Tadilat',
      'temizlik': 'Temizlik',
      'nakliye': 'Nakliye',
    };
    return categoryNames[category] ?? category;
  }

  /// Get area type display name
  String getAreaTypeDisplayName(String areaType) {
    const areaNames = {
      'kitchen': 'Mutfak',
      'bathroom': 'Banyo',
      'living_room': 'Oturma Odası',
      'bedroom': 'Yatak Odası',
      'balcony': 'Balkon',
      'garden': 'Bahçe',
      'office': 'Ofis',
      'other': 'Diğer',
    };
    return areaNames[areaType] ?? areaType;
  }

  /// Get urgency display name
  String getUrgencyDisplayName(String urgency) {
    const urgencyNames = {
      'low': 'Düşük',
      'normal': 'Normal',
      'high': 'Yüksek',
      'urgent': 'Acil',
      'emergency': 'Acil Durum',
    };
    return urgencyNames[urgency] ?? urgency;
  }
}

/// Analytics dashboard constants
class AnalyticsDashboardConstants {
  static const List<String> categories = [
    'elektrik',
    'tesisatçı',
    'boyacı',
    'marangoz',
    'tadilat',
    'temizlik',
    'nakliye',
  ];

  static const List<String> areaTypes = [
    'kitchen',
    'bathroom',
    'living_room',
    'bedroom',
    'balcony',
    'garden',
    'office',
    'other',
  ];

  static const List<String> urgencyLevels = [
    'low',
    'normal',
    'high',
    'urgent',
    'emergency',
  ];

  static const List<int> defaultPeriods = [7, 14, 30, 60, 90, 180, 365];

  static const Map<String, Color> chartColors = {
    'primary': Color(0xFF3B82F6),
    'secondary': Color(0xFF10B981),
    'accent': Color(0xFFF59E0B),
    'danger': Color(0xFFEF4444),
    'warning': Color(0xFFF97316),
    'info': Color(0xFF06B6D4),
    'success': Color(0xFF22C55E),
    'purple': Color(0xFF8B5CF6),
  };

  static const Map<String, double> kpiThresholds = {
    'acceptance_rate_excellent': 80.0,
    'acceptance_rate_good': 60.0,
    'acceptance_rate_poor': 40.0,
    'response_time_excellent': 2.0,
    'response_time_good': 6.0,
    'response_time_poor': 24.0,
    'satisfaction_excellent': 4.5,
    'satisfaction_good': 4.0,
    'satisfaction_poor': 3.5,
    'completion_rate_excellent': 95.0,
    'completion_rate_good': 85.0,
    'completion_rate_poor': 70.0,
  };

  /// Get KPI color based on value and thresholds
  static Color getKpiColor(String metric, double value) {
    final excellent = kpiThresholds['${metric}_excellent'];
    final good = kpiThresholds['${metric}_good'];
    final poor = kpiThresholds['${metric}_poor'];

    if (excellent != null && good != null && poor != null) {
      if (metric == 'response_time') {
        // Lower is better for response time
        if (value <= excellent) return DesignTokens.primaryCoral;
        if (value <= good) return DesignTokens.primaryCoral;
        return Colors.red;
      } else {
        // Higher is better for other metrics
        if (value >= excellent) return DesignTokens.primaryCoral;
        if (value >= good) return DesignTokens.primaryCoral;
        return Colors.red;
      }
    }

    return Colors.grey;
  }

  /// Get metric icon
  static IconData getMetricIcon(String metric) {
    switch (metric) {
      case 'quotes':
      case 'total_quotes':
      case 'total_requests':
        return Icons.description;
      case 'acceptance_rate':
        return Icons.check_circle;
      case 'revenue':
      case 'total_revenue':
      case 'total_spent':
        return Icons.attach_money;
      case 'rating':
      case 'avg_rating':
        return Icons.star;
      case 'response_time':
        return Icons.schedule;
      case 'completed_jobs':
        return Icons.task_alt;
      default:
        return Icons.analytics;
    }
  }

  /// Format duration
  static String formatDuration(double hours) {
    if (hours < 1) {
      return '${(hours * 60).toInt()} dakika';
    } else if (hours < 24) {
      return '${hours.toStringAsFixed(1)} saat';
    } else {
      return '${(hours / 24).toStringAsFixed(1)} gün';
    }
  }

  /// Format large numbers
  static String formatLargeNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}