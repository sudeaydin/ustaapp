import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

class ActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityList({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: DesignTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
          border: Border.all(color: DesignTokens.gray300),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: DesignTokens.gray600,
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(
                'Henüz aktivite bulunmuyor',
                style: TextStyle(
                  color: DesignTokens.gray600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radius12),
        border: Border.all(color: DesignTokens.gray300),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(
          color: DesignTokens.gray300,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(activity);
        },
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final message = activity['message'] as String;
    final time = activity['time'] as String;
    final amount = activity['amount'] as String?;

    return ListTile(
      contentPadding: const EdgeInsets.all(DesignTokens.space16),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getActivityColor(type).withOpacity(0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radius8),
        ),
        child: Icon(
          _getActivityIcon(type),
          color: _getActivityColor(type),
          size: 20,
        ),
      ),
      title: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: DesignTokens.gray900,
        ),
      ),
      subtitle: Text(
        time,
        style: TextStyle(
          fontSize: 12,
          color: DesignTokens.gray600,
        ),
      ),
      trailing: amount != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DesignTokens.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.success,
                ),
              ),
            )
          : null,
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'job_completed':
        return Icons.check_circle;
      case 'review_received':
      case 'review_left':
        return Icons.star;
      case 'job_started':
        return Icons.play_circle;
      case 'proposal_sent':
        return Icons.send;
      case 'proposal_received':
        return Icons.inbox;
      case 'job_posted':
        return Icons.post_add;
      case 'payment_completed':
        return Icons.payment;
      case 'quote_accepted':
        return Icons.thumb_up;
      case 'quote_rejected':
        return Icons.thumb_down;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'job_completed':
      case 'payment_completed':
      case 'quote_accepted':
        return DesignTokens.success;
      case 'review_received':
      case 'review_left':
        return DesignTokens.warning;
      case 'job_started':
      case 'proposal_sent':
        return DesignTokens.info;
      case 'proposal_received':
      case 'job_posted':
        return DesignTokens.primaryCoral;
      case 'quote_rejected':
        return DesignTokens.error;
      default:
        return DesignTokens.gray600;
    }
  }
}