import 'package:flutter/material.dart';

/// Centralized Design Token System for iOS + Airbnb Aesthetics
/// Single source of truth for all design decisions
class DesignTokens {
  // ========================================
  // PRIMARY COLORS - Airbnb + iOS Style
  // ========================================
  
  /// Primary Brand Color - Airbnb Coral
  static const Color primaryCoral = Color(0xFFFF5A5F);
  static const Color primaryCoralLight = Color(0xFFFF7A7E);
  static const Color primaryCoralDark = Color(0xFFE04348);
  
  /// Accent Color - Teal
  static const Color accentTeal = Color(0xFF00A699);
  static const Color accentTealLight = Color(0xFF33B8AC);
  static const Color accentTealDark = Color(0xFF008A7B);
  
  // Accent aliases for backward compatibility
  static const Color accent = accentTeal;
  static const Color accentLight = accentTealLight;
  
  // ========================================
  // GRAY SCALE - iOS System Grays
  // ========================================
  
  static const Color gray900 = Color(0xFF111827); // iOS Label Primary
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4B5563); // iOS Label Secondary
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray300 = Color(0xFFD1D5DB); // iOS Separator
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray50 = Color(0xFFF9FAFB);
  
  // ========================================
  // SEMANTIC COLORS
  // ========================================
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // ========================================
  // SURFACE COLORS
  // ========================================
  
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF8F9FA);
  static const Color surfaceTertiary = Color(0xFFF1F3F4);
  
  /// Dark Mode Surface Colors
  static const Color darkSurfacePrimary = Color(0xFF000000);
  static const Color darkSurfaceSecondary = Color(0xFF111827);
  static const Color darkSurfaceTertiary = Color(0xFF1F2937);
  
  /// Overlay Colors (for modals, dialogs)
  static const Color overlayColor = Color(0x80000000); // 50% black
  
  // ========================================
  // SPACING SYSTEM - 4pt Grid
  // ========================================
  
  static const double spaceUnit = 4.0;
  static const double space4 = spaceUnit * 1;      // 4pt
  static const double space6 = 6.0;                // 6pt
  static const double space8 = spaceUnit * 2;      // 8pt
  static const double space12 = spaceUnit * 3;     // 12pt
  static const double space16 = spaceUnit * 4;     // 16pt
  static const double space20 = spaceUnit * 5;     // 20pt
  static const double space24 = spaceUnit * 6;     // 24pt
  static const double space32 = spaceUnit * 8;     // 32pt
  static const double space40 = spaceUnit * 10;    // 40pt
  static const double space48 = spaceUnit * 12;    // 48pt
  static const double space56 = spaceUnit * 14;    // 56pt
  static const double space64 = spaceUnit * 16;    // 64pt
  
  /// Component Spacing
  static const double spacingScreenEdge = space16;     // 16pt
  static const double spacingCardPadding = space16;    // 16pt
  static const double spacingSectionGap = space24;     // 24pt
  static const double spacingListGap = space12;        // 12pt
  
  // ========================================
  // BORDER RADIUS - iOS Rounded Corners
  // ========================================
  
  static const double radius4 = 4.0;
  static const double radius6 = 6.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;  // Primary card radius
  static const double radius16 = 16.0;  // Large card radius
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radiusPill = 999.0; // Pill shape
  
  // ========================================
  // SHADOWS - iOS Soft Shadows
  // ========================================
  
  static const double shadowBlur4 = 4.0;
  static const double shadowBlur8 = 8.0;
  static const double shadowBlur12 = 12.0;
  static const double shadowBlur16 = 16.0;
  static const double shadowBlur24 = 24.0;
  
  static const double shadowOpacityLight = 0.1;
  static const double shadowOpacityMedium = 0.15;
  static const double shadowOpacityHeavy = 0.25;
  
  // ========================================
  // OPACITY LEVELS
  // ========================================
  
  static const double opacity10 = 0.1;
  static const double opacity20 = 0.2;
  static const double opacity30 = 0.3;
  static const double opacity40 = 0.4;
  static const double opacity50 = 0.5;
  static const double opacity60 = 0.6;
  static const double opacity70 = 0.7;
  static const double opacity80 = 0.8;
  static const double opacity90 = 0.9;
  
  // ========================================
  // MOTION & ANIMATION
  // ========================================
  
  static const Duration durationFast = const Duration(milliseconds: 150);
  static const Duration durationNormal = const Duration(milliseconds: 250);
  static const Duration durationSlow = const Duration(milliseconds: 400);
  
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseInOut = Curves.easeInOut;
  
  // ========================================
  // SIZE TOKENS
  // ========================================
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  static const double buttonHeight = 48.0;
  static const double inputHeight = 44.0;  // iOS standard
  
  // ========================================
  // COMPATIBILITY PROPERTIES
  // ========================================
  
  /// Color aliases for backward compatibility
  static const Color background = surfacePrimary;
  static const Color textLight = gray600;
  static const Color textMuted = gray500;
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
  static const Color uclaBlue = accentTeal;
  static const Color nonPhotoBlue = accentTeal;
  static const Color mintGreen = success;
  static const Color buttonPrimary = primaryCoral;
  static const Color buttonDanger = error;
  static const Color buttonDisabled = gray300;
  static const double inputBorderRadius = radius12;
  static const List<Color> headerGradient = [primaryCoral, primaryCoralDark];
  static const List<Color> accentGradient = [accentTeal, accentTealDark];
  static const Color surfaceSecondaryColor = surfaceSecondary;
  
  // Dark mode compatibility
  static const Color darkPrimaryCoral = Color(0xFFFF6B6F);
  static const Color darkAccentTeal = Color(0xFF1FB3A6);
  static const Color darkGray900 = Color(0xFFFAFAFA);
  static const Color darkGray800 = Color(0xFFE5E7EB);
  static const Color darkGray700 = Color(0xFFD1D5DB);
  static const Color darkGray600 = Color(0xFF9CA3AF);
  static const Color darkGray500 = Color(0xFF6B7280);
  static const Color darkGray400 = Color(0xFF4B5563);
  static const Color darkGray300 = Color(0xFF374151);
  static const Color darkGray200 = Color(0xFF1F2937);
  static const Color darkGray100 = Color(0xFF111827);
  static const Color darkGray50 = Color(0xFF000000);
  
  // Typography compatibility
  static const String fontFamilyPrimary = '.SF Pro Text';
  static const String fontFamilyDisplay = '.SF Pro Display';
  static const String fontFamilyMono = '.SF Mono';
  
  static const double fontSize34 = 34.0;
  static const double fontSize28 = 28.0;
  static const double fontSize22 = 22.0;
  static const double fontSize20 = 20.0;
  static const double fontSize17 = 17.0;
  static const double fontSize16 = 16.0;
  static const double fontSize15 = 15.0;
  static const double fontSize13 = 13.0;
  static const double fontSize12 = 12.0;
  static const double fontSize11 = 11.0;
  
  static const double lineHeight41 = 41.0;
  static const double lineHeight34 = 34.0;
  static const double lineHeight28 = 28.0;
  static const double lineHeight25 = 25.0;
  static const double lineHeight22 = 22.0;
  static const double lineHeight21 = 21.0;
  static const double lineHeight20 = 20.0;
  static const double lineHeight18 = 18.0;
  static const double lineHeight16 = 16.0;
  static const double lineHeight13 = 13.0;
  
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightHeavy = FontWeight.w800;
  
  // Size compatibility
  static const double iconSize16 = 16.0;
  static const double iconSize20 = 20.0;
  static const double iconSize24 = 24.0;
  static const double iconSize28 = 28.0;
  static const double iconSize32 = 32.0;
  
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 56.0;
  
  static const double spacingButtonPadding = space16;
  static const Color surfacePrimary70 = Color(0xB3FFFFFF); // 70% opacity white
  
  // Elevation compatibility
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
  
  // Spacing shortcuts
  static const SizedBox verticalSpaceXS = const SizedBox(height: space4);
  static const SizedBox verticalSpaceSM = const SizedBox(height: space8);
  static const SizedBox verticalSpaceMD = const SizedBox(height: space16);
  static const SizedBox horizontalSpaceXS = const SizedBox(width: space4);
  static const SizedBox horizontalSpaceSM = const SizedBox(width: space8);
  static const SizedBox horizontalSpaceMD = const SizedBox(width: space16);
  static const EdgeInsets spacingCardPaddingInsets = const EdgeInsets.all(space16);
  static const EdgeInsets spacingScreenEdgeInsets = const EdgeInsets.all(spacingScreenEdge);
  
  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Primary Coral Gradient
  static LinearGradient get primaryCoralGradient => LinearGradient(
    colors: [primaryCoral, primaryCoralDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Helper methods for gradients and shadows
  static LinearGradient getGradient(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static BoxShadow getCardShadow({double blurRadius = 12}) {
    return BoxShadow(
      color: Colors.black.withOpacity(shadowOpacityLight),
      blurRadius: blurRadius,
      offset: const Offset(0, 2),
    );
  }
  
  static BoxShadow getElevatedShadow({double blurRadius = 12}) {
    return BoxShadow(
      color: Colors.black.withOpacity(shadowOpacityMedium),
      blurRadius: blurRadius,
      offset: const Offset(0, 4),
    );
  }
  
  // Shadow presets for compatibility
  static List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: Colors.black.withOpacity(shadowOpacityLight),
      blurRadius: shadowBlur12,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowElevated => [
    BoxShadow(
      color: Colors.black.withOpacity(shadowOpacityMedium),
      blurRadius: shadowBlur16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowFloating => [
    BoxShadow(
      color: Colors.black.withOpacity(shadowOpacityHeavy),
      blurRadius: shadowBlur24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static ButtonStyle getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryCoral,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: const Borderconst Radius.circular(radius12),
      ),
    );
  }
  
  static EdgeInsets getEdgeInsets({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) return const EdgeInsets.all(all);
    return const EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );
  }
  
  /// Get text color based on background luminance
  static Color getContrastColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? gray900 : Colors.white;
  }
}