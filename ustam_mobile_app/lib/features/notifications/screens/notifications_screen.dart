import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text('Tümünü Okundu İşaretle'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          final isRead = index > 5;
          return Container(
            color: isRead ? null : Colors.blue.shade50,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isRead ? Colors.grey.shade300 : Colors.blue,
                child: Icon(
                  [Icons.work, Icons.message, Icons.payment, Icons.star][index % 4],
                  color: isRead ? Colors.grey : Colors.white,
                ),
              ),
              title: Text(
                [
                  'Yeni iş talebi aldınız',
                  'Yeni mesajınız var',
                  'Ödeme tamamlandı',
                  'Yeni değerlendirme'
                ][index % 4],
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Bildirim detay metni burada görünecek...',
                style: TextStyle(
                  color: isRead ? Colors.grey : Colors.black87,
                ),
              ),
              trailing: Text(
                '${index + 1}s önce',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                // Mark as read and navigate
              },
            ),
          );
        },
      ),
    );
  }
}