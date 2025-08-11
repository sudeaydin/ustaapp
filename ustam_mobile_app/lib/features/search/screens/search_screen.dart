import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/accessibility_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/search_filters.dart';
import '../providers/search_provider.dart';
import '../widgets/craftsman_card.dart' as search_widgets;
import '../widgets/search_filters_sheet.dart';
import '../widgets/search_map_view.dart';
import '../../../core/widgets/error_message.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> 
    with AccessibilityMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  SearchFilters _filters = SearchFilters();
  int _currentIndex = 1; // Search is second tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).loadFilterOptions();
      _performSearch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    // Update filters with current search query
    _filters = _filters.copyWith(query: _searchController.text.trim());
    
    // Perform search with current filters
    await ref.read(searchProvider.notifier).searchCraftsmenWithFilters(_filters);
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
             appBar: CommonAppBar(
         title: 'Usta Ara',
         showTutorialTrigger: true,
         userType: authState.user?['user_type'],
       ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.getGradient(AppColors.primaryGradient),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.textWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [AppColors.getElevatedShadow()],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Usta, kategori veya hizmet ara...',
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          onChanged: (value) {
                            // Debounced search
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (_searchController.text == value) {
                                _performSearch();
                              }
                            });
                          },
                          onSubmitted: (value) => _performSearch(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.textWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: AppColors.textWhite,
                          size: 24,
                        ),
                        onPressed: _showFiltersSheet,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
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
          
                     // Tab Bar
           Container(
             color: AppColors.background,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.list), text: 'Liste'),
                Tab(icon: Icon(Icons.map), text: 'Harita'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // List View
                _buildListView(searchState),
                // Map View
                SearchMapView(
                  craftsmen: searchState.craftsmen,
                  onCraftsmanTap: _navigateToCraftsmanDetail,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              color: AppColors.textWhite,
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
        child: CircularProgressIndicator(color: AppColors.primary),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Arama kriterlerinize uygun usta bulunamadı',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _filters = SearchFilters();
                  _searchController.clear();
                });
                _performSearch();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Filtreleri Temizle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _performSearch,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: searchState.craftsmen.length,
        itemBuilder: (context, index) {
          final craftsman = searchState.craftsmen[index];
          return Padding(
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