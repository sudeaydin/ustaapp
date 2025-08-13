import 'package:flutter/material.dart';

/// iOS + Airbnb Design Tokens
/// Tüm tasarım kararları bu dosyadan yönetilir
/// Light/Dark mode, Dynamic Type, RTL desteği dahil
class DesignTokens {
  DesignTokens._();

  // ========================================
  // COLOR TOKENS
  // ========================================
  
  /// Primary Colors - Airbnb Coral Theme
  static const Color primaryCoral = Color(0xFFFF5A5F);
  static const Color primaryCoralDark = Color(0xFFE14348);
  static const Color primaryCoralLight = Color(0xFFFF7A7E);
  
  /// Accent Colors - Teal
  static const Color accentTeal = Color(0xFF00A699);
  static const Color accentTealDark = Color(0xFF008A7B);
  static const Color accentTealLight = Color(0xFF1FB3A6);
  
  /// Neutral Colors - iOS Gray Scale
  static const Color gray900 = Color(0xFF111827); // iOS Label Primary
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4B5563); // iOS Label Secondary
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray300 = Color(0xFFD1D5DB); // iOS Separator
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray50 = Color(0xFFFAFAFA);
  
  /// Semantic Colors - iOS System Colors
  static const Color success = Color(0xFF34C759);  // iOS Green
  static const Color warning = Color(0xFFFFCC00);  // iOS Yellow
  static const Color error = Color(0xFFFF3B30);    // iOS Red
  static const Color info = Color(0xFF007AFF);     // iOS Blue
  
  /// Surface Colors
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFAFAFA);
  static const Color surfaceTertiary = Color(0xFFF3F4F6);
  
  // ========================================
  // DARK MODE COLORS
  // ========================================
  
  /// Dark Mode - Primary Colors
  static const Color darkPrimaryCoral = Color(0xFFFF6B6F);
  static const Color darkAccentTeal = Color(0xFF1FB3A6);
  
  /// Dark Mode - Neutral Colors
  static const Color darkGray900 = Color(0xFFFAFAFA); // Dark Label Primary
  static const Color darkGray800 = Color(0xFFE5E7EB);
  static const Color darkGray700 = Color(0xFFD1D5DB);
  static const Color darkGray600 = Color(0xFF9CA3AF); // Dark Label Secondary
  static const Color darkGray500 = Color(0xFF6B7280);
  static const Color darkGray400 = Color(0xFF4B5563);
  static const Color darkGray300 = Color(0xFF374151); // Dark Separator
  static const Color darkGray200 = Color(0xFF1F2937);
  static const Color darkGray100 = Color(0xFF111827);
  static const Color darkGray50 = Color(0xFF000000);
  
  /// Dark Mode - Surface Colors
  static const Color darkSurfacePrimary = Color(0xFF000000);
  static const Color darkSurfaceSecondary = Color(0xFF111827);
  static const Color darkSurfaceTertiary = Color(0xFF1F2937);
  
  // ========================================
  // TYPOGRAPHY TOKENS
  // ========================================
  
  /// Font Families - iOS San Francisco
  static const String fontFamilyPrimary = '.SF Pro Text';
  static const String fontFamilyDisplay = '.SF Pro Display';
  static const String fontFamilyMono = '.SF Mono';
  
  /// Font Sizes - iOS Typography Scale
  static const double fontSize34 = 34.0; // iOS Large Title
  static const double fontSize28 = 28.0; // iOS Title 1
  static const double fontSize22 = 22.0; // iOS Title 2
  static const double fontSize20 = 20.0; // iOS Title 3
  static const double fontSize17 = 17.0; // iOS Body
  static const double fontSize16 = 16.0; // iOS Callout
  static const double fontSize15 = 15.0; // iOS Subhead
  static const double fontSize13 = 13.0; // iOS Footnote
  static const double fontSize12 = 12.0; // iOS Caption 1
  static const double fontSize11 = 11.0; // iOS Caption 2
  
  /// Line Heights - iOS Standard
  static const double lineHeight41 = 41.0; // 34pt font
  static const double lineHeight34 = 34.0; // 28pt font
  static const double lineHeight28 = 28.0; // 22pt font
  static const double lineHeight25 = 25.0; // 20pt font
  static const double lineHeight22 = 22.0; // 17pt font
  static const double lineHeight21 = 21.0; // 16pt font
  static const double lineHeight20 = 20.0; // 15pt font
  static const double lineHeight18 = 18.0; // 13pt font
  static const double lineHeight16 = 16.0; // 12pt font
  static const double lineHeight13 = 13.0; // 11pt font
  
  /// Font Weights - iOS Standard
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightHeavy = FontWeight.w800;
  
  // ========================================
  // SPACING TOKENS
  // ========================================
  
  /// Base Unit - 4pt Grid System
  static const double spaceUnit = 4.0;
  
  /// Spacing Scale
  static const double space2 = spaceUnit * 0.5;  // 2pt
  static const double space4 = spaceUnit * 1;    // 4pt
  static const double space8 = spaceUnit * 2;    // 8pt
  static const double space12 = spaceUnit * 3;   // 12pt
  static const double space16 = spaceUnit * 4;   // 16pt
  static const double space20 = spaceUnit * 5;   // 20pt
  static const double space24 = spaceUnit * 6;   // 24pt
  static const double space32 = spaceUnit * 8;   // 32pt
  static const double space40 = spaceUnit * 10;  // 40pt
  static const double space48 = spaceUnit * 12;  // 48pt
  static const double space64 = spaceUnit * 16;  // 64pt
  
  /// Component Spacing
  static const double spacingScreenEdge = space16;     // 16pt
  static const double spacingCardPadding = space16;    // 16pt
  static const double spacingButtonPadding = space16;  // 16pt
  static const double spacingSectionGap = space24;     // 24pt
  static const double spacingElementGap = space12;     // 12pt
  
  // ========================================
  // RADIUS TOKENS
  // ========================================
  
  /// Border Radius - iOS Rounded Corners
  static const double radius4 = 4.0;
  static const double radius6 = 6.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;  // Primary card radius
  static const double radius16 = 16.0;  // Large card radius
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radiusPill = 999.0; // Pill shape

  // ========================================
  // COMPATIBILITY PROPERTIES
  // ========================================
  
  /// Surface Colors for compatibility
  static const Color surfaceSecondaryColor = surfaceSecondary;
  static const Color surfacePrimary70 = Color(0xB3FFFFFF); // 70% opacity
  
  /// Gradient helpers
  static const LinearGradient primaryCoralGradient = LinearGradient(
    colors: [primaryCoral, primaryCoralDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Screen edge insets for compatibility
  static const EdgeInsets spacingScreenEdgeInsets = EdgeInsets.all(spacingScreenEdge);
  
  // ========================================
  // SHADOW TOKENS
  // ========================================
  
  /// iOS Shadows - Soft and Subtle
  static const double shadowBlur4 = 4.0;
  static const double shadowBlur8 = 8.0;
  static const double shadowBlur12 = 12.0;
  static const double shadowBlur16 = 16.0;
  static const double shadowBlur20 = 20.0;
  
  static const double shadowOpacityLight = 0.08;
  static const double shadowOpacityMedium = 0.12;
  static const double shadowOpacityHeavy = 0.16;
  
  /// Shadow Presets
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
      blurRadius: shadowBlur20,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowFloating => [
    BoxShadow(
      color: Colors.black.withOpacity(shadowOpacityHeavy),
      blurRadius: shadowBlur20,
      offset: const Offset(0, 8),
    ),
  ];
  
  // ========================================
  // OPACITY TOKENS
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
  // MOTION TOKENS
  // ========================================
  
  /// Duration - iOS Standard Animations
  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 300);
  static const Duration durationSlower = Duration(milliseconds: 500);
  
  /// Curves - iOS Easing
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveDecelerate = Curves.easeOut;
  static const Curve curveAccelerate = Curves.easeIn;
  static const Curve curveSpring = Curves.elasticOut;
  
  // ========================================
  // ELEVATION TOKENS
  // ========================================
  
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
  
  // ========================================
  // SIZE TOKENS
  // ========================================
  
  /// Icon Sizes - iOS Standard
  static const double iconSize16 = 16.0;
  static const double iconSize20 = 20.0;
  static const double iconSize24 = 24.0;
  static const double iconSize28 = 28.0;
  static const double iconSize32 = 32.0;
  
  /// Button Heights - iOS Standard
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 44.0;  // iOS standard
  static const double buttonHeightLarge = 56.0;
  
  /// Input Heights
  static const double inputHeight = 44.0;  // iOS standard
  
  // ========================================
  // MISSING PROPERTIES FROM OLD THEME
  // ========================================
  
  // Color aliases for compatibility
  static const Color background = surfacePrimary;
  static const Color textLight = gray600;
  static const Color textMuted = gray500;
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color uclaBlue = accentTeal;
  static const Color nonPhotoBlue = accentTeal;
  static const Color mintGreen = success;
  static const Color buttonPrimary = primaryCoral;
  static const Color buttonDanger = error;
  static const Color buttonDisabled = gray300;
  static const double inputBorderRadius = radius12;
  static const List<Color> headerGradient = [primaryCoral, primaryCoralDark];
  static const List<Color> accentGradient = [accentTeal, accentTealDark];
  
  // Dark mode colors
  static const Color darkSurfacePrimary = Color(0xFF1C1C1E);
  
  // Spacing shortcuts
  static const SizedBox verticalSpaceXS = SizedBox(height: space4);
  static const SizedBox verticalSpaceSM = SizedBox(height: space8);
  static const SizedBox verticalSpaceMD = SizedBox(height: space16);
  static const SizedBox horizontalSpaceXS = SizedBox(width: space4);
  static const SizedBox horizontalSpaceSM = SizedBox(width: space8);
  static const SizedBox horizontalSpaceMD = SizedBox(width: space16);
  static const EdgeInsets spacingCardPaddingInsets = EdgeInsets.all(space16);
  
  // ========================================
  // HELPER METHODS
  // ========================================
  
  // Helper methods for gradients and shadows
  static LinearGradient getGradient(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static BoxShadow getCardShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(shadowOpacityLight),
      blurRadius: shadowBlur12,
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
  
  static ButtonStyle getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryCoral,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius12),
      ),
    );
  }
  
  /// Get color based on brightness
  static Color getAdaptiveColor(Color lightColor, Color darkColor, Brightness brightness) {
    return brightness == Brightness.light ? lightColor : darkColor;
  }
  
  /// Get text color for contrast
  static Color getContrastTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? gray900 : Colors.white;
  }
  
  /// Create rounded rectangle border
  static RoundedRectangleBorder getRoundedBorder(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
  }
  
  /// Create EdgeInsets from spacing token
  static EdgeInsets getEdgeInsets({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) return EdgeInsets.all(all);
    return EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );
  }
}