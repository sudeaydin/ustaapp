import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'dart:math' show pow;

/// Accessibility utilities for WCAG compliance in Flutter
class AccessibilityUtils {
  static bool _initialized = false;

  /// Initialize accessibility features
  static void initialize() {
    if (_initialized) return;
    
    // Enable accessibility features
    WidgetsBinding.instance.ensureSemantics();
    _initialized = true;
  }

  /// Announce message to screen readers
  static void announce(String message, {TextDirection? textDirection}) {
    SemanticsService.announce(
      message, 
      textDirection ?? TextDirection.ltr,
    );
  }

  /// Check if screen reader is enabled
  static bool get isScreenReaderEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.accessibleNavigation;
  }

  /// Check if high contrast is enabled
  static bool get isHighContrastEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.highContrast;
  }

  /// Check if reduce motion is enabled
  static bool get isReduceMotionEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
  }

  /// Get recommended font scale
  static double get fontScale {
    return WidgetsBinding.instance.platformDispatcher.textScaleFactor;
  }

  /// Generate semantic label for buttons
  static String generateButtonLabel(String text, {
    bool isLoading = false,
    bool isDisabled = false,
    String? hint,
  }) {
    String label = text;
    
    if (isLoading) {
      label += ', yükleniyor';
    }
    
    if (isDisabled) {
      label += ', devre dışı';
    }
    
    if (hint != null) {
      label += ', $hint';
    }
    
    return label;
  }

  /// Generate semantic label for form fields
  static String generateFieldLabel(String label, {
    bool isRequired = false,
    String? error,
    String? hint,
  }) {
    String semanticLabel = label;
    
    if (isRequired) {
      semanticLabel += ', gerekli alan';
    }
    
    if (error != null) {
      semanticLabel += ', hata: $error';
    }
    
    if (hint != null) {
      semanticLabel += ', ipucu: $hint';
    }
    
    return semanticLabel;
  }

  /// Check color contrast ratio
  static double calculateContrastRatio(Color foreground, Color background) {
    final l1 = _getRelativeLuminance(foreground);
    final l2 = _getRelativeLuminance(background);
    
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Get relative luminance of a color
  static double _getRelativeLuminance(Color color) {
    final r = _normalize(color.red);
    final g = _normalize(color.green);
    final b = _normalize(color.blue);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _normalize(int value) {
    final val = value / 255.0;
    return val <= 0.03928 ? val / 12.92 : pow((val + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Get accessible colors based on contrast requirements
  static Color getAccessibleTextColor(Color background, {
    bool requireAAA = false,
  }) {
    final whiteContrast = calculateContrastRatio(Colors.white, background);
    final blackContrast = calculateContrastRatio(Colors.black, background);
    
    final requiredRatio = requireAAA ? 7.0 : 4.5;
    
    if (whiteContrast >= requiredRatio) {
      return Colors.white;
    } else if (blackContrast >= requiredRatio) {
      return Colors.black;
    } else {
      // Return the one with better contrast
      return whiteContrast > blackContrast ? Colors.white : Colors.black;
    }
  }
}

/// Accessible button widget
class AccessibleButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final ButtonStyle? style;
  final String? variant;

  const AccessibleButton({
    Key? key,
    this.text,
    this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.style,
    this.variant,
  }) : assert(text != null || child != null, 'Either text or child must be provided'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = semanticLabel ?? AccessibilityUtils.generateButtonLabel(
      text ?? 'Button',
      isLoading: isLoading,
      isDisabled: isDisabled,
      hint: tooltip,
    );

    Widget buttonChild = child ?? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (icon != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: icon!,
          ),
        if (text != null) Text(text!),
      ],
    );

    Widget button = variant == 'secondary'
        ? OutlinedButton(
            onPressed: (isDisabled || isLoading) ? null : onPressed,
            style: style,
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: (isDisabled || isLoading) ? null : onPressed,
            style: style,
            child: buttonChild,
          );

    button = Semantics(
      label: effectiveLabel,
      button: true,
      enabled: !isDisabled && !isLoading,
      child: button,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Accessible text field widget
class AccessibleTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final String? hintText;
  final bool isRequired;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;

  const AccessibleTextField({
    Key? key,
    required this.label,
    this.controller,
    this.errorText,
    this.hintText,
    this.isRequired = false,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = semanticLabel ?? AccessibilityUtils.generateFieldLabel(
      label,
      isRequired: isRequired,
      error: errorText,
      hint: hintText,
    );

    return Semantics(
      label: effectiveLabel,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          RichText(
            text: TextSpan(
              text: label,
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Text field
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              border: const OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
            validator: isRequired 
              ? (value) => value?.isEmpty ?? true ? 'Bu alan gereklidir' : null
              : null,
          ),
          
          // Error message with proper semantics
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Accessible modal dialog
class AccessibleModal extends StatefulWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final VoidCallback? onDismiss;
  final String? semanticLabel;

  const AccessibleModal({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
    this.onDismiss,
    this.semanticLabel,
  }) : super(key: key);

  @override
  State<AccessibleModal> createState() => _AccessibleModalState();
}

class _AccessibleModalState extends State<AccessibleModal> {
  @override
  void initState() {
    super.initState();
    // Announce modal opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityUtils.announce('Modal açıldı: ${widget.title}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? 'Modal: ${widget.title}',
      scopesRoute: true,
      child: AlertDialog(
        title: Semantics(
          header: true,
          child: Text(widget.title),
        ),
        content: widget.content,
        actions: [
          if (widget.actions != null) ...widget.actions!,
          if (widget.onDismiss != null)
            AccessibleButton(
              text: 'Kapat',
              onPressed: widget.onDismiss,
              semanticLabel: 'Modalı kapat',
            ),
        ],
      ),
    );
  }
}

/// Accessible list tile
class AccessibleListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool isSelected;

  const AccessibleListTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String label = semanticLabel ?? title;
    if (subtitle != null) {
      label += ', $subtitle';
    }
    if (isSelected) {
      label += ', seçili';
    }

    return Semantics(
      label: label,
      button: onTap != null,
      selected: isSelected,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        selected: isSelected,
      ),
    );
  }
}

/// Accessible card widget
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? tooltip;

  const AccessibleCard({
    Key? key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    if (tooltip != null) {
      card = Tooltip(
        message: tooltip!,
        child: card,
      );
    }

    return card;
  }
}

/// Accessible progress indicator
class AccessibleProgressIndicator extends StatelessWidget {
  final double? value;
  final String? semanticLabel;
  final String? progressText;

  const AccessibleProgressIndicator({
    Key? key,
    this.value,
    this.semanticLabel,
    this.progressText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String label = semanticLabel ?? 'İlerleme göstergesi';
    
    if (value != null) {
      final percentage = (value! * 100).round();
      label += ', %$percentage tamamlandı';
    }
    
    if (progressText != null) {
      label += ', $progressText';
    }

    return Semantics(
      label: label,
      value: value != null ? '${(value! * 100).round()}%' : null,
      child: value != null 
        ? LinearProgressIndicator(value: value)
        : const LinearProgressIndicator(),
    );
  }
}

/// Accessible tab bar
class AccessibleTabBar extends StatelessWidget {
  final List<Tab> tabs;
  final TabController controller;
  final String? semanticLabel;

  const AccessibleTabBar({
    Key? key,
    required this.tabs,
    required this.controller,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Sekmeler',
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) => Semantics(
          label: tab.text ?? 'Sekme',
          button: true,
          selected: tabs.indexOf(tab) == controller.index,
          child: tab,
        )).toList(),
      ),
    );
  }
}

/// Accessibility mixin for widgets
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  /// Announce when widget is mounted
  void announceMount(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityUtils.announce(message);
    });
  }

  /// Announce when data changes
  void announceDataChange(String message) {
    AccessibilityUtils.announce(message);
  }

  /// Focus on a widget
  void focusWidget(FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }
}

/// Accessibility constants
class AccessibilityConstants {
  static const Duration announcementDelay = Duration(milliseconds: 500);
  static const Duration focusDelay = Duration(milliseconds: 100);
  
  // Semantic labels
  static const String loading = 'Yükleniyor';
  static const String error = 'Hata';
  static const String success = 'Başarılı';
  static const String required = 'Gerekli alan';
  static const String optional = 'İsteğe bağlı';
  static const String selected = 'Seçili';
  static const String disabled = 'Devre dışı';
  
  // Button actions
  static const String tapToOpen = 'Açmak için dokunun';
  static const String tapToClose = 'Kapatmak için dokunun';
  static const String tapToSelect = 'Seçmek için dokunun';
  static const String tapToEdit = 'Düzenlemek için dokunun';
  static const String tapToDelete = 'Silmek için dokunun';
  
  // Navigation
  static const String goBack = 'Geri git';
  static const String goForward = 'İleri git';
  static const String goToHome = 'Ana sayfaya git';
  static const String openMenu = 'Menüyü aç';
  static const String closeMenu = 'Menüyü kapat';
}

/// Accessibility helper functions
extension AccessibilityExtensions on Widget {
  /// Add semantic label to any widget
  Widget withSemantics({
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? selected,
    bool? enabled,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      selected: selected,
      enabled: enabled,
      onTap: onTap,
      child: this,
    );
  }

  /// Make widget focusable
  Widget makeFocusable(FocusNode focusNode) {
    return Focus(
      focusNode: focusNode,
      child: this,
    );
  }

  /// Add tooltip
  Widget withTooltip(String message) {
    return Tooltip(
      message: message,
      child: this,
    );
  }
}

/// Screen reader announcements helper
class ScreenReaderAnnouncer {
  static final List<String> _pendingAnnouncements = [];
  static bool _isAnnouncing = false;

  /// Queue an announcement
  static void announce(String message) {
    _pendingAnnouncements.add(message);
    _processQueue();
  }

  /// Process announcement queue
  static void _processQueue() async {
    if (_isAnnouncing || _pendingAnnouncements.isEmpty) return;
    
    _isAnnouncing = true;
    
    while (_pendingAnnouncements.isNotEmpty) {
      final message = _pendingAnnouncements.removeAt(0);
      AccessibilityUtils.announce(message);
      
      // Wait between announcements
      await Future.delayed(AccessibilityConstants.announcementDelay);
    }
    
    _isAnnouncing = false;
  }

  /// Clear all pending announcements
  static void clear() {
    _pendingAnnouncements.clear();
  }
}