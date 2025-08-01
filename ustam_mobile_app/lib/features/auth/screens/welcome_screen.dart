import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getGradient(
            AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),
                
                // Logo - Splash ile aynı tasarım
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow effect
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentYellow.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(80),
                      ),
                    ),
                    // Main logo container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppColors.getGradient([
                          AppColors.cardBackground,
                          AppColors.surfaceColor,
                        ]),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.accentYellow.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          AppColors.getElevatedShadow(blurRadius: 25),
                          BoxShadow(
                            color: AppColors.accentYellow.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Cartoon-style tool icon
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: AppColors.getGradient(AppColors.warningGradient),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentYellow.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.engineering_rounded,
                              size: 35,
                              color: AppColors.textWhite,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Main title with shadow effect
                Stack(
                  children: [
                                         // Shadow text
                     Text(
                       'Ustam',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3
                          ..color = AppColors.textWhite.withOpacity(0.3),
                        letterSpacing: 2,
                      ),
                    ),
                                         // Main text
                     const Text(
                       'Ustam',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Subtitle with modern styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.textWhite.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Usta bul, işini yaptır',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Giriş Butonları - Modern Design
                Column(
                  children: [
                    // Müşteri Giriş Butonu
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.cardBackground, AppColors.surfaceColor],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [AppColors.getElevatedShadow()],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person_rounded, size: 20, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Müşteri Girişi',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Usta Giriş Butonu
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.textWhite.withOpacity(0.3), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login-craftsman');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.textWhite.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.engineering_rounded, size: 20, color: AppColors.textWhite),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Usta Girişi',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Alt Bilgi
                const Text(
                  'Hizmet şartları ve gizlilik politikası',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}