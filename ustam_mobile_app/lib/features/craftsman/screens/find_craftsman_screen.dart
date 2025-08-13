import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/common_app_bar.dart';

class FindCraftsmanScreen extends ConsumerStatefulWidget {
  const FindCraftsmanScreen({super.key});

  @override
  ConsumerState<FindCraftsmanScreen> createState() => _FindCraftsmanScreenState();
}

class _FindCraftsmanScreenState extends ConsumerState<FindCraftsmanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tümü';
  String _selectedLocation = 'İstanbul';
  
  final List<String> _categories = [
    'Tümü', 'Elektrik', 'Tesisatçı', 'Boyacı', 'Marangoz', 
    'Temizlik', 'Tadilat', 'Klima', 'Beyaz Eşya'
  ];

  final List<Map<String, dynamic>> _mockCraftsmen = [
    {
      'name': 'Ahmet Yılmaz',
      'category': 'Elektrik',
      'rating': 4.8,
      'reviewCount': 124,
      'distance': '2.3 km',
      'price': '₺150-250/saat',
      'image': 'assets/images/craftsman1.jpg',
      'isOnline': true,
    },
    {
      'name': 'Mehmet Kaya',
      'category': 'Tesisatçı',
      'rating': 4.6,
      'reviewCount': 89,
      'distance': '3.1 km',
      'price': '₺120-200/saat',
      'image': 'assets/images/craftsman2.jpg',
      'isOnline': false,
    },
    {
      'name': 'Fatma Demir',
      'category': 'Temizlik',
      'rating': 4.9,
      'reviewCount': 156,
      'distance': '1.8 km',
      'price': '₺80-120/saat',
      'image': 'assets/images/craftsman3.jpg',
      'isOnline': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: const CommonAppBar(
        title: 'Usta Bul',
        showBackButton: true,
        userType: 'customer',
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: DesignTokens.surfacePrimary,
              boxShadow: [DesignTokens.getCardShadow()],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: DesignTokens.gray100,
                    borderRadius: BorderRadius.circular(DesignTokens.radius12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Usta ara (isim, kategori, konum)',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(DesignTokens.space16),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space12),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: DesignTokens.gray100,
                          selectedColor: DesignTokens.primaryCoral.withOpacity(0.2),
                          checkmarkColor: DesignTokens.primaryCoral,
                          labelStyle: TextStyle(
                            color: isSelected ? DesignTokens.primaryCoral : DesignTokens.gray700,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Craftsmen List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.space16),
              itemCount: _mockCraftsmen.length + 1, // +1 for "Can't find" section
              itemBuilder: (context, index) {
                if (index == _mockCraftsmen.length) {
                  // "Can't find craftsman" section at the bottom
                  return _buildCantFindSection();
                }
                
                final craftsman = _mockCraftsmen[index];
                return _buildCraftsmanCard(craftsman);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCraftsmanCard(Map<String, dynamic> craftsman) {
    return AirbnbCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: DesignTokens.gray300,
                  borderRadius: BorderRadius.circular(DesignTokens.radius12),
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: DesignTokens.gray600,
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              
              // Craftsman Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          craftsman['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.gray900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (craftsman['isOnline'])
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: DesignTokens.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      craftsman['category'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: DesignTokens.primaryCoral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${craftsman['rating']} (${craftsman['reviewCount']})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: DesignTokens.gray600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: DesignTokens.gray600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          craftsman['distance'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: DesignTokens.gray600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          
          // Price and Actions
          Row(
            children: [
              Text(
                craftsman['price'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.gray900,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to craftsman profile
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: DesignTokens.primaryCoral),
                  foregroundColor: DesignTokens.primaryCoral,
                ),
                child: const Text('Profil'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: Start chat or call
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryCoral,
                  foregroundColor: Colors.white,
                ),
                child: const Text('İletişim'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCantFindSection() {
    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.space24),
      padding: const EdgeInsets.all(DesignTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignTokens.warning.withOpacity(0.1),
            DesignTokens.warning.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radius16),
        border: Border.all(
          color: DesignTokens.warning.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: DesignTokens.warning,
          ),
          const SizedBox(height: DesignTokens.space16),
          const Text(
            'İstediğiniz Ustayı Bulamadınız mı?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'İş ilanı verin, ustalar size ulaşsın!\nEn uygun teklifleri karşılaştırın.',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/marketplace/new');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: DesignTokens.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radius12),
                ),
              ),
              child: const Text(
                'İLAN VER - Ustalar Size Gelsin!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}