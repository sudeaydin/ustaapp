import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../messages/screens/messages_screen.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';


class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: const CommonAppBar(
        title: 'Ana Sayfa',
        showNotifications: true,
        showTutorialTrigger: true,
        userType: 'customer',
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.space16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [DesignTokens.primaryCoral, DesignTokens.primaryCoralDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [DesignTokens.getElevatedShadow()],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(DesignTokens.radius16),
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hoş Geldiniz!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'İhtiyacınız olan ustayı bulun',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Actions
              Container(
                key: const Key('quick_actions'),
                padding: const EdgeInsets.all(DesignTokens.space16),
                decoration: BoxDecoration(
                  color: DesignTokens.surfacePrimary,
                  borderRadius: BorderRadius.circular(DesignTokens.radius16),
                  boxShadow: [DesignTokens.getCardShadow()],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hızlı İşlemler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.gray900,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    // Primary Actions Row - USTA BUL & İLAN VER side by side
                    Row(
                      children: [
                        Expanded(
                          child: _buildPrimaryActionCard(
                            'USTA BUL',
                            'İhtiyacınız olan ustayı hemen bulun!',
                            Icons.search_rounded,
                            DesignTokens.primaryCoral,
                            () {
                              print('🔍 Usta Bul butonuna tıklandı');
                              Navigator.pushNamed(context, '/search');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSecondaryActionCard(
                            'İLAN VER',
                            'Ustalar size ulaşsın!',
                            Icons.campaign_rounded,
                            DesignTokens.warning,
                            () {
                              print('📝 İlan Ver butonuna tıklandı');
                              Navigator.pushNamed(context, '/marketplace/new');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    const Text(
                      'Diğer İşlemler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.gray700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                              'Mesajlar',
                              'Ustalarla iletişim kurun',
                              Icons.chat_bubble_rounded,
                              DesignTokens.primaryCoral,
                              () {
                                print('💬 Mesajlar butonuna tıklandı');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MessagesScreen(userType: 'customer'),
                                  ),
                                );
                              },
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                              'İlanlarım',
                              'Aktif ilanlarınızı görün',
                              Icons.list_alt_rounded,
                              DesignTokens.info,
                              () {
                                print('📋 İlanlarım butonuna tıklandı');
                                Navigator.pushNamed(context, '/marketplace/mine');
                              },
                            ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            'Takvim',
                            'Randevularınızı görün',
                            Icons.calendar_today,
                            DesignTokens.primaryCoral,
                            () {
                              print('📅 Takvim butonuna tıklandı');
                              Navigator.pushNamed(context, '/calendar', arguments: 'customer');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            'Destek',
                            'Yardım ve destek alın',
                            Icons.support_agent,
                            DesignTokens.warning,
                            () {
                              print('🆘 Destek butonuna tıklandı');
                              Navigator.pushNamed(
                                context, 
                                '/support',
                                arguments: 'customer',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recent Activities
              Container(
                padding: const EdgeInsets.all(DesignTokens.space16),
                decoration: BoxDecoration(
                  color: DesignTokens.surfacePrimary,
                  borderRadius: BorderRadius.circular(DesignTokens.radius16),
                  boxShadow: [DesignTokens.getCardShadow()],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Son Aktiviteler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.gray900,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    _buildActivityCard(
                      title: 'Elektrik Tesisatı',
                      subtitle: 'Ahmet Usta ile mesajlaşma',
                      status: 'Teklif Bekleniyor',
                      statusColor: DesignTokens.warning,
                      icon: Icons.electrical_services,
                    ),
                    const SizedBox(height: 12),
                    _buildActivityCard(
                      title: 'Boyama İşi',
                      subtitle: 'Mehmet Usta - Teklif Verildi',
                      status: 'İnceleme',
                      statusColor: DesignTokens.info,
                      icon: Icons.format_paint,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        userType: 'customer',
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AirbnbCard(
      onTap: onTap,
      backgroundColor: color.withOpacity(0.05),
      border: Border.all(color: color.withOpacity(0.2)),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AirbnbCard(
      onTap: onTap,
      backgroundColor: color.withOpacity(0.1),
      border: Border.all(color: color.withOpacity(0.3)),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AirbnbCard(
      onTap: onTap,
      backgroundColor: color.withOpacity(0.05),
      border: Border.all(color: color.withOpacity(0.2)),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return AirbnbCard(
      backgroundColor: DesignTokens.surfaceSecondaryColor,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radius12),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DesignTokens.gray600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radius12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}