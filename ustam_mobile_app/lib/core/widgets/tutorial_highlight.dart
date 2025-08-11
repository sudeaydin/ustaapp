import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/tutorial_provider.dart';

class TutorialHighlight extends ConsumerStatefulWidget {
  final Widget child;
  final String tutorialKey;

  const TutorialHighlight({
    super.key,
    required this.child,
    required this.tutorialKey,
  });

  @override
  ConsumerState<TutorialHighlight> createState() => _TutorialHighlightState();
}

class _TutorialHighlightState extends ConsumerState<TutorialHighlight>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  bool _wasActive = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500), // Slower pulse
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }



  void _startPulsing() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulsing() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTarget = ref.watch(tutorialProvider);
    final isActive = activeTarget == widget.tutorialKey;
    
    // Debug print
    print('TutorialHighlight ${widget.tutorialKey}: activeTarget=$activeTarget, isActive=$isActive');
    
    // Control pulsing based on active state
    if (isActive && !_wasActive) {
      print('Starting pulse for ${widget.tutorialKey}');
      _startPulsing();
    } else if (!isActive && _wasActive) {
      print('Stopping pulse for ${widget.tutorialKey}');
      _stopPulsing();
    }
    _wasActive = isActive;
    
    if (!isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                // Main glow
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4 * _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
                // Inner glow
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.6 * _glowAnimation.value),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
                // Outer glow
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2 * _glowAnimation.value),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.8 * _glowAnimation.value),
                  width: 3,
                ),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}