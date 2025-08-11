import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/api_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../widgets/analytics_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/activity_list.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> 
    with AnalyticsMixin {
  String _selectedTimeRange = '30';
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String? _error;

  final List<Map<String, String>> _timeRangeOptions = [
    {'value': '7', 'label': 'Son 7 Gün'},
    {'value': '30', 'label': 'Son 30 Gün'},
    {'value': '90', 'label': 'Son 3 Ay'},
    {'value': '365', 'label': 'Son 1 Yıl'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Track analytics page view
      context.analytics.trackScreenView('analytics');

      // Fetch real analytics data
      final response = await ApiService.getInstance().get(
        '/analytics/dashboard/overview',
        queryParams: {'time_range': _selectedTimeRange},
        requiresAuth: true,
      );

      if (response.success) {
        setState(() {
          _analyticsData = response.data;
          _isLoading = false;
        });
      } else {
        // Fallback to mock data
        setState(() {
          _analyticsData = _generateMockData(user.userType ?? 'customer');
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Analitik veriler yüklenirken bir hata oluştu';
        _analyticsData = _generateMockData(user.userType ?? 'customer');
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _generateMockData(String userType) {
    if (userType == 'craftsman') {
      return {
        'overview': {
          'total_jobs': 45,
          'total_earnings': 12500.0,
          'average_rating': 4.7,
          'response_time': 2.3,
        },
        'trends': {
          'jobs': {'change': '+15%', 'change_type': 'positive'},
          'earnings': {'change': '+22%', 'change_type': 'positive'},
          'rating': {'change': '+0.3', 'change_type': 'positive'},
          'response_time': {'change': '-12%', 'change_type': 'positive'},
        },
        'charts': {
          'jobs_over_time': [
            {'label': 'Pzt', 'value': 8},
            {'label': 'Sal', 'value': 6},
            {'label': 'Çar', 'value': 9},
            {'label': 'Per', 'value': 7},
            {'label': 'Cum', 'value': 5},
            {'label': 'Cmt', 'value': 4},
            {'label': 'Paz', 'value': 6},
          ],
          'job_categories': [
            {'label': 'Elektrik', 'value': 15},
            {'label': 'Tesisat', 'value': 12},
            {'label': 'Boyama', 'value': 8},
            {'label': 'Temizlik', 'value': 6},
            {'label': 'Diğer', 'value': 4},
          ],
        },
        'recent_activity': [
          {
            'type': 'job_completed',
            'message': 'Elektrik tesisatı işi tamamlandı',
            'time': '2 saat önce',
            'amount': '₺450'
          },
          {
            'type': 'review_received',
            'message': 'Yeni 5 yıldızlı değerlendirme aldınız',
            'time': '4 saat önce'
          },
        ]
      };
    } else {
      return {
        'overview': {
          'total_jobs': 12,
          'total_spent': 3200.0,
          'active_jobs': 2,
          'saved_money': 800.0,
        },
        'trends': {
          'jobs': {'change': '+8%', 'change_type': 'positive'},
          'spent': {'change': '+18%', 'change_type': 'neutral'},
          'active_jobs': {'change': '+1', 'change_type': 'positive'},
          'saved_money': {'change': '+25%', 'change_type': 'positive'},
        },
        'charts': {
          'spending_over_time': [
            {'label': 'Ocak', 'value': 800},
            {'label': 'Şubat', 'value': 650},
            {'label': 'Mart', 'value': 900},
            {'label': 'Nisan', 'value': 750},
            {'label': 'Mayıs', 'value': 600},
            {'label': 'Haziran', 'value': 500},
          ],
          'jobs_by_category': [
            {'label': 'Elektrik', 'value': 4},
            {'label': 'Tesisat', 'value': 3},
            {'label': 'Boyama', 'value': 2},
            {'label': 'Temizlik', 'value': 2},
            {'label': 'Diğer', 'value': 1},
          ],
        },
        'recent_activity': [
          {
            'type': 'job_completed',
            'message': 'Klima montajı işi tamamlandı',
            'time': '1 saat önce',
            'amount': '₺350'
          },
        ]
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Lütfen giriş yapın'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Analitikler',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              AnalyticsService.getInstance().trackEvent('time_range_changed', {'range': value});
              setState(() {
                _selectedTimeRange = value;
              });
              _fetchAnalyticsData();
            },
            itemBuilder: (context) => _timeRangeOptions.map((option) {
              return PopupMenuItem<String>(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _timeRangeOptions.firstWhere(
                      (option) => option['value'] == _selectedTimeRange,
                    )['label']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analitik veriler yükleniyor...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchAnalyticsData,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAnalyticsData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Section
                        Text(
                          'Genel Bakış',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildOverviewCards(),
                        
                        const SizedBox(height: 32),
                        
                        // Charts Section
                        Text(
                          'Grafikler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCharts(),
                        
                        const SizedBox(height: 32),
                        
                        // Recent Activity
                        Text(
                          'Son Aktiviteler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ActivityList(
                          activities: _analyticsData?['recent_activity'] ?? [],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Performance Insights
                        _buildPerformanceInsights(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildOverviewCards() {
    final user = ref.watch(authProvider);
    final overview = _analyticsData?['overview'] ?? {};
    final trends = _analyticsData?['trends'] ?? {};

    if (user?.userType == 'craftsman') {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          AnalyticsCard(
            title: 'Toplam İş',
            value: '${overview['total_jobs'] ?? 0}',
            change: trends['jobs']?['change'] ?? '+0%',
            changeType: trends['jobs']?['change_type'] ?? 'neutral',
            icon: Icons.work,
            color: AppColors.primary,
          ),
          AnalyticsCard(
            title: 'Toplam Kazanç',
            value: '₺${(overview['total_earnings'] ?? 0).toStringAsFixed(0)}',
            change: trends['earnings']?['change'] ?? '+0%',
            changeType: trends['earnings']?['change_type'] ?? 'neutral',
            icon: Icons.monetization_on,
            color: AppColors.success,
          ),
          AnalyticsCard(
            title: 'Ortalama Puan',
            value: '${overview['average_rating'] ?? 0}',
            change: trends['rating']?['change'] ?? '+0',
            changeType: trends['rating']?['change_type'] ?? 'neutral',
            icon: Icons.star,
            color: AppColors.warning,
          ),
          AnalyticsCard(
            title: 'Yanıt Süresi',
            value: '${overview['response_time'] ?? 0}h',
            change: trends['response_time']?['change'] ?? '+0%',
            changeType: trends['response_time']?['change_type'] ?? 'neutral',
            icon: Icons.access_time,
            color: AppColors.info,
          ),
        ],
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          AnalyticsCard(
            title: 'Toplam İş',
            value: '${overview['total_jobs'] ?? 0}',
            change: trends['jobs']?['change'] ?? '+0%',
            changeType: trends['jobs']?['change_type'] ?? 'neutral',
            icon: Icons.assignment,
            color: AppColors.primary,
          ),
          AnalyticsCard(
            title: 'Toplam Harcama',
            value: '₺${(overview['total_spent'] ?? 0).toStringAsFixed(0)}',
            change: trends['spent']?['change'] ?? '+0%',
            changeType: trends['spent']?['change_type'] ?? 'neutral',
            icon: Icons.payment,
            color: AppColors.error,
          ),
          AnalyticsCard(
            title: 'Aktif İşler',
            value: '${overview['active_jobs'] ?? 0}',
            change: trends['active_jobs']?['change'] ?? '+0',
            changeType: trends['active_jobs']?['change_type'] ?? 'neutral',
            icon: Icons.pending_actions,
            color: AppColors.warning,
          ),
          AnalyticsCard(
            title: 'Tasarruf',
            value: '₺${(overview['saved_money'] ?? 0).toStringAsFixed(0)}',
            change: trends['saved_money']?['change'] ?? '+0%',
            changeType: trends['saved_money']?['change_type'] ?? 'neutral',
            icon: Icons.savings,
            color: AppColors.success,
          ),
        ],
      );
    }
  }

  Widget _buildCharts() {
    final user = ref.watch(authProvider);
    final charts = _analyticsData?['charts'] ?? {};

    return Column(
      children: [
        if (user?.userType == 'craftsman') ...[
          ChartWidget(
            title: 'Haftalık İş Dağılımı',
            type: ChartType.bar,
            data: List<Map<String, dynamic>>.from(
              charts['jobs_over_time'] ?? [],
            ),
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          ChartWidget(
            title: 'İş Kategorileri',
            type: ChartType.pie,
            data: List<Map<String, dynamic>>.from(
              charts['job_categories'] ?? [],
            ),
          ),
        ] else ...[
          ChartWidget(
            title: 'Aylık Harcama Trendi',
            type: ChartType.line,
            data: List<Map<String, dynamic>>.from(
              charts['spending_over_time'] ?? [],
            ),
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          ChartWidget(
            title: 'İş Kategorileri',
            type: ChartType.pie,
            data: List<Map<String, dynamic>>.from(
              charts['jobs_by_category'] ?? [],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPerformanceInsights() {
    final user = ref.watch(authProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'Performans Önerileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user?.userType == 'craftsman') ...[
            _buildInsightCard(
              'Yanıt Hızı',
              'Daha hızlı yanıt vererek daha fazla iş alabilirsiniz.',
              Icons.flash_on,
              AppColors.info,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              'Portfolyo',
              'Daha fazla iş fotoğrafı ekleyerek güven oluşturun.',
              Icons.photo_library,
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              'Değerlendirmeler',
              'Müşterilerinizden değerlendirme istemeyi unutmayın.',
              Icons.star_rate,
              AppColors.warning,
            ),
          ] else ...[
            _buildInsightCard(
              'Bütçe Takibi',
              'Aylık harcama limitinizi belirleyerek tasarruf edin.',
              Icons.account_balance_wallet,
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              'Karşılaştırma',
              'Birden fazla teklif alarak en uygun fiyatı bulun.',
              Icons.compare,
              AppColors.info,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              'Planlama',
              'İşlerinizi önceden planlayarak daha iyi fiyatlar alın.',
              Icons.schedule,
              AppColors.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}