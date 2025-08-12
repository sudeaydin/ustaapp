import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

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
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.cardBorderRadius),
        boxShadow: _getBoxShadow(),
        border: border,
      ),
      child: onTap != null 
        ? CupertinoButton(
            onPressed: () {
              print('🎯 AirbnbCard onTap called');
              onTap!();
            },
            padding: EdgeInsets.zero,
            minSize: 0,
            child: Container(
              padding: padding ?? AppSpacing.cardPaddingInsets,
              child: child,
            ),
          )
        : Padding(
            padding: padding ?? AppSpacing.cardPaddingInsets,
            child: child,
          ),
    );

    return cardWidget;
  }

  List<BoxShadow>? _getBoxShadow() {
    switch (type) {
      case AirbnbCardType.standard:
        return AppSpacing.cardShadow;
      case AirbnbCardType.elevated:
        return AppSpacing.elevatedShadow;
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
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            AppSpacing.horizontalSpaceMD,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                if (subtitle != null) ...[
                  AppSpacing.verticalSpaceXS,
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            AppSpacing.horizontalSpaceMD,
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
              topLeft: Radius.circular(AppSpacing.cardBorderRadius),
              topRight: Radius.circular(AppSpacing.cardBorderRadius),
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
              padding: AppSpacing.cardPaddingInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) title!,
                  if (title != null && subtitle != null)
                    AppSpacing.verticalSpaceXS,
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
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            AppSpacing.horizontalSpaceMD,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                AppSpacing.verticalSpaceXS,
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            AppSpacing.horizontalSpaceMD,
            trailing!,
          ],
        ],
      ),
    );
  }
}