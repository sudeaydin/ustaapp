import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
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
  int _currentIndex = 1; // Search is second tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadCities();
      _performSearch();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/search/categories'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Categories response: $data');
        if (data['success'] && data['data'] != null) {
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
        print('Cities response: $data');
        if (data['success'] && data['data'] != null && data['data']['cities'] != null) {
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
        print('Search response: $data');
        if (data['success'] && data['data'] != null && data['data']['craftsmen'] != null) {
          setState(() {
            _craftsmen = List<Map<String, dynamic>>.from(data['data']['craftsmen']);
          });
        } else {
          print('No craftsmen found in response');
          setState(() {
            _craftsmen = [];
          });
        }
      } else {
        print('Search failed with status: ${response.statusCode}');
        setState(() {
          _craftsmen = [];
        });
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
            // Modern Header - Figma Design
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF1E40AF),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header Title
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Usta Ara',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar - Modern Design
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Usta, hizmet veya kategori ara...',
                          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
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
                    const SizedBox(height: 16),
                    // Filter Toggle Button - Figma Style
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_craftsmen.length} Usta Bulundu',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_list, size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'Filtreler',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.search_off,
                                  size: 50,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Sonuç Bulunamadı',
                                style: TextStyle(
                                  fontSize: 20,
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
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    // Navigate to craftsman detail
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Avatar - Figma Style
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(35),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    craftsman['avatar'] ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          craftsman['name'] ?? '',
                                                          style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF1E293B),
                                                          ),
                                                        ),
                                                      ),
                                                      if (craftsman['is_verified'] == true)
                                                        Container(
                                                          padding: const EdgeInsets.all(6),
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
                                                  const SizedBox(height: 8),
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
                                        const SizedBox(height: 16),
                                        // Skills - Figma Style
                                        if (craftsman['skills'] != null && (craftsman['skills'] as List).isNotEmpty)
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (craftsman['skills'] as List).take(3).map((skill) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEFF6FF),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: const Color(0xFFDBEAFE)),
                                                ),
                                                child: Text(
                                                  skill.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF1E40AF),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        const SizedBox(height: 16),
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
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF10B981),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '${craftsman['hourly_rate']}₺/saat',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Action Buttons
                                        Row(
                                          children: [
                                            // İşletmeyi İncele Button
                                            Expanded(
                                              child: Container(
                                                height: 48,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    // Navigate to business profile (will be implemented)
                                                    Navigator.pushNamed(context, '/craftsman-detail', arguments: {
                                                      'craftsman': craftsman,
                                                    });
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: const Color(0xFF3B82F6),
                                                    side: const BorderSide(color: Color(0xFF3B82F6)),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'İşletmeyi İncele',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Teklif Al Button
                                            Expanded(
                                              child: Container(
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    // Navigate to quote form
                                                    Navigator.pushNamed(context, '/quote-form', arguments: {
                                                      'craftsman': craftsman,
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF3B82F6),
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  child: const Text(
                                                    'Teklif Al',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              // Navigate to appropriate dashboard based on user type
              final authState = ref.read(authProvider);
              if (authState.user?['user_type'] == 'craftsman') {
                Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
              } else {
                Navigator.pushReplacementNamed(context, '/customer-dashboard');
              }
              break;
            case 1:
              // Already on search
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/messages');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Arama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilim',
          ),
        ],
      ),
    );
  }
}