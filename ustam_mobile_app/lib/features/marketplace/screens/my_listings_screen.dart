import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/airbnb_card.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  // Mock data for now
  final List<Map<String, dynamic>> _mockListings = [
    {
      'id': '1',
      'title': 'Elektrik Tesisatı Tamiri',
      'description': 'Evin elektrik tesisatında sorun var, acil çözüm gerekiyor.',
      'category': 'Elektrik',
      'budget': '₺500-800',
      'location': 'Kadıköy, İstanbul',
      'status': 'Aktif',
      'statusColor': DesignTokens.success,
      'createdAt': '2 gün önce',
      'offersCount': 5,
    },
    {
      'id': '2',
      'title': 'Ev Boyama İşi',
      'description': '3+1 daire boyama işi, kaliteli işçilik arıyorum.',
      'category': 'Boyacı',
      'budget': '₺2000-3000',
      'location': 'Beşiktaş, İstanbul',
      'status': 'Teklif Bekleniyor',
      'statusColor': DesignTokens.warning,
      'createdAt': '5 gün önce',
      'offersCount': 3,
    },
    {
      'id': '3',
      'title': 'Mutfak Dolabı Tamiri',
      'description': 'Mutfak dolap kapakları onarılacak.',
      'category': 'Marangoz',
      'budget': '₺300-500',
      'location': 'Şişli, İstanbul',
      'status': 'Tamamlandı',
      'statusColor': DesignTokens.gray600,
      'createdAt': '1 hafta önce',
      'offersCount': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: const CommonAppBar(
        title: 'İlanlarım',
        showBackButton: true,
        userType: 'customer',
      ),
      body: _mockListings.isEmpty ? _buildEmptyState() : _buildListingsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/marketplace/new');
        },
        backgroundColor: DesignTokens.primaryCoral,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni İlan'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: DesignTokens.gray400,
          ),
          const SizedBox(height: DesignTokens.space16),
          const Text(
            'Henüz İlan Vermediniz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İş ilanı vererek ustalardan teklif alabilirsiniz.',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/marketplace/new');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('İlk İlanınızı Verin'),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.space16),
      itemCount: _mockListings.length,
      itemBuilder: (context, index) {
        final listing = _mockListings[index];
        return _buildListingCard(listing);
      },
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    return AirbnbCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  listing['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.gray900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: listing['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radius8),
                ),
                child: Text(
                  listing['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: listing['statusColor'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            listing['description'],
            style: const TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Category and Budget
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryCoral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radius8),
                ),
                child: Text(
                  listing['category'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.primaryCoral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                listing['budget'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.gray900,
                ),
              ),
              const Spacer(),
              Text(
                listing['createdAt'],
                style: const TextStyle(
                  fontSize: 12,
                  color: DesignTokens.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Location and Offers
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: DesignTokens.gray600,
              ),
              const SizedBox(width: 4),
              Text(
                listing['location'],
                style: const TextStyle(
                  fontSize: 12,
                  color: DesignTokens.gray600,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.local_offer,
                size: 16,
                color: DesignTokens.info,
              ),
              const SizedBox(width: 4),
              Text(
                '${listing['offersCount']} Teklif',
                style: const TextStyle(
                  fontSize: 12,
                  color: DesignTokens.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to listing detail
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: DesignTokens.primaryCoral),
                    foregroundColor: DesignTokens.primaryCoral,
                  ),
                  child: const Text('Detay'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to offers
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryCoral,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Teklifler'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}