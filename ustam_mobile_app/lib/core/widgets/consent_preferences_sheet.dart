import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConsentPreferencesSheet extends StatefulWidget {
  const ConsentPreferencesSheet({Key? key}) : super(key: key);

  @override
  State<ConsentPreferencesSheet> createState() => _ConsentPreferencesSheetState();
}

class _ConsentPreferencesSheetState extends State<ConsentPreferencesSheet> {
  bool marketingConsent = false;
  bool analyticsConsent = false;
  bool notificationConsent = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Onay Tercihleri',
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
          const SizedBox(height: 24),
          _buildConsentTile(
            'Pazarlama İletişimi',
            'Kampanya ve promosyonlar hakkında bilgilendirilmek istiyorum',
            marketingConsent,
            (value) => setState(() => marketingConsent = value),
          ),
          _buildConsentTile(
            'Analitik Veriler',
            'Uygulama deneyimini iyileştirmek için anonim veri paylaşımı',
            analyticsConsent,
            (value) => setState(() => analyticsConsent = value),
          ),
          _buildConsentTile(
            'Bildirimler',
            'Önemli güncellemeler ve mesajlar için bildirim alma',
            notificationConsent,
            (value) => setState(() => notificationConsent = value),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentTile(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _savePreferences() {
    // TODO: Save preferences to backend
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tercihleriniz kaydedildi'),
        backgroundColor: Colors.green,
      ),
    );
  }
}