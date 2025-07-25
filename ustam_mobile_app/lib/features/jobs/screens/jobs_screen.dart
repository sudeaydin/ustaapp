import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                      Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Mehmet K.'),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('İstanbul'),
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
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${DateTime.now().day + index}.${DateTime.now().month}.2024'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Navigate to job detail page
                          _showJobDetail(context, index);
                        },
                        child: const Text('Detayları Gör'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new job request
        },
        child: const Icon(Icons.add),
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
            Text('💰 Bütçe: ${job['price']}'),
            const SizedBox(height: 8),
            Text('📍 Konum: ${job['location']}'),
            const SizedBox(height: 8),
            Text('📅 Tarih: ${job['date']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('📊 Durum: '),
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
    Color color;
    switch (status) {
      case 'Yeni':
        color = Colors.orange;
        break;
      case 'Devam Ediyor':
        color = Colors.blue;
        break;
      case 'Tamamlandı':
        color = Colors.green;
        break;
      case 'İptal':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}