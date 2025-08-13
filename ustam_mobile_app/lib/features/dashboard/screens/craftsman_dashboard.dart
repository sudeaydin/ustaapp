import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';

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
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: const CommonAppBar(
        title: 'Usta Dashboard',
        showTutorialTrigger: true,
        userType: 'craftsman',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DesignTokens.primaryCoral, DesignTokens.primaryCoralDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [DesignTokens.getElevatedShadow()],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.engineering_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Usta Dashboard',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'İşlerinizi yönetin ve büyütün',
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
                ),

                const SizedBox(height: DesignTokens.space24),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/jobs', arguments: {'filter': 'active'});
                        },
                        borderRadius: BorderRadius.circular(DesignTokens.radius16),
                        child: _buildStatCard(
                          'Aktif İşler',
                          '5',
                          'Bu ay',
                          DesignTokens.primaryCoral,
                          Icons.work_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/earnings');
                        },
                        borderRadius: BorderRadius.circular(DesignTokens.radius16),
                        child: _buildStatCard(
                          'Toplam Kazanç',
                          '₺12,500',
                          'Bu ay',
                          DesignTokens.success,
                          Icons.attach_money_rounded,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/quotes', arguments: {'filter': 'pending'});
                        },
                        borderRadius: BorderRadius.circular(DesignTokens.radius16),
                        child: _buildStatCard(
                          'Teklif Talepleri',
                          '8',
                          'Beklemede',
                          DesignTokens.warning,
                          Icons.assignment_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/reviews');
                        },
                        borderRadius: BorderRadius.circular(DesignTokens.radius16),
                        child: _buildStatCard(
                          'Müşteri Puanı',
                          '4.8',
                          '124 değerlendirme',
                          DesignTokens.info,
                          Icons.star_rounded,
                        ),
                      ),
                    ),
                  ],
                ),

                                 const SizedBox(height: DesignTokens.space24),

                                 // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        'Pazar Yeri',
                        'İş ilanlarını gör ve teklif ver',
                        Icons.storefront_rounded,
                        DesignTokens.primaryCoral,
                        () => Navigator.pushNamed(context, '/marketplace'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        'Tekliflerim',
                        'Verdiğim teklifleri yönet',
                        Icons.assignment_turned_in_rounded,
                        DesignTokens.info,
                        () => Navigator.pushNamed(context, '/marketplace/offers'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        'İşletme Profili',
                        'Bilgilerini güncelle',
                        Icons.business_rounded,
                        DesignTokens.success,
                        () => Navigator.pushNamed(context, '/business-profile'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        'Takvim',
                        'Randevularınızı yönetin',
                        Icons.calendar_today,
                        DesignTokens.primaryCoral,
                        () => Navigator.pushNamed(context, '/calendar', arguments: 'craftsman'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        'Mesajlar',
                        'Müşterilerle iletişim',
                        Icons.chat_bubble_rounded,
                        DesignTokens.warning,
                        () => Navigator.pushNamed(context, '/messages'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        'Değerlendirmeler',
                        'Müşteri yorumları',
                        Icons.star_rate,
                        Colors.amber,
                        () => Navigator.pushNamed(context, '/reviews', arguments: {
                          'craftsmanId': 1, // TODO: Get actual craftsman ID
                          'craftsmanName': 'Profilim',
                        }),
                      ),
                    ),
                  ],
                ),

                 const SizedBox(height: DesignTokens.space24),

                 // Recent Quote Requests
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
                        'Son Teklif Talepleri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.gray900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space16),
                      _buildQuoteRequestCard(
                        title: 'Elektrik Tesisatı',
                        customer: 'Ayşe Yılmaz',
                        budget: '₺500-800',
                        location: 'Kadıköy, İstanbul',
                        status: 'Yeni',
                        statusColor: DesignTokens.primaryCoral,
                      ),
                      const SizedBox(height: 12),
                      _buildQuoteRequestCard(
                        title: 'Boyama İşi',
                        customer: 'Mehmet Kaya',
                        budget: '₺1000-1500',
                        location: 'Beşiktaş, İstanbul',
                        status: 'Teklif Verildi',
                        statusColor: DesignTokens.info,
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
    return AirbnbCard(
      backgroundColor: color.withOpacity(0.05),
      border: Border.all(color: color.withOpacity(0.2)),
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
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.gray600,
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
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
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
                color: DesignTokens.gray600,
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
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceSecondaryColor,
        borderRadius: BorderRadius.circular(DesignTokens.radius12),
        border: Border.all(
          color: DesignTokens.gray300,
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
                    color: DesignTokens.gray900,
                  ),
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
          const SizedBox(height: 8),
          Text(
            'Müşteri: $customer',
            style: const TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bütçe: $budget',
            style: const TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Konum: $location',
            style: const TextStyle(
              fontSize: 14,
              color: DesignTokens.gray600,
            ),
          ),
        ],
      ),
    );
  }
}