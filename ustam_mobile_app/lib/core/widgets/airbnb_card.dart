import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

enum AirbnbCardType { standard, elevated, flat }

class AirbnbCard extends StatelessWidget {
  final Widget child;
  final AirbnbCardType type;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Border? border;

  const AirbnbCard({
    super.key,
    required this.child,
    this.type = AirbnbCardType.standard,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: DesignTokens.space8),
      decoration: BoxDecoration(
        color: backgroundColor ?? DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radius16),
        boxShadow: _getBoxShadow(),
        border: border,
      ),
      child: onTap != null 
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                debugPrint('🎯 AirbnbCard onTap called - RESPONSIVE VERSION');
                onTap!();
              },
              borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radius16),
              child: Container(
                padding: padding ?? DesignTokens.getEdgeInsets(all: DesignTokens.spacingCardPadding),
                child: child,
              ),
            ),
          )
        : Padding(
            padding: padding ?? DesignTokens.getEdgeInsets(all: DesignTokens.spacingCardPadding),
            child: child,
          ),
    );

    return cardWidget;
  }

  List<BoxShadow>? _getBoxShadow() {
    switch (type) {
      case AirbnbCardType.standard:
        return DesignTokens.shadowCard;
      case AirbnbCardType.elevated:
        return DesignTokens.shadowElevated;
      case AirbnbCardType.flat:
        return null;
    }
  }
}

// Specialized card components
class AirbnbListCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const AirbnbListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AirbnbCard(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(DesignTokens.space16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            DesignTokens.horizontalSpaceMD,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                if (subtitle != null) ...[
                  DesignTokens.verticalSpaceXS,
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            DesignTokens.horizontalSpaceMD,
            trailing!,
          ],
        ],
      ),
    );
  }
}

class AirbnbImageCard extends StatelessWidget {
  final Widget image;
  final Widget? title;
  final Widget? subtitle;
  final Widget? overlay;
  final VoidCallback? onTap;
  final double? height;
  final double? aspectRatio;

  const AirbnbImageCard({
    super.key,
    required this.image,
    this.title,
    this.subtitle,
    this.overlay,
    this.onTap,
    this.height,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    return AirbnbCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(DesignTokens.radius16),
              topRight: Radius.circular(DesignTokens.radius16),
            ),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: aspectRatio ?? 16 / 9,
                  child: SizedBox(
                    width: double.infinity,
                    height: height,
                    child: image,
                  ),
                ),
                if (overlay != null)
                  Positioned.fill(child: overlay!),
              ],
            ),
          ),
          
          // Content section
          if (title != null || subtitle != null)
            Padding(
              padding: DesignTokens.spacingCardPaddingInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) title!,
                  if (title != null && subtitle != null)
                    DesignTokens.verticalSpaceXS,
                  if (subtitle != null) subtitle!,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AirbnbStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AirbnbStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AirbnbCard(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(DesignTokens.space8),
              decoration: BoxDecoration(
                color: (iconColor ?? DesignTokens.primaryCoral).withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.space8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? DesignTokens.primaryCoral,
                size: 24,
              ),
            ),
            DesignTokens.horizontalSpaceMD,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DesignTokens.gray600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                DesignTokens.verticalSpaceXS,
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    color: DesignTokens.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            DesignTokens.horizontalSpaceMD,
            trailing!,
          ],
        ],
      ),
    );
  }
}