import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/review_provider.dart';
import '../widgets/review_card.dart';
import '../widgets/review_statistics_widget.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  final int craftsmanId;
  final String craftsmanName;

  const ReviewsScreen({
    super.key,
    required this.craftsmanId,
    required this.craftsmanName,
  });

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load reviews and statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).loadCraftsmanReviews(widget.craftsmanId);
      ref.read(reviewProvider.notifier).loadReviewStatistics(widget.craftsmanId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: '${widget.craftsmanName} - Değerlendirmeler',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: DesignTokens.primaryCoral,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: DesignTokens.primaryCoral,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  text: 'Değerlendirmeler',
                  icon: const Icon(Icons.rate_review),
                ),
                Tab(
                  text: 'İstatistikler',
                  icon: const Icon(Icons.analytics),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewsTab(reviewState),
                _buildStatisticsTab(reviewState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(ReviewState reviewState) {
    if (reviewState.isLoading) {
      return const Center(child: LoadingSpinner());
    }

    if (reviewState.error != null) {
      return Center(
        child: ErrorMessage(
          message: reviewState.error!,
          onRetry: () {
            ref.read(reviewProvider.notifier).loadCraftsmanReviews(widget.craftsmanId);
          },
        ),
      );
    }

    if (reviewState.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Henüz değerlendirme yapılmamış',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu usta için ilk değerlendirmeyi siz yapın!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(reviewProvider.notifier).loadCraftsmanReviews(widget.craftsmanId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(DesignTokens.space16),
        itemCount: reviewState.reviews.length,
        itemBuilder: (context, index) {
          final review = reviewState.reviews[index];
          return ReviewCard(
            review: review,
            showCustomerInfo: true,
          );
        },
      ),
    );
  }

  Widget _buildStatisticsTab(ReviewState reviewState) {
    if (reviewState.isLoading) {
      return const Center(child: LoadingSpinner());
    }

    if (reviewState.statistics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'İstatistik bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: ReviewStatisticsWidget(
        statistics: reviewState.statistics!,
      ),
    );
  }
}