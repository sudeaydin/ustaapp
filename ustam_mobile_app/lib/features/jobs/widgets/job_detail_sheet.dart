import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class JobDetailSheet extends StatelessWidget {
  final Map<String, dynamic> job;
  final String userType;

  const JobDetailSheet({
    Key? key,
    required this.job,
    required this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job['title'] ?? 'İş Detayı',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            job['description'] ?? '',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          if (job['budget'] != null)
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Bütçe: ₺${job['budget']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kapat'),
            ),
          ),
        ],
      ),
    );
  }
}