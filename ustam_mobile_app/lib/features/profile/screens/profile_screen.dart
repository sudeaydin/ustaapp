import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${user?['first_name']?[0] ?? 'U'}${user?['last_name']?[0] ?? 'U'}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?['email'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      user?['user_type'] == 'customer' ? 'Müşteri' : 'Usta',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            
            // Profile Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Kişisel Bilgiler',
                    subtitle: 'Ad, soyad, telefon bilgilerini düzenle',
                    onTap: () => _showInfoDialog(context, 'Kişisel Bilgiler', 'Kişisel bilgilerinizi buradan düzenleyebilirsiniz.'),
                  ),
                  _buildProfileOption(
                    icon: Icons.security,
                    title: 'Güvenlik',
                    subtitle: 'Şifre değiştir, güvenlik ayarları',
                    onTap: () => _showInfoDialog(context, 'Güvenlik', 'Şifrenizi değiştirebilir ve güvenlik ayarlarınızı yönetebilirsiniz.'),
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Bildirimler',
                    subtitle: 'Bildirim tercihlerini yönet',
                    onTap: () => _showInfoDialog(context, 'Bildirimler', 'Bildirim tercihlerinizi buradan ayarlayabilirsiniz.'),
                  ),
                  _buildProfileOption(
                    icon: Icons.payment,
                    title: 'Ödeme Yöntemleri',
                    subtitle: 'Kart bilgileri ve ödeme geçmişi',
                    onTap: () => _showInfoDialog(context, 'Ödeme Yöntemleri', 'Kart bilgilerinizi ve ödeme geçmişinizi görüntüleyebilirsiniz.'),
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Yardım ve Destek',
                    subtitle: 'SSS, iletişim, geri bildirim',
                    onTap: () => _showInfoDialog(context, 'Yardım ve Destek', 'Sık sorulan sorular ve destek bilgileri burada yer alır.'),
                  ),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: 'Hakkında',
                    subtitle: 'Uygulama sürümü ve yasal bilgiler',
                    onTap: () => _showInfoDialog(context, 'Hakkında', 'Ustam v1.0.0\n\nTürkiye\'nin en güvenilir usta bulma platformu.'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLogoutDialog(context, ref);
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Çıkış Yap',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}