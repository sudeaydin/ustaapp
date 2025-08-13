import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/analytics_dashboard_utils.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/cost_calculator_widget.dart';
import '../widgets/performance_chart_widget.dart';
import '../widgets/trend_chart_widget.dart';
import '../../../core/theme/design_tokens.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AnalyticsDashboardService _analyticsService = AnalyticsDashboardService();
  final AnalyticsDashboardManager _manager = AnalyticsDashboardManager();
  
  Map<String, dynamic>? _dashboardData;
  RealtimeMetrics? _realtimeMetrics;
  Map<String, dynamic>? _constants;
  
  bool _isLoading = true;
  String? _error;
  int _selectedPeriod = 30;
  
  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    final tabCount = user?.userType == 'admin' ? 5 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadData();
    }
  }

  Future<void> _initialize() async {
    await _manager.initialize();
    _constants = _manager.constants;
    _loadData();
    _setupRealtimeUpdates();
  }

  void _setupRealtimeUpdates() {
    // Update realtime metrics every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadRealtimeMetrics();
        _setupRealtimeUpdates();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _manager.refreshDashboard(days: _selectedPeriod);
      _dashboardData = _manager.dashboardData;
      await _loadRealtimeMetrics();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRealtimeMetrics() async {
    try {
      await _manager.refreshRealtimeMetrics();
      if (mounted) {
        setState(() {
          _realtimeMetrics = _manager.realtimeMetrics;
        });
      }
    } catch (e) {
      debugPrint('Error loading realtime metrics: $e');
    }
  }

  Widget _buildOverviewTab() {
    if (_dashboardData == null) {
      return const Center(child: Text('Veri yüklenemedi'));
    }

    final user = ref.watch(authProvider);
    final overview = _dashboardData!['overview'];
    final trends = _dashboardData!['trends'] ?? _dashboardData!['spending_trends'];
    final categories = _dashboardData!['top_categories'] ?? _dashboardData!['preferred_categories'];
    final recentActivity = _dashboardData!['recent_activity'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Realtime Metrics
          if (_realtimeMetrics != null) ...[
            const Text(
              'Anlık Metrikler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: _realtimeMetrics!.metrics.entries.map((entry) {
                return _buildMetricCard(
                  entry.key.replaceAll('_', ' ').toUpperCase(),
                  entry.value.toString(),
                  AnalyticsDashboardConstants.getMetricIcon(entry.key),
                  AnalyticsDashboardConstants.chartColors['primary']!,
                );
              }).toList(),
            ),
            const SizedBox(height: DesignTokens.space24),
          ],

          // Overview Metrics
          if (overview != null) ...[
            const Text(
              'Genel Bakış',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                if (user?.userType == 'craftsman') ...[
                  _buildMetricCard(
                    'Toplam Teklifler',
                    overview['total_quotes'].toString(),
                    Icons.description,
                    AnalyticsDashboardConstants.chartColors['primary']!,
                  ),
                  _buildMetricCard(
                    'Kabul Oranı',
                    _manager.formatPercentage(overview['acceptance_rate']),
                    Icons.check_circle,
                    AnalyticsDashboardConstants.getKpiColor('acceptance_rate', overview['acceptance_rate']),
                  ),
                  _buildMetricCard(
                    'Toplam Gelir',
                    _manager.formatCurrency(overview['total_revenue']),
                    Icons.attach_money,
                    AnalyticsDashboardConstants.chartColors['success']!,
                  ),
                  _buildMetricCard(
                    'Ortalama Puan',
                    overview['avg_rating'].toStringAsFixed(1),
                    Icons.star,
                    AnalyticsDashboardConstants.getKpiColor('satisfaction', overview['avg_rating']),
                  ),
                ] else ...[
                  _buildMetricCard(
                    'Toplam Talepler',
                    overview['total_requests'].toString(),
                    Icons.description,
                    AnalyticsDashboardConstants.chartColors['primary']!,
                  ),
                  _buildMetricCard(
                    'Tamamlanan İşler',
                    overview['completed_jobs'].toString(),
                    Icons.task_alt,
                    AnalyticsDashboardConstants.chartColors['success']!,
                  ),
                  _buildMetricCard(
                    'Toplam Harcama',
                    _manager.formatCurrency(overview['total_spent'] ?? 0),
                    Icons.attach_money,
                    AnalyticsDashboardConstants.chartColors['warning']!,
                  ),
                  _buildMetricCard(
                    'Ortalama İş Değeri',
                    _manager.formatCurrency(overview['avg_job_value'] ?? 0),
                    Icons.analytics,
                    AnalyticsDashboardConstants.chartColors['info']!,
                  ),
                ],
              ],
            ),
            const SizedBox(height: DesignTokens.space24),
          ],

          // Performance Trends
          if (trends != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.userType == 'craftsman' ? 'Performans Trendi' : 'Harcama Trendi',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    SizedBox(
                      height: 200,
                      child: PerformanceChartWidget(
                        body: PerformanceTrends.fromJson(trends),
                        userType: user?.userType ?? 'customer',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
          ],

          // Top Categories
          if (categories != null && categories.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.userType == 'craftsman' ? 'En İyi Kategoriler' : 'Tercih Edilen Kategoriler',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    ...categories.take(5).map<Widget>((category) {
                      final categoryData = CategoryPerformance.fromJson(category);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AnalyticsDashboardConstants.chartColors['primary'],
                                borderRadius: BorderRadius.circular(DesignTokens.radius8),
                              ),
                              child: Center(
                                child: Text(
                                  '${categories.indexOf(category) + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _manager.getCategoryDisplayName(categoryData.category),
                                    style: const TextStyle(fontWeight: FontWeight.medium),
                                  ),
                                  Text(
                                    user?.userType == 'craftsman'
                                        ? '${categoryData.totalQuotes} teklif, ${_manager.formatPercentage(categoryData.acceptanceRate)} kabul'
                                        : '${categoryData.totalRequests ?? 0} talep, ${_manager.formatCurrency(categoryData.totalSpent ?? 0)} harcama',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _manager.formatCurrency(categoryData.revenue),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: DesignTokens.primaryCoral,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
          ],

          // Recent Activity (for craftsmen)
          if (user?.userType == 'craftsman' && recentActivity != null && recentActivity.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Son Aktiviteler',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    ...recentActivity.take(5).map<Widget>((activity) {
                      final activityData = RecentActivity.fromJson(activity);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              activityData.typeIcon,
                              color: activityData.statusColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activityData.title,
                                    style: const TextStyle(fontWeight: FontWeight.medium),
                                  ),
                                  Text(
                                    activityData.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    activityData.customerName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: activityData.statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(DesignTokens.radius12),
                                  ),
                                  child: Text(
                                    _manager.getStatusText(activityData.status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.medium,
                                      color: activityData.statusColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(activityData.date),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    if (_dashboardData == null) {
      return const Center(child: Text('Trend verileri yüklenemedi'));
    }

    final user = ref.watch(authProvider);
    final trends = _dashboardData!['trends'] ?? _dashboardData!['spending_trends'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        children: [
          if (trends != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.userType == 'craftsman' ? 'Performans Trendi' : 'Harcama Trendi',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    SizedBox(
                      height: 250,
                      child: TrendChartWidget(
                        body: PerformanceTrends.fromJson(trends),
                        userType: user?.userType ?? 'customer',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Maliyet Hesaplayıcı',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DesignTokens.space16),
              CostCalculatorWidget(constants: _constants),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessTab() {
    final user = ref.watch(authProvider);
    if (user?.userType != 'admin' || _dashboardData == null) {
      return const Center(child: Text('Bu sekme sadece yöneticiler için kullanılabilir'));
    }

    final conversionFunnel = _dashboardData!['conversion_funnel'];
    final revenueAnalytics = _dashboardData!['revenue_analytics'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        children: [
          // Conversion Funnel
          if (conversionFunnel != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dönüşüm Hunisi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    ...conversionFunnel['stages'].entries.map<Widget>((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key.toString().replaceAll('_', ' ').toUpperCase()),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
          ],

          // Revenue Analytics
          if (revenueAnalytics != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gelir Analizi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.space16),
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryCoral.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radius8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money, color: DesignTokens.primaryCoral, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _manager.formatCurrency(revenueAnalytics['total_revenue']),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: DesignTokens.primaryCoral,
                                ),
                              ),
                              Text(
                                'Toplam Gelir ($_selectedPeriod gün)',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlatformTab() {
    final user = ref.watch(authProvider);
    if (user?.userType != 'admin' || _dashboardData == null) {
      return const Center(child: Text('Bu sekme sadece yöneticiler için kullanılabilir'));
    }

    final platformTrends = _dashboardData!['platform_trends'];
    final categoryTrends = _dashboardData!['category_trends'];
    final geographicTrends = _dashboardData!['geographic_trends'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        children: [
          // Platform Overview
          if (platformTrends != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Platform Genel Bakış',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _buildMetricCard(
                          'Yeni Müşteriler',
                          platformTrends['new_customers'].toString(),
                          Icons.person_add,
                          AnalyticsDashboardConstants.chartColors['primary']!,
                        ),
                        _buildMetricCard(
                          'Yeni Ustalar',
                          platformTrends['new_craftsmen'].toString(),
                          Icons.build,
                          AnalyticsDashboardConstants.chartColors['secondary']!,
                        ),
                        _buildMetricCard(
                          'Platform Geliri',
                          _manager.formatCurrency(platformTrends['platform_revenue']),
                          Icons.attach_money,
                          AnalyticsDashboardConstants.chartColors['success']!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
          ],

          // Geographic Trends
          if (geographicTrends != null && geographicTrends.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coğrafi Dağılım',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    ...geographicTrends.take(10).map<Widget>((city) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    city['city'],
                                    style: const TextStyle(fontWeight: FontWeight.medium),
                                  ),
                                  Text(
                                    '${city['quote_count']} teklif',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _manager.formatCurrency(city['revenue']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: DesignTokens.primaryCoral,
                                  ),
                                ),
                                Text(
                                  'Ort: ${_manager.formatCurrency(city['avg_price'])}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}s önce';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final tabs = [
      const Tab(icon: Icon(Icons.dashboard), text: 'Genel'),
      const Tab(icon: Icon(Icons.trending_up), text: 'Trendler'),
      const Tab(icon: Icon(Icons.calculate), text: 'Hesaplayıcı'),
      if (user?.userType == 'admin') ...[
        const Tab(icon: Icon(Icons.business), text: 'İş'),
        const Tab(icon: Icon(Icons.public), text: 'Platform'),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik Dashboard'),
        actions: [
          // Period Selector
          PopupMenuButton<int>(
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              _loadData();
            },
            itemBuilder: (context) => AnalyticsDashboardConstants.defaultPeriods
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text('Son $period gün'),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Son $_selectedPeriod gün',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          // Refresh Button
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true,
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingSpinner())
          : _error != null
              ? Center(child: ErrorMessage(message: _error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTrendsTab(),
                    _buildCostCalculatorTab(),
                    if (user?.userType == 'admin') ...[
                      _buildBusinessTab(),
                      _buildPlatformTab(),
                    ],
                  ],
                ),
    );
  }
}