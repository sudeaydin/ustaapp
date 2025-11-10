// ignore_for_file: dead_code, undefined_getter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isCustomer = user?['user_type'] == 'customer';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: DesignTokens.primaryCoralGradient,
        ),
        child: Column(
          children: [
            // Custom AppBar with 3D effect
            Container(
              decoration: BoxDecoration(
                gradient: DesignTokens.primaryCoralGradient,
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primaryCoral.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: const Padding(
      padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: DesignTokens.surfacePrimary.withOpacity(0.2),
                          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                          boxShadow: [
                            BoxShadow(
                              color: DesignTokens.surfacePrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(-2, -2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.build_circle,
                          color: DesignTokens.surfacePrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Text(
                          'Merhaba, ${user?['first_name'] ?? 'Kullanıcı'}! 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.surfacePrimary,
                          ),
                        ),
                      ),
                      // Menu Button
                      Container(
                        decoration: BoxDecoration(
                          color: DesignTokens.surfacePrimary.withOpacity(0.2),
                          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: DesignTokens.surfacePrimary),
                          onSelected: (value) {
                            switch (value) {
                              case 'profile':
                                context.go('/profile');
                                break;
                              case 'logout':
                                ref.read(authProvider.notifier).logout();
                                context.go('/login');
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outlined),
                                  const SizedBox(width: 8),
                                  const Text('Profil'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  const Icon(Icons.logout),
                                  const SizedBox(width: 8),
                                  const Text('Çıkış Yap'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    _buildStatsSection(context, isCustomer),
                    
                    const SizedBox(height: DesignTokens.space24),
                    
                    // Quick Actions
                    Text(
                      'Hızlı İşlemler',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    _buildQuickActions(context, isCustomer),
                    
                    const SizedBox(height: DesignTokens.space24),
                    
                    // Recent Activity
                    Text(
                      isCustomer ? 'Son İşlerim' : 'Son Tekliflerim',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    _buildRecentActivity(context, isCustomer),
                    
                    const SizedBox(height: DesignTokens.space24),
                    
                    // Popular Categories (for customers)
                    if (isCustomer) ...[
                      Text(
                        'Popüler Kategoriler',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
 SizedBox(height: DesignTokens.space16),
                      _buildPopularCategories(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isCustomer) {
    if (isCustomer) {
      // Müşteri için: İş sayısı ve harcama odaklı
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context: context,
              title: 'Yaptırdığım İşler',
              value: '12',
              icon: Icons.home_repair_service_outlined,
              color: AppTheme.primaryColor,
              onTap: () => context.go('/jobs'),
            ),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: _buildStatCard(
              context: context,
              title: 'Aktif İşler',
              value: '3',
              icon: Icons.pending_actions_outlined,
              color: AppTheme.secondaryColor,
              onTap: () => context.go('/jobs'),
            ),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: _buildStatCard(
              context: context,
              title: 'Toplam Harcama',
              value: '₺2.4K',
              icon: Icons.account_balance_wallet_outlined,
              color: DesignTokens.success,
              onTap: () => context.go('/jobs'),
            ),
          ),
        ],
      );
    } else {
      // Usta için: Teklif ve kazanç odaklı
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context: context,
              title: 'Verdiğim Teklifler',
              value: '28',
              icon: Icons.request_quote_outlined,
              color: AppTheme.primaryColor,
              onTap: () => context.go('/jobs'),
            ),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: _buildStatCard(
              context: context,
              title: 'Kazanılan İşler',
              value: '15',
              icon: Icons.work_history_outlined,
              color: AppTheme.secondaryColor,
              onTap: () => context.go('/jobs'),
            ),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: _buildStatCard(
              context: context,
              title: 'Toplam Kazanç',
              value: '₺8.2K',
              icon: Icons.trending_up_outlined,
              color: DesignTokens.success,
              onTap: () => context.go('/jobs'),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => isPressed = true),
            onTapUp: (_) {
              setState(() => isPressed = false);
              // Mobile için kısa hover efekti
              setState(() => isHovered = true);
              Future.delayed(const Duration(milliseconds: 150), () {
                setState(() => isHovered = false);
              });
            },
            onTapCancel: () => setState(() => isPressed = false),
            onTap: () {
              // Haptic feedback for mobile
              HapticFeedback.lightImpact();
              onTap();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()
                ..scale(isPressed ? 0.92 : (isHovered ? 1.08 : 1.0)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPressed
                    // ignore: dead_code
                    ? [color.withOpacity(0.3), color.withOpacity(0.15)]
                    : isHovered 
                      // ignore: dead_code
                      ? [color.withOpacity(0.25), color.withOpacity(0.12)]
                      : [color.withOpacity(0.15), color.withOpacity(0.08)],
                ),
                borderRadius: const BorderRadius.circular(20),
                border: Border.all(
                  color: isPressed 
                    // ignore: dead_code
                    ? color.withOpacity(0.6)
                    : isHovered 
                      ? color.withOpacity(0.4) 
                      : color.withOpacity(0.2),
                  width: isPressed ? 3 : (isHovered ? 2 : 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isPressed ? 0.4 : (isHovered ? 0.3 : 0.15)),
                    blurRadius: isPressed ? 25 : (isHovered ? 20 : 12),
                    offset: Offset(0, isPressed ? 2 : (isHovered ? 8 : 4)),
                    spreadRadius: isPressed ? 0 : (isHovered ? 2 : 0),
                  ),
                  if (isHovered || isPressed) BoxShadow(
                    color: DesignTokens.surfacePrimary.withOpacity(isPressed ? 0.9 : 0.7),
                    blurRadius: isPressed ? 20 : 15,
                    offset: Offset(isPressed ? -2 : -4, isPressed ? -2 : -4),
                  ),
                ],
              ),
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPressed
                    ? [color.withOpacity(0.4), color.withOpacity(0.3)]
                    : isHovered 
                      ? [color.withOpacity(0.35), color.withOpacity(0.25)]
                      : [color.withOpacity(0.2), color.withOpacity(0.1)],
                ),
                borderRadius: const BorderRadius.circular(DesignTokens.radius16),
                boxShadow: (isHovered || isPressed) ? [
                  BoxShadow(
                    color: color.withOpacity(isPressed ? 0.4 : 0.3),
                    blurRadius: isPressed ? 15 : 10,
                    offset: Offset(0, isPressed ? 2 : 4),
                  ),
                ] : null,
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isPressed ? 0.9 : (isHovered ? 1.15 : 1.0),
                child: Icon(
                  icon, 
                  size: 28, 
                  color: isPressed 
                    ? color.withOpacity(0.9)
                    : isHovered 
                      ? color 
                      : color.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isPressed ? 28 : (isHovered ? 26 : 24),
                fontWeight: FontWeight.bold,
                color: isPressed 
                  ? color.withOpacity(0.95)
                  : isHovered 
                    ? color 
                    : color.withOpacity(0.9),
              ),
              child: Text(value),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isPressed ? 13 : (isHovered ? 12 : 11),
                color: isPressed 
                  ? Colors.grey[800]
                  : isHovered 
                    ? Colors.grey[700] 
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isCustomer) {
    if (isCustomer) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildActionCard(
            title: 'Yeni İş Talebi',
            icon: Icons.add_circle_outline,
            color: AppTheme.primaryColor,
            onTap: () => context.push('/job-request/new'),
          ),
          _buildActionCard(
            title: 'Usta Ara',
            icon: Icons.search,
            color: AppTheme.secondaryColor,
            onTap: () => context.go('/search'),
          ),
          _buildActionCard(
            title: 'Mesajlarım',
            icon: Icons.chat_bubble_outline,
            color: AppTheme.primaryLight,
            onTap: () => context.go('/messages'),
          ),
          _buildActionCard(
            title: 'Ödeme Geçmişi',
            icon: Icons.payment,
            color: AppTheme.secondaryLight,
            onTap: () => context.push('/payment-history'),
          ),
        ],
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildActionCard(
            title: 'Tekliflerim',
            icon: Icons.assignment_outlined,
            color: AppTheme.primaryColor,
            onTap: () => context.go('/jobs'),
          ),
          _buildActionCard(
            title: 'Yeni Teklifler',
            icon: Icons.notification_add,
            color: AppTheme.secondaryColor,
            onTap: () => context.go('/search'),
          ),
          _buildActionCard(
            title: 'Mesajlarım',
            icon: Icons.chat_bubble_outline,
            color: AppTheme.primaryLight,
            onTap: () => context.go('/messages'),
          ),
          _buildActionCard(
            title: 'Portföyüm',
            icon: Icons.photo_library_outlined,
            color: AppTheme.secondaryLight,
            onTap: () => context.go('/profile'),
          ),
        ],
      );
    }
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.circular(DesignTokens.radius12),
        child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, bool isCustomer) {
    return Column(
      children: List.generate(3, (index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: DesignTokens.uclaBlue.shade100,
              child: Icon(
                isCustomer ? Icons.work : Icons.person,
                color: DesignTokens.uclaBlue,
              ),
            ),
            title: Text(
              isCustomer 
                ? 'Elektrik Tesisatı İşi #${index + 1}'
                : 'Ahmet K. - Elektrik İşi',
            ),
            subtitle: Text(
              isCustomer
                ? 'Durum: ${['Beklemede', 'Devam Ediyor', 'Tamamlandı'][index]}'
                : 'Teklif: ${[1500, 2000, 1200][index]} TL',
            ),
            trailing: _buildStatusChip(['Yeni', 'Aktif', 'Bitti'][index]),
            onTap: () {
              // Navigate to job detail
              context.go('/jobs');
            },
          ),
        );
      }),
    );
  }

  Widget _buildPopularCategories(BuildContext context) {
    final categories = [
      {'name': 'Elektrik', 'icon': Icons.electrical_services, 'color': AppTheme.secondaryColor},
      {'name': 'Su Tesisatı', 'icon': Icons.plumbing, 'color': AppTheme.primaryColor},
      {'name': 'Boyacı', 'icon': Icons.format_paint, 'color': AppTheme.secondaryLight},
      {'name': 'Temizlik', 'icon': Icons.cleaning_services, 'color': AppTheme.primaryLight},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => context.go('/search'),
              borderRadius: const BorderRadius.circular(DesignTokens.radius12),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withOpacity(0.1),
                      borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    LinearGradient gradient;
    Color shadowColor;
    
    switch (status.toLowerCase()) {
      case 'yeni':
        gradient = AppTheme.pendingGradient;
        shadowColor = const Color(0xFFF59E0B);
        break;
      case 'aktif':
        gradient = AppTheme.activeGradient;
        shadowColor = DesignTokens.success;
        break;
      case 'bitti':
        gradient = AppTheme.completedGradient;
        shadowColor = DesignTokens.uclaBlue;
        break;
      default:
        gradient = AppTheme.pendingGradient;
        shadowColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        status,
        style: TextStyle(
          color: DesignTokens.surfacePrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}