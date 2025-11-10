import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';

class CraftsmanQuotesScreen extends ConsumerStatefulWidget {
  const CraftsmanQuotesScreen({super.key});

  @override
  ConsumerState<CraftsmanQuotesScreen> createState() => _CraftsmanQuotesScreenState();
}

class _CraftsmanQuotesScreenState extends ConsumerState<CraftsmanQuotesScreen> {
  int _currentIndex = 3; // Teklifler sekmesi
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
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: const CommonAppBar(
        title: 'Tekliflerim',
        showBackButton: true,
        userType: 'craftsman',
      ),
      body: _quotes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.space16),
              itemCount: _quotes.length,
              itemBuilder: (context, index) {
                final quote = _quotes[index];
                return _buildQuoteCard(quote);
              },
            ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        userType: 'craftsman',
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
            color: DesignTokens.textMuted,
          ),
          SizedBox(height: DesignTokens.space16),
          Text(
            'Henüz Teklif Yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Müşterilerden gelen teklif talepleri\nburada görünecek',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.textLight,
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
        color: DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radius16),
        border: Border.all(color: _getStatusBorderColor(quote['status'])),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
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
                    borderRadius: BorderRadius.circular(DesignTokens.radius12),
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
                    color: DesignTokens.textLight,
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
                    color: DesignTokens.uclaBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      quote['customer_name'][0],
                      style: const TextStyle(
                        color: DesignTokens.surfacePrimary,
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
                          color: DesignTokens.gray900,
                        ),
                      ),
                      Text(
                        '${quote['category']} - ${quote['area_type']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textLight,
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
                color: DesignTokens.surfacePrimary,
                borderRadius: BorderRadius.circular(DesignTokens.radius12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Bütçe', '${quote['budget_range']} TL'),
                  
                  // Show customer's preferred date range
                  if (quote['preferred_start_date'] != null || quote['preferred_end_date'] != null) ...[
                    if (quote['preferred_start_date'] != null && quote['preferred_end_date'] != null)
                      _buildDetailRow('📅 Tercih Edilen Tarih', 
                        '${_formatDateOnly(quote['preferred_start_date'])} - ${_formatDateOnly(quote['preferred_end_date'])}'),
                    if (quote['preferred_start_date'] != null && quote['preferred_end_date'] == null)
                      _buildDetailRow('📅 En Erken Başlangıç', _formatDateOnly(quote['preferred_start_date'])),
                    if (quote['preferred_start_date'] == null && quote['preferred_end_date'] != null)
                      _buildDetailRow('📅 En Geç Bitiş', _formatDateOnly(quote['preferred_end_date'])),
                    if (quote['is_flexible_dates'] == true)
                      _buildDetailRow('🔄 Tarih Esnekliği', 'Esnek'),
                  ],
                  
                  if (quote['urgency_level'] != null && quote['urgency_level'] != 'normal')
                    _buildDetailRow('⚡ Aciliyet', _getUrgencyText(quote['urgency_level'])),
                  
                  _buildDetailRow('📝 Açıklama', quote['description']),
                  
                  // Show craftsman's proposed dates if available
                  if (quote['estimated_start_date'] != null || quote['estimated_end_date'] != null) ...[
                    if (quote['estimated_start_date'] != null && quote['estimated_end_date'] != null)
                      _buildDetailRow('📅 Önerdiğim Tarih', 
                        '${_formatDateOnly(quote['estimated_start_date'])} - ${_formatDateOnly(quote['estimated_end_date'])}'),
                    if (quote['estimated_start_date'] != null && quote['estimated_end_date'] == null)
                      _buildDetailRow('📅 Başlangıç Önerim', _formatDateOnly(quote['estimated_start_date'])),
                    if (quote['estimated_start_date'] == null && quote['estimated_end_date'] != null)
                      _buildDetailRow('📅 Bitiş Önerim', _formatDateOnly(quote['estimated_end_date'])),
                  ],
                  
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
                  color: DesignTokens.primaryCoral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radius12),
                  border: Border.all(color: DesignTokens.primaryCoral),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yanıtım:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.primaryCoral,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quote['my_response'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: DesignTokens.gray900,
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
                      style: DesignTokens.getPrimaryButtonStyle().copyWith(
                        backgroundColor: MaterialStateProperty.all(DesignTokens.success),
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
                color: DesignTokens.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: DesignTokens.gray900,
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
      case 'details_requested': return DesignTokens.uclaBlue;
      case 'quoted': return DesignTokens.success;
      case 'accepted': return DesignTokens.success;
      case 'rejected': return const Color(0xFFDC2626);
      default: return DesignTokens.nonPhotoBlue.withOpacity(0.3);
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFED7AA);
      case 'details_requested': return const Color(0xFFBFDBFE);
      case 'quoted': return const Color(0xFFBBF7D0);
      case 'accepted': return const Color(0xFFBBF7D0);
      case 'rejected': return const Color(0xFFFECACA);
      default: return DesignTokens.surfaceSecondaryColor;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFF9A3412);
      case 'details_requested': return DesignTokens.primaryCoral;
      case 'quoted': return const Color(0xFF065F46);
      case 'accepted': return const Color(0xFF065F46);
      case 'rejected': return const Color(0xFF991B1B);
      default: return DesignTokens.gray600;
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

  String _formatDateOnly(String? dateString) {
    if (dateString == null) return 'Belirtilmemiş';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Geçersiz tarih';
    }
  }

  String _getUrgencyText(String level) {
    switch (level) {
      case 'urgent': return 'Acil';
      case 'emergency': return 'Acil Durum';
      case 'normal': return 'Normal';
      default: return level;
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
            const SizedBox(height: DesignTokens.space16),
            TextField(
              style: DesignTokens.inputTextStyle,
              decoration: DesignTokens.inputDecoration(
                labelText: 'Sormak istediğiniz detaylar',
                hintText: 'Örn: Mevcut durumun fotoğrafını gönderebilir misiniz?',
                alignLabelWithHint: true,
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
            style: DesignTokens.getPrimaryButtonStyle(),
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
    DateTime? proposedStartDate;
    DateTime? proposedEndDate;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Teklif Ver'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show customer's preferred dates if available
                if (quote['preferred_start_date'] != null || quote['preferred_end_date'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryCoral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radius8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Müşterinin Tercih Ettiği Tarihler:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        if (quote['preferred_start_date'] != null)
                          Text('Başlangıç: ${_formatDate(quote['preferred_start_date'])}'),
                        if (quote['preferred_end_date'] != null)
                          Text('Bitiş: ${_formatDate(quote['preferred_end_date'])}'),
                        if (quote['is_flexible_dates'] == true)
                          const Text('(Tarihler esnek)', style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                ],
                
                TextField(
                  controller: priceController,
                  style: DesignTokens.inputTextStyle,
                  decoration: DesignTokens.inputDecoration(
                    labelText: 'Fiyat (₺)',
                    hintText: 'Örn: 1500',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: DesignTokens.space16),
                TextField(
                  controller: durationController,
                  style: DesignTokens.inputTextStyle,
                  decoration: DesignTokens.inputDecoration(
                    labelText: 'Tahmini Süre (gün)',
                    hintText: 'Örn: 3',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: DesignTokens.space16),
                
                // Proposed date range
                const Text(
                  'Önerdiğiniz Tarih Aralığı:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: proposedStartDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              proposedStartDate = picked;
                              if (proposedEndDate != null && proposedEndDate!.isBefore(picked)) {
                                proposedEndDate = null;
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DesignTokens.inputBackground,
                            border: Border.all(color: DesignTokens.inputBorderColor),
                            borderRadius: BorderRadius.circular(DesignTokens.radius8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                proposedStartDate != null
                                    ? '${proposedStartDate!.day}/${proposedStartDate!.month}/${proposedStartDate!.year}'
                                    : 'Başlangıç',
                                style: TextStyle(
                                  color: proposedStartDate != null
                                      ? DesignTokens.gray900
                                      : DesignTokens.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: proposedEndDate ?? (proposedStartDate ?? DateTime.now()),
                            firstDate: proposedStartDate ?? DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              proposedEndDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DesignTokens.inputBackground,
                            border: Border.all(color: DesignTokens.inputBorderColor),
                            borderRadius: BorderRadius.circular(DesignTokens.radius8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                proposedEndDate != null
                                    ? '${proposedEndDate!.day}/${proposedEndDate!.month}/${proposedEndDate!.year}'
                                    : 'Bitiş',
                                style: TextStyle(
                                  color: proposedEndDate != null
                                      ? DesignTokens.gray900
                                      : DesignTokens.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space16),
                
                TextField(
                  controller: notesController,
                  style: DesignTokens.inputTextStyle,
                  decoration: DesignTokens.inputDecoration(
                    labelText: 'Notlar ve Açıklamalar',
                    hintText: 'İş detayları, kullanılacak malzemeler vs.',
                    alignLabelWithHint: true,
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
                // TODO: Submit quote with proposed dates
                // Include proposedStartDate and proposedEndDate in the API call
              },
              style: DesignTokens.getPrimaryButtonStyle().copyWith(backgroundColor: MaterialStateProperty.all(DesignTokens.success)),
              child: const Text('Teklif Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}