import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UserAgreementModal extends StatelessWidget {
  const UserAgreementModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kullanıcı Sözleşmesi'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UstamApp Kullanıcı Sözleşmesi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.primaryCoral,
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              const Text(
                '1. GENEL HÜKÜMLER\n\n'
                'Bu sözleşme, UstamApp platformunu kullanan tüm kullanıcılar için geçerlidir.\n\n'
                '2. KULLANICI YÜKÜMLÜLÜKLERİ\n\n'
                '- Doğru ve güncel bilgi sağlamak\n'
                '- Platform kurallarına uymak\n'
                '- Diğer kullanıcılara saygılı davranmak\n\n'
                '3. PLATFORM KURALLARI\n\n'
                '- Yanıltıcı bilgi paylaşmak yasaktır\n'
                '- Spam ve taciz tolere edilmez\n'
                '- Fikri mülkiyet haklarına saygı gösterilmelidir\n\n'
                '4. GİZLİLİK VE GÜVENLİK\n\n'
                'Kişisel verileriniz KVKK kapsamında korunmaktadır.\n\n'
                '5. ÖDEME VE FATURALANDIRMA\n\n'
                'Tüm ödemeler güvenli kanallardan işlenir.\n\n'
                '6. SORUMLULUK SINIRLAMALARI\n\n'
                'Platform, kullanıcılar arası anlaşmazlıklarda aracı rolü üstlenir.\n\n'
                '7. SÖZLEşME DEĞİşİKLİKLERİ\n\n'
                'Bu sözleşme önceden bildirimle güncellenebilir.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Reddet'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignTokens.primaryCoral,
            foregroundColor: Colors.white,
          ),
          child: const Text('Kabul Et'),
        ),
      ],
    );
  }
}