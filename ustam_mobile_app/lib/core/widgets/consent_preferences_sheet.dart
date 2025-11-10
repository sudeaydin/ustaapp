import '../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import '../utils/legal_utils.dart';

class ConsentPreferencesSheet extends StatefulWidget {
  const ConsentPreferencesSheet({Key? key}) : super(key: key);

  @override
  State<ConsentPreferencesSheet> createState() => _ConsentPreferencesSheetState();
}

class _ConsentPreferencesSheetState extends State<ConsentPreferencesSheet> {
  bool _marketingConsent = false;
  bool _analyticsConsent = false;
  bool _functionalConsent = true;
  bool _performanceConsent = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
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
          const SizedBox(height: DesignTokens.space24),
          _buildConsentTile(
            'Pazarlama İletişimi',
            'Kampanya ve promosyonlar hakkında bilgilendirilmek istiyorum',
            _marketingConsent,
            (value) => setState(() => _marketingConsent = value),
          ),
          _buildConsentTile(
            'Analitik Veriler',
            'Uygulama deneyimini iyileştirmek için anonim veri paylaşımı',
            _analyticsConsent,
            (value) => setState(() => _analyticsConsent = value),
          ),
          _buildConsentTile(
            'Fonksiyonel Özellikler',
            'Temel uygulama işlevleri ve kişiselleştirme',
            _functionalConsent,
            (value) => setState(() => _functionalConsent = value),
          ),
          _buildConsentTile(
            'Performans İzleme',
            'Uygulama performansını izleme ve iyileştirme',
            _performanceConsent,
            (value) => setState(() => _performanceConsent = value),
          ),
          const SizedBox(height: DesignTokens.space24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryCoral,
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
        padding: const EdgeInsets.all(DesignTokens.space16),
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
                      color: DesignTokens.gray600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: DesignTokens.primaryCoral,
            ),
          ],
        ),
      ),
    );
  }

  void _savePreferences() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Tercihler kaydediliyor...'),
            ],
          ),
        ),
      );

      // Save preferences to backend via LegalUtils
      await LegalUtils.recordConsent({
        'analytics': _analyticsConsent,
        'marketing': _marketingConsent,
        'functional': _functionalConsent,
        'performance': _performanceConsent,
      });

      // Close loading dialog
      Navigator.of(context).pop();

      // Close preferences sheet
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tercihleriniz başarıyla kaydedildi'),
          backgroundColor: DesignTokens.primaryCoral,
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tercihler kaydedilemedi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}