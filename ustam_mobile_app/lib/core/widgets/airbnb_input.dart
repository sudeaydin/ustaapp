import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';
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
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

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
    this.keyboardType,
    this.inputFormatters,
    this.validator,
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
                  ? DesignTokens.error 
                  : DesignTokens.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          DesignTokens.verticalSpaceXS,
        ],
        
        Container(
          decoration: DesignTokens.inputContainerDecoration(
            isEnabled: widget.enabled,
            isFocused: _isFocused,
            hasError: widget.errorText != null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onEditingComplete: widget.onEditingComplete,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.type == AirbnbInputType.password && _isObscured,
            keyboardType: widget.keyboardType ?? _getKeyboardType(),
            inputFormatters: widget.inputFormatters,
            textInputAction: widget.textInputAction,
            maxLines: widget.type == AirbnbInputType.multiline
                ? (widget.maxLines ?? 4)
                : 1,
            maxLength: widget.maxLength,
            validator: widget.validator,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: DesignTokens.inputTextColor),
            decoration: DesignTokens.inputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? DesignTokens.primaryCoral
                          : DesignTokens.textMuted,
                      size: 20,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              hideCounter: widget.maxLength != null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
                vertical: DesignTokens.space16,
              ),
            ).copyWith(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              prefixIconColor: _isFocused
                  ? DesignTokens.primaryCoral
                  : DesignTokens.textMuted,
              suffixIconColor: _isFocused
                  ? DesignTokens.primaryCoral
                  : DesignTokens.textMuted,
            ),
          ),
        ),
        
        if (widget.errorText != null) ...[
          DesignTokens.verticalSpaceXS,
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: DesignTokens.error,
              ),
              DesignTokens.horizontalSpaceXS,
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: AppTypography.labelSmall.copyWith(
                    color: DesignTokens.error,
                  ),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          DesignTokens.verticalSpaceXS,
          Text(
            widget.helperText!,
            style: AppTypography.labelSmall,
          ),
        ],
      ],
    );
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
          color: _isFocused ? DesignTokens.primaryCoral : DesignTokens.textMuted,
          size: 20,
        ),
      );
    } else if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixIconTap,
        child: Icon(
          widget.suffixIcon,
          color: _isFocused ? DesignTokens.primaryCoral : DesignTokens.textMuted,
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
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: DesignTokens.inputTextColor),
      decoration: DesignTokens.inputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space24,
          vertical: DesignTokens.space16,
        ),
        borderRadius: 24,
      ).copyWith(
        prefixIconColor: DesignTokens.primaryCoral,
        suffixIconColor: DesignTokens.primaryCoral,
      ),
    );
  }
}