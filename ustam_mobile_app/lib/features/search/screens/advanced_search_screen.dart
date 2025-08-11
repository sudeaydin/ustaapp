import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../models/search_filters.dart';
import '../providers/search_provider.dart';
import '../widgets/craftsman_card.dart';
import '../widgets/search_filters_sheet.dart';
import '../widgets/search_map_view.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  SearchFilters _filters = SearchFilters();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load initial data
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

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Gelişmiş Arama',
        showBackButton: true,
        actions: [
          // Clear filters button
          if (_filters.hasActiveFilters)
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Filtreleri Temizle',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar and filters
          _buildSearchHeader(),
          
          // Tab bar
          _buildTabBar(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(searchState),
                _buildMapView(searchState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFiltersSheet,
        backgroundColor: AppColors.primary,
        child: Stack(
          children: [
            const Icon(Icons.filter_list, color: Colors.white),
            if (_filters.activeFilterCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${_filters.activeFilterCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Search field
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _searchController,
                  hintText: 'Usta, hizmet veya şehir ara...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(query: value);
                    });
                  },
                  onSubmitted: (value) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _performSearch,
                icon: const Icon(Icons.search),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          // Active filters chips
          if (_filters.hasActiveFilters) ...[
            const SizedBox(height: 12),
            _buildActiveFiltersChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final chips = <Widget>[];
    
    if (_filters.category != null) {
      chips.add(_buildFilterChip('Kategori: ${_filters.category}', () {
        setState(() {
          _filters = _filters.copyWith(category: null);
        });
        _performSearch();
      }));
    }
    
    if (_filters.city != null) {
      chips.add(_buildFilterChip('Şehir: ${_filters.city}', () {
        setState(() {
          _filters = _filters.copyWith(city: null);
        });
        _performSearch();
      }));
    }
    
    if (_filters.minRating != null || _filters.maxRating != null) {
      final minText = _filters.minRating?.toStringAsFixed(1) ?? '0';
      final maxText = _filters.maxRating?.toStringAsFixed(1) ?? '5';
      chips.add(_buildFilterChip('Puan: $minText-$maxText', () {
        setState(() {
          _filters = _filters.copyWith(minRating: null, maxRating: null);
        });
        _performSearch();
      }));
    }
    
    if (_filters.minPrice != null || _filters.maxPrice != null) {
      final minText = _filters.minPrice?.toStringAsFixed(0) ?? '0';
      final maxText = _filters.maxPrice?.toStringAsFixed(0) ?? '∞';
      chips.add(_buildFilterChip('Fiyat: ₺$minText-₺$maxText', () {
        setState(() {
          _filters = _filters.copyWith(minPrice: null, maxPrice: null);
        });
        _performSearch();
      }));
    }
    
    if (_filters.isVerified == true) {
      chips.add(_buildFilterChip('Doğrulanmış', () {
        setState(() {
          _filters = _filters.copyWith(isVerified: null);
        });
        _performSearch();
      }));
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: chips,
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      deleteIconColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
    );
  }

  Widget _buildTabBar() {
    return Container(
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
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            text: 'Liste',
            icon: Icon(Icons.list),
          ),
          Tab(
            text: 'Harita',
            icon: Icon(Icons.map),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(SearchState searchState) {
    if (searchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchState.error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Tekrar Dene',
              onPressed: _performSearch,
            ),
          ],
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
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Arama kriterlerinize uygun usta bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Filtreleri değiştirmeyi deneyin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Filtreleri Temizle',
              type: ButtonType.outlined,
              onPressed: _clearFilters,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _performSearch,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: searchState.craftsmen.length,
        itemBuilder: (context, index) {
          final craftsman = searchState.craftsmen[index];
          return CraftsmanCard(
            craftsman: craftsman,
            onTap: () => _navigateToCraftsmanDetail(craftsman),
          );
        },
      ),
    );
  }

  Widget _buildMapView(SearchState searchState) {
    return SearchMapView(
      craftsmen: searchState.craftsmen,
      isLoading: searchState.isLoading,
      onCraftsmanTap: _navigateToCraftsmanDetail,
    );
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFiltersSheet(
        filters: _filters,
        filterOptions: ref.read(searchProvider).filterOptions,
        onFiltersChanged: (newFilters) {
          setState(() {
            _filters = newFilters;
          });
          _performSearch();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filters = SearchFilters();
      _searchController.clear();
    });
    _performSearch();
  }

  Future<void> _performSearch() async {
    await ref.read(searchProvider.notifier).searchCraftsmen(_filters);
  }

  void _navigateToCraftsmanDetail(dynamic craftsman) {
    Navigator.pushNamed(
      context,
      '/craftsman-detail',
      arguments: {
        'craftsmanId': craftsman['id'],
        'craftsmanName': craftsman['name'],
      },
    );
  }
}