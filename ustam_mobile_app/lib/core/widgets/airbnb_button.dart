import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/design_tokens.dart';

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('🎯 AirbnbButton tapped! Loading: $isLoading, OnPressed: ${onPressed != null}');
            if (!isLoading && onPressed != null) {
              print('✅ Calling onPressed callback');
              onPressed!();
            } else {
              print('❌ Button tap ignored - Loading: $isLoading, Callback: ${onPressed != null}');
            }
          },
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: Container(
            width: isFullWidth ? double.infinity : null,
            height: _getHeight(),
            decoration: _getButtonDecoration(),
            child: Center(child: _buildButtonContent()),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AirbnbButtonSize.small:
        return DesignTokens.buttonHeightSmall;
      case AirbnbButtonSize.medium:
        return DesignTokens.buttonHeightMedium;
      case AirbnbButtonSize.large:
        return DesignTokens.buttonHeightLarge;
    }
  }

  double _getBorderRadius() {
    return DesignTokens.radius12;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AirbnbButtonSize.small:
        return DesignTokens.getEdgeInsets(horizontal: DesignTokens.space12, vertical: DesignTokens.space8);
      case AirbnbButtonSize.medium:
        return DesignTokens.getEdgeInsets(horizontal: DesignTokens.spacingButtonPadding, vertical: DesignTokens.space12);
      case AirbnbButtonSize.large:
        return DesignTokens.getEdgeInsets(horizontal: DesignTokens.space24, vertical: DesignTokens.space16);
    }
  }

  TextStyle _getTextStyle() {
    final fontSize = switch (size) {
      AirbnbButtonSize.small => DesignTokens.fontSize15,
      AirbnbButtonSize.medium => DesignTokens.fontSize16,
      AirbnbButtonSize.large => DesignTokens.fontSize17,
    };

    return TextStyle(
      fontFamily: DesignTokens.fontFamilyPrimary,
      fontSize: fontSize,
      fontWeight: DesignTokens.fontWeightSemibold,
      color: _getTextColor(),
    );
  }

  Color _getTextColor() {
    if (onPressed == null) return DesignTokens.gray600;
    
    switch (type) {
      case AirbnbButtonType.primary:
        return Colors.white;
      case AirbnbButtonType.secondary:
        return Colors.white;
      case AirbnbButtonType.outline:
        return DesignTokens.primaryCoral;
      case AirbnbButtonType.text:
        return DesignTokens.primaryCoral;
    }
  }

  Color _getBackgroundColor() {
    if (onPressed == null) return DesignTokens.gray300;
    
    switch (type) {
      case AirbnbButtonType.primary:
        return DesignTokens.primaryCoral;
      case AirbnbButtonType.secondary:
        return DesignTokens.accentTeal;
      case AirbnbButtonType.outline:
        return Colors.transparent;
      case AirbnbButtonType.text:
        return Colors.transparent;
    }
  }

  BoxDecoration _getButtonDecoration() {
    return BoxDecoration(
      color: onPressed == null ? DesignTokens.gray300 : _getBackgroundColor(),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: type == AirbnbButtonType.outline 
          ? Border.all(
              color: onPressed == null ? DesignTokens.gray300 : DesignTokens.primaryCoral,
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
    return DesignTokens.shadowCard;
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
          DesignTokens.horizontalSpaceSM,
          Icon(icon, size: _getIconSize()),
        ] : [
          Icon(icon, size: _getIconSize()),
          DesignTokens.horizontalSpaceSM,
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