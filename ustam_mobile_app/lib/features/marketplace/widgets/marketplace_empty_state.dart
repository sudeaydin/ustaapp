import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_button.dart';

class MarketplaceEmptyState extends StatelessWidget {
  const MarketplaceEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.primaryCoral.withOpacity(0.1),
                    DesignTokens.primaryCoralDark.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.circular(100),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circles
                  Positioned(
                    top: 40,
                    right: 40,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryCoral.withOpacity(0.2),
                        borderRadius: const BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 30,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryCoral.withOpacity(0.15),
                        borderRadius: const BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  
                  // Main icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryCoral.withOpacity(0.2),
                      borderRadius: const BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 50,
                      color: DesignTokens.primaryCoral,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DesignTokens.space32),
            
            // Title
            const Text(
              'Henüz İlan Yok',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DesignTokens.gray900,
              ),
            ),
            
            const SizedBox(height: DesignTokens.space12),
            
            // Description
            const Text(
              'Pazar yerinde henüz hiç iş ilanı bulunmuyor.\nİlk ilanı sen oluştur!',
              style: TextStyle(
                fontSize: 16,
                color: DesignTokens.gray600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: DesignTokens.space32),
            
            // Create listing button
            AirbnbButton(
              text: 'İlan Oluştur',
              onPressed: () {
                Navigator.pushNamed(context, '/marketplace/new');
              },
              type: AirbnbButtonType.primary,
              size: AirbnbButtonSize.large,
              icon: Icons.add_circle_outline,
            ),
            
            const SizedBox(height: DesignTokens.space16),
            
            // Secondary button
            AirbnbButton(
              text: 'Filtreleri Temizle',
              onPressed: () {
                // This will be handled by the parent widget
                Navigator.pop(context);
              },
              type: AirbnbButtonType.outline,
              size: AirbnbButtonSize.medium,
            ),
            
            const SizedBox(height: DesignTokens.space40),
            
            // Tips section
            Container(
              padding: const EdgeInsets.all(DesignTokens.space20),
              decoration: BoxDecoration(
                color: DesignTokens.primaryCoral.withOpacity(0.05),
                borderRadius: const BorderRadius.circular(DesignTokens.radius16),
                border: Border.all(
                  color: DesignTokens.primaryCoral.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryCoral.withOpacity(0.1),
                          borderRadius: const BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: DesignTokens.primaryCoral,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      const Expanded(
                        child: Text(
                          'İpuçları',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Tips list
                  _buildTip('Detaylı açıklama yazın', 'Ne iş yaptırmak istediğinizi açık şekilde belirtin'),
                  const SizedBox(height: DesignTokens.space12),
                  _buildTip('Fotoğraf ekleyin', 'Görsel malzemeler daha fazla teklif almanızı sağlar'),
                  const SizedBox(height: DesignTokens.space12),
                  _buildTip('Bütçe belirleyin', 'Gerçekçi bir bütçe aralığı ustalar için yol gösterici olur'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: DesignTokens.primaryCoral,
            borderRadius: const BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: DesignTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: DesignTokens.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}