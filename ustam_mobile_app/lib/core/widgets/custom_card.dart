import '../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

enum CardType { elevated, flat, outlined }

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardType type;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.type = CardType.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadiusValue = borderRadius ?? AppConfig.defaultBorderRadius;
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(DesignTokens.space16),
      decoration: _getDecoration(borderRadiusValue),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        child: cardContent,
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: cardContent,
    );
  }

  BoxDecoration _getDecoration(double borderRadiusValue) {
    switch (type) {
      case CardType.elevated:
        return BoxDecoration(
          color: backgroundColor ?? DesignTokens.surfacePrimary,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          boxShadow: [
            DesignTokens.getCardShadow(blurRadius: elevation ?? AppConfig.cardElevation * 4),
          ],
        );
      case CardType.flat:
        return BoxDecoration(
          color: backgroundColor ?? DesignTokens.surfacePrimary,
          borderRadius: BorderRadius.circular(borderRadiusValue),
        );
      case CardType.outlined:
        return BoxDecoration(
          color: backgroundColor ?? DesignTokens.surfacePrimary,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          border: Border.all(
            color: DesignTokens.nonPhotoBlue.withOpacity(0.3),
            width: 1,
          ),
        );
    }
  }
}

// Specialized card variants
class ProfileCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      type: CardType.elevated,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      onTap: onTap,
      child: child,
    );
  }
}

class MessageCard extends StatelessWidget {
  final Widget child;
  final bool isOwn;
  final VoidCallback? onTap;

  const MessageCard({
    super.key,
    required this.child,
    this.isOwn = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      type: CardType.flat,
      backgroundColor: isOwn 
          ? DesignTokens.primaryCoral.withOpacity(0.1)
          : DesignTokens.surfacePrimary,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(
        left: isOwn ? 50 : 0,
        right: isOwn ? 0 : 50,
        bottom: 8,
      ),
      onTap: onTap,
      child: child,
    );
  }
}

class CraftsmanCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CraftsmanCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      type: CardType.elevated,
      padding: const EdgeInsets.all(DesignTokens.space16),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      onTap: onTap,
      child: child,
    );
  }
}