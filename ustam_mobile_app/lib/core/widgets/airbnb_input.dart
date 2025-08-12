import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AirbnbInputType { text, email, password, search, multiline }

class AirbnbInput extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final AirbnbInputType type;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AirbnbInput({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.controller,
    this.onChanged,
    this.onTap,
    this.type = AirbnbInputType.text,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines,
    this.maxLength,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  State<AirbnbInput> createState() => _AirbnbInputState();
}

class _AirbnbInputState extends State<AirbnbInput> {
  bool _isObscured = true;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.copyWith(
              color: widget.errorText != null 
                  ? AppColors.error 
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
        ],
        
        Container(
          decoration: BoxDecoration(
            color: widget.enabled 
                ? AppColors.background 
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
            border: Border.all(
              color: _getBorderColor(),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onEditingComplete: widget.onEditingComplete,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.type == AirbnbInputType.password && _isObscured,
            keyboardType: _getKeyboardType(),
            textInputAction: widget.textInputAction,
            maxLines: widget.type == AirbnbInputType.multiline 
                ? (widget.maxLines ?? 4) 
                : 1,
            maxLength: widget.maxLength,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              prefixIcon: widget.prefixIcon != null 
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused 
                          ? AppColors.primary 
                          : AppColors.textMuted,
                      size: 20,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              counterText: '', // Hide character counter
            ),
          ),
        ),
        
        if (widget.errorText != null) ...[
          AppSpacing.verticalSpaceXS,
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.error,
              ),
              AppSpacing.horizontalSpaceXS,
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          AppSpacing.verticalSpaceXS,
          Text(
            widget.helperText!,
            style: AppTypography.labelSmall,
          ),
        ],
      ],
    );
  }

  Color _getBorderColor() {
    if (widget.errorText != null) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.border;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case AirbnbInputType.email:
        return TextInputType.emailAddress;
      case AirbnbInputType.multiline:
        return TextInputType.multiline;
      case AirbnbInputType.text:
      case AirbnbInputType.password:
      case AirbnbInputType.search:
      default:
        return TextInputType.text;
    }
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == AirbnbInputType.password) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
        child: Icon(
          _isObscured ? Icons.visibility : Icons.visibility_off,
          color: _isFocused ? AppColors.primary : AppColors.textMuted,
          size: 20,
        ),
      );
    } else if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixIconTap,
        child: Icon(
          widget.suffixIcon,
          color: _isFocused ? AppColors.primary : AppColors.textMuted,
          size: 20,
        ),
      );
    }
    return null;
  }
}

// Search input specifically styled for Airbnb
class AirbnbSearchInput extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const AirbnbSearchInput({
    super.key,
    this.hintText = 'Nerede kalmak istiyorsun?',
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Airbnb search style
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.primary, // Pembe renk
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary, // Pembe renk
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}