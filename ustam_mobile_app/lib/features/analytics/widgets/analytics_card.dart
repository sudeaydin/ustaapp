import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final String changeType; // 'positive', 'negative', 'neutral'
  final IconData icon;
  final Color color;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.changeType,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color changeColor;
    IconData changeIcon;

    switch (changeType) {
      case 'positive':
        changeColor = AppColors.success;
        changeIcon = Icons.trending_up;
        break;
      case 'negative':
        changeColor = AppColors.error;
        changeIcon = Icons.trending_down;
        break;
      default:
        changeColor = AppColors.textSecondary;
        changeIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
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
                changeIcon,
                color: changeColor,
                size: 16,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Change indicator
          Row(
            children: [
              Icon(
                changeIcon,
                color: changeColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}