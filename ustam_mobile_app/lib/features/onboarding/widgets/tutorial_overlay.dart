import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';

class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String? targetKey;
  final Alignment alignment;
  final Widget? customContent;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    this.targetKey,
    this.alignment = Alignment.center,
    this.customContent,
    this.onNext,
    this.onSkip,
  });
}

class TutorialOverlay extends ConsumerStatefulWidget {
  final List<TutorialStep> steps;
  final String userType;
  final VoidCallback onComplete;
  final bool showOnFirstLaunch;

  const TutorialOverlay({
    Key? key,
    required this.steps,
    required this.userType,
    required this.onComplete,
    this.showOnFirstLaunch = true,
  }) : super(key: key);

  @override
  ConsumerState<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends ConsumerState<TutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _checkAndShowTutorial();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowTutorial() async {
    if (!widget.showOnFirstLaunch) return;

    final prefs = await SharedPreferences.getInstance();
    
    // ALWAYS SHOW FOR TESTING - Remove this line for production
    await prefs.remove('onboarding_completed_${widget.userType}');
    
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed_${widget.userType}') ?? false;
    
    if (!hasCompletedOnboarding && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isVisible = true;
      });
      _animationController.forward();
    }
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed_${widget.userType}', true);
    
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        widget.onComplete();
      }
    });
  }

  Widget _buildTutorialCard() {
    final currentStepData = widget.steps[_currentStep];
    final locale = ref.watch(languageProvider);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Stack(
          children: [
            // Highlight target if exists
            if (currentStepData.targetKey != null)
              _buildTargetHighlight(currentStepData.targetKey!),

            // Tutorial card
            Align(
              alignment: currentStepData.alignment,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress indicator
                            Row(
                              children: [
                                Text(
                                  '${'step'.tr(locale)} ${_currentStep + 1}/${widget.steps.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: _skipTutorial,
                                  child: Text('skip'.tr(locale)),
                                ),
                              ],
                            ),
                            
                            // Progress bar
                            LinearProgressIndicator(
                              value: (_currentStep + 1) / widget.steps.length,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Content
                            if (currentStepData.customContent != null)
                              currentStepData.customContent!
                            else
                              Column(
                                children: [
                                  Text(
                                    currentStepData.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    currentStepData.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            
                            const SizedBox(height: 24),
                            
                            // Navigation buttons
                            Row(
                              children: [
                                if (_currentStep > 0)
                                  TextButton(
                                    onPressed: _previousStep,
                                    child: Text('previous'.tr(locale)),
                                  )
                                else
                                  const SizedBox.shrink(),
                                
                                const Spacer(),
                                
                                // Step indicators
                                Row(
                                  children: List.generate(
                                    widget.steps.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index == _currentStep
                                            ? AppColors.primary
                                            : index < _currentStep
                                                ? AppColors.primary.withOpacity(0.5)
                                                : AppColors.border,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const Spacer(),
                                
                                ElevatedButton(
                                  onPressed: _nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    _currentStep == widget.steps.length - 1
                                        ? 'finish'.tr(locale)
                                        : 'next'.tr(locale),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetHighlight(String targetKey) {
    return Positioned(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return _buildTutorialCard();
  }
}

// Tutorial steps for different user types
class TutorialSteps {
  static List<TutorialStep> getCustomerSteps() {
    return [
      TutorialStep(
        id: 'welcome',
        title: 'UstamApp\'e Hoş Geldiniz! 👋',
        description: 'Size platformu tanıtmak ve nasıl kullanacağınızı göstermek istiyoruz.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        id: 'dashboard',
        title: 'Dashboard\'unuz 📊',
        description: 'Buradan tüm işlerinizi, tekliflerinizi ve mesajlarınızı takip edebilirsiniz.',
        targetKey: 'dashboard_tab',
        alignment: Alignment.bottomCenter,
      ),
      TutorialStep(
        id: 'search',
        title: 'Usta Arayın 🔍',
        description: 'İhtiyacınız olan ustayı kategorilere göre arayabilir, filtreler kullanabilir ve detaylarını inceleyebilirsiniz.',
        targetKey: 'search_tab',
        alignment: Alignment.bottomCenter,
      ),
      TutorialStep(
        id: 'quote_request',
        title: 'Teklif İsteyin 💬',
        description: 'Beğendiğiniz ustadan teklif isteyebilir, iş detaylarınızı paylaşabilir ve fiyat alabilirsiniz.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        id: 'messages',
        title: 'Mesajlaşma 📱',
        description: 'Ustalarla doğrudan mesajlaşabilir, teklif detaylarını konuşabilir ve iş sürecini takip edebilirsiniz.',
        targetKey: 'messages_tab',
        alignment: Alignment.bottomCenter,
      ),
      TutorialStep(
        id: 'profile',
        title: 'Profiliniz 👤',
        description: 'Profil bilgilerinizi güncelleyebilir, geçmiş işlerinizi görebilir ve hesap ayarlarınızı yönetebilirsiniz.',
        targetKey: 'profile_tab',
        alignment: Alignment.bottomCenter,
      ),
      TutorialStep(
        id: 'complete',
        title: 'Hazırsınız! 🎉',
        description: 'Artık UstamApp\'i kullanmaya hazırsınız! İhtiyacınız olan ustayı bulun ve işinizi halledin.',
        alignment: Alignment.center,
      ),
    ];
  }

  static List<TutorialStep> getCraftsmanSteps() {
    return [
      TutorialStep(
        id: 'welcome',
        title: 'Usta Paneline Hoş Geldiniz! 🔨',
        description: 'UstamApp usta paneline hoş geldiniz! İşinizi büyütmenize yardımcı olacağız.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        id: 'dashboard',
        title: 'Usta Dashboard\'u 📈',
        description: 'Buradan gelen talepleri, aktif işlerinizi, kazançlarınızı ve performansınızı takip edebilirsiniz.',
        targetKey: 'dashboard_tab',
        alignment: Alignment.bottomCenter,
      ),
      TutorialStep(
        id: 'business_profile',
        title: 'İşletme Profiliniz 🏢',
        description: 'İşletme bilgilerinizi, portfolyonuzu, hizmetlerinizi ve çalışma saatlerinizi buradan yönetebilirsiniz.',
        targetKey: 'profile_tab',
        alignment: Alignment.bottomCenter,
      ),
      TutorialStep(
        id: 'quote_requests',
        title: 'Teklif Talepleri 📋',
        description: 'Müşteri taleplerine teklif verebilir, detay isteyebilir, kabul edebilir veya reddedebilirsiniz.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        id: 'job_management',
        title: 'İş Takibi 🔧',
        description: 'Kabul ettiğiniz işleri takip edebilir, malzeme listesi oluşturabilir, zaman kaydı tutabilir ve ilerleme raporlayabilirsiniz.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        id: 'messages',
        title: 'Müşteri İletişimi 💬',
        description: 'Müşterilerle doğrudan mesajlaşabilir, iş detaylarını konuşabilir ve anlık güncelleme verebilirsiniz.',
        targetKey: 'messages_tab',
        alignment: Alignment.bottomCenter,
      ),
      TutorialStep(
        id: 'analytics',
        title: 'Performans Analizi 📊',
        description: 'İş performansınızı, müşteri memnuniyetinizi, kazançlarınızı ve trend analizlerini görebilirsiniz.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        id: 'complete',
        title: 'İşinizi Büyütün! 🚀',
        description: 'Artık UstamApp\'i tam olarak kullanmaya hazırsınız! Müşteri taleplerini alın ve işinizi büyütün.',
        alignment: Alignment.center,
      ),
    ];
  }
}

class TutorialManager extends ConsumerWidget {
  final Widget child;
  final String userType;

  const TutorialManager({
    Key? key,
    required this.child,
    required this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child,
        TutorialOverlay(
          steps: userType == 'customer' 
              ? TutorialSteps.getCustomerSteps()
              : TutorialSteps.getCraftsmanSteps(),
          userType: userType,
          onComplete: () {
            // Tutorial completed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  userType == 'customer' 
                      ? 'Hoş geldiniz! Artık usta aramaya başlayabilirsiniz.'
                      : 'Hoş geldiniz! Artık teklif almaya başlayabilirsiniz.',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
      ],
    );
  }
}

// Tutorial trigger widget for manual testing
class TutorialTrigger extends ConsumerWidget {
  final String userType;

  const TutorialTrigger({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.small(
      onPressed: () async {
        // Reset onboarding for testing
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('onboarding_completed_$userType');
        
        // Show tutorial overlay
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => TutorialOverlay(
            steps: userType == 'customer' 
                ? TutorialSteps.getCustomerSteps()
                : TutorialSteps.getCraftsmanSteps(),
            userType: userType,
            showOnFirstLaunch: false,
            onComplete: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.help_outline, color: Colors.white),
      tooltip: 'Tutorial\'ı Tekrar Göster',
    );
  }
}