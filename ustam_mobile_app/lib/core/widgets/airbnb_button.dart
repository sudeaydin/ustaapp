import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
      child: CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        padding: EdgeInsets.zero,
        minSize: 0,
        child: Container(
          width: isFullWidth ? double.infinity : null,
          height: _getHeight(),
          decoration: _getButtonDecoration(),
          child: Center(child: _buildButtonContent()),
        ),
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
        return AppColors.primary;
      case AirbnbButtonType.outline:
        return Colors.transparent;
      case AirbnbButtonType.text:
        return Colors.transparent;
    }
  }

  BoxDecoration _getButtonDecoration() {
    return BoxDecoration(
      color: onPressed == null ? AppColors.buttonDisabled : _getBackgroundColor(),
      borderRadius: AppSpacing.buttonBorderRadiusGeometry,
      border: type == AirbnbButtonType.outline 
          ? Border.all(
              color: onPressed == null ? AppColors.buttonDisabled : AppColors.primary,
              width: 1.5,
            )
          : null,
      boxShadow: _getBoxShadow(),
    );
  }

  List<BoxShadow>? _getBoxShadow() {
    if (type == AirbnbButtonType.outline || type == AirbnbButtonType.text || onPressed == null) {
      return null;
    }
    return [
      BoxShadow(
        color: AppColors.shadowMedium.withOpacity(0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
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