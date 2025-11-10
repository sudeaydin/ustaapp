import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/services/api_service.dart';

class LegalConsentModal extends StatefulWidget {
  final String userType; // 'individual' or 'corporate'
  final VoidCallback? onAccepted;
  final VoidCallback? onRejected;

  const LegalConsentModal({
    Key? key,
    required this.userType,
    this.onAccepted,
    this.onRejected,
  }) : super(key: key);

  @override
  State<LegalConsentModal> createState() => _LegalConsentModalState();
}

class _LegalConsentModalState extends State<LegalConsentModal> {
  bool termsAccepted = false;
  bool privacyAccepted = false;
  bool cookieAccepted = false;
  bool kvkkAccepted = false;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: const Borderconst Radius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryCoral.withOpacity(0.1),
                    borderRadius: const Borderconst Radius.circular(10),
                  ),
                  child: const Icon(
                    Icons.gavel,
                    color: DesignTokens.primaryCoral,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yasal Onaylar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.gray900,
                        ),
                      ),
                      Text(
                        'Devam etmek için aşağıdaki belgeleri onaylamanız gerekiyor',
                        style: TextStyle(
                          fontSize: 14,
                          color: DesignTokens.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Consent items
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildConsentItem(
                      title: 'Kullanım Koşulları',
                      description: 'Platform kullanım şartları ve kuralları',
                      isAccepted: termsAccepted,
                      onChanged: (value) => setState(() => termsAccepted = value ?? false),
                      onViewDocument: () => _viewDocument('terms_of_service'),
                      isRequired: true,
                    ),
                    
                    _buildConsentItem(
                      title: widget.userType == 'individual' 
                          ? 'Bireysel Hesap Sözleşmesi' 
                          : 'Kurumsal Hesap Sözleşmesi',
                      description: widget.userType == 'individual'
                          ? 'Bireysel kullanıcılar için hesap sözleşmesi'
                          : 'Hizmet veren ustalar için kurumsal sözleşme',
                      isAccepted: privacyAccepted,
                      onChanged: (value) => setState(() => privacyAccepted = value ?? false),
                      onViewDocument: () => _viewDocument(
                        widget.userType == 'individual' ? 'user_agreement' : 'corporate_agreement'
                      ),
                      isRequired: true,
                    ),
                    
                    _buildConsentItem(
                      title: 'Gizlilik Politikası',
                      description: 'Kişisel verilerin işlenmesi ve gizlilik koşulları',
                      isAccepted: cookieAccepted,
                      onChanged: (value) => setState(() => cookieAccepted = value ?? false),
                      onViewDocument: () => _viewDocument('privacy_policy'),
                      isRequired: true,
                    ),
                    
                    _buildConsentItem(
                      title: 'KVKK Aydınlatma Metni',
                      description: 'Kişisel veri işleme hakları ve bilgilendirme',
                      isAccepted: kvkkAccepted,
                      onChanged: (value) => setState(() => kvkkAccepted = value ?? false),
                      onViewDocument: () => _viewDocument('kvkk_summary'),
                      isRequired: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : () {
                      widget.onRejected?.call();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.gray600,
                      side: BorderSide(color: DesignTokens.gray300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reddet'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canAccept && !isSubmitting ? _handleAccept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primaryCoral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Kabul Et'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _canAccept {
    return termsAccepted && privacyAccepted && cookieAccepted && kvkkAccepted;
  }

  Widget _buildConsentItem({
    required String title,
    required String description,
    required bool isAccepted,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onViewDocument,
    bool isRequired = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const Borderconst Radius.circular(12),
        border: Border.all(
          color: isAccepted 
              ? DesignTokens.primaryCoral.withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.gray900,
                          ),
                        ),
                        if (isRequired)
                          const Text(
                            ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: DesignTokens.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isAccepted,
                onChanged: onChanged,
                activeColor: DesignTokens.primaryCoral,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onViewDocument,
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Belgeyi Görüntüle'),
            style: TextButton.styleFrom(
              foregroundColor: DesignTokens.primaryCoral,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _viewDocument(String documentType) {
    // Navigate to document viewer
    // This would open the specific document
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('$documentType belgesi açılıyor...'),
        backgroundColor: DesignTokens.primaryCoral,
      ),
    );
  }

  Future<void> _handleAccept() async {
    if (!_canAccept) return;

    setState(() => isSubmitting = true);

    try {
      // Record consent in backend
      final consentData = {
        'terms_of_service': termsAccepted,
        'user_agreement': privacyAccepted,
        'privacy_policy': cookieAccepted,
        'kvkk_summary': kvkkAccepted,
        'user_type': widget.userType,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await ApiService().post('/legal/consent/record', consentData);

      if (response.success) {
        widget.onAccepted?.call();
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Yasal onaylar başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response.message ?? 'Onay kaydedilemedi');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }
}