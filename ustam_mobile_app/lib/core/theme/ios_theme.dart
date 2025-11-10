import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'design_tokens.dart';

/// iOS + Airbnb Theme System
/// Material3 + Cupertino hybrid approach for iOS-like experience
class iOSTheme {
  iOSTheme._();

  // ========================================
  // LIGHT THEME
  // ========================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme - iOS + Airbnb
      colorScheme: ColorScheme.light(
        primary: DesignTokens.primaryCoral,
        primaryContainer: DesignTokens.primaryCoralLight,
        secondary: DesignTokens.accentTeal,
        secondaryContainer: DesignTokens.accentTealLight,
        surface: DesignTokens.surfacePrimary,
        surfaceContainerLowest: DesignTokens.surfacePrimary,
        surfaceContainerLow: DesignTokens.surfaceSecondary,
        surfaceContainer: DesignTokens.surfaceTertiary,
        surfaceContainerHigh: DesignTokens.gray100,
        surfaceContainerHighest: DesignTokens.gray200,
        error: DesignTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DesignTokens.gray900,
        onError: Colors.white,
        outline: DesignTokens.gray300,
        outlineVariant: DesignTokens.gray200,
        shadow: DesignTokens.gray900.withOpacity(DesignTokens.shadowOpacityLight),
        scrim: DesignTokens.gray900.withOpacity(DesignTokens.opacity50),
      ),
      
      // Scaffold
      scaffoldBackgroundColor: DesignTokens.surfacePrimary,
      
      // Typography - iOS San Francisco
      textTheme: _buildTextTheme(Brightness.light),
      
      // App Bar - iOS Large Title Style
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.surfacePrimary,
        foregroundColor: DesignTokens.gray900,
        elevation: DesignTokens.elevation0,
        scrolledUnderElevation: DesignTokens.elevation1,
        shadowColor: DesignTokens.gray900.withOpacity(DesignTokens.shadowOpacityLight),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyDisplay,
          fontSize: DesignTokens.fontSize22,
          fontWeight: DesignTokens.fontWeightSemibold,
          color: DesignTokens.gray900,
          height: DesignTokens.lineHeight28 / DesignTokens.fontSize22,
        ),
        toolbarTextStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize17,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.gray900,
        ),
        iconTheme: IconThemeData(
          color: DesignTokens.gray900,
          size: DesignTokens.iconSize24,
        ),
        actionsIconTheme: IconThemeData(
          color: DesignTokens.primaryCoral,
          size: DesignTokens.iconSize24,
        ),
      ),
      
      // Card Theme - Airbnb Style
      cardTheme: CardThemeData(
        color: DesignTokens.surfacePrimary,
        shadowColor: Colors.black.withOpacity(DesignTokens.shadowOpacityLight),
        elevation: DesignTokens.elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.circular(DesignTokens.radius16),
        ),
        margin: DesignTokens.getEdgeInsets(all: DesignTokens.space8),
      ),
      
      // Elevated Button - Primary CTA
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryCoral,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.gray300,
          disabledForegroundColor: DesignTokens.gray600,
          elevation: DesignTokens.elevation2,
          shadowColor: DesignTokens.primaryCoral.withOpacity(DesignTokens.opacity30),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          ),
          padding: DesignTokens.getEdgeInsets(
            horizontal: DesignTokens.spacingButtonPadding,
            vertical: DesignTokens.space12,
          ),
          minimumSize: Size(double.infinity, DesignTokens.buttonHeightMedium),
          textStyle: TextStyle(
            fontFamily: DesignTokens.fontFamilyPrimary,
            fontSize: DesignTokens.fontSize16,
            fontWeight: DesignTokens.fontWeightSemibold,
            height: DesignTokens.lineHeight21 / DesignTokens.fontSize16,
          ),
        ),
      ),
      
      // Outlined Button - Secondary
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryCoral,
          disabledForegroundColor: DesignTokens.gray600,
          side: BorderSide(
            color: DesignTokens.primaryCoral,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          ),
          padding: DesignTokens.getEdgeInsets(
            horizontal: DesignTokens.spacingButtonPadding,
            vertical: DesignTokens.space12,
          ),
          minimumSize: Size(double.infinity, DesignTokens.buttonHeightMedium),
          textStyle: TextStyle(
            fontFamily: DesignTokens.fontFamilyPrimary,
            fontSize: DesignTokens.fontSize16,
            fontWeight: DesignTokens.fontWeightSemibold,
            height: DesignTokens.lineHeight21 / DesignTokens.fontSize16,
          ),
        ),
      ),
      
      // Text Button - Tertiary
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.primaryCoral,
          disabledForegroundColor: DesignTokens.gray600,
          padding: DesignTokens.getEdgeInsets(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space12,
          ),
          minimumSize: Size(0, DesignTokens.buttonHeightMedium),
          textStyle: TextStyle(
            fontFamily: DesignTokens.fontFamilyPrimary,
            fontSize: DesignTokens.fontSize16,
            fontWeight: DesignTokens.fontWeightSemibold,
            height: DesignTokens.lineHeight21 / DesignTokens.fontSize16,
          ),
        ),
      ),
      
      // Input Decoration - iOS Style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surfaceSecondary,
        contentPadding: DesignTokens.getEdgeInsets(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.gray300,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.gray300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.primaryCoral,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.error,
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize15,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.gray600,
        ),
        hintStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize15,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.gray500,
        ),
        errorStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize13,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.error,
        ),
      ),
      
      // Bottom Navigation Bar - iOS Tab Bar Style
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfacePrimary,
        selectedItemColor: DesignTokens.primaryCoral,
        unselectedItemColor: DesignTokens.gray600,
        selectedLabelStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize11,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize11,
          fontWeight: DesignTokens.fontWeightRegular,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: DesignTokens.elevation8,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: DesignTokens.gray300,
        thickness: 0.5,
        space: 0.5,
      ),
      
      // List Tile Theme - iOS Style
      listTileTheme: ListTileThemeData(
        contentPadding: DesignTokens.getEdgeInsets(
          horizontal: DesignTokens.spacingScreenEdge,
          vertical: DesignTokens.space8,
        ),
        minVerticalPadding: DesignTokens.space8,
        titleTextStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize17,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.gray900,
          height: DesignTokens.lineHeight22 / DesignTokens.fontSize17,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize15,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.gray600,
          height: DesignTokens.lineHeight20 / DesignTokens.fontSize15,
        ),
        iconColor: DesignTokens.gray600,
      ),
      
      // Snack Bar Theme - iOS Style
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.gray900,
        contentTextStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize15,
          fontWeight: DesignTokens.fontWeightRegular,
          color: Colors.white,
        ),
        actionTextColor: DesignTokens.primaryCoral,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Switch Theme - iOS Style
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return DesignTokens.gray300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignTokens.primaryCoral;
          }
          return DesignTokens.gray300;
        }),
      ),
      
      // Extensions
      extensions: [
        _iOSExtension.light,
      ],
    );
  }
  
  // ========================================
  // DARK THEME
  // ========================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme - iOS + Airbnb Dark
      colorScheme: ColorScheme.dark(
        primary: DesignTokens.darkPrimaryCoral,
        primaryContainer: DesignTokens.primaryCoralDark,
        secondary: DesignTokens.darkAccentTeal,
        secondaryContainer: DesignTokens.accentTealDark,
        surface: DesignTokens.darkSurfacePrimary,
        surfaceContainerLowest: DesignTokens.darkSurfacePrimary,
        surfaceContainerLow: DesignTokens.darkSurfaceSecondary,
        surfaceContainer: DesignTokens.darkSurfaceTertiary,
        surfaceContainerHigh: DesignTokens.darkGray200,
        surfaceContainerHighest: DesignTokens.darkGray300,
        error: DesignTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DesignTokens.darkGray900,
        onError: Colors.white,
        outline: DesignTokens.darkGray300,
        outlineVariant: DesignTokens.darkGray200,
        shadow: Colors.black.withOpacity(DesignTokens.shadowOpacityMedium),
        scrim: Colors.black.withOpacity(DesignTokens.opacity60),
      ),
      
      // Scaffold
      scaffoldBackgroundColor: DesignTokens.darkSurfacePrimary,
      
      // Typography - iOS San Francisco
      textTheme: _buildTextTheme(Brightness.dark),
      
      // Extensions
      extensions: [
        _iOSExtension.dark,
      ],
    );
  }
  
  // ========================================
  // CUPERTINO THEME
  // ========================================
  
  static CupertinoThemeData get cupertinoLightTheme {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: DesignTokens.primaryCoral,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: DesignTokens.surfacePrimary,
      barBackgroundColor: DesignTokens.surfacePrimary.withOpacity(0.9),
      textTheme: CupertinoTextThemeData(
        primaryColor: DesignTokens.gray900,
        textStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize17,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.gray900,
        ),
      ),
    );
  }
  
  static CupertinoThemeData get cupertinoDarkTheme {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: DesignTokens.darkPrimaryCoral,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: DesignTokens.darkSurfacePrimary,
      barBackgroundColor: DesignTokens.darkSurfacePrimary.withOpacity(0.9),
      textTheme: CupertinoTextThemeData(
        primaryColor: DesignTokens.darkGray900,
        textStyle: TextStyle(
          fontFamily: DesignTokens.fontFamilyPrimary,
          fontSize: DesignTokens.fontSize17,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.darkGray900,
        ),
      ),
    );
  }
  
  // ========================================
  // TEXT THEME BUILDER
  // ========================================
  
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textPrimary = brightness == Brightness.light 
        ? DesignTokens.gray900 
        : DesignTokens.darkGray900;
    final Color textSecondary = brightness == Brightness.light 
        ? DesignTokens.gray600 
        : DesignTokens.darkGray600;
    
    return TextTheme(
      // Display - Large headlines
      displayLarge: TextStyle(
        fontFamily: DesignTokens.fontFamilyDisplay,
        fontSize: DesignTokens.fontSize34,
        fontWeight: DesignTokens.fontWeightBold,
        color: textPrimary,
        height: DesignTokens.lineHeight41 / DesignTokens.fontSize34,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: DesignTokens.fontFamilyDisplay,
        fontSize: DesignTokens.fontSize28,
        fontWeight: DesignTokens.fontWeightSemibold,
        color: textPrimary,
        height: DesignTokens.lineHeight34 / DesignTokens.fontSize28,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        fontFamily: DesignTokens.fontFamilyDisplay,
        fontSize: DesignTokens.fontSize22,
        fontWeight: DesignTokens.fontWeightSemibold,
        color: textPrimary,
        height: DesignTokens.lineHeight28 / DesignTokens.fontSize22,
        letterSpacing: -0.1,
      ),
      
      // Headline - Section headers
      headlineLarge: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize22,
        fontWeight: DesignTokens.fontWeightSemibold,
        color: textPrimary,
        height: DesignTokens.lineHeight28 / DesignTokens.fontSize22,
      ),
      headlineMedium: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize20,
        fontWeight: DesignTokens.fontWeightSemibold,
        color: textPrimary,
        height: DesignTokens.lineHeight25 / DesignTokens.fontSize20,
      ),
      headlineSmall: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize17,
        fontWeight: DesignTokens.fontWeightSemibold,
        color: textPrimary,
        height: DesignTokens.lineHeight22 / DesignTokens.fontSize17,
      ),
      
      // Title - Component titles
      titleLarge: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize17,
        fontWeight: DesignTokens.fontWeightSemibold,
        color: textPrimary,
        height: DesignTokens.lineHeight22 / DesignTokens.fontSize17,
      ),
      titleMedium: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize16,
        fontWeight: DesignTokens.fontWeightMedium,
        color: textPrimary,
        height: DesignTokens.lineHeight21 / DesignTokens.fontSize16,
      ),
      titleSmall: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize15,
        fontWeight: DesignTokens.fontWeightMedium,
        color: textSecondary,
        height: DesignTokens.lineHeight20 / DesignTokens.fontSize15,
      ),
      
      // Body - Main content
      bodyLarge: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize17,
        fontWeight: DesignTokens.fontWeightRegular,
        color: textPrimary,
        height: DesignTokens.lineHeight22 / DesignTokens.fontSize17,
      ),
      bodyMedium: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize15,
        fontWeight: DesignTokens.fontWeightRegular,
        color: textPrimary,
        height: DesignTokens.lineHeight20 / DesignTokens.fontSize15,
      ),
      bodySmall: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize13,
        fontWeight: DesignTokens.fontWeightRegular,
        color: textSecondary,
        height: DesignTokens.lineHeight18 / DesignTokens.fontSize13,
      ),
      
      // Label - Buttons, captions
      labelLarge: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize16,
        fontWeight: DesignTokens.fontWeightSemibold,
        color: textPrimary,
        height: DesignTokens.lineHeight21 / DesignTokens.fontSize16,
      ),
      labelMedium: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize13,
        fontWeight: DesignTokens.fontWeightMedium,
        color: textSecondary,
        height: DesignTokens.lineHeight18 / DesignTokens.fontSize13,
      ),
      labelSmall: TextStyle(
        fontFamily: DesignTokens.fontFamilyPrimary,
        fontSize: DesignTokens.fontSize11,
        fontWeight: DesignTokens.fontWeightMedium,
        color: textSecondary,
        height: DesignTokens.lineHeight13 / DesignTokens.fontSize11,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ========================================
// CUSTOM THEME EXTENSION
// ========================================

@immutable
class _iOSExtension extends ThemeExtension<_iOSExtension> {
  const _iOSExtension({
    required this.cardShadow,
    required this.elevatedShadow,
    required this.floatingShadow,
    required this.primaryGradient,
    required this.accentGradient,
    required this.surfaceGradient,
  });

  final List<BoxShadow> cardShadow;
  final List<BoxShadow> elevatedShadow;
  final List<BoxShadow> floatingShadow;
  final LinearGradient primaryGradient;
  final LinearGradient accentGradient;
  final LinearGradient surfaceGradient;

  static const light = _iOSExtension(
    cardShadow: [
      BoxShadow(
        color: Color(0x14000000), // 8% opacity
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
    elevatedShadow: [
      BoxShadow(
        color: Color(0x1F000000), // 12% opacity
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
    floatingShadow: [
      BoxShadow(
        color: Color(0x29000000), // 16% opacity
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
    primaryGradient: LinearGradient(
      colors: [DesignTokens.primaryCoral, DesignTokens.primaryCoralDark],
    ),
    accentGradient: LinearGradient(
      colors: [DesignTokens.accentTeal, DesignTokens.accentTealDark],
    ),
    surfaceGradient: LinearGradient(
      colors: [DesignTokens.surfacePrimary, DesignTokens.surfaceSecondary],
    ),
  );

  static const dark = _iOSExtension(
    cardShadow: [
      BoxShadow(
        color: Color(0x29000000), // 16% opacity for dark mode
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
    elevatedShadow: [
      BoxShadow(
        color: Color(0x3D000000), // 24% opacity for dark mode
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
    floatingShadow: [
      BoxShadow(
        color: Color(0x52000000), // 32% opacity for dark mode
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
    primaryGradient: LinearGradient(
      colors: [DesignTokens.darkPrimaryCoral, DesignTokens.primaryCoralDark],
    ),
    accentGradient: LinearGradient(
      colors: [DesignTokens.darkAccentTeal, DesignTokens.accentTealDark],
    ),
    surfaceGradient: LinearGradient(
      colors: [DesignTokens.darkSurfacePrimary, DesignTokens.darkSurfaceSecondary],
    ),
  );

  @override
  _iOSExtension copyWith({
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? elevatedShadow,
    List<BoxShadow>? floatingShadow,
    LinearGradient? primaryGradient,
    LinearGradient? accentGradient,
    LinearGradient? surfaceGradient,
  }) {
    return _iOSExtension(
      cardShadow: cardShadow ?? this.cardShadow,
      elevatedShadow: elevatedShadow ?? this.elevatedShadow,
      floatingShadow: floatingShadow ?? this.floatingShadow,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      accentGradient: accentGradient ?? this.accentGradient,
      surfaceGradient: surfaceGradient ?? this.surfaceGradient,
    );
  }

  @override
  _iOSExtension lerp(_iOSExtension? other, double t) {
    if (other is! _iOSExtension) return this;
    return _iOSExtension(
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      elevatedShadow: t < 0.5 ? elevatedShadow : other.elevatedShadow,
      floatingShadow: t < 0.5 ? floatingShadow : other.floatingShadow,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      accentGradient: LinearGradient.lerp(accentGradient, other.accentGradient, t)!,
      surfaceGradient: LinearGradient.lerp(surfaceGradient, other.surfaceGradient, t)!,
    );
  }
}

// ========================================
// THEME EXTENSION GETTER
// ========================================

extension iOSThemeExtension on ThemeData {
  _iOSExtension get iOSExtension => extension<_iOSExtension>()!;
}