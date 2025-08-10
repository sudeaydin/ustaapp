import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> conversation;
  
  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _currentMessages = [];
  
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }
  
  void _loadMessages() {
    final conversationId = widget.conversation['id'];
    _currentMessages = _getMessagesForConversation(conversationId);
  }
  
  List<Map<String, dynamic>> get _messages => _currentMessages;
  
  List<Map<String, dynamic>> _getMessagesForConversation(String conversationId) {
    switch (conversationId) {
      case '1': // Kabul Edilmiş
        return [
    {
      'id': '1',
      'text': '''Teklif Talebi:

Kategori: Elektrikçi
Alan: yatak_odası
Bütçe: 1000-2000 TL
Açıklama: Yatak odası elektrik tesisatı yenilenmesi gerekiyor.''',
      'timestamp': '10:00',
      'isMe': true,
      'messageType': 'quote_request',
      'quote': {
        'id': 1,
        'status': 'accepted',
        'category': 'Elektrikçi',
        'area_type': 'yatak_odası',
        'budget_range': '1000-2000',
        'description': 'Yatak odası elektrik tesisatı yenilenmesi gerekiyor.'
      }
    },
    {
      'id': '2',
      'text': '''Teklif Yanıtı:

Fiyat: ₺1800
Tahmini Süre: 2 gün
Başlangıç: 25.01.2025
Bitiş: 26.01.2025

Notlar: Elektrik tesisatını tamamen yenileyeceğim. Kaliteli malzeme kullanacağım.''',
      'timestamp': '14:30',
      'isMe': false,
      'messageType': 'quote_response',
      'quote': {
        'id': 1,
        'status': 'quoted',
        'quoted_price': 1800,
        'estimated_duration_days': 2
      }
    },
    {
      'id': '3',
      'text': '''✅ Teklif Kararı:

Teklifinizi kabul ediyorum. Ödeme yapmaya hazırım.''',
      'timestamp': '16:00',
      'isMe': true,
      'messageType': 'quote_decision',
    },
    {
      'id': '4',
      'text': 'Harika! Ödeme onaylandıktan sonra Perşembe sabahı 9:00\'da başlayabilirim.',
      'timestamp': '16:15',
      'isMe': false,
      'messageType': 'text',
    },
        ];
      case '2': // Detay İstenmiş
        return [
          {
            'id': '1',
            'text': '''Teklif Talebi:

Kategori: Tesisatçı
Alan: banyo
Bütçe: 1000-2000 TL
Açıklama: Duş kabini değişimi ve tesisat kontrolü.''',
            'timestamp': '08:00',
            'isMe': true,
            'messageType': 'quote_request',
            'quote': {
              'id': 2,
              'status': 'details_requested',
              'category': 'Tesisatçı',
              'area_type': 'banyo',
              'budget_range': '1000-2000',
              'description': 'Duş kabini değişimi ve tesisat kontrolü.'
            }
          },
          {
            'id': '2',
            'text': '''Teklif Yanıtı:

Daha fazla detay istiyorum. Mevcut duş kabininin boyutları nedir? Hangi marka tercih ediyorsunuz? Tesisat ne kadar eski?''',
            'timestamp': '09:00',
            'isMe': false,
            'messageType': 'quote_response',
          },
          {
            'id': '3',
            'text': 'Mevcut kabin 80x80 cm. Kaliteli bir marka olsun yeter, öneriniz var mı? Tesisat yaklaşık 15 yıllık.',
            'timestamp': '14:15',
            'isMe': true,
            'messageType': 'text',
          },
        ];
      case '3': // Bekleyen
        return [
          {
            'id': '1',
            'text': '''Teklif Talebi:

Kategori: Boyacı
Alan: salon
Bütçe: 2000-5000 TL
Açıklama: Salon duvarları boyama işi.

Ek Detaylar: Modern renkler tercih ediyorum, öneriniz var mı?''',
            'timestamp': '16:00',
            'isMe': true,
            'messageType': 'quote_request',
            'quote': {
              'id': 3,
              'status': 'pending',
              'category': 'Boyacı',
              'area_type': 'salon',
              'budget_range': '2000-5000',
              'description': 'Salon duvarları boyama işi.',
              'additional_details': 'Modern renkler tercih ediyorum, öneriniz var mı?'
            }
          },
          {
            'id': '2',
            'text': 'Teklif talebiniz iletildi. Usta yanıtını bekleyin...',
            'timestamp': '16:01',
            'isMe': false,
            'messageType': 'system',
          },
        ];
      case '4': // Teklif Verilmiş
        return [
          {
            'id': '1',
            'text': '''Teklif Talebi:

Kategori: Temizlik
Alan: diğer
Bütçe: 500-1000 TL
Açıklama: Ev temizliği hizmeti.''',
            'timestamp': '12:00',
            'isMe': true,
            'messageType': 'quote_request',
            'quote': {
              'id': 4,
              'status': 'quoted',
              'category': 'Temizlik',
              'area_type': 'diğer',
              'budget_range': '500-1000',
              'description': 'Ev temizliği hizmeti.'
            }
          },
          {
            'id': '2',
            'text': '''Teklif Yanıtı:

Fiyat: ₺800
Tahmini Süre: 1 gün
Başlangıç: 24.01.2025
Bitiş: 24.01.2025

Notlar: Detaylı ev temizliği yapacağım. Tüm malzemeler dahil.''',
            'timestamp': '13:30',
            'isMe': false,
            'messageType': 'quote_response',
            'quote': {
              'id': 4,
              'status': 'quoted',
              'quoted_price': 800,
              'estimated_duration_days': 1
            }
          },
        ];
      case '5': // Reddedilmiş
        return [
          {
            'id': '1',
            'text': '''Teklif Talebi:

Kategori: Elektrikçi
Alan: mutfak
Bütçe: 500-1000 TL
Açıklama: Mutfak aydınlatması yenilenmesi gerekiyor.''',
            'timestamp': '14:00',
            'isMe': true,
            'messageType': 'quote_request',
            'quote': {
              'id': 5,
              'status': 'rejected',
              'category': 'Elektrikçi',
              'area_type': 'mutfak',
              'budget_range': '500-1000',
              'description': 'Mutfak aydınlatması yenilenmesi gerekiyor.'
            }
          },
          {
            'id': '2',
            'text': '''Teklif Yanıtı:

Fiyat: ₺1200
Tahmini Süre: 1 gün
Başlangıç: 26.01.2025
Bitiş: 26.01.2025

Notlar: Mutfak LED aydınlatma sistemi kurulumu 1200 TL.''',
            'timestamp': '18:00',
            'isMe': false,
            'messageType': 'quote_response',
            'quote': {
              'id': 5,
              'status': 'quoted',
              'quoted_price': 1200,
              'estimated_duration_days': 1
            }
          },
          {
            'id': '3',
            'text': '''❌ Teklif Kararı:

Teklifinizi reddediyorum. Bütçem bu iş için uygun değil. Teşekkürler.''',
            'timestamp': '20:00',
            'isMe': true,
            'messageType': 'quote_decision',
          },
          {
            'id': '4',
            'text': 'Anladım, başka bir zamanda tekrar görüşebiliriz. İyi günler!',
            'timestamp': '20:15',
            'isMe': false,
            'messageType': 'text',
          },
                 ];
       case '6': // Usta - Bekleyen Teklif
         return [
           {
             'id': '1',
             'text': '''Teklif Talebi:

Kategori: Elektrikçi
Alan: salon
Bütçe: 2000-5000 TL
Açıklama: Salon aydınlatması tamamen yenilenmeli, spot ve avize montajı.

Ek Detaylar: Modern LED sistemleri tercih ediyorum.''',
             'timestamp': '15:00',
             'isMe': false,
             'messageType': 'quote_request',
             'quote': {
               'id': 6,
               'status': 'pending',
               'category': 'Elektrikçi',
               'area_type': 'salon',
               'budget_range': '2000-5000',
               'description': 'Salon aydınlatması tamamen yenilenmeli, spot ve avize montajı.',
               'additional_details': 'Modern LED sistemleri tercih ediyorum.'
             }
           },
         ];
       case '7': // Usta - Detay İstediğim
         return [
           {
             'id': '1',
             'text': '''Teklif Talebi:

Kategori: Tesisatçı
Alan: banyo
Bütçe: 1000-2000 TL
Açıklama: Duş kabini değişimi ve tesisat kontrolü.''',
             'timestamp': '08:00',
             'isMe': false,
             'messageType': 'quote_request',
             'quote': {
               'id': 7,
               'status': 'details_requested',
               'category': 'Tesisatçı',
               'area_type': 'banyo',
               'budget_range': '1000-2000',
               'description': 'Duş kabini değişimi ve tesisat kontrolü.'
             }
           },
           {
             'id': '2',
             'text': '''Teklif Yanıtı:

Daha fazla detay istiyorum. Mevcut duş kabininin boyutları nedir? Hangi marka tercih ediyorsunuz? Tesisat ne kadar eski?''',
             'timestamp': '09:00',
             'isMe': true,
             'messageType': 'quote_response',
           },
           {
             'id': '3',
             'text': 'Mevcut duş kabinin boyutları 80x80 cm. Kaliteli bir marka olsun yeter, öneriniz var mı? Tesisat yaklaşık 15 yıllık.',
             'timestamp': '09:30',
             'isMe': false,
             'messageType': 'text',
           },
         ];
       case '8': // Usta - Kabul Edilmiş
         return [
           {
             'id': '1',
             'text': '''Teklif Talebi:

Kategori: Elektrikçi
Alan: yatak_odası
Bütçe: 1000-2000 TL
Açıklama: Yatak odası elektrik tesisatı yenilenmesi gerekiyor.''',
             'timestamp': '10:00',
             'isMe': false,
             'messageType': 'quote_request',
             'quote': {
               'id': 8,
               'status': 'accepted',
               'category': 'Elektrikçi',
               'area_type': 'yatak_odası',
               'budget_range': '1000-2000',
               'description': 'Yatak odası elektrik tesisatı yenilenmesi gerekiyor.'
             }
           },
           {
             'id': '2',
             'text': '''Teklif Yanıtı:

Fiyat: ₺1800
Tahmini Süre: 2 gün
Başlangıç: 25.01.2025
Bitiş: 26.01.2025

Notlar: Elektrik tesisatını tamamen yenileyeceğim. Kaliteli malzeme kullanacağım.''',
             'timestamp': '14:30',
             'isMe': true,
             'messageType': 'quote_response',
             'quote': {
               'id': 8,
               'status': 'quoted',
               'quoted_price': 1800,
               'estimated_duration_days': 2
             }
           },
           {
             'id': '3',
             'text': '''✅ Teklif Kararı:

Teklifinizi kabul ediyorum. Harika!''',
             'timestamp': '16:00',
             'isMe': false,
             'messageType': 'quote_decision',
           },
         ];
       case '6': // Usta - Bekleyen Teklif
         return [
           {
             'id': '1',
             'text': '''Teklif Talebi:

Kategori: Elektrikçi
Alan: salon
Bütçe: 2000-5000 TL
Açıklama: Salon aydınlatması tamamen yenilenmeli, spot ve avize montajı.

Ek Detaylar: Modern LED sistemleri tercih ediyorum.''',
             'timestamp': '15:00',
             'isMe': false,
             'messageType': 'quote_request',
             'quote': {
               'id': 6,
               'status': 'pending',
               'category': 'Elektrikçi',
               'area_type': 'salon',
               'budget_range': '2000-5000',
               'description': 'Salon aydınlatması tamamen yenilenmeli, spot ve avize montajı.',
               'additional_details': 'Modern LED sistemleri tercih ediyorum.'
             }
           },
         ];
       case '7': // Usta - Detay İstediğim
         return [
           {
             'id': '1',
             'text': '''Teklif Talebi:

Kategori: Tesisatçı
Alan: banyo
Bütçe: 1000-2000 TL
Açıklama: Duş kabini değişimi ve tesisat kontrolü.''',
             'timestamp': '08:00',
             'isMe': false,
             'messageType': 'quote_request',
             'quote': {
               'id': 7,
               'status': 'details_requested',
               'category': 'Tesisatçı',
               'area_type': 'banyo',
               'budget_range': '1000-2000',
               'description': 'Duş kabini değişimi ve tesisat kontrolü.'
             }
           },
           {
             'id': '2',
             'text': '''Teklif Yanıtı:

Daha fazla detay istiyorum. Mevcut duş kabininin boyutları nedir? Hangi marka tercih ediyorsunuz? Tesisat ne kadar eski?''',
             'timestamp': '09:00',
             'isMe': true,
             'messageType': 'quote_response',
           },
           {
             'id': '3',
             'text': 'Mevcut duş kabinin boyutları 80x80 cm. Kaliteli bir marka olsun yeter, öneriniz var mı? Tesisat yaklaşık 15 yıllık.',
             'timestamp': '09:30',
             'isMe': false,
             'messageType': 'text',
           },
         ];
       case '8': // Usta - Kabul Edilmiş
         return [
           {
             'id': '1',
             'text': '''Teklif Talebi:

Kategori: Elektrikçi
Alan: yatak_odası
Bütçe: 1000-2000 TL
Açıklama: Yatak odası elektrik tesisatı yenilenmesi gerekiyor.''',
             'timestamp': '10:00',
             'isMe': false,
             'messageType': 'quote_request',
             'quote': {
               'id': 8,
               'status': 'accepted',
               'category': 'Elektrikçi',
               'area_type': 'yatak_odası',
               'budget_range': '1000-2000',
               'description': 'Yatak odası elektrik tesisatı yenilenmesi gerekiyor.'
             }
           },
           {
             'id': '2',
             'text': '''Teklif Yanıtı:

Fiyat: ₺1800
Tahmini Süre: 2 gün
Başlangıç: 25.01.2025
Bitiş: 26.01.2025

Notlar: Elektrik tesisatını tamamen yenileyeceğim. Kaliteli malzeme kullanacağım.''',
             'timestamp': '14:30',
             'isMe': true,
             'messageType': 'quote_response',
             'quote': {
               'id': 8,
               'status': 'quoted',
               'quoted_price': 1800,
               'estimated_duration_days': 2
             }
           },
           {
             'id': '3',
             'text': '''✅ Teklif Kararı:

Teklifinizi kabul ediyorum. Harika!''',
             'timestamp': '16:00',
             'isMe': false,
             'messageType': 'quote_decision',
           },
         ];
       case '9': // Yeni Örnek - Karar Bekleyen Teklif
         return [
           {
             'id': '1',
             'text': '''Teklif Talebi:

Kategori: Boyacı
Alan: salon
Bütçe: 3000-5000 TL
Açıklama: Salon duvarları boyama işi.

Ek Detaylar: Modern renkler tercih ediyorum, öneriniz var mı?''',
             'timestamp': '09:00',
             'isMe': true,
             'messageType': 'quote_request',
             'quote': {
               'id': 9,
               'status': 'quoted',
               'category': 'Boyacı',
               'area_type': 'salon',
               'budget_range': '3000-5000',
               'description': 'Salon duvarları boyama işi.',
               'additional_details': 'Modern renkler tercih ediyorum, öneriniz var mı?'
             }
           },
           {
             'id': '2',
             'text': '''Teklif Yanıtı:

Fiyat: ₺3500
Tahmini Süre: 3 gün
Başlangıç: 27.01.2025
Bitiş: 29.01.2025

Notlar: Salon duvarlarını modern renklerle boyayacağım. Kaliteli boya kullanacağım. Renk önerilerim: Açık gri, krem veya beyaz tonları.''',
             'timestamp': '11:00',
             'isMe': false,
             'messageType': 'quote_response',
             'quote': {
               'id': 9,
               'status': 'quoted',
               'quoted_price': 3500,
               'estimated_duration_days': 3
             }
           },
         ];
       default:
         return [];
     }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(widget.conversation['avatar']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.conversation['business_name'],
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
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.nonPhotoBlue.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'Mesajınızı yazın...',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.uclaBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: AppColors.cardBackground, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(widget.conversation['avatar']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getMessageBackgroundColor(message, isMe),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                border: _getMessageBorder(message, isMe),
                boxShadow: isMe ? null : [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote message action buttons
                  if (message['messageType'] == 'quote_request' && !isMe) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          _showQuoteFormDialog(message['quote']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Formu İncele',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                  if (message['messageType'] == 'quote_response' && !isMe && message['quote']?['status'] == 'quoted') ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _acceptQuote(message['quote']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                elevation: 3,
                                shadowColor: AppColors.success.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Kabul Et',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _rejectQuote(message['quote']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                elevation: 3,
                                shadowColor: AppColors.error.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Reddet',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _requestNewQuote(message['quote']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                elevation: 3,
                                shadowColor: AppColors.info.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Yeni Teklif',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 14,
                      color: _getMessageTextColor(message, isMe),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['timestamp'],
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _currentMessages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': _messageController.text.trim(),
          'timestamp': _getCurrentTime(),
          'isMe': true,
          'messageType': 'text',
        });
      });
      
      _messageController.clear();
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Color _getMessageBackgroundColor(Map<String, dynamic> message, bool isMe) {
    if (message['messageType'] == 'quote_request') {
      return const Color(0xFFFED7AA); // Orange background
    } else if (message['messageType'] == 'quote_response') {
      return const Color(0xFFBFDBFE); // Blue background
    } else if (message['messageType'] == 'quote_decision') {
      return const Color(0xFFBBF7D0); // Green background
    }
    return isMe ? AppColors.uclaBlue : Colors.white;
  }

  Border? _getMessageBorder(Map<String, dynamic> message, bool isMe) {
    if (message['messageType'] == 'quote_request') {
      return Border.all(color: const Color(0xFFEA580C));
    } else if (message['messageType'] == 'quote_response') {
      return Border.all(color: AppColors.uclaBlue);
    } else if (message['messageType'] == 'quote_decision') {
      return Border.all(color: AppColors.success);
    }
    return isMe ? null : Border.all(color: AppColors.nonPhotoBlue.withOpacity(0.3));
  }

  Color _getMessageTextColor(Map<String, dynamic> message, bool isMe) {
    if (message['messageType'] == 'quote_request') {
      return const Color(0xFF9A3412);
    } else if (message['messageType'] == 'quote_response') {
      return AppColors.delftBlue;
    } else if (message['messageType'] == 'quote_decision') {
      return const Color(0xFF065F46);
    }
    return isMe ? Colors.white : AppColors.textPrimary;
  }

  void _showQuoteFormDialog(Map<String, dynamic>? quote) {
    if (quote == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teklif Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuoteDetailRow('Kategori', quote['category'] ?? ''),
            _buildQuoteDetailRow('Alan', quote['area_type'] ?? ''),
            _buildQuoteDetailRow('Bütçe', '${quote['budget_range']} TL'),
            _buildQuoteDetailRow('Açıklama', quote['description'] ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to quote response screen
            },
            child: const Text('Teklif Ver'),
          ),
        ],
      ),
    );
  }

  void _showQuoteDecisionDialog(Map<String, dynamic>? quote) {
    if (quote == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teklif Kararı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuoteDetailRow('Fiyat', '₺${quote['quoted_price']}'),
            _buildQuoteDetailRow('Süre', '${quote['estimated_duration_days']} gün'),
            const SizedBox(height: 16),
            const Text('Bu teklifi kabul ediyor musunuz?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Reject quote
            },
            child: const Text('Reddet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Accept quote and navigate to payment
            },
            child: const Text('Kabul Et'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _acceptQuote(Map<String, dynamic>? quote) {
    if (quote == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Teklif Kabul'),
        content: const Text('Bu teklifi kabul etmek istediğinizden emin misiniz? Ödeme sayfasına yönlendirileceksiniz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentMessages.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'text': '''✅ Teklif Kararı:

Teklifinizi kabul ediyorum. Ödeme yapmaya hazırım.''',
                  'timestamp': _getCurrentTime(),
                  'isMe': true,
                  'messageType': 'quote_decision',
                });
              });
                             _scrollToBottom();
               _showPaymentDialog(quote);
            },
            style: AppColors.getPrimaryButtonStyle().copyWith(backgroundColor: MaterialStateProperty.all(AppColors.success)),
            child: const Text('Kabul Et'),
          ),
        ],
      ),
    );
  }

  void _rejectQuote(Map<String, dynamic>? quote) {
    if (quote == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Teklif Reddi'),
        content: const Text('Bu teklifi reddetmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentMessages.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'text': '''❌ Teklif Kararı:

Teklifinizi reddediyorum. Bütçem bu iş için uygun değil. Teşekkürler.''',
                  'timestamp': _getCurrentTime(),
                  'isMe': true,
                  'messageType': 'quote_decision',
                });
              });
              _scrollToBottom();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
  }

  void _requestNewQuote(Map<String, dynamic>? quote) {
    if (quote == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Teklif İsteği'),
        content: const Text('Yeni bir teklif istemek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentMessages.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'text': '''🔄 Teklif Kararı:

Teklifinizi reddediyorum. Daha uygun bir teklif verebilir misiniz?''',
                  'timestamp': _getCurrentTime(),
                  'isMe': true,
                  'messageType': 'quote_decision',
                });
              });
              _scrollToBottom();
            },
            style: AppColors.getPrimaryButtonStyle(),
            child: const Text('Yeni Teklif İste'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showPaymentDialog(Map<String, dynamic>? quote) {
    if (quote == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Ödeme'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ Teklif Kabul Edildi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildQuoteDetailRow('Tutar', '₺${quote['quoted_price']}'),
                  _buildQuoteDetailRow('Süre', '${quote['estimated_duration_days']} gün'),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '₺${quote['quoted_price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ödeme yönteminizi seçin:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.uclaBlue),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.credit_card, color: AppColors.uclaBlue),
                  SizedBox(width: 8),
                  Text('Kredi Kartı ile Öde'),
                ],
              ),
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
              _showPaymentSuccessDialog();
            },
            style: AppColors.getPrimaryButtonStyle().copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.success),
            ),
            child: const Text(
              'Ödeme Yap',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('✅ Ödeme Başarılı'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: AppColors.success,
            ),
            SizedBox(height: 16),
            Text(
              'Ödemeniz başarıyla tamamlandı!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'İş süreci başladı. Usta ile iletişimde kalabilirsiniz.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to job tracking screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              'İşi Takip Et',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}