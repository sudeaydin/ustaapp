import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum AirbnbButtonType { primary, secondary, outline, text }
enum AirbnbButtonSize { small, medium, large }

class AirbnbButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AirbnbButtonType type;
  final AirbnbButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconRight;

  const AirbnbButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AirbnbButtonType.primary,
    this.size = AirbnbButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: _buildButtonContent(),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AirbnbButtonSize.small:
        return 36;
      case AirbnbButtonSize.medium:
        return 48;
      case AirbnbButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AirbnbButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AirbnbButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AirbnbButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = size == AirbnbButtonSize.small 
        ? AppTypography.buttonTextSmall 
        : AppTypography.buttonText;
    
    return baseStyle.copyWith(
      color: _getTextColor(),
    );
  }

  Color _getTextColor() {
    if (onPressed == null) return AppColors.textMuted;
    
    switch (type) {
      case AirbnbButtonType.primary:
        return AppColors.textWhite;
      case AirbnbButtonType.secondary:
        return AppColors.textWhite;
      case AirbnbButtonType.outline:
        return AppColors.primary;
      case AirbnbButtonType.text:
        return AppColors.primary;
    }
  }

  Color _getBackgroundColor() {
    if (onPressed == null) return AppColors.buttonDisabled;
    
    switch (type) {
      case AirbnbButtonType.primary:
        return AppColors.primary;
      case AirbnbButtonType.secondary:
        return AppColors.secondary;
      case AirbnbButtonType.outline:
        return Colors.transparent;
      case AirbnbButtonType.text:
        return Colors.transparent;
    }
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getTextColor(),
      disabledBackgroundColor: AppColors.buttonDisabled,
      disabledForegroundColor: AppColors.textMuted,
      elevation: _getElevation(),
      shadowColor: _getShadowColor(),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.buttonBorderRadiusGeometry,
        side: _getBorderSide(),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  double _getElevation() {
    if (type == AirbnbButtonType.outline || type == AirbnbButtonType.text) {
      return 0;
    }
    return onPressed == null ? 0 : 2;
  }

  Color _getShadowColor() {
    return AppColors.shadowMedium;
  }

  BorderSide _getBorderSide() {
    if (type == AirbnbButtonType.outline) {
      return BorderSide(
        color: onPressed == null ? AppColors.buttonDisabled : AppColors.primary,
        width: 1.5,
      );
    }
    return BorderSide.none;
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: iconRight ? [
          Text(text, style: _getTextStyle()),
          AppSpacing.horizontalSpaceSM,
          Icon(icon, size: _getIconSize()),
        ] : [
          Icon(icon, size: _getIconSize()),
          AppSpacing.horizontalSpaceSM,
          Text(text, style: _getTextStyle()),
        ],
      );
    }

    return Text(text, style: _getTextStyle());
  }

  double _getIconSize() {
    switch (size) {
      case AirbnbButtonSize.small:
        return 16;
      case AirbnbButtonSize.medium:
        return 20;
      case AirbnbButtonSize.large:
        return 24;
    }
  }
}

// Convenience constructors
class AirbnbPrimaryButton extends AirbnbButton {
  const AirbnbPrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.size = AirbnbButtonSize.medium,
    super.isLoading = false,
    super.isFullWidth = false,
    super.icon,
    super.iconRight = false,
  }) : super(type: AirbnbButtonType.primary);
}

class AirbnbSecondaryButton extends AirbnbButton {
  const AirbnbSecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.size = AirbnbButtonSize.medium,
    super.isLoading = false,
    super.isFullWidth = false,
    super.icon,
    super.iconRight = false,
  }) : super(type: AirbnbButtonType.secondary);
}

class AirbnbOutlineButton extends AirbnbButton {
  const AirbnbOutlineButton({
    super.key,
    required super.text,
    super.onPressed,
    super.size = AirbnbButtonSize.medium,
    super.isLoading = false,
    super.isFullWidth = false,
    super.icon,
    super.iconRight = false,
  }) : super(type: AirbnbButtonType.outline);
}

class AirbnbTextButton extends AirbnbButton {
  const AirbnbTextButton({
    super.key,
    required super.text,
    super.onPressed,
    super.size = AirbnbButtonSize.medium,
    super.isLoading = false,
    super.isFullWidth = false,
    super.icon,
    super.iconRight = false,
  }) : super(type: AirbnbButtonType.text);
}