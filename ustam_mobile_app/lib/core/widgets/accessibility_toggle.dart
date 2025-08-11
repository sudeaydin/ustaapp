import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accessibility_provider.dart';
import '../theme/app_colors.dart';

class AccessibilityToggle extends ConsumerWidget {
  const AccessibilityToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityMode = ref.watch(accessibilityProvider);
    final isColorblindMode = accessibilityMode == AccessibilityMode.colorblind;

    return PopupMenuButton<AccessibilityMode>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.textWhite.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isColorblindMode ? Icons.visibility_outlined : Icons.palette_outlined,
          color: AppColors.textWhite,
          size: 20,
        ),
      ),
      onSelected: (AccessibilityMode mode) {
        ref.read(accessibilityProvider.notifier).setAccessibilityMode(mode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<AccessibilityMode>(
          value: AccessibilityMode.normal,
          child: Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: !isColorblindMode ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Normal Renkler',
                style: TextStyle(
                  color: !isColorblindMode ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: !isColorblindMode ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<AccessibilityMode>(
          value: AccessibilityMode.colorblind,
          child: Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                color: isColorblindMode ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Renk Körü Modu',
                style: TextStyle(
                  color: isColorblindMode ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isColorblindMode ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SimpleAccessibilityToggle extends ConsumerWidget {
  const SimpleAccessibilityToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityMode = ref.watch(accessibilityProvider);
    final isColorblindMode = accessibilityMode == AccessibilityMode.colorblind;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          isColorblindMode ? Icons.visibility_outlined : Icons.palette_outlined,
          color: AppColors.textWhite,
          size: 20,
        ),
        onPressed: () {
          final newMode = isColorblindMode 
              ? AccessibilityMode.normal 
              : AccessibilityMode.colorblind;
          ref.read(accessibilityProvider.notifier).setAccessibilityMode(newMode);
        },
        tooltip: isColorblindMode ? 'Normal Renkler' : 'Renk Körü Modu',
      ),
    );
  }
}