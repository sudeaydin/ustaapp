import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/utils/job_management_utils.dart';

class JobCard extends StatelessWidget {
  final dynamic job; // Can be Map or Job object
  final String userType;
  final VoidCallback? onTap;
  final VoidCallback? onUpdate;

  const JobCard({
    Key? key,
    required this.job,
    required this.userType,
    this.onTap,
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle both Map and Job object
    final String status = job is Job ? job.status.name : (job['status'] ?? 'pending');
    final String priority = job is Job ? job.priority.name : (job['priority'] ?? 'normal');
    
    return AirbnbCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
      child: const Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job is Job ? job.title : (job['title'] ?? 'İsimsiz İş'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job is Job ? (job.description ?? '') : (job['description'] ?? ''),
                style: TextStyle(
                  color: DesignTokens.gray600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (priority == 'high')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DesignTokens.error.withOpacity(0.1),
                        borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
                      ),
                      child: Text(
                        'Acil',
                        style: TextStyle(
                          color: DesignTokens.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if ((job is Job ? job.estimatedCost : job['budget']) != null)
                    Text(
                      '₺${job is Job ? job.estimatedCost : job['budget']}',
                      style: TextStyle(
                        color: DesignTokens.success,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
      case 'completed':
        color = DesignTokens.success;
        text = 'Tamamlandı';
        break;
      case 'in_progress':
        color = DesignTokens.primaryCoral;
        text = 'Devam Ediyor';
        break;
      case 'pending':
        color = DesignTokens.warning;
        text = 'Beklemede';
        break;
      case 'cancelled':
        color = DesignTokens.error;
        text = 'İptal';
        break;
      default:
        color = DesignTokens.textMuted;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
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