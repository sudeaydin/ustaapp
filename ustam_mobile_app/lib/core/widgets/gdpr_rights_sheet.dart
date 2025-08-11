import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GDPRRightsSheet extends StatelessWidget {
  const GDPRRightsSheet({Key? key}) : super(key: key);

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
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
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
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _exerciseRight(String rightType) {
    // TODO: Implement GDPR right exercise
    print('Exercising GDPR right: $rightType');
  }
}