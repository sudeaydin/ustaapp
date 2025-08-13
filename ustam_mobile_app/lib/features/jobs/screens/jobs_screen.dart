import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Custom 3D AppBar
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DesignTokens.surfacePrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(DesignTokens.radius12),
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          color: DesignTokens.surfacePrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'İşlerim',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.surfacePrimary,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: DesignTokens.surfacePrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(DesignTokens.radius12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.filter_list, color: DesignTokens.surfacePrimary),
                          onPressed: () {
                            // Show filter options
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Body Content
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.space16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowDark,
                  offset: const Offset(6, 6),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppTheme.shadowLight,
                  offset: const Offset(-6, -6),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Elektrik Tesisatı İşi #${index + 1}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      _buildStatusChip(['Yeni', 'Devam Ediyor', 'Tamamlandı', 'İptal'][index % 4]),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Ev elektrik tesisatı kontrolü ve arıza giderme işi.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('Mehmet K.', style: TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(width: DesignTokens.space16),
                      Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('İstanbul', style: TextStyle(color: AppTheme.textSecondary)),
                      const Spacer(),
                      Text(
                        '₺${[1500, 2000, 1800, 1200][index % 4]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('${DateTime.now().day + index}.${DateTime.now().month}.2024', style: TextStyle(color: AppTheme.textSecondary)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(DesignTokens.radius12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            // Navigate to job detail page
                            _showJobDetail(context, index);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radius12),
                            ),
                          ),
                          child: const Text(
                            'Detayları Gör',
                            style: TextStyle(
                              color: DesignTokens.surfacePrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: DesignTokens.surfacePrimary.withOpacity(0.8),
              blurRadius: 8,
              offset: const Offset(-3, -3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Add new job request
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Yeni iş talebi özelliği yakında!')),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: DesignTokens.surfacePrimary, size: 28),
        ),
      ),
    );
  }

  void _showJobDetail(BuildContext context, int index) {
    final jobs = [
      {
        'title': 'Elektrik Tesisatı Sorunu',
        'description': 'Evimde elektrik kesintisi var, acil müdahale gerekiyor.',
        'price': '500-800 TL',
        'location': 'Kadıköy, İstanbul',
        'date': '15.12.2024',
        'status': 'Yeni'
      },
      {
        'title': 'Su Tesisatı Tamiri',
        'description': 'Mutfak lavabosunda su kaçağı mevcut.',
        'price': '300-500 TL',
        'location': 'Beşiktaş, İstanbul',
        'date': '14.12.2024',
        'status': 'Devam Ediyor'
      },
      {
        'title': 'Daire Boyası',
        'description': '2+1 daire tamamen boyanacak.',
        'price': '2000-3000 TL',
        'location': 'Şişli, İstanbul',
        'date': '13.12.2024',
        'status': 'Tamamlandı'
      },
    ];

    final job = jobs[index % jobs.length];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job['title']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📝 ${job['description']}'),
            const SizedBox(height: 8),
            Text('Bütçe: ${job['price']}'),
            const SizedBox(height: 8),
            Text('📍 Konum: ${job['location']}'),
            const SizedBox(height: 8),
            Text('📅 Tarih: ${job['date']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Durum: '),
                _buildStatusChip(job['status']!),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İş detayları güncellendi')),
              );
            },
            child: const Text('İşlem Yap'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    LinearGradient gradient;
    IconData icon;
    
    switch (status) {
      case 'Yeni':
        gradient = AppTheme.pendingGradient;
        icon = Icons.new_releases;
        break;
      case 'Devam Ediyor':
        gradient = AppTheme.activeGradient;
        icon = Icons.trending_up;
        break;
      case 'Tamamlandı':
        gradient = AppTheme.completedGradient;
        icon = Icons.check_circle;
        break;
      case 'İptal':
        gradient = AppTheme.cancelledGradient;
        icon = Icons.cancel;
        break;
      default:
        gradient = const LinearGradient(colors: [Colors.grey, Colors.grey]);
        icon = Icons.help;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: DesignTokens.surfacePrimary),
            const SizedBox(width: 4),
            Text(
              status,
              style: const TextStyle(
                fontSize: 12, 
                color: DesignTokens.surfacePrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}