import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/airbnb_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Usta Bul',
      subtitle: 'İhtiyacınız olan ustayı kolayca bulun',
      description: 'Deneyimli ve güvenilir ustalar ile tanışın. İşinizi profesyonel ellere teslim edin.',
      icon: Icons.search_rounded,
      color: DesignTokens.uclaBlue,
    ),
    OnboardingPage(
      title: 'Teklif Al',
      subtitle: 'Hızlı ve uygun fiyatlı teklifler',
      description: 'Birden fazla ustadan teklif alın, en uygun fiyatı seçin.',
      icon: Icons.request_quote_rounded,
      color: DesignTokens.nonPhotoBlue,
    ),
    OnboardingPage(
      title: 'Güvenle Çalış',
      subtitle: 'Güvenli ve kaliteli hizmet',
      description: 'Değerlendirmeler ve referanslar ile güvenle çalışın.',
      icon: Icons.verified_rounded,
      color: DesignTokens.primaryCoral,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Atla',
                      style: TextStyle(
                        color: DesignTokens.gray600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(DesignTokens.space24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container - Modern & Professional
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: DesignTokens.getGradient([
                              page.color.withOpacity(0.1),
                              page.color.withOpacity(0.05),
                            ]),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(
                              color: page.color.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              DesignTokens.getElevatedShadow(blurRadius: 20),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 70,
                            color: page.color,
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Title
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.gray900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: DesignTokens.space16),
                        
                        // Subtitle
                        Text(
                          page.subtitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: DesignTokens.space24),
                        
                        // Description
                        Text(
                          page.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: DesignTokens.textLight,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page Indicator & Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Page Dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? DesignTokens.uclaBlue
                              : DesignTokens.nonPhotoBlue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Next Button - Modern Design
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: DesignTokens.getGradient(DesignTokens.primaryCoralGradient),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.uclaBlue.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _nextPage,
                      icon: Icon(
                        _currentPage == _pages.length - 1 
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: DesignTokens.surfacePrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}