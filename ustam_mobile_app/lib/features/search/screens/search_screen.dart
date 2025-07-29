import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  String _selectedCity = '';
  String _selectedSortBy = 'rating';
  bool _showFilters = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _craftsmen = [];
  List<Map<String, dynamic>> _categories = [];
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCities();
    _performSearch();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/search/categories'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadCities() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/search/locations'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _cities = List<String>.from(data['data']['cities']);
          });
        }
      }
    } catch (e) {
      print('Error loading cities: $e');
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final queryParams = <String, String>{};
      if (_searchController.text.isNotEmpty) {
        queryParams['q'] = _searchController.text;
      }
      if (_selectedCategory.isNotEmpty) {
        queryParams['category'] = _selectedCategory;
      }
      if (_selectedCity.isNotEmpty) {
        queryParams['city'] = _selectedCity;
      }
      queryParams['sort_by'] = _selectedSortBy;

      final uri = Uri.parse('http://localhost:5000/api/search/craftsmen').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _craftsmen = List<Map<String, dynamic>>.from(data['data']['craftsmen']);
          });
        }
      }
    } catch (e) {
      print('Error performing search: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 14,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search - Figma Design
            Container(
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar - Modern Design
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Usta, hizmet veya kategori ara...',
                          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    _performSearch();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                        onSubmitted: (value) {
                          _performSearch();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Toggle Button - Figma Style
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_craftsmen.length} Usta Bulundu',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_list, size: 16, color: const Color(0xFF1E40AF)),
                                const SizedBox(width: 4),
                                Text(
                                  'Filtreler',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Filters Section - Collapsible
            if (_showFilters)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                                hint: const Text('Kategori', style: TextStyle(fontSize: 14)),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem(value: '', child: Text('Tüm Kategoriler')),
                                  ..._categories.map((category) => DropdownMenuItem(
                                    value: category['name'],
                                    child: Text(category['name']),
                                  )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value ?? '';
                                  });
                                  _performSearch();
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCity.isEmpty ? null : _selectedCity,
                                hint: const Text('Şehir', style: TextStyle(fontSize: 14)),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem(value: '', child: Text('Tüm Şehirler')),
                                  ..._cities.map((city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCity = value ?? '';
                                  });
                                  _performSearch();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSortBy,
                                hint: const Text('Sıralama', style: TextStyle(fontSize: 14)),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'rating', child: Text('Puana Göre')),
                                  DropdownMenuItem(value: 'rate', child: Text('Fiyata Göre')),
                                  DropdownMenuItem(value: 'name', child: Text('İsme Göre')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSortBy = value!;
                                  });
                                  _performSearch();
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = '';
                              _selectedCity = '';
                              _selectedSortBy = 'rating';
                              _searchController.clear();
                            });
                            _performSearch();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Temizle',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Results - Figma Card Design
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                      ),
                    )
                  : _craftsmen.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Icon(
                                  Icons.search_off,
                                  size: 40,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Sonuç Bulunamadı',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Arama kriterlerinize uygun usta bulunamadı.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _craftsmen.length,
                          itemBuilder: (context, index) {
                            final craftsman = _craftsmen[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    // Navigate to craftsman detail
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Avatar - Figma Style
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    craftsman['avatar'] ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          craftsman['name'] ?? '',
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: Color(0xFF1E293B),
                                                          ),
                                                        ),
                                                      ),
                                                      if (craftsman['is_verified'] == true)
                                                        Container(
                                                          padding: const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF3B82F6),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: const Icon(
                                                            Icons.verified,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    craftsman['business_name'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 14,
                                                        color: const Color(0xFF94A3B8),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${craftsman['city'] ?? ''}, ${craftsman['district'] ?? ''}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Color(0xFF94A3B8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Skills - Figma Style
                                        if (craftsman['skills'] != null && (craftsman['skills'] as List).isNotEmpty)
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: (craftsman['skills'] as List).take(3).map((skill) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEFF6FF),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  skill.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF1E40AF),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _buildStarRating(craftsman['average_rating']?.toDouble() ?? 0.0),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${craftsman['total_reviews'] ?? 0} değerlendirme',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                            const Spacer(),
                                            if (craftsman['hourly_rate'] != null)
                                              Text(
                                                '${craftsman['hourly_rate']}₺/saat',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF059669),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}