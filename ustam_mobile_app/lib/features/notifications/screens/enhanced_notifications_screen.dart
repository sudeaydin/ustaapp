import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/enhanced_notifications_utils.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';

class EnhancedNotificationsScreen extends ConsumerStatefulWidget {
  const EnhancedNotificationsScreen({super.key});

  @override
  ConsumerState<EnhancedNotificationsScreen> createState() => _EnhancedNotificationsScreenState();
}

class _EnhancedNotificationsScreenState extends ConsumerState<EnhancedNotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final EnhancedNotificationsService _notificationService = EnhancedNotificationsService();
  
  NotificationPreferences? _preferences;
  NotificationAnalytics? _analytics;
  List<LocationShare> _locationShares = [];
  
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      switch (_tabController.index) {
        case 0: // Preferences
          _preferences = await _notificationService.getNotificationPreferences();
          break;
        case 1: // Analytics
          _analytics = await _notificationService.getNotificationAnalytics();
          break;
        case 2: // Location
          _locationShares = await _notificationService.getLocationShares();
          break;
        case 3: // Test
          // No specific data loading needed for test tab
          break;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPushPermission() async {
    try {
      // In a real implementation, you would use firebase_messaging package
      // For now, we'll simulate the token registration
      final mockToken = 'mock-fcm-token-${DateTime.now().millisecondsSinceEpoch}';
      
      final success = await _notificationService.registerDeviceToken(mockToken);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Push bildirimleri başarıyla etkinleştirildi!'),
            backgroundColor: DesignTokens.primaryCoral,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Push bildirimleri etkinleştirilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePreferences(NotificationPreferences newPreferences) async {
    try {
      final success = await _notificationService.updateNotificationPreferences(newPreferences);
      if (success) {
        setState(() {
          _preferences = newPreferences;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tercihler güncellendi'),
              backgroundColor: DesignTokens.primaryCoral,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tercihler güncellenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startLocationSharing() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Konum izni reddedildi';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Konum izni kalıcı olarak reddedildi';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      
      final locationShare = await _notificationService.createLocationShare(
        latitude: position.latitude,
        longitude: position.longitude,
        durationMinutes: 60,
        purpose: 'job_tracking',
      );

      if (locationShare != null) {
        setState(() {
          _locationShares.add(locationShare);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konum paylaşımı başlatıldı'),
              backgroundColor: DesignTokens.primaryCoral,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konum paylaşımı başlatılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopLocationSharing(int shareId) async {
    try {
      final success = await _notificationService.stopLocationShare(shareId);
      if (success) {
        setState(() {
          _locationShares.removeWhere((share) => share.id == shareId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konum paylaşımı durduruldu'),
              backgroundColor: DesignTokens.primaryCoral,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konum paylaşımı durdurulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createTestCalendarEvent() async {
    try {
      final event = await _notificationService.createCalendarEvent(
        title: 'Test İş Hatırlatması',
        description: 'Bu bir test takvim etkinliğidir',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        location: 'Test Lokasyonu',
        attendees: [],
      );

      if (event != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Takvim etkinliği oluşturuldu'),
            backgroundColor: DesignTokens.primaryCoral,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Takvim etkinliği oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      final success = await _notificationService.sendTestNotification();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test bildirimi gönderildi!'),
            backgroundColor: DesignTokens.primaryCoral,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test bildirimi gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPreferencesTab() {
    if (_preferences == null) {
      return const Center(child: Text('Tercihler yüklenemedi'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Push Notifications Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications, color: DesignTokens.primaryCoral),
                      const SizedBox(width: 8),
                      const Text(
                        'Push Bildirimleri',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Anlık bildirimler almak için push bildirimlerini etkinleştirin',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  ElevatedButton(
                    onPressed: _requestPushPermission,
                    child: const Text('Push Bildirimlerini Etkinleştir'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: DesignTokens.space16),

          // Notification Types
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bildirim Türleri',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  ...NotificationType.values.map((type) {
                    final isEnabled = _preferences!.types[type.name] ?? true;
                    return SwitchListTile(
                      title: Text(NotificationHelpers.getNotificationTypeDisplayName(type)),
                      subtitle: Text(_getNotificationTypeDescription(type)),
                      value: isEnabled,
                      onChanged: (value) {
                        final newTypes = Map<String, bool>.from(_preferences!.types);
                        newTypes[type.name] = value;
                        _updatePreferences(NotificationPreferences(
                          types: newTypes,
                          channels: _preferences!.channels,
                          quietHours: _preferences!.quietHours,
                          weekendNotifications: _preferences!.weekendNotifications,
                          language: _preferences!.language,
                          timezone: _preferences!.timezone,
                        ));
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.space16),

          // Quiet Hours
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sessiz Saatler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Başlangıç'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(DesignTokens.radius8),
                              ),
                              child: Text(_preferences!.quietHours['start'] ?? '22:00'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bitiş'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(DesignTokens.radius8),
                              ),
                              child: Text(_preferences!.quietHours['end'] ?? '08:00'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.space16),

          // Weekend Notifications
          Card(
            child: SwitchListTile(
              title: const Text('Hafta Sonu Bildirimleri'),
              subtitle: const Text('Cumartesi ve Pazar günü bildirim al'),
              value: _preferences!.weekendNotifications,
              onChanged: (value) {
                _updatePreferences(NotificationPreferences(
                  types: _preferences!.types,
                  channels: _preferences!.channels,
                  quietHours: _preferences!.quietHours,
                  weekendNotifications: value,
                  language: _preferences!.language,
                  timezone: _preferences!.timezone,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics == null) {
      return const Center(child: Text('Analitik veriler yüklenemedi'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        children: [
          // Metrics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMetricCard(
                'Toplam Gönderilen',
                _analytics!.totalSent.toString(),
                Icons.send,
                DesignTokens.primaryCoral,
              ),
              _buildMetricCard(
                'Teslim Edilen',
                _analytics!.delivered.toString(),
                Icons.check_circle,
                DesignTokens.primaryCoral,
              ),
              _buildMetricCard(
                'Açılan',
                _analytics!.opened.toString(),
                Icons.visibility,
                DesignTokens.primaryCoral,
              ),
              _buildMetricCard(
                'Açılma Oranı',
                '${_analytics!.openRate.toStringAsFixed(1)}%',
                Icons.analytics,
                DesignTokens.primaryCoral,
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.space24),

          // Channel Performance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kanal Performansı',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  ..._analytics!.byChannel.entries.map((entry) {
                    final channel = entry.key;
                    final stats = entry.value as Map<String, dynamic>;
                    final delivered = stats['delivered'] ?? 0;
                    final sent = stats['sent'] ?? 0;
                    final successRate = sent > 0 ? (delivered / sent * 100) : 0;

                    return ListTile(
                      leading: Icon(NotificationHelpers.getDeliveryChannelIcon(
                        DeliveryChannel.values.firstWhere(
                          (c) => c.name == channel,
                          orElse: () => DeliveryChannel.push,
                        ),
                      )),
                      title: Text(channel.toUpperCase()),
                      subtitle: Text('$delivered/$sent teslim edildi'),
                      trailing: Text(
                        '%${successRate.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: successRate > 80 ? DesignTokens.primaryCoral : DesignTokens.primaryCoral,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        children: [
          // Start Location Sharing Button
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                children: [
                  const Icon(Icons.location_on, size: 48, color: DesignTokens.primaryCoral),
                  const SizedBox(height: DesignTokens.space16),
                  const Text(
                    'Konum Paylaşımı',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'İş takibi için konumunuzu paylaşın',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  ElevatedButton.icon(
                    onPressed: _startLocationSharing,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Konum Paylaşımını Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primaryCoral,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.space16),

          // Active Location Shares
          if (_locationShares.isNotEmpty) ...[
            const Text(
              'Aktif Konum Paylaşımları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DesignTokens.space16),
            ..._locationShares.map((share) => Card(
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: share.isActive ? DesignTokens.primaryCoral : Colors.grey,
                ),
                title: Text(share.purpose),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Başladı: ${_formatDateTime(share.createdAt)}'),
                    Text('Bitiş: ${_formatDateTime(share.expiresAt)}'),
                    if (!share.isExpired)
                      Text('Kalan süre: ${_formatDuration(share.remainingTime)}'),
                  ],
                ),
                trailing: share.isActive
                    ? IconButton(
                        icon: const Icon(Icons.stop, color: Colors.red),
                        onPressed: () => _stopLocationSharing(share.id),
                      )
                    : const Icon(Icons.check_circle, color: Colors.grey),
              ),
            )).toList(),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.location_off, size: 48, color: Colors.grey),
                    SizedBox(height: DesignTokens.space16),
                    Text(
                      'Aktif konum paylaşımı yok',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                children: [
                  const Icon(Icons.notification_add, size: 48, color: DesignTokens.primaryCoral),
                  const SizedBox(height: DesignTokens.space16),
                  const Text(
                    'Test Bildirimi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bildirim sisteminizi test edin',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  ElevatedButton.icon(
                    onPressed: _sendTestNotification,
                    icon: const Icon(Icons.send),
                    label: const Text('Test Bildirimi Gönder'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.space16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today, size: 48, color: DesignTokens.primaryCoral),
                  const SizedBox(height: DesignTokens.space16),
                  const Text(
                    'Takvim Etkinliği',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Test takvim etkinliği oluşturun',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  ElevatedButton.icon(
                    onPressed: _createTestCalendarEvent,
                    icon: const Icon(Icons.event),
                    label: const Text('Test Etkinliği Oluştur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primaryCoral,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getNotificationTypeDescription(NotificationType type) {
    switch (type) {
      case NotificationType.quoteUpdate:
        return 'Teklif durumu değişiklikleri';
      case NotificationType.jobUpdate:
        return 'İş durumu güncellemeleri';
      case NotificationType.message:
        return 'Yeni mesajlar';
      case NotificationType.reminder:
        return 'İş hatırlatmaları';
      case NotificationType.emergency:
        return 'Acil durum bildirimleri';
      case NotificationType.system:
        return 'Sistem bildirimleri';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} gün';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} saat';
    } else {
      return '${duration.inMinutes} dakika';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Bildirimler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Tercihler'),
            Tab(icon: Icon(Icons.analytics), text: 'Analitik'),
            Tab(icon: Icon(Icons.location_on), text: 'Konum'),
            Tab(icon: Icon(Icons.science), text: 'Test'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingSpinner())
          : _error != null
              ? Center(child: ErrorMessage(message: _error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPreferencesTab(),
                    _buildAnalyticsTab(),
                    _buildLocationTab(),
                    _buildTestTab(),
                  ],
                ),
    );
  }
}