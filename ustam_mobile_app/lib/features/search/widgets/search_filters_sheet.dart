import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/theme/design_tokens.dart';
import '../models/search_filters.dart';
import '../providers/search_provider.dart';

class SearchFiltersSheet extends ConsumerStatefulWidget {
  final SearchFilters filters;
  final FilterOptions? filterOptions;
  final ValueChanged<SearchFilters> onFiltersChanged;

  const SearchFiltersSheet({
    super.key,
    required this.filters,
    required this.filterOptions,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends ConsumerState<SearchFiltersSheet> {
  late SearchFilters _currentFilters;
  late RangeValues _priceRange;
  late RangeValues _ratingRange;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
    
    // Initialize ranges
    if (widget.filterOptions != null) {
      _priceRange = RangeValues(
        _currentFilters.minPrice ?? widget.filterOptions!.priceRange.min,
        _currentFilters.maxPrice ?? widget.filterOptions!.priceRange.max,
      );
      _ratingRange = RangeValues(
        _currentFilters.minRating ?? widget.filterOptions!.ratingRange.min,
        _currentFilters.maxRating ?? widget.filterOptions!.ratingRange.max,
      );
    } else {
      _priceRange = const RangeValues(0, 1000);
      _ratingRange = const RangeValues(0, 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: const Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const Borderconst Radius.circular(2),
            ),
          ),
          
          // Header
          const Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Arama Filtreleri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Temizle'),
                ),
              ],
            ),
          ),
          
          // Filters content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter
                  _buildCategoryFilter(),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Location filters
                  _buildLocationFilters(),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Price range
                  if (widget.filterOptions != null)
                    _buildPriceRangeFilter(),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Rating range
                  if (widget.filterOptions != null)
                    _buildRatingRangeFilter(),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Verification and portfolio filters
                  _buildBooleanFilters(),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Sorting options
                  if (widget.filterOptions != null)
                    _buildSortingOptions(),
                  
                  const SizedBox(height: 100), // Space for buttons
                ],
              ),
            ),
          ),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesProvider);
            
            return categoriesAsync.when(
              data: (categories) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final isSelected = _currentFilters.category == category['name'];
                    return FilterChip(
                      label: Text(category['name']),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _currentFilters = _currentFilters.copyWith(
                            category: selected ? category['name'] : null,
                          );
                        });
                      },
                      selectedColor: DesignTokens.primaryCoral.withOpacity(0.2),
                      checkmarkColor: DesignTokens.primaryCoral,
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const Text('Kategoriler yüklenemedi: $error'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konum',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // City dropdown
        Consumer(
          builder: (context, ref, child) {
            final locationsAsync = ref.watch(locationsProvider);
            
            return locationsAsync.when(
              data: (cities) {
                return DropdownButtonFormField<String>(
                  value: _currentFilters.city,
                  decoration: const InputDecoration(
                    labelText: 'Şehir',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: const Text('Tüm Şehirler'),
                    ),
                    ...cities.map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _currentFilters = _currentFilters.copyWith(
                        city: value,
                        district: null, // Clear district when city changes
                      );
                    });
                    if (value != null) {
                      ref.read(searchProvider.notifier).loadDistricts(value);
                    }
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const Text('Şehirler yüklenemedi: $error'),
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // District dropdown
        if (_currentFilters.city != null)
          DropdownButtonFormField<String>(
            value: _currentFilters.district,
            decoration: const InputDecoration(
              labelText: 'İlçe',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: const Text('Tüm İlçeler'),
              ),
              ...ref.watch(searchProvider).districts.map((district) => DropdownMenuItem(
                value: district,
                child: Text(district),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(district: value);
              });
            },
          ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    final priceRange = widget.filterOptions!.priceRange;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saatlik Ücret (₺${_priceRange.start.toInt()} - ₺${_priceRange.end.toInt()})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: _priceRange,
          min: priceRange.min,
          max: priceRange.max,
          divisions: 20,
          activeColor: DesignTokens.primaryCoral,
          onChanged: (values) {
            setState(() {
              _priceRange = values;
              _currentFilters = _currentFilters.copyWith(
                minPrice: values.start,
                maxPrice: values.end,
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('₺${priceRange.min.toInt()}'),
            const Text('₺${priceRange.max.toInt()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Puan (${_ratingRange.start.toStringAsFixed(1)} - ${_ratingRange.end.toStringAsFixed(1)})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: _ratingRange,
          min: 0,
          max: 5,
          divisions: 10,
          activeColor: DesignTokens.primaryCoral,
          onChanged: (values) {
            setState(() {
              _ratingRange = values;
              _currentFilters = _currentFilters.copyWith(
                minRating: values.start,
                maxRating: values.end,
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const Text(' ${_ratingRange.start.toStringAsFixed(1)}'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const Text(' ${_ratingRange.end.toStringAsFixed(1)}'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBooleanFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diğer Filtreler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Verification filter
        CheckboxListTile(
          title: const Text('Sadece Doğrulanmış Ustalar'),
          subtitle: Text(
            widget.filterOptions != null 
                ? '${widget.filterOptions!.verificationStats.verifiedCount} doğrulanmış usta'
                : '',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _currentFilters.isVerified ?? false,
          onChanged: (value) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isVerified: value);
            });
          },
          activeColor: DesignTokens.primaryCoral,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
        // Portfolio filter
        CheckboxListTile(
          title: const Text('Portföyü Olan Ustalar'),
          subtitle: Text(
            widget.filterOptions != null 
                ? '${widget.filterOptions!.portfolioStats.withPortfolio} portföylü usta'
                : '',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _currentFilters.hasPortfolio ?? false,
          onChanged: (value) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(hasPortfolio: value);
            });
          },
          activeColor: DesignTokens.primaryCoral,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildSortingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sıralama',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Sort by dropdown
        DropdownButtonFormField<String>(
          value: _currentFilters.sortBy,
          decoration: const InputDecoration(
            labelText: 'Sırala',
            border: OutlineInputBorder(),
          ),
          items: widget.filterOptions!.sortOptions.map((option) => DropdownMenuItem(
            value: option.value,
            child: Text(option.label),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(sortBy: value);
              });
            }
          },
        ),
        
        const SizedBox(height: 12),
        
        // Sort order dropdown
        DropdownButtonFormField<String>(
          value: _currentFilters.sortOrder,
          decoration: const InputDecoration(
            labelText: 'Sıralama Yönü',
            border: OutlineInputBorder(),
          ),
          items: widget.filterOptions!.sortOrders.map((order) => DropdownMenuItem(
            value: order.value,
            child: Text(order.label),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(sortOrder: value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Temizle',
              type: ButtonType.outlined,
              onPressed: _clearAllFilters,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: 'Filtrele (${_getResultCount()})',
              type: ButtonType.primary,
              onPressed: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = SearchFilters();
      if (widget.filterOptions != null) {
        _priceRange = RangeValues(
          widget.filterOptions!.priceRange.min,
          widget.filterOptions!.priceRange.max,
        );
        _ratingRange = RangeValues(
          widget.filterOptions!.ratingRange.min,
          widget.filterOptions!.ratingRange.max,
        );
      }
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_currentFilters);
    Navigator.of(context).pop();
  }

  String _getResultCount() {
    final searchState = ref.watch(searchProvider);
    return '${searchState.craftsmen.length}';
  }
}