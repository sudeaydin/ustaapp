import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'quote',
      'title': 'Yeni Teklif Talebi',
      'message': 'Ahmet Yılmaz size temizlik hizmeti için teklif talebi gönderdi.',
      'timestamp': '2 dakika önce',
      'isRead': false,
      'icon': Icons.request_quote,
      'color': DesignTokens.uclaBlue,
    },
    {
      'id': '2',
      'type': 'message',
      'title': 'Yeni Mesaj',
      'message': 'Mehmet Özkan size mesaj gönderdi.',
      'timestamp': '15 dakika önce',
      'isRead': false,
      'icon': Icons.message,
      'color': DesignTokens.success,
    },
    {
      'id': '3',
      'type': 'payment',
      'title': 'Ödeme Alındı',
      'message': 'Temizlik hizmeti için 400₺ ödeme alındı.',
      'timestamp': '1 saat önce',
      'isRead': true,
      'icon': Icons.payment,
      'color': Color(0xFFF59E0B),
    },
    {
      'id': '4',
      'type': 'job',
      'title': 'İş Tamamlandı',
      'message': 'Mobilya montajı işi başarıyla tamamlandı.',
      'timestamp': '3 saat önce',
      'isRead': true,
      'icon': Icons.check_circle,
      'color': DesignTokens.success,
    },
    {
      'id': '5',
      'type': 'review',
      'title': 'Yeni Değerlendirme',
      'message': 'Ayşe Demir size 5 yıldız verdi.',
      'timestamp': '1 gün önce',
      'isRead': true,
      'icon': Icons.star,
      'color': Color(0xFFF59E0B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CommonAppBar(
        title: 'Bildirimler',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Tümünü Okundu İşaretle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.space16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationTile(notification);
              },
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
              borderRadius: const BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 60,
              color: DesignTokens.textMuted,
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          const Text(
            'Bildirim Yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yeni bildirimler burada\n görünecek',
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

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.white : DesignTokens.primaryCoral.withOpacity(0.1),
        borderRadius: const BorderRadius.circular(DesignTokens.radius16),
        border: Border.all(
          color: notification['isRead'] 
              ? DesignTokens.nonPhotoBlue.withOpacity(0.3)
              : DesignTokens.primaryCoral.withOpacity(0.3),
        ),
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
          borderRadius: const BorderRadius.circular(DesignTokens.radius16),
          onTap: () => _handleNotificationTap(notification),
          child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
            child: Row(
              children: [
                // Notification Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification['color'].withOpacity(0.1),
                    borderRadius:  BorderRadius.circular(DesignTokens.radius12),
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['color'],
                    size: 24,
                  ),
                ),
                SizedBox(width: DesignTokens.space16),
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification['isRead'] 
                                    ? FontWeight.w500 
                                    : FontWeight.w600,
                                color: DesignTokens.gray900,
                              ),
                            ),
                          ),
                          if (!notification['isRead'])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: DesignTokens.uclaBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 14,
                          color: notification['isRead'] 
                              ? DesignTokens.textLight
                              : DesignTokens.gray600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        notification['timestamp'],
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Button
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: DesignTokens.textMuted,
                  ),
                  onPressed: () => _showNotificationActions(notification),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    setState(() {
      notification['isRead'] = true;
    });

    // Navigate based on notification type
    switch (notification['type']) {
      case 'quote':
        // Navigate to quote details
        break;
      case 'message':
        // Navigate to chat
        break;
      case 'payment':
        // Navigate to payment details
        break;
      case 'job':
        // Navigate to job details
        break;
      case 'review':
        // Navigate to review details
        break;
    }
  }

  void _showNotificationActions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: DesignTokens.surfacePrimary,
          borderRadius: BorderRadius.only(
            topLeft:  Radius.circular(20),
            topRight:  Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.nonPhotoBlue.withOpacity(0.3),
                borderRadius: const BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.mark_email_read, color: DesignTokens.uclaBlue),
              title: const Text('Okundu İşaretle'),
              onTap: () {
                setState(() {
                  notification['isRead'] = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: DesignTokens.error),
              title: const Text('Bildirimi Sil'),
              onTap: () {
                setState(() {
                  _notifications.remove(notification);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }
}
