import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../messages/screens/messages_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';
import '../../../core/widgets/tutorial_highlight.dart';
import '../../onboarding/widgets/tutorial_overlay.dart';

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
      backgroundColor: AppColors.backgroundLight,
      appBar: const CommonAppBar(
        title: 'Ana Sayfa',
        showNotifications: true,
        showTutorialTrigger: true,
        userType: 'customer',
      ),
      body: TutorialManager(
        userType: 'customer',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: AppColors.getGradient(AppColors.accentGradient),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppColors.getElevatedShadow()],
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
                            color: AppColors.textWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            color: AppColors.textWhite,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hoş Geldiniz!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'İhtiyacınız olan ustayı bulun',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textWhite,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.getCardShadow()],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hızlı İşlemler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TutorialHighlight(
                            tutorialKey: 'search_button',
                            child: _buildQuickActionCard(
                              'Usta Ara',
                              'Kategorilere göre usta bulun',
                              Icons.search_rounded,
                              AppColors.primary,
                              () async {
                                print('🔍 Usta Ara butonuna tıklandı');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🔍 Usta Ara açılıyor...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                
                                // Add small delay to show feedback
                                await Future.delayed(const Duration(milliseconds: 300));
                                
                                if (mounted) {
                                  Navigator.pushNamed(context, '/search');
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TutorialHighlight(
                            tutorialKey: 'messages_tab',
                            child: _buildQuickActionCard(
                              'Mesajlar',
                              'Ustalarla iletişim kurun',
                              Icons.chat_bubble_rounded,
                              AppColors.primary,
                              () async {
                                print('💬 Mesajlar butonuna tıklandı');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('💬 Mesajlar açılıyor...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                
                                await Future.delayed(const Duration(milliseconds: 300));
                                
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MessagesScreen(userType: 'customer'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            'Profil',
                            'Hesap bilgilerinizi düzenleyin',
                            Icons.person,
                            Colors.green,
                            () async {
                              print('👤 Profil butonuna tıklandı');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('👤 Profil açılıyor...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              
                              await Future.delayed(const Duration(milliseconds: 300));
                              
                              if (mounted) {
                                Navigator.pushNamed(context, '/profile');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            'Takvim',
                            'Randevularınızı görün',
                            Icons.calendar_today,
                            Colors.orange,
                            () async {
                              print('📅 Takvim butonuna tıklandı');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('📅 Takvim açılıyor...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              
                              await Future.delayed(const Duration(milliseconds: 300));
                              
                              if (mounted) {
                                Navigator.pushNamed(context, '/calendar', arguments: 'customer');
                              }
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
                            'Destek',
                            'Yardım ve destek alın',
                            Icons.support_agent,
                            AppColors.warning,
                            () async {
                              print('🆘 Destek butonuna tıklandı');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🆘 Destek açılıyor...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              
                              await Future.delayed(const Duration(milliseconds: 300));
                              
                              if (mounted) {
                                Navigator.pushNamed(
                                  context, 
                                  '/support',
                                  arguments: 'customer',
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            'Ayarlar',
                            'Hesap ayarlarınızı yönetin',
                            Icons.settings,
                            Colors.grey,
                            () async {
                              print('⚙️ Ayarlar butonuna tıklandı');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⚙️ Ayarlar açılıyor...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              
                              await Future.delayed(const Duration(milliseconds: 300));
                              
                              if (mounted) {
                                Navigator.pushNamed(context, '/settings');
                              }
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.getCardShadow()],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Son Aktiviteler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityCard(
                      title: 'Elektrik Tesisatı',
                      subtitle: 'Ahmet Usta ile mesajlaşma',
                      status: 'Teklif Bekleniyor',
                      statusColor: AppColors.warning,
                      icon: Icons.electrical_services,
                    ),
                    const SizedBox(height: 12),
                    _buildActivityCard(
                      title: 'Boyama İşi',
                      subtitle: 'Mehmet Usta - Teklif Verildi',
                      status: 'İnceleme',
                      statusColor: AppColors.info,
                      icon: Icons.format_paint,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              color: AppColors.textSecondary,
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
      backgroundColor: AppColors.surfaceColor,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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