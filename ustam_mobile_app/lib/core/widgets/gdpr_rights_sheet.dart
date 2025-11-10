import '../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import '../utils/legal_utils.dart';

class GDPRRightsSheet extends StatefulWidget {
  const GDPRRightsSheet({Key? key}) : super(key: key);

  @override
  State<GDPRRightsSheet> createState() => _GDPRRightsSheetState();
}

class _GDPRRightsSheetState extends State<GDPRRightsSheet> {
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
                  'KVKK Hakları',
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
          _buildRightTile(
            Icons.visibility,
            'Veri Görme Hakkı',
            'Hangi kişisel verilerinizin işlendiğini öğrenin',
            () => _exerciseRight('data_access'),
          ),
          _buildRightTile(
            Icons.edit,
            'Düzeltme Hakkı',
            'Yanlış veya eksik verilerinizi düzeltin',
            () => _exerciseRight('data_correction'),
          ),
          _buildRightTile(
            Icons.delete,
            'Silme Hakkı',
            'Verilerinizin silinmesini talep edin',
            () => _exerciseRight('data_deletion'),
          ),
          _buildRightTile(
            Icons.download,
            'Taşınabilirlik Hakkı',
            'Verilerinizi indirin veya başka platforma taşıyın',
            () => _exerciseRight('data_portability'),
          ),
          _buildRightTile(
            Icons.block,
            'İşlemeyi Durdurma Hakkı',
            'Belirli veri işleme faaliyetlerini durdurun',
            () => _exerciseRight('processing_restriction'),
          ),
          const SizedBox(height: DesignTokens.space16),
        ],
      ),
    );
  }

  Widget _buildRightTile(
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: DesignTokens.primaryCoral),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: DesignTokens.gray600,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _exerciseRight(String rightType) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('İşlem gerçekleştiriliyor...'),
            ],
          ),
        ),
      );

      // Call the legal utils to exercise the right
      switch (rightType) {
        case 'data_access':
        case 'data_export':
          await LegalUtils.requestDataExport();
          break;
        case 'data_deletion':
        case 'account_deletion':
          await LegalUtils.requestAccountDeletion();
          break;
        case 'data_portability':
          await LegalUtils.requestDataExport(); // Same as data export
          break;
        case 'data_correction':
          // Navigate to profile edit
          Navigator.of(context).pushNamed('/profile');
          return; // Don't show success message for navigation
        case 'processing_restriction':
          // Show info about contacting support
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: const Text('Veri işlemeyi durdurma talebi için kvkk@ustam.app adresine başvurun.'),
              backgroundColor: Colors.blue,
            ),
          );
          return;
        default:
          throw Exception('Unknown right type: $rightType');
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('GDPR hakkınız başarıyla talep edildi. E-posta adresinizi kontrol edin.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem gerçekleştirilemedi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}