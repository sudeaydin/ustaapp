import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/ios_icons.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_input.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/utils/accessibility_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/search_filters.dart';
import '../providers/search_provider.dart';
import '../widgets/craftsman_card.dart' as search_widgets;
import '../widgets/search_filters_sheet.dart';
import '../../../core/widgets/error_message.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> 
    with AccessibilityMixin {
  final TextEditingController _searchController = TextEditingController();
  SearchFilters _filters = SearchFilters();
  int _currentIndex = 1; // Search is second tab

  @override
  void initState() {
    super.initState();
    
    // Load filter options and do initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).loadFilterOptions();
      // Do initial search to show all craftsmen
      ref.read(searchProvider.notifier).searchCraftsmen();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    // Update search query in provider
    ref.read(searchProvider.notifier).updateQuery(_searchController.text.trim());
    
    // Perform basic search
    await ref.read(searchProvider.notifier).searchCraftsmen();
  }

  void _showFiltersSheet() {
    final searchState = ref.read(searchProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFiltersSheet(
        filters: _filters,
        filterOptions: searchState.filterOptions,
        onFiltersChanged: (newFilters) {
          setState(() {
            _filters = newFilters;
          });
          _performSearch();
        },
      ),
    );
  }

  void _navigateToCraftsmanDetail(dynamic craftsman) {
    Navigator.pushNamed(
      context,
      '/craftsman-detail',
      arguments: {
        'craftsman': craftsman,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
             appBar: CommonAppBar(
         title: 'Usta Ara',
         showBackButton: true,
         showTutorialTrigger: true,
         userType: authState.user?['user_type'],
       ),
      body: Column(
        children: [
          // Airbnb Search Header - Clean White Style
          Container(
            padding: DesignTokens.spacingScreenEdgeInsets,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Airbnb Search Bar
                AirbnbSearchInput(
                  hintText: 'Hangi hizmeti arıyorsun?',
                  controller: _searchController,
                  onChanged: (value) => _performSearch(),
                ),
                DesignTokens.verticalSpaceMD,
                
                // Filter Button Row
                Row(
                  children: [
                    Expanded(child: Container()), // Spacer
                    const SizedBox(width: 12),
                    // Filter Button - Outline Style
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const Borderconst Radius.circular(DesignTokens.radius16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          iOSIcons.tune,
                          color: DesignTokens.primaryCoral, // Pembe renk
                          size: 24,
                        ),
                        onPressed: _showFiltersSheet,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: DesignTokens.space16),
                
                                 // Quick Filters
                 if (_filters.hasActiveFilters) ...[
                  Container(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (_filters.category != null) ...[
                          _buildQuickFilterChip(
                            'Kategori: ${_filters.category}',
                            () => setState(() {
                              _filters = _filters.copyWith(category: null);
                              _performSearch();
                            }),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (_filters.city != null) ...[
                          _buildQuickFilterChip(
                            'Şehir: ${_filters.city}',
                            () => setState(() {
                              _filters = _filters.copyWith(city: null);
                              _performSearch();
                            }),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (_filters.minRating != null) ...[
                          _buildQuickFilterChip(
                            'Min ${_filters.minRating} ⭐',
                            () => setState(() {
                              _filters = _filters.copyWith(minRating: null);
                              _performSearch();
                            }),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (_filters.isVerified == true) ...[
                          _buildQuickFilterChip(
                            'Doğrulanmış',
                            () => setState(() {
                              _filters = _filters.copyWith(isVerified: null);
                              _performSearch();
                            }),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          
          // Content - Direct list view instead of tabs
          Expanded(
            child: _buildListView(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const Borderconst Radius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              iOSIcons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(SearchState searchState) {
    if (searchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DesignTokens.primaryCoral),
      );
    }

    if (searchState.error != null) {
      return Center(
        child: ErrorMessage(
          message: searchState.error!.userFriendlyMessage,
          onRetry: _performSearch,
        ),
      );
    }

    if (searchState.craftsmen.isEmpty) {
      // Check if this is initial state (no search performed yet) or empty results
      final isInitialState = searchState.query.isEmpty && 
                             !searchState.isLoading && 
                             searchState.error == null &&
                             (searchState.currentFilters == null || !searchState.currentFilters!.hasActiveFilters);
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isInitialState ? iOSIcons.search : iOSIcons.searchOff,
              size: 64,
              color: DesignTokens.gray600.withOpacity(0.5),
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              isInitialState 
                ? 'Usta aramak için yukarıdaki arama çubuğunu kullanın'
                : 'Arama kriterlerinize uygun usta bulunamadı',
              style: TextStyle(
                color: DesignTokens.gray600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space16),
            ElevatedButton.icon(
              onPressed: () {
                if (isInitialState) {
                  _performSearch();
                } else {
                  setState(() {
                    _filters = SearchFilters();
                    _searchController.clear();
                  });
                  _performSearch();
                }
              },
              icon: Icon(isInitialState ? iOSIcons.search : iOSIcons.refresh),
              label: Text(isInitialState ? 'Tüm Ustaları Göster' : 'Filtreleri Temizle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryCoral,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _performSearch,
      color: DesignTokens.primaryCoral,
      child: ListView.builder(
        padding: const EdgeInsets.all(DesignTokens.space16),
        itemCount: searchState.craftsmen.length,
        itemBuilder: (context, index) {
          final craftsman = searchState.craftsmen[index];
          return const Padding(
            padding: const EdgeInsets.only(bottom: 16),
                         child: search_widgets.CraftsmanCard(
               craftsman: craftsman,
               onTap: () => _navigateToCraftsmanDetail(craftsman),
             ),
          );
        },
      ),
    );
  }
}