import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WarrantyCard extends StatelessWidget {
  final Map<String, dynamic> warranty;
  final Map<String, dynamic>? job;
  final String userType;
  final VoidCallback? onUpdate;

  const WarrantyCard({
    Key? key,
    required this.warranty,
    this.job,
    required this.userType,
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = warranty['status'] ?? 'active';
    final expiryDate = warranty['expiry_date'];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Garanti Belgesi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              warranty['description'] ?? 'Garanti açıklaması mevcut değil',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (expiryDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bitiş: $expiryDate',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Show warranty details
                    },
                    child: const Text('Detayları Gör'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: status == 'active' ? () {
                      // File warranty claim
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Talep Oluştur'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = AppColors.success;
        text = 'Aktif';
        break;
      case 'expired':
        color = AppColors.error;
        text = 'Süresi Dolmuş';
        break;
      case 'claimed':
        color = AppColors.warning;
        text = 'Talep Edildi';
        break;
      default:
        color = AppColors.textMuted;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}