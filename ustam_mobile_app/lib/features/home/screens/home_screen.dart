import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isCustomer = user?['user_type'] == 'customer';

    return Scaffold(
      appBar: AppBar(
        title: Text('Merhaba, ${user?['first_name'] ?? 'Kullanıcı'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go('/profile');
                  break;
                case 'logout':
                  ref.read(authProvider.notifier).logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outlined),
                    SizedBox(width: 8),
                    Text('Profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            _buildStatsSection(isCustomer),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Hızlı İşlemler',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context, isCustomer),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            Text(
              isCustomer ? 'Son İşlerim' : 'Son Tekliflerim',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildRecentActivity(isCustomer),
            
            const SizedBox(height: 24),
            
            // Popular Categories (for customers)
            if (isCustomer) ...[
              Text(
                'Popüler Kategoriler',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildPopularCategories(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isCustomer) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: isCustomer ? 'Toplam İşlerim' : 'Toplam Tekliflerim',
            value: '12',
            icon: Icons.work_outline,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: isCustomer ? 'Aktif İşler' : 'Bekleyen Teklifler',
            value: '3',
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: isCustomer ? 'Tamamlanan' : 'Kazanılan',
            value: '9',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
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
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
            color: Colors.blue,
            onTap: () => context.push('/job-request/new'),
          ),
          _buildActionCard(
            title: 'Usta Ara',
            icon: Icons.search,
            color: Colors.green,
            onTap: () => context.go('/search'),
          ),
          _buildActionCard(
            title: 'Mesajlarım',
            icon: Icons.chat_bubble_outline,
            color: Colors.purple,
            onTap: () => context.go('/messages'),
          ),
          _buildActionCard(
            title: 'Ödeme Geçmişi',
            icon: Icons.payment,
            color: Colors.orange,
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
            color: Colors.blue,
            onTap: () => context.go('/jobs'),
          ),
          _buildActionCard(
            title: 'Yeni Teklifler',
            icon: Icons.notification_add,
            color: Colors.green,
            onTap: () => context.go('/search'),
          ),
          _buildActionCard(
            title: 'Mesajlarım',
            icon: Icons.chat_bubble_outline,
            color: Colors.purple,
            onTap: () => context.go('/messages'),
          ),
          _buildActionCard(
            title: 'Portföyüm',
            icon: Icons.photo_library_outlined,
            color: Colors.orange,
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
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

  Widget _buildRecentActivity(bool isCustomer) {
    return Column(
      children: List.generate(3, (index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                isCustomer ? Icons.work : Icons.person,
                color: Colors.blue,
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
            trailing: Chip(
              label: Text(
                ['Yeni', 'Aktif', 'Bitti'][index],
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: [Colors.orange, Colors.blue, Colors.green][index].shade100,
            ),
            onTap: () {
              // Navigate to job detail
            },
          ),
        );
      }),
    );
  }

  Widget _buildPopularCategories(BuildContext context) {
    final categories = [
      {'name': 'Elektrik', 'icon': Icons.electrical_services, 'color': Colors.yellow},
      {'name': 'Su Tesisatı', 'icon': Icons.plumbing, 'color': Colors.blue},
      {'name': 'Boyacı', 'icon': Icons.format_paint, 'color': Colors.red},
      {'name': 'Temizlik', 'icon': Icons.cleaning_services, 'color': Colors.green},
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
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
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
                    style: const TextStyle(
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
}