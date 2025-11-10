import 'package:flutter/material.dart';
import 'design_tokens.dart' as dt;

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Light Theme - Primary theme for the app
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme - Based on our custom palette
      colorScheme: ColorScheme.light(
        primary: dt.DesignTokens.primaryCoral,
        primaryContainer: dt.DesignTokens.primaryCoralLight,
        secondary: dt.DesignTokens.accent,
        secondaryContainer: dt.DesignTokens.accentLight,
        surface: dt.DesignTokens.surfacePrimary,
        surfaceContainerHighest: dt.DesignTokens.surfacePrimary,
        error: dt.DesignTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: dt.DesignTokens.gray900,
        onError: Colors.white,
        outline: dt.DesignTokens.nonPhotoBlue.withOpacity(0.3),
        shadow: dt.DesignTokens.shadowMedium,
      ),
      
      // Scaffold Theme
      scaffoldBackgroundColor: dt.DesignTokens.surfacePrimary,
      
      // App Bar Theme - Consistent across all screens
      appBarTheme: AppBarTheme(
        backgroundColor: dt.DesignTokens.surfacePrimary,
        foregroundColor: dt.DesignTokens.gray900,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: dt.DesignTokens.shadowLight,
        titleTextStyle: TextStyle(
          color: dt.DesignTokens.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: dt.DesignTokens.gray900,
          size: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      
      // Text Theme - Typography scale
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: dt.DesignTokens.gray900,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: dt.DesignTokens.gray900,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: dt.DesignTokens.gray900,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: dt.DesignTokens.gray900,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: dt.DesignTokens.gray900,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: dt.DesignTokens.gray900,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: dt.DesignTokens.gray900,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: dt.DesignTokens.gray900,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: dt.DesignTokens.gray600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: dt.DesignTokens.gray900,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: dt.DesignTokens.gray900,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: dt.DesignTokens.gray600,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: dt.DesignTokens.gray900,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: dt.DesignTokens.gray600,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: dt.DesignTokens.textMuted,
          height: 1.4,
        ),
      ),
      
      // Card Theme - Consistent card styling
      cardTheme: CardTheme(
        color: dt.DesignTokens.surfacePrimary,
        elevation: 2,
        shadowColor: dt.DesignTokens.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dt.DesignTokens.buttonPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: dt.DesignTokens.buttonDisabled,
          disabledForegroundColor: dt.DesignTokens.textMuted,
          elevation: 4,
          shadowColor: dt.DesignTokens.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dt.DesignTokens.primaryCoral,
          disabledForegroundColor: dt.DesignTokens.textMuted,
          side: BorderSide(color: dt.DesignTokens.primaryCoral, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dt.DesignTokens.primaryCoral,
          disabledForegroundColor: dt.DesignTokens.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme - Form styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dt.DesignTokens.surfacePrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
          borderSide: BorderSide(
            color: dt.DesignTokens.nonPhotoBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
          borderSide: BorderSide(
            color: dt.DesignTokens.nonPhotoBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
          borderSide: BorderSide(
            color: dt.DesignTokens.primaryCoral,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
          borderSide: BorderSide(
            color: dt.DesignTokens.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
          borderSide: BorderSide(
            color: dt.DesignTokens.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(dt.DesignTokens.space16),
        hintStyle: TextStyle(
          color: dt.DesignTokens.textMuted,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: dt.DesignTokens.gray600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        counterStyle: TextStyle(color: dt.DesignTokens.gray600),
        helperStyle: TextStyle(color: dt.DesignTokens.gray600),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dt.DesignTokens.surfacePrimary,
        selectedItemColor: dt.DesignTokens.primaryCoral,
        unselectedItemColor: dt.DesignTokens.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: dt.DesignTokens.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius16),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: dt.DesignTokens.nonPhotoBlue.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: dt.DesignTokens.surfacePrimary,
        selectedColor: dt.DesignTokens.primaryCoral.withOpacity(0.1),
        disabledColor: dt.DesignTokens.buttonDisabled,
        labelStyle: TextStyle(color: dt.DesignTokens.gray900),
        secondaryLabelStyle: TextStyle(color: dt.DesignTokens.gray600),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius8),
          side: BorderSide(
            color: dt.DesignTokens.nonPhotoBlue.withOpacity(0.3),
          ),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: dt.DesignTokens.surfacePrimary,
        elevation: 8,
        shadowColor: dt.DesignTokens.shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius16),
        ),
        titleTextStyle: TextStyle(
          color: dt.DesignTokens.gray900,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: dt.DesignTokens.gray600,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dt.DesignTokens.gray900,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: dt.DesignTokens.primaryCoral,
        linearTrackColor: dt.DesignTokens.nonPhotoBlue.withOpacity(0.3),
        circularTrackColor: dt.DesignTokens.nonPhotoBlue.withOpacity(0.3),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: dt.DesignTokens.primaryCoralLight,
        primaryContainer: dt.DesignTokens.primaryCoral,
        secondary: dt.DesignTokens.accent,
        secondaryContainer: dt.DesignTokens.accentLight,
        surface: dt.DesignTokens.darkSurfacePrimary,
        surfaceContainerHighest: const Color(0xFF0F1419),
        error: dt.DesignTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        outline: dt.DesignTokens.nonPhotoBlue.withOpacity(0.5),
        shadow: dt.DesignTokens.shadowDark,
      ),
      scaffoldBackgroundColor: dt.DesignTokens.darkSurfacePrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: dt.DesignTokens.darkSurfacePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: dt.DesignTokens.shadowDark,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      cardTheme: CardTheme(
        color: dt.DesignTokens.darkSurfacePrimary.withOpacity(0.8),
        elevation: 4,
        shadowColor: dt.DesignTokens.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
        ),
      ),
    );
  }

  // Helper method to get current theme based on system
  static ThemeData getTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  // Custom decoration helpers
  static BoxDecoration get neuomorphicDecoration => BoxDecoration(
        color: dt.DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(dt.DesignTokens.radius16),
        boxShadow: [
          BoxShadow(
            color: dt.DesignTokens.shadowLight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: dt.DesignTokens.shadowMedium,
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      );

  static BoxDecoration get pressedNeuomorphicDecoration => BoxDecoration(
        color: dt.DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(dt.DesignTokens.radius16),
        boxShadow: [
          BoxShadow(
            color: dt.DesignTokens.shadowMedium,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      );

  // Gradient decorations
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
        gradient: dt.DesignTokens.primaryCoralGradient,
        borderRadius: BorderRadius.circular(dt.DesignTokens.radius16),
        boxShadow: [dt.DesignTokens.getElevatedShadow()],
      );

  static BoxDecoration get accentGradientDecoration => BoxDecoration(
        gradient: dt.DesignTokens.getGradient(dt.DesignTokens.accentGradient),
        borderRadius: BorderRadius.circular(dt.DesignTokens.radius16),
        boxShadow: [dt.DesignTokens.getElevatedShadow()],
      );

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Common curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.fastOutSlowIn;
}
