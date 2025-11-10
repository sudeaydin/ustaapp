import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/job_management_utils.dart';

class JobDetailSheet extends StatelessWidget {
  final dynamic job; // Can be Map or Job object
  final String userType;
  final VoidCallback? onUpdate;

  const JobDetailSheet({
    Key? key,
    required this.job,
    required this.userType,
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job is Job ? job.title : (job['title'] ?? 'İş Detayı'),
                  style: TextStyle(
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
          const SizedBox(height: DesignTokens.space16),
                      Text(
              job is Job ? (job.description ?? '') : (job['description'] ?? ''),
            style: TextStyle(
              color: DesignTokens.gray600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
                      if ((job is Job ? job.estimatedCost : job['budget']) != null)
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 20),
                const SizedBox(width: 8),
                                  Text(
                    'Bütçe: ₺${job is Job ? job.estimatedCost : job['budget']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: DesignTokens.space24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryCoral,
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