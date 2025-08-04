import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation - Cartoon Style
                AnimatedBuilder(
                  animation: _logoScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow effect
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accentYellow.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(90),
                            ),
                          ),
                          // Main logo container
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: AppColors.getGradient([
                                AppColors.cardBackground,
                                AppColors.surfaceColor,
                              ]),
                              borderRadius: BorderRadius.circular(35),
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
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.getGradient(AppColors.warningGradient),
                                    borderRadius: BorderRadius.circular(20),
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
                                    size: 40,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // App Title Animation - Modern & Cartoon
                AnimatedBuilder(
                  animation: _textOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          // Main title with shadow effect
                          Stack(
                            children: [
                                                             // Shadow text
                               Text(
                                 'ustam',
                                style: TextStyle(
                                  fontSize: 46,
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
                                 'ustam',
                                 style: TextStyle(
                                   fontSize: 46,
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
                          const SizedBox(height: 16),
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
                                fontSize: 16,
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 80),
                
                // Loading Indicator - Modern Style
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.textWhite.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}