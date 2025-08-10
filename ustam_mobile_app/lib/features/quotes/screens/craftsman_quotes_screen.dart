import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class CraftsmanQuotesScreen extends ConsumerStatefulWidget {
  const CraftsmanQuotesScreen({super.key});

  @override
  ConsumerState<CraftsmanQuotesScreen> createState() => _CraftsmanQuotesScreenState();
}

class _CraftsmanQuotesScreenState extends ConsumerState<CraftsmanQuotesScreen> {
  final List<Map<String, dynamic>> _quotes = [
    {
      'id': 1,
      'customer_name': 'Ali Demir',
      'category': 'Elektrikçi',
      'area_type': 'salon',
      'budget_range': '2000-5000',
      'description': 'Salon aydınlatması tamamen yenilenmeli, spot ve avize montajı.',
      'status': 'pending',
      'created_at': '2025-01-22T15:00:00',
      'my_response': null,
    },
    {
      'id': 2,
      'customer_name': 'Fatma Yılmaz',
      'category': 'Tesisatçı',
      'area_type': 'banyo',
      'budget_range': '1000-2000',
      'description': 'Duş kabini değişimi ve tesisat kontrolü.',
      'status': 'details_requested',
      'created_at': '2025-01-22T08:00:00',
      'my_response': 'Daha fazla detay istiyorum. Mevcut duş kabininin boyutları nedir?',
    },
    {
      'id': 3,
      'customer_name': 'Mehmet Özkan',
      'category': 'Elektrikçi',
      'area_type': 'yatak_odası',
      'budget_range': '1000-2000',
      'description': 'Yatak odası elektrik tesisatı yenilenmesi gerekiyor.',
      'status': 'accepted',
      'created_at': '2025-01-20T10:00:00',
      'my_response': 'Elektrik tesisatını tamamen yenileyeceğim. Kaliteli malzeme kullanacağım.',
      'quoted_price': 1800,
      'estimated_duration_days': 2,
    },
    {
      'id': 4,
      'customer_name': 'Ayşe Kaya',
      'category': 'Elektrikçi',
      'area_type': 'mutfak',
      'budget_range': '500-1000',
      'description': 'Mutfak aydınlatması yenilenmesi gerekiyor.',
      'status': 'rejected',
      'created_at': '2025-01-19T14:00:00',
      'my_response': 'Mutfak LED aydınlatma sistemi kurulumu 1200 TL.',
      'quoted_price': 1200,
      'estimated_duration_days': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tekliflerim',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _quotes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _quotes.length,
              itemBuilder: (context, index) {
                final quote = _quotes[index];
                return _buildQuoteCard(quote);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 16),
          Text(
            'Henüz Teklif Yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Müşterilerden gelen teklif talepleri\nburada görünecek',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> quote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusBorderColor(quote['status'])),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(quote['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getStatusIcon(quote['status']),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(quote['status']),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusTextColor(quote['status']),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(quote['created_at']),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Customer info
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.uclaBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      quote['customer_name'][0],
                      style: const TextStyle(
                        color: AppColors.cardBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote['customer_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${quote['category']} - ${quote['area_type']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Quote details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Bütçe', '${quote['budget_range']} TL'),
                  _buildDetailRow('📝 Açıklama', quote['description']),
                  if (quote['quoted_price'] != null)
                    _buildDetailRow('💵 Verdiğim Teklif', '₺${quote['quoted_price']}'),
                  if (quote['estimated_duration_days'] != null)
                    _buildDetailRow('⏱️ Tahmini Süre', '${quote['estimated_duration_days']} gün'),
                ],
              ),
            ),
            
            if (quote['my_response'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.uclaBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yanıtım:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.delftBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quote['my_response'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Action buttons
            if (quote['status'] == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _requestDetails(quote),
                      child: const Text('Detay İste'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _giveQuote(quote),
                      style: AppColors.getPrimaryButtonStyle().copyWith(
                        backgroundColor: MaterialStateProperty.all(AppColors.success),
                      ),
                      child: const Text('Teklif Ver'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFEA580C);
      case 'details_requested': return AppColors.uclaBlue;
      case 'quoted': return AppColors.success;
      case 'accepted': return AppColors.success;
      case 'rejected': return const Color(0xFFDC2626);
      default: return AppColors.nonPhotoBlue.withOpacity(0.3);
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFED7AA);
      case 'details_requested': return const Color(0xFFBFDBFE);
      case 'quoted': return const Color(0xFFBBF7D0);
      case 'accepted': return const Color(0xFFBBF7D0);
      case 'rejected': return const Color(0xFFFECACA);
      default: return AppColors.surfaceColor;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFF9A3412);
      case 'details_requested': return AppColors.delftBlue;
      case 'quoted': return const Color(0xFF065F46);
      case 'accepted': return const Color(0xFF065F46);
      case 'rejected': return const Color(0xFF991B1B);
      default: return AppColors.textSecondary;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return '📋';
      case 'details_requested': return '❓';
      case 'quoted': return '💰';
      case 'accepted': return '✅';
      case 'rejected': return '❌';
      default: return '📄';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Bekleyen';
      case 'details_requested': return 'Detay İstedim';
      case 'quoted': return 'Teklif Verdim';
      case 'accepted': return 'Kabul Edildi';
      case 'rejected': return 'Reddedildi';
      default: return 'Bilinmiyor';
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Bugün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _requestDetails(Map<String, dynamic> quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detay İste'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bu müşteriden daha fazla detay istemek istediğinizden emin misiniz?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Sormak istediğiniz detaylar',
                border: OutlineInputBorder(),
                hintText: 'Örn: Mevcut durumun fotoğrafını gönderebilir misiniz?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Send detail request
            },
            style: AppColors.getPrimaryButtonStyle(),
            child: const Text('Detay İste'),
          ),
        ],
      ),
    );
  }

  void _giveQuote(Map<String, dynamic> quote) {
    final priceController = TextEditingController();
    final notesController = TextEditingController();
    final durationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teklif Ver'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Fiyat (₺)',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: 1500',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Tahmini Süre (gün)',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: 3',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar ve Açıklamalar',
                  border: OutlineInputBorder(),
                  hintText: 'İş detayları, kullanılacak malzemeler vs.',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (priceController.text.isEmpty || durationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fiyat ve süre alanları zorunludur')),
                );
                return;
              }
              Navigator.pop(context);
              // TODO: Submit quote
            },
            style: AppColors.getPrimaryButtonStyle().copyWith(backgroundColor: MaterialStateProperty.all(AppColors.success)),
            child: const Text('Teklif Gönder'),
          ),
        ],
      ),
    );
  }
}