import 'package:flutter/material.dart';

class AppColors {
  // New Color Palette - Modern & Professional
  static const Color poppy = Color(0xFFD64045);           // Primary Red
  static const Color mintGreen = Color(0xFFE9FFF9);       // Light Background
  static const Color nonPhotoBlue = Color(0xFF9ED8DB);    // Secondary Blue
  static const Color uclaBlue = Color(0xFF467599);        // Primary Blue
  static const Color delftBlue = Color(0xFF1D3354);       // Dark Blue

  // Primary Colors - Based on new palette
  static const Color primary = uclaBlue;                  // Main brand color
  static const Color primaryDark = delftBlue;             // Dark variant
  static const Color primaryLight = nonPhotoBlue;         // Light variant
  static const Color accent = poppy;                      // Accent color
  static const Color accentLight = Color(0xFFE57373);     // Lighter accent

  // Background Colors - Clean & Modern
  static const Color backgroundLight = mintGreen;         // Main background
  static const Color backgroundDark = delftBlue;          // Dark background
  static const Color cardBackground = Color(0xFFFFFFFF);  // Card background
  static const Color cardBackground70 = Color(0xB3FFFFFF); // Card background with 70% opacity
  static const Color surfaceColor = Color(0xFFF5FFFE);    // Surface color
  static const Color overlayColor = Color(0x1A1D3354);    // Overlay with delft blue

  // Text Colors - Readable & Professional
  static const Color textPrimary = delftBlue;             // Primary text
  static const Color textSecondary = uclaBlue;            // Secondary text
  static const Color textLight = Color(0xFF6B7280);       // Light text
  static const Color textWhite = Color(0xFFFFFFFF);       // White text
  static const Color textMuted = Color(0xFF9CA3AF);       // Muted text

  // Status Colors - Clear Communication
  static const Color success = Color(0xFF10B981);         // Success green
  static const Color warning = Color(0xFFF59E0B);         // Warning amber
  static const Color error = poppy;                       // Error red
  static const Color info = nonPhotoBlue;                 // Info blue
  
  // Additional Colors for compatibility
  static const Color background = backgroundLight;        // Main background
  static const Color surface = surfaceColor;              // Surface color
  static const Color secondary = nonPhotoBlue;            // Secondary color
  static const Color border = Color(0xFFE5E7EB);          // Border color

  // Colorblind-friendly palette (high contrast, distinct patterns)
  static const Color colorblindPrimary = Color(0xFF0066CC);      // Strong blue
  static const Color colorblindSecondary = Color(0xFFFF9900);    // Strong orange  
  static const Color colorblindAccent = Color(0xFF9900CC);       // Strong purple
  static const Color colorblindSuccess = Color(0xFF006600);      // Strong green
  static const Color colorblindWarning = Color(0xFFCC6600);      // Strong brown-orange
  static const Color colorblindError = Color(0xFFCC0000);        // Strong red
  static const Color colorblindInfo = Color(0xFF0099CC);         // Strong cyan
  static const Color colorblindBackground = Color(0xFFF8F9FA);   // Very light gray
  static const Color colorblindSurface = Color(0xFFFFFFFF);      // Pure white
  static const Color colorblindBorder = Color(0xFF666666);       // Medium gray

  // Button Colors - Interactive Elements
  static const Color buttonPrimary = uclaBlue;
  static const Color buttonSecondary = nonPhotoBlue;
  static const Color buttonDanger = poppy;
  static const Color buttonSuccess = Color(0xFF10B981);
  static const Color buttonDisabled = Color(0xFFE5E7EB);

  // Gradient Colors - Modern Transitions
  static const List<Color> primaryGradient = [
    uclaBlue,
    delftBlue,
  ];
  
  static const List<Color> accentGradient = [
    poppy,
    Color(0xFFB91C1C),
  ];
  
  static const List<Color> lightGradient = [
    mintGreen,
    nonPhotoBlue,
  ];
  
  static const List<Color> backgroundGradient = [
    mintGreen,
    Color(0xFFF0FDFA),
  ];

  // Shadow Colors - Subtle Depth
  static const Color shadowLight = Color(0x0A1D3354);
  static const Color shadowMedium = Color(0x1A1D3354);
  static const Color shadowDark = Color(0x25467599);

  // Helper Methods
  static LinearGradient getGradient(List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );
  }

  static BoxShadow getCardShadow({double blurRadius = 8.0}) {
    return BoxShadow(
      color: shadowLight,
      blurRadius: blurRadius,
      offset: const Offset(0, 2),
    );
  }

  static BoxShadow getElevatedShadow({double blurRadius = 16.0}) {
    return BoxShadow(
      color: shadowMedium,
      blurRadius: blurRadius,
      offset: const Offset(0, 4),
    );
  }

  // Modern Button Styles
  static ButtonStyle getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: buttonPrimary,
      foregroundColor: textWhite,
      elevation: 4,
      shadowColor: shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  static ButtonStyle getSecondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: buttonSecondary,
      foregroundColor: textPrimary,
      elevation: 2,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  static ButtonStyle getDangerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: buttonDanger,
      foregroundColor: textWhite,
      elevation: 4,
      shadowColor: shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  static ButtonStyle getOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: primary,
      side: const BorderSide(color: primary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  // Colorblind mode helpers
  static Color getPrimaryColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindPrimary : primary;
  }

  static Color getSecondaryColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindSecondary : secondary;
  }

  static Color getAccentColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindAccent : accent;
  }

  static Color getSuccessColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindSuccess : success;
  }

  static Color getWarningColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindWarning : warning;
  }

  static Color getErrorColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindError : error;
  }

  static Color getInfoColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindInfo : info;
  }

  static Color getBackgroundColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindBackground : backgroundLight;
  }

  static Color getSurfaceColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindSurface : surfaceColor;
  }

  static Color getBorderColor(bool isColorblindMode) {
    return isColorblindMode ? colorblindBorder : border;
  }
}