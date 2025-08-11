import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../config/app_config.dart';

enum ButtonType { primary, secondary, danger, outlined, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && !isLoading && onPressed != null;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(isEnabled),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return AppConfig.buttonHeight;
      case ButtonSize.large:
        return 56;
    }
  }

  Widget _buildButton(bool isEnabled) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getPrimaryStyle(),
          child: _buildButtonContent(),
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getSecondaryStyle(),
          child: _buildButtonContent(),
        );
      case ButtonType.danger:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getDangerStyle(),
          child: _buildButtonContent(),
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getOutlinedStyle(),
          child: _buildButtonContent(),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getTextStyle(),
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outlined || type == ButtonType.text
                ? AppColors.primary
                : AppColors.textWhite,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonStyle _getPrimaryStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonPrimary,
      foregroundColor: AppColors.textWhite,
      disabledBackgroundColor: AppColors.buttonDisabled,
      disabledForegroundColor: AppColors.textMuted,
      elevation: 4,
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  ButtonStyle _getSecondaryStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonSecondary,
      foregroundColor: AppColors.textPrimary,
      disabledBackgroundColor: AppColors.buttonDisabled,
      disabledForegroundColor: AppColors.textMuted,
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  ButtonStyle _getDangerStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonDanger,
      foregroundColor: AppColors.textWhite,
      disabledBackgroundColor: AppColors.buttonDisabled,
      disabledForegroundColor: AppColors.textMuted,
      elevation: 4,
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  ButtonStyle _getOutlinedStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textMuted,
      side: BorderSide(
        color: isLoading ? AppColors.buttonDisabled : AppColors.primary,
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  ButtonStyle _getTextStyle() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }
}