import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../config/app_config.dart';
import 'hover_button.dart';

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
      child: HoverButton(
        onTap: isEnabled ? onPressed : null,
        hoverColor: isEnabled ? _getHoverColor() : Colors.grey,
        hoverScale: isEnabled ? 1.05 : 1.0,
        borderRadius: BorderRadius.circular(DesignTokens.radius12),
        child: _buildButton(isEnabled),
      ),
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

  Color _getHoverColor() {
    switch (type) {
      case ButtonType.primary:
        return DesignTokens.primaryCoral;
      case ButtonType.secondary:
        return DesignTokens.primaryCoral;
      case ButtonType.danger:
        return DesignTokens.error;
      case ButtonType.outlined:
        return DesignTokens.primaryCoral;
      case ButtonType.text:
        return DesignTokens.primaryCoral;
    }
  }

  Widget _buildButton(bool isEnabled) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: null, // HoverButton handles the actual onPressed
          style: _getPrimaryStyle(),
          child: _buildButtonContent(),
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: null, // HoverButton handles the actual onPressed
          style: _getSecondaryStyle(),
          child: _buildButtonContent(),
        );
      case ButtonType.danger:
        return ElevatedButton(
          onPressed: null, // HoverButton handles the actual onPressed
          style: _getDangerStyle(),
          child: _buildButtonContent(),
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: null, // HoverButton handles the actual onPressed
          style: _getOutlinedStyle(),
          child: _buildButtonContent(),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: null, // HoverButton handles the actual onPressed
          style: _getTextButtonStyle(),
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
                ? DesignTokens.primaryCoral
                : Colors.white,
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
      backgroundColor: DesignTokens.buttonPrimary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: DesignTokens.buttonDisabled,
      disabledForegroundColor: DesignTokens.textMuted,
      elevation: 4,
      shadowColor: DesignTokens.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  ButtonStyle _getSecondaryStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: DesignTokens.primaryCoral,
      foregroundColor: DesignTokens.gray900,
      disabledBackgroundColor: DesignTokens.buttonDisabled,
      disabledForegroundColor: DesignTokens.textMuted,
      elevation: 2,
      shadowColor: DesignTokens.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  ButtonStyle _getDangerStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: DesignTokens.buttonDanger,
      foregroundColor: Colors.white,
      disabledBackgroundColor: DesignTokens.buttonDisabled,
      disabledForegroundColor: DesignTokens.textMuted,
      elevation: 4,
      shadowColor: DesignTokens.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  ButtonStyle _getOutlinedStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: DesignTokens.primaryCoral,
      disabledForegroundColor: DesignTokens.textMuted,
      side: BorderSide(
        color: isLoading ? DesignTokens.buttonDisabled : DesignTokens.primaryCoral,
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      padding: _getPadding(),
      textStyle: _getTextStyle(),
    );
  }

  ButtonStyle _getTextButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: DesignTokens.primaryCoral,
      disabledForegroundColor: DesignTokens.textMuted,
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
        return TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }
}