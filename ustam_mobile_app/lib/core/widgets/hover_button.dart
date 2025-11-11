import '../theme/design_tokens.dart';
import 'package:flutter/material.dart';

class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? hoverColor;
  final double hoverScale;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  HoverButton({
    super.key,
    required this.child,
    this.onTap,
    this.hoverColor,
    this.hoverScale = 1.05,
    this.animationDuration = const Duration(milliseconds: 200),
    this.borderRadius,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    if (!_isHovered) {
      setState(() {
        _isHovered = true;
      });
      _animationController.forward();
    }
  }

  void _onHoverEnd() {
    if (_isHovered) {
      setState(() {
        _isHovered = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverStart(),
      onExit: (_) => _onHoverEnd(),
      child: GestureDetector(
        onTapDown: (_) => _onHoverStart(),
        onTapUp: (_) => _onHoverEnd(),
        onTapCancel: () => _onHoverEnd(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(DesignTokens.radius8),
                  color: (widget.hoverColor ?? DesignTokens.primaryCoral)
                      .withOpacity(_opacityAnimation.value),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: (widget.hoverColor ?? DesignTokens.primaryCoral)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}