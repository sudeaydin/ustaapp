import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_card.dart';

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
        changeColor = DesignTokens.success;
        changeIcon = Icons.trending_up;
        break;
      case 'negative':
        changeColor = DesignTokens.error;
        changeIcon = Icons.trending_down;
        break;
      default:
        changeColor = DesignTokens.gray600;
        changeIcon = Icons.trending_flat;
    }

    return AirbnbCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
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
                  borderRadius: BorderRadius.circular(DesignTokens.radius8),
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
              color: DesignTokens.gray600,
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
              color: DesignTokens.gray900,
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