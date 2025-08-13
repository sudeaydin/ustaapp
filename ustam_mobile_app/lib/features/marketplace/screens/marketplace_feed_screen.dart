import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/marketplace_filter_bar.dart';
import '../widgets/marketplace_listing_card.dart';
import '../widgets/marketplace_empty_state.dart';
import 'marketplace_listing_detail_screen.dart';
import '../../auth/providers/auth_provider.dart';

class MarketplaceFeedScreen extends ConsumerStatefulWidget {
  const MarketplaceFeedScreen({super.key});

  @override
  ConsumerState<MarketplaceFeedScreen> createState() => _MarketplaceFeedScreenState();
}

class _MarketplaceFeedScreenState extends ConsumerState<MarketplaceFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 1; // Marketplace is second tab after dashboard

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial listings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceFeedProvider.notifier).loadListings(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(marketplaceFeedProvider.notifier).loadListings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final marketplaceFeedState = ref.watch(marketplaceFeedProvider);

    // Role-based access control - Only craftsmen can see marketplace feed
    if (authState.user?['user_type'] != 'craftsman') {
      return Scaffold(
        backgroundColor: DesignTokens.surfacePrimary,
        appBar: const CommonAppBar(
          title: 'Erişim Reddedildi',
          showBackButton: true,
          userType: 'customer',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block_rounded,
                size: 64,
                color: DesignTokens.warning,
              ),
              const SizedBox(height: DesignTokens.space16),
              const Text(
                'Bu sayfa sadece ustalar için!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Müşteriler usta arayabilir veya iş ilanı verebilir.',
                style: TextStyle(
                  fontSize: 14,
                  color: DesignTokens.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.space24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/find-craftsman');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryCoral,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Usta Bul'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CommonAppBar(
        title: 'Pazar Yeri',
        userType: authState.user?['user_type'] ?? 'customer',
        actions: [
          if (authState.user?['user_type'] == 'customer')
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/marketplace/new'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          const MarketplaceFilterBar(),
          
          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(marketplaceFeedProvider.notifier).loadListings(refresh: true);
              },
              child: _buildContent(marketplaceFeedState, authState.user?['user_type'] ?? 'customer'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        userType: authState.user?['user_type'] ?? 'customer',
      ),
    );
  }

  Widget _buildContent(MarketplaceFeedState state, String userType) {
    if (state.isLoading && state.listings.isEmpty) {
      return _buildLoadingSkeleton();
    }

    if (state.error != null && state.listings.isEmpty) {
      return _buildErrorState(state.error!);
    }

    if (state.listings.isEmpty) {
      return const MarketplaceEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(DesignTokens.space16),
      itemCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.listings.length) {
          return _buildLoadingMoreIndicator();
        }

        final listing = state.listings[index];
        return MarketplaceListingCard(
          listing: listing,
          userType: userType,
          onTap: () => Navigator.pushNamed(
            context, 
            '/marketplace/listing/${listing.id}',
          ),
          onOfferTap: userType == 'craftsman' 
              ? () => Navigator.pushNamed(
                  context,
                  '/marketplace/listing/${listing.id}/offer',
                )
              : null,
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.space16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space16),
      child: AirbnbCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: DesignTokens.gray300,
                borderRadius: BorderRadius.circular(DesignTokens.radius8),
              ),
            ),
            const SizedBox(height: DesignTokens.space8),
            
            // Description skeleton
            Container(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                color: DesignTokens.gray300,
                borderRadius: BorderRadius.circular(DesignTokens.radius8),
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            
            // Bottom row skeleton
            Row(
              children: [
                Container(
                  height: 16,
                  width: 80,
                  decoration: BoxDecoration(
                    color: DesignTokens.gray300,
                    borderRadius: BorderRadius.circular(DesignTokens.radius8),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 32,
                  width: 100,
                  decoration: BoxDecoration(
                    color: DesignTokens.gray300,
                    borderRadius: BorderRadius.circular(DesignTokens.radius16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.primaryCoral),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DesignTokens.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: DesignTokens.error,
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            
            const Text(
              'Bir Hata Oluştu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignTokens.gray900,
              ),
            ),
            const SizedBox(height: DesignTokens.space8),
            
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space24),
            
            AirbnbButton(
              text: 'Tekrar Dene',
              onPressed: () {
                ref.read(marketplaceFeedProvider.notifier).loadListings(refresh: true);
              },
              type: AirbnbButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }
}