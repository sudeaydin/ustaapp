import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/marketplace_provider.dart';

class MarketplaceFilterBar extends ConsumerStatefulWidget {
  const MarketplaceFilterBar({super.key});

  @override
  ConsumerState<MarketplaceFilterBar> createState() => _MarketplaceFilterBarState();
}

class _MarketplaceFilterBarState extends ConsumerState<MarketplaceFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLocation;
  double? _minBudget;
  double? _maxBudget;

  final List<String> _categories = [
    'Elektrik',
    'Su Tesisatı',
    'Boyacı',
    'Temizlik',
    'Taşıma',
    'Tadilat',
    'Bahçe',
    'Diğer',
  ];

  final List<String> _locations = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Adana',
    'Konya',
    'Diğer',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(marketplaceFeedProvider);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        boxShadow: [
          BoxShadow(
            color: DesignTokens.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: DesignTokens.gray100,
              borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İş ara...',
                prefixIcon: const Icon(Icons.search, color: DesignTokens.gray500),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: DesignTokens.gray500),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                  vertical: DesignTokens.space12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                _applyFilters();
              },
            ),
          ),

          const SizedBox(height: DesignTokens.space12),

          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category filter
                _buildFilterChip(
                  label: _selectedCategory ?? 'Kategori',
                  isSelected: _selectedCategory != null,
                  onTap: () => _showCategoryFilter(),
                ),
                const SizedBox(width: DesignTokens.space8),

                // Location filter
                _buildFilterChip(
                  label: _selectedLocation ?? 'Konum',
                  isSelected: _selectedLocation != null,
                  onTap: () => _showLocationFilter(),
                ),
                const SizedBox(width: DesignTokens.space8),

                // Budget filter
                _buildFilterChip(
                  label: _getBudgetLabel(),
                  isSelected: _minBudget != null || _maxBudget != null,
                  onTap: () => _showBudgetFilter(),
                ),
                const SizedBox(width: DesignTokens.space8),

                // Clear filters
                if (_hasActiveFilters())
                  _buildFilterChip(
                    label: 'Temizle',
                    isSelected: false,
                    onTap: () => _clearFilters(),
                    icon: Icons.clear,
                    color: DesignTokens.error,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? color,
  }) {
    final backgroundColor = isSelected 
        ? (color ?? DesignTokens.primaryCoral).withOpacity(0.1)
        : DesignTokens.gray100;
    
    final textColor = isSelected 
        ? (color ?? DesignTokens.primaryCoral)
        : DesignTokens.gray600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space12,
          vertical: DesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
          border: Border.all(
            color: isSelected 
                ? (color ?? DesignTokens.primaryCoral)
                : DesignTokens.gray300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
 SizedBox(width: DesignTokens.space4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(
        title: 'Kategori Seç',
        items: _categories,
        selectedItem: _selectedCategory,
        onItemSelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLocationFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(
        title: 'Konum Seç',
        items: _locations,
        selectedItem: _selectedLocation,
        onItemSelected: (location) {
          setState(() {
            _selectedLocation = location;
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showBudgetFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBudgetFilterSheet(),
    );
  }

  Widget _buildFilterSheet({
    required String title,
    required List<String> items,
    required String? selectedItem,
    required Function(String) onItemSelected,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(DesignTokens.radius24),
          topRight: const Radius.circular(DesignTokens.radius24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: DesignTokens.space12),
            decoration: BoxDecoration(
              color: DesignTokens.gray300,
              borderRadius: const Borderconst Radius.circular(2),
            ),
          ),

          // Title
          const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignTokens.gray900,
              ),
            ),
          ),

          // Items
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item == selectedItem;

              return ListTile(
                title: Text(
                  item,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? DesignTokens.primaryCoral : DesignTokens.gray900,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: DesignTokens.primaryCoral)
                    : null,
                onTap: () => onItemSelected(item),
              );
            },
          ),

          // Bottom padding
          const SizedBox(height: DesignTokens.space16),
        ],
      ),
    );
  }

  Widget _buildBudgetFilterSheet() {
    double tempMinBudget = _minBudget ?? 0;
    double tempMaxBudget = _maxBudget ?? 10000;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          decoration: const BoxDecoration(
            color: DesignTokens.surfacePrimary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(DesignTokens.radius24),
              topRight: const Radius.circular(DesignTokens.radius24),
            ),
          ),
          child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: DesignTokens.space16),
                  decoration: BoxDecoration(
                    color: DesignTokens.gray300,
                    borderRadius: const Borderconst Radius.circular(2),
                  ),
                ),

                // Title
                const Text(
                  'Bütçe Aralığı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.gray900,
                  ),
                ),

                const SizedBox(height: DesignTokens.space24),

                // Budget range
                Text(
                  '₺${tempMinBudget.toInt()} - ₺${tempMaxBudget.toInt()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.primaryCoral,
                  ),
                ),

                const SizedBox(height: DesignTokens.space16),

                // Range slider
                RangeSlider(
                  values: RangeValues(tempMinBudget, tempMaxBudget),
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  activeColor: DesignTokens.primaryCoral,
                  onChanged: (values) {
                    setSheetState(() {
                      tempMinBudget = values.start;
                      tempMaxBudget = values.end;
                    });
                  },
                ),

                const SizedBox(height: DesignTokens.space24),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _minBudget = tempMinBudget;
                        _maxBudget = tempMaxBudget;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primaryCoral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: DesignTokens.space12),
                      shape: RoundedRectangleBorder(
                        borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
                      ),
                    ),
                    child: const Text('Uygula'),
                  ),
                ),

                const SizedBox(height: DesignTokens.space16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getBudgetLabel() {
    if (_minBudget != null || _maxBudget != null) {
      return '₺${_minBudget?.toInt() ?? 0} - ₺${_maxBudget?.toInt() ?? 10000}';
    }
    return 'Bütçe';
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null ||
           _selectedLocation != null ||
           _minBudget != null ||
           _maxBudget != null ||
           _searchController.text.isNotEmpty;
  }

  void _applyFilters() {
    ref.read(marketplaceFeedProvider.notifier).updateFilters(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      selectedCategory: _selectedCategory,
      selectedLocation: _selectedLocation,
      minBudget: _minBudget,
      maxBudget: _maxBudget,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedLocation = null;
      _minBudget = null;
      _maxBudget = null;
    });
    ref.read(marketplaceFeedProvider.notifier).clearFilters();
  }
}