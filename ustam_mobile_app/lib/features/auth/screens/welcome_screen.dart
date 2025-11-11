import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/providers/language_provider.dart';

/// iOS + Airbnb Design System Welcome Screen
/// UPDATED: Uses new DesignTokens for colors, spacing, typography
/// 🎨 TEMA AKTIF: Coral primary (#FF5A5F), iOS shadows, 16px radius
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final locale = ref.watch(languageProvider); // Unused variable

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.language_outlined,
              color: DesignTokens.gray600,
            ),
            onPressed: () {
              // Language selection logic
            },
          ),
        ],
      ),
      backgroundColor: DesignTokens.surfacePrimary,
      body: SafeArea(
        child: Padding(
          padding: DesignTokens.getEdgeInsets(all: DesignTokens.spacingScreenEdge),
          child: Column(
            children: [
              // Top section with logo and title
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo - iOS + Airbnb Design
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryCoral,
                        borderRadius: BorderRadius.circular(DesignTokens.radius24),
                        boxShadow: DesignTokens.shadowElevated,
                      ),
                      child: Icon(
                        Icons.handyman_outlined,
                        size: DesignTokens.iconSize32 * 2, // 64pt
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: DesignTokens.space24),
                    
                    // Main title - iOS Large Title Style
                    Text(
                      'UstanBurada',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: DesignTokens.gray900,
                        fontFamily: DesignTokens.fontFamilyDisplay,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: DesignTokens.space12),
                    
                    // Subtitle - iOS Body Style
                    Text(
                      'Güvenilir Usta Bulma Platformu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: DesignTokens.gray600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Bottom section with buttons
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Customer Login Button - iOS Style
                    SizedBox(
                      width: double.infinity,
                      height: DesignTokens.buttonHeightMedium,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: DesignTokens.iconSize20,
                            ),
                            const SizedBox(width: DesignTokens.space8),
                            const Text('Müşteri Girişi Yap'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: DesignTokens.space16),
                    
                    // Craftsman Login Button - Secondary Style
                    SizedBox(
                      width: double.infinity,
                      height: DesignTokens.buttonHeightMedium,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login-craftsman');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.handyman_outlined,
                              size: DesignTokens.iconSize20,
                            ),
                            const SizedBox(width: DesignTokens.space8),
                            const Text('Usta Girişi Yap'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: DesignTokens.space24),
                    
                    // Register link - Tertiary Style
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('Hesabın yok mu? Kayıt ol'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}