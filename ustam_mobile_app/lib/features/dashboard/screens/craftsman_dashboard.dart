import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../messages/screens/messages_screen.dart';
import '../../../core/theme/app_colors.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Modern ve Çizgifilmsel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.getGradient(AppColors.warningGradient),
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
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '👋 Hoş geldiniz Usta!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Bugün nasıl gidiyor?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.textWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_active_rounded, color: AppColors.textWhite),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Aktif İşler',
                      value: '5',
                      icon: Icons.work,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Bu Ay Kazanç',
                      value: '₺2,450',
                      icon: Icons.attach_money,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Değerlendirme',
                      value: '4.8',
                      icon: Icons.star,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Tamamlanan',
                      value: '12',
                      icon: Icons.check_circle,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              const Text(
                'Hızlı İşlemler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.message,
                      title: 'Mesajlar',
                      subtitle: '3 yeni mesaj',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.pushNamed(context, '/messages');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.notifications,
                      title: 'Bildirimler',
                      subtitle: '5 yeni bildirim',
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.assignment,
                      title: 'Teklifler',
                      subtitle: '2 yeni teklif',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        // Navigate to business profile for now (quotes list will be added later)
                        Navigator.pushNamed(context, '/business-profile');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.business,
                      title: 'İşletmem',
                      subtitle: 'Profil yönetimi',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.pushNamed(context, '/business-profile');
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Recent Jobs
              const Text(
                'Son İşler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildJobCard(
                title: 'Ev Temizliği',
                location: 'Kadıköy, İstanbul',
                date: 'Bugün',
                status: 'Devam Ediyor',
                statusColor: const Color(0xFF3B82F6),
                amount: '₺150',
              ),
              
              const SizedBox(height: 12),
              
              _buildJobCard(
                title: 'Mobilya Montajı',
                location: 'Ataşehir, İstanbul',
                date: 'Dün',
                status: 'Tamamlandı',
                statusColor: const Color(0xFF10B981),
                amount: '₺300',
              ),
              
              const SizedBox(height: 12),
              
              _buildJobCard(
                title: 'Elektrik Tamiri',
                location: 'Üsküdar, İstanbul',
                date: '2 gün önce',
                status: 'Beklemede',
                statusColor: const Color(0xFFF59E0B),
                amount: '₺200',
              ),
              const SizedBox(height: 80), // Fixed bottom padding for navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getGradient(AppColors.warningGradient),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [AppColors.getElevatedShadow()],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                // Already on craftsman dashboard
                break;
              case 1:
                Navigator.pushNamed(context, '/business-profile');
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessagesScreen(userType: 'craftsman'),
                  ),
                );
                break;
              case 3:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.textWhite,
          unselectedItemColor: AppColors.textWhite.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded, size: 28),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_rounded),
              activeIcon: Icon(Icons.business_rounded, size: 28),
              label: 'İşletmem',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded, size: 28),
              label: 'Mesajlar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded, size: 28),
              label: 'Profilim',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required String location,
    required String date,
    required String status,
    required Color statusColor,
    required String amount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Job detail sayfasına git
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.work,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
              ),
            ],
          ),
        ),
          ),
        ),
      );
    }
}