import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/design_tokens.dart';

import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  final String? userType;
  
  const MessagesScreen({super.key, this.userType});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  int _currentIndex = 2;
  
  Future<void> _navigateToHomeDashboard() async {
    try {
      // Check widget userType parameter first (most reliable when coming from dashboards)
      if (widget.userType == 'craftsman') {
        print('✅ Widget param: Navigating to craftsman dashboard');
        Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
        return;
      }
      
      // Try auth provider second
      final authState = ref.read(authProvider);
      print('Messages Screen - Auth State: ${authState.user}');
      
      if (authState.user != null && authState.user?['user_type'] == 'craftsman') {
        print('✅ Auth Provider: Navigating to craftsman dashboard');
        Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
        return;
      }
      
      // Fallback: Check SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('user_type');
      print('Messages Screen - SharedPrefs User Type: $userType');
      
      if (userType == 'craftsman') {
        print('✅ SharedPrefs: Navigating to craftsman dashboard');
        Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
        return;
      }
      
      print('❌ Fallback: Navigating to customer dashboard');
      Navigator.pushReplacementNamed(context, '/customer-dashboard');
    } catch (e) {
      print('⚠️ Error in navigation: $e');
      Navigator.pushReplacementNamed(context, '/customer-dashboard');
    }
  } // Messages is third tab
  
  List<Map<String, dynamic>> get _conversations {
    // Get user type from widget parameter or auth provider
    final userType = widget.userType ?? ref.read(authProvider).user?['user_type'] ?? 'customer';
    
    if (userType == 'craftsman') {
      return _craftsmanConversations;
    } else {
      return _customerConversations;
    }
  }
  
  final List<Map<String, dynamic>> _customerConversations = [
    {
      'id': '1',
      'name': 'Ahmet Yılmaz',
      'business_name': 'Yılmaz Elektrik',
      'avatar': 'https://picsum.photos/400/400?random=1',
      'lastMessage': '✅ Teklifinizi kabul ediyorum. Ödeme yapmaya hazırım.',
      'timestamp': '16:00',
      'unreadCount': 0,
      'isOnline': true,
      'status': 'accepted',
      'statusIcon': '✅',
      'jobTitle': 'Elektrik Tesisatı'
    },
    {
      'id': '2',
      'name': 'Mehmet Kaya',
      'business_name': 'Kaya Tesisatçılık',
      'avatar': 'https://picsum.photos/400/400?random=2',
      'lastMessage': 'Mevcut kabin 80x80 cm. Kaliteli bir marka olsun yeter.',
      'timestamp': '14:15',
      'unreadCount': 1,
      'isOnline': false,
      'status': 'details_requested',
      'statusIcon': '❓',
      'jobTitle': 'Duş Kabini Değişimi'
    },
    {
      'id': '3',
      'name': 'Ali Demir',
      'business_name': 'Müşteri',
      'avatar': 'https://picsum.photos/400/400?random=3',
      'lastMessage': 'Teklif talebiniz iletildi. Usta yanıtını bekleyin...',
      'timestamp': '16:01',
      'unreadCount': 0,
      'isOnline': true,
      'status': 'pending',
      'statusIcon': '📋',
      'jobTitle': 'Salon Boyama'
    },
    {
      'id': '4',
      'name': 'Fatma Çelik',
      'business_name': 'Çelik Temizlik',
      'avatar': 'https://picsum.photos/400/400?random=10',
      'lastMessage': 'Fiyat: ₺800 - Detaylı ev temizliği yapacağım.',
      'timestamp': '13:30',
      'unreadCount': 1,
      'isOnline': true,
      'status': 'quoted',
      'statusIcon': '💰',
      'jobTitle': 'Ev Temizliği'
    },
    {
      'id': '5',
      'name': 'Hasan Öztürk',
      'business_name': 'Öztürk Elektrik',
      'avatar': 'https://picsum.photos/400/400?random=5',
      'lastMessage': '❌ Anladım, başka bir zamanda tekrar görüşebiliriz.',
      'timestamp': '20:15',
      'unreadCount': 0,
      'isOnline': false,
      'status': 'rejected',
      'statusIcon': '❌',
      'jobTitle': 'Mutfak Aydınlatması'
    },
    {
      'id': '9',
      'name': 'Serkan Yılmaz',
      'business_name': 'Yılmaz Boyacılık',
      'avatar': 'https://picsum.photos/400/400?random=6',
      'lastMessage': 'Fiyat: ₺3500 - Salon boyama işi için teklifim.',
      'timestamp': '11:00',
      'unreadCount': 1,
      'isOnline': true,
      'status': 'quoted',
      'statusIcon': '💰',
      'jobTitle': 'Karar Bekleyen - Salon Boyama'
    },
  ];
  
  final List<Map<String, dynamic>> _craftsmanConversations = [
    {
      'id': '6',
      'name': 'Ali Demir',
      'business_name': 'Müşteri',
      'avatar': 'https://picsum.photos/400/400?random=3',
      'lastMessage': 'Salon aydınlatması için teklif talebiniz var.',
      'timestamp': '15:00',
      'unreadCount': 1,
      'isOnline': true,
      'status': 'pending',
      'statusIcon': '📋',
      'jobTitle': 'Bekleyen Teklif - Salon Aydınlatması'
    },
    {
      'id': '7',
      'name': 'Fatma Yılmaz',
      'business_name': 'Müşteri',
      'avatar': 'https://picsum.photos/400/400?random=11',
      'lastMessage': 'Mevcut duş kabinin boyutları 80x80 cm.',
      'timestamp': '09:00',
      'unreadCount': 0,
      'isOnline': false,
      'status': 'details_requested',
      'statusIcon': '❓',
      'jobTitle': 'Detay İstediğim - Duş Kabini'
    },
    {
      'id': '8',
      'name': 'Mehmet Özkan',
      'business_name': 'Müşteri',
      'avatar': 'https://picsum.photos/400/400?random=1',
      'lastMessage': '✅ Teklifinizi kabul ediyorum. Harika!',
      'timestamp': '16:00',
      'unreadCount': 0,
      'isOnline': true,
      'status': 'accepted',
      'statusIcon': '✅',
      'jobTitle': 'Kabul Edilmiş - Elektrik İşi'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userType = widget.userType ?? ref.read(authProvider).user?['user_type'] ?? 'customer';
    
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CommonAppBar(
        title: 'Mesajlar',
        userType: userType,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _conversations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.space16),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return _buildConversationTile(conversation);
              },
            ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        userType: userType,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: DesignTokens.surfaceSecondaryColor,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.message_outlined,
              size: 60,
              color: DesignTokens.textMuted,
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          const Text(
            'Henüz Mesaj Yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Teklif gönderdiğiniz ustalardan\nmesajlar burada görünecek',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.uclaBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radius12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Usta Bul',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radius16),
        border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radius16),
          onTap: () {
            Navigator.pushNamed(context, '/chat', arguments: {
              'conversation': conversation,
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        image: DecorationImage(
                          image: NetworkImage(conversation['avatar']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (conversation['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: DesignTokens.success,
                            borderRadius: BorderRadius.circular(DesignTokens.radius12),
                            border: Border.all(color: DesignTokens.surfacePrimary, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conversation['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: DesignTokens.gray900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  conversation['business_name'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: DesignTokens.textLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      conversation['statusIcon'] ?? '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        conversation['jobTitle'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: DesignTokens.gray600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                conversation['timestamp'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: DesignTokens.textMuted,
                                ),
                              ),
                              if (conversation['unreadCount'] > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.uclaBlue,
                                    borderRadius: BorderRadius.circular(DesignTokens.radius12),
                                  ),
                                  child: Text(
                                    conversation['unreadCount'].toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: DesignTokens.surfacePrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        conversation['lastMessage'],
                        style: TextStyle(
                          fontSize: 14,
                          color: conversation['unreadCount'] > 0 
                              ? DesignTokens.gray900
                              : DesignTokens.textLight,
                          fontWeight: conversation['unreadCount'] > 0 
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}