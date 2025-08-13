import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/airbnb_card.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> listing;
  
  const ListingDetailScreen({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CommonAppBar(
        title: 'İlan Detayı',
        showBackButton: true,
        userType: 'customer',
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: Navigate to edit screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İlan düzenleme özelliği yakında!')),
                  );
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            AirbnbCard(
              backgroundColor: listing['statusColor'].withOpacity(0.1),
              border: Border.all(color: listing['statusColor'].withOpacity(0.3)),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(listing['status']),
                    color: listing['statusColor'],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing['status'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: listing['statusColor'],
                          ),
                        ),
                        Text(
                          _getStatusDescription(listing['status']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: DesignTokens.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            
            // Title and Description
            AirbnbCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    listing['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: DesignTokens.gray700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            
            // Details
            AirbnbCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İlan Detayları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Kategori', listing['category'], Icons.category),
                  _buildDetailRow('Bütçe', listing['budget'], Icons.attach_money),
                  _buildDetailRow('Konum', listing['location'], Icons.location_on),
                  _buildDetailRow('Yayın Tarihi', listing['createdAt'], Icons.calendar_today),
                  _buildDetailRow('Teklif Sayısı', '${listing['offersCount']} Teklif', Icons.local_offer),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/listing-offers',
                    arguments: listing,
                  );
                },
                icon: const Icon(Icons.local_offer),
                label: Text('Teklifler (${listing['offersCount']})'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: DesignTokens.primaryCoral),
                  foregroundColor: DesignTokens.primaryCoral,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: DesignTokens.gray600,
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DesignTokens.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Aktif':
        return Icons.check_circle;
      case 'Teklif Bekleniyor':
        return Icons.hourglass_empty;
      case 'Tamamlandı':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Aktif':
        return 'İlanınız yayında ve ustalar teklif verebilir';
      case 'Teklif Bekleniyor':
        return 'Ustalardan gelen teklifleri değerlendirin';
      case 'Tamamlandı':
        return 'İş tamamlandı ve ödeme yapıldı';
      default:
        return 'İlan durumu';
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text('Bu ilanı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İlan silindi')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}