import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

class CreateAppointmentSheet extends StatelessWidget {
  final String userType;
  final DateTime? selectedDate;
  final VoidCallback? onAppointmentCreated;

  const CreateAppointmentSheet({
    super.key,
    required this.userType,
    this.selectedDate,
    this.onAppointmentCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Padding(
      padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            const Text(
              'Randevu Oluştur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Placeholder content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 64,
                      color: DesignTokens.primaryCoral.withOpacity(0.7),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    Text(
                      'Randevu Oluşturma',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.primaryCoral,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu özellik çok yakında!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (selectedDate != null) ...[
 SizedBox(height: DesignTokens.space16),
                      Text(
                        'Seçilen tarih: ${_formatDate(selectedDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}