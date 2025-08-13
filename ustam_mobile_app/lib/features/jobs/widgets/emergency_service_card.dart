import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/job_management_utils.dart';

class EmergencyServiceCard extends StatelessWidget {
  final dynamic emergency; // Can be Map or EmergencyService object
  final VoidCallback? onRequestEmergency;
  final VoidCallback? onUpdate;

  const EmergencyServiceCard({
    Key? key,
    this.emergency,
    this.onRequestEmergency,
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: DesignTokens.error.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.emergency,
                  color: DesignTokens.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Acil Servis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Acil durumlarda 7/24 hizmet veren ustalarımızla iletişime geçin.',
              style: TextStyle(
                color: DesignTokens.gray600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRequestEmergency,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.error,
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 20),
                    SizedBox(width: 8),
                    Text('Acil Servis Çağır'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}