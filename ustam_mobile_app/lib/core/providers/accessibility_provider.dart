import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Accessibility mode enum
enum AccessibilityMode {
  normal,
  colorblind,
}

class AccessibilityNotifier extends StateNotifier<AccessibilityMode> {
  AccessibilityNotifier() : super(AccessibilityMode.normal) {
    _loadAccessibilityMode();
  }

  Future<void> _loadAccessibilityMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('accessibility_mode') ?? 0;
    state = AccessibilityMode.values[modeIndex];
  }

  Future<void> setAccessibilityMode(AccessibilityMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accessibility_mode', mode.index);
  }

  bool get isColorblindMode => state == AccessibilityMode.colorblind;
  bool get isNormalMode => state == AccessibilityMode.normal;
}

final accessibilityProvider = StateNotifierProvider<AccessibilityNotifier, AccessibilityMode>((ref) {
  return AccessibilityNotifier();
});