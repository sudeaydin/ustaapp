import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';
import '../config/app_config.dart';

enum TextFieldType { text, email, password, phone, number, multiline }

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? hintText; // Backward compatibility
  final String? initialValue;
  final TextFieldType type;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool required;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.hintText, // Backward compatibility
    this.initialValue,
    this.type = TextFieldType.text,
    this.onChanged,
    this.validator,
    this.controller,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.required = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: TextStyle(
                color: DesignTokens.gray900,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              children: [
                if (widget.required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: DesignTokens.error),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: DesignTokens.inputContainerDecoration(
            isEnabled: widget.enabled,
            isFocused: _focusNode.hasFocus,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: widget.type == TextFieldType.password ? _obscureText : false,
            keyboardType: _getKeyboardType(),
            inputFormatters: _getInputFormatters(),
            maxLines: widget.type == TextFieldType.multiline ? null : widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            validator: widget.validator ?? _getDefaultValidator(),
            style: DesignTokens.inputTextStyle,
            decoration: InputDecoration(
              hintText: widget.hint ?? widget.hintText,
              hintStyle: DesignTokens.inputHintTextStyle,
              prefixIcon: widget.prefixIcon,
              suffixIcon: _getSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(DesignTokens.space16),
              counterText: '', // Hide character counter
            ),
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case TextFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ];
      case TextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }

  Widget? _getSuffixIcon() {
    if (widget.type == TextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: DesignTokens.textMuted,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  String? Function(String?)? _getDefaultValidator() {
    if (!widget.required) return null;
    
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '${widget.label ?? 'Bu alan'} gereklidir';
      }
      
      switch (widget.type) {
        case TextFieldType.text:
        case TextFieldType.multiline:
          // No specific validation for text fields
          break;
        case TextFieldType.email:
          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
            return 'Geçerli bir e-posta adresi girin';
          }
          break;
        case TextFieldType.password:
          if (value.length < AppConfig.minPasswordLength) {
            return 'Şifre en az ${AppConfig.minPasswordLength} karakter olmalıdır';
          }
          break;
        case TextFieldType.phone:
          if (value.length < 10) {
            return 'Geçerli bir telefon numarası girin';
          }
          break;
        case TextFieldType.number:
          if (double.tryParse(value) == null) {
            return 'Geçerli bir sayı girin';
          }
          break;
      }
      
      return null;
    };
  }
}

// Specialized text field variants
class SearchTextField extends StatelessWidget {
  final String hint;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const SearchTextField({
    super.key,
    required this.hint,
    this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hint: hint,
      onChanged: onChanged,
      controller: controller,
      prefixIcon: Icon(Icons.search, color: DesignTokens.textMuted),
      suffixIcon: onClear != null
          ? IconButton(
              icon: Icon(Icons.clear, color: DesignTokens.textMuted),
              onPressed: onClear,
            )
          : null,
    );
  }
}