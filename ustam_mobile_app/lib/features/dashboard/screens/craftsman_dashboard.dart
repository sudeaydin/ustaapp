import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../messages/screens/messages_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';
import '../../onboarding/widgets/tutorial_overlay.dart';

class CraftsmanDashboard extends ConsumerStatefulWidget {
  const CraftsmanDashboard({super.key});

  @override
  ConsumerState<CraftsmanDashboard> createState() => _CraftsmanDashboardState();
}

class _CraftsmanDashboardState extends ConsumerState<CraftsmanDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CommonAppBar(
        title: 'Usta Dashboard',
        showTutorialTrigger: true,
        userType: 'craftsman',
      ),
      body: TutorialManager(
        userType: 'craftsman',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.getGradient(AppColors.accentGradient),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [AppColors.getElevatedShadow()],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.textWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.engineering_rounded,
                          color: AppColors.textWhite,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Usta Dashboard',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'İşlerinizi yönetin ve büyütün',
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
                ),

                const SizedBox(height: 24),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Aktif İşler',
                        '5',
                        'Bu ay',
                        AppColors.primary,
                        Icons.work_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Toplam Kazanç',
                        '₺12,500',
                        'Bu ay',
                        AppColors.success,
                        Icons.attach_money_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Teklif Talepleri',
                        '8',
                        'Beklemede',
                        AppColors.warning,
                        Icons.assignment_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Müşteri Puanı',
                        '4.8',
                        '⭐ (95 değerlendirme)',
                        AppColors.info,
                        Icons.star_rounded,
                      ),
                    ),
                  ],
                ),

                                 const SizedBox(height: 24),

                 // Quick Actions
                 Row(
                   children: [
                     Expanded(
                       child: _buildQuickActionCard(
                         'Tekliflerim',
                         'Teklif taleplerine bak',
                         Icons.assignment_rounded,
                         AppColors.primary,
                         () => Navigator.pushNamed(context, '/craftsman-quotes'),
                       ),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: _buildQuickActionCard(
                         'İşletme Profili',
                         'Bilgilerini güncelle',
                         Icons.business_rounded,
                         AppColors.info,
                         () => Navigator.pushNamed(context, '/business-profile'),
                       ),
                     ),
                   ],
                 ),

                 const SizedBox(height: 24),

                 // Recent Quote Requests
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
                        'Son Teklif Talepleri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuoteRequestCard(
                        title: 'Elektrik Tesisatı',
                        customer: 'Ayşe Yılmaz',
                        budget: '₺500-800',
                        location: 'Kadıköy, İstanbul',
                        status: 'Yeni',
                        statusColor: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _buildQuoteRequestCard(
                        title: 'Boyama İşi',
                        customer: 'Mehmet Kaya',
                        budget: '₺1000-1500',
                        location: 'Beşiktaş, İstanbul',
                        status: 'Teklif Verildi',
                        statusColor: AppColors.info,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        userType: 'craftsman',
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
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
      ),
    );
  }

  Widget _buildQuoteRequestCard({
    required String title,
    required String customer,
    required String budget,
    required String location,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
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
          const SizedBox(height: 8),
          Text(
            'Müşteri: $customer',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bütçe: $budget',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Konum: $location',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}