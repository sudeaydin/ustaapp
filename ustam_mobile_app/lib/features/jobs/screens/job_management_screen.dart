import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/job_management_utils.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../widgets/job_card.dart';
import '../widgets/job_detail_sheet.dart';
import '../widgets/emergency_service_card.dart';
import '../widgets/warranty_card.dart';
import '../widgets/time_tracker_widget.dart';
import '../../auth/providers/auth_provider.dart';

class JobManagementScreen extends ConsumerStatefulWidget {
  const JobManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobManagementScreen> createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends ConsumerState<JobManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final JobManagementService _jobService = JobManagementService();
  
  List<Job> _jobs = [];
  List<Job> _warranties = [];
  List<EmergencyService> _emergencies = [];
  Map<String, dynamic> _performanceMetrics = {};
  
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    final isCustomer = user?.userType == 'customer';
    
    // Initialize tabs based on user type
    _tabController = TabController(
      length: isCustomer ? 4 : 5, // Add emergency tab for craftsmen
      vsync: this,
    );
    
    _tabController.addListener(_onTabChanged);
    _loadData();
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

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = ref.read(authProvider);
      if (user == null) return;

      final userType = user.userType;
      final currentTab = _tabController.index;

      // Load performance metrics
      final metricsResponse = await _jobService.getPerformanceMetrics(userType ?? 'customer');
      _performanceMetrics = metricsResponse;

      // Load data based on current tab
      switch (currentTab) {
        case 0: // Active jobs
          final activeJobs = await _jobService.getJobs(
            userType: userType,
            status: 'in_progress',
          );
          _jobs = activeJobs;
          break;
          
        case 1: // Completed jobs
          final completedJobs = await _jobService.getJobs(
            userType: userType,
            status: 'completed',
          );
          _jobs = completedJobs;
          break;
          
        case 2: // Warranties
          final warranties = await _jobService.getWarranties(userType ?? 'customer');
          _warranties = warranties;
          break;
          
        case 3: // All jobs
          final allJobs = await _jobService.getJobs(userType: userType);
          _jobs = allJobs;
          break;
          
        case 4: // Emergency (craftsmen only)
          if (userType == 'craftsman') {
            final emergencies = await _jobService.getNearbyEmergencies();
            _emergencies = emergencies;
          }
          break;
      }

    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showJobDetail(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailSheet(
        job: job,
        userType: ref.read(authProvider)?.userType ?? 'customer',
        onUpdate: _loadData,
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    if (_performanceMetrics.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performans Özeti',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Toplam İş',
                  value: '${_performanceMetrics['total_jobs'] ?? 0}',
                  icon: Icons.work,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Tamamlanan',
                  value: '${_performanceMetrics['completed_jobs'] ?? 0}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Tamamlanma Oranı',
                  value: '${(_performanceMetrics['completion_rate'] ?? 0).round()}%',
                  icon: Icons.trending_up,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Ortalama Puan',
                  value: '${_performanceMetrics['avg_satisfaction'] ?? 0}/5',
                  icon: Icons.star,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(child: LoadingSpinner());
    }

    if (_error != null) {
      return Center(
        child: ErrorMessage(
          message: _error!,
          onRetry: _loadData,
        ),
      );
    }

    switch (_tabController.index) {
      case 0: // Active jobs
      case 1: // Completed jobs
      case 3: // All jobs
        return _buildJobsList();
        
      case 2: // Warranties
        return _buildWarrantiesList();
        
      case 4: // Emergency (craftsmen only)
        return _buildEmergenciesList();
        
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildJobsList() {
    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'İş bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        final job = _jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JobCard(
            job: job,
            userType: ref.read(authProvider)?.userType ?? 'customer',
            onTap: () => _showJobDetail(job),
            onUpdate: _loadData,
          ),
        );
      },
    );
  }

  Widget _buildWarrantiesList() {
    if (_warranties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aktif garanti bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _warranties.length,
      itemBuilder: (context, index) {
        final warranty = _warranties[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WarrantyCard(
            warranty: {'status': 'active', 'description': 'Garanti kapsamında'}, // Mock warranty data
            job: warranty is Map<String, dynamic> ? warranty : warranty.toMap(),
            userType: ref.read(authProvider)?.userType ?? 'customer',
            onUpdate: _loadData,
          ),
        );
      },
    );
  }

  Widget _buildEmergenciesList() {
    if (_emergencies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emergency,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Yakında acil servis talebi yok',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _emergencies.length,
      itemBuilder: (context, index) {
        final emergency = _emergencies[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EmergencyServiceCard(
            emergency: emergency,
            onUpdate: _loadData,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final isCustomer = user?.userType == 'customer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('İş Yönetimi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: !isCustomer,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(
              icon: Icon(Icons.work),
              text: 'Aktif',
            ),
            const Tab(
              icon: Icon(Icons.check_circle),
              text: 'Tamamlanan',
            ),
            const Tab(
              icon: Icon(Icons.security),
              text: 'Garantiler',
            ),
            const Tab(
              icon: Icon(Icons.list),
              text: 'Tümü',
            ),
            if (!isCustomer)
              const Tab(
                icon: Icon(Icons.emergency),
                text: 'Acil Servis',
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPerformanceMetrics(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(), // Active
                _buildTabContent(), // Completed
                _buildTabContent(), // Warranties
                _buildTabContent(), // All
                if (!isCustomer) _buildTabContent(), // Emergency
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: user?.userType == 'craftsman' 
        ? FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => TimeTrackerWidget(
                  onUpdate: _loadData,
                ),
              );
            },
            icon: const Icon(Icons.timer),
            label: const Text('Zaman Takibi'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          )
        : null,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}