import 'package:flutter/material.dart';
import 'app_colors.dart';

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
        primary: DesignTokens.primaryCoral,
        primaryContainer: DesignTokens.primaryCoralLight,
        secondary: DesignTokens.accent,
        secondaryContainer: DesignTokens.accentLight,
        surface: DesignTokens.surfacePrimary,
        surfaceContainerHighest: DesignTokens.surfacePrimary,
        error: DesignTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DesignTokens.gray900,
        onError: Colors.white,
        outline: DesignTokens.nonPhotoBlue.withOpacity(0.3),
        shadow: DesignTokens.shadowMedium,
      ),
      
      // Scaffold Theme
      scaffoldBackgroundColor: DesignTokens.surfacePrimary,
      
      // App Bar Theme - Consistent across all screens
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.surfacePrimary,
        foregroundColor: DesignTokens.gray900,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: DesignTokens.shadowLight,
        titleTextStyle: TextStyle(
          color: DesignTokens.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: DesignTokens.gray900,
          size: 24,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      
      // Text Theme - Typography scale
      textTheme: TextTheme(
        // Display styles - For large text
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: DesignTokens.gray900,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: DesignTokens.gray900,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: DesignTokens.gray900,
          height: 1.3,
        ),
        
        // Headline styles - For section headers
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: DesignTokens.gray900,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DesignTokens.gray900,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DesignTokens.gray900,
          height: 1.4,
        ),
        
        // Title styles - For card titles, list items
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: DesignTokens.gray900,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: DesignTokens.gray900,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: DesignTokens.gray600,
          height: 1.4,
        ),
        
        // Body styles - For main content
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: DesignTokens.gray900,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: DesignTokens.gray900,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: DesignTokens.gray600,
          height: 1.5,
        ),
        
        // Label styles - For buttons, form labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: DesignTokens.gray900,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: DesignTokens.gray600,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: DesignTokens.textMuted,
          height: 1.4,
        ),
      ),
      
      // Card Theme - Consistent card styling
      cardTheme: CardThemeData(
        color: DesignTokens.surfacePrimary,
        elevation: 2,
        shadowColor: DesignTokens.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.buttonPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.buttonDisabled,
          disabledForegroundColor: DesignTokens.textMuted,
          elevation: 4,
          shadowColor: DesignTokens.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radius12),
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
          foregroundColor: DesignTokens.primaryCoral,
          disabledForegroundColor: DesignTokens.textMuted,
          side: BorderSide(color: DesignTokens.primaryCoral, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radius12),
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
          foregroundColor: DesignTokens.primaryCoral,
          disabledForegroundColor: DesignTokens.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radius12),
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
        fillColor: DesignTokens.surfacePrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.nonPhotoBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.nonPhotoBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.primaryCoral,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
          borderSide: BorderSide(
            color: DesignTokens.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(DesignTokens.space16),
        hintStyle: TextStyle(
          color: DesignTokens.textMuted,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: DesignTokens.gray600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfacePrimary,
        selectedItemColor: DesignTokens.primaryCoral,
        unselectedItemColor: DesignTokens.textMuted,
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
        backgroundColor: DesignTokens.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius16),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: DesignTokens.nonPhotoBlue.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.surfacePrimary,
        selectedColor: DesignTokens.primaryCoral.withOpacity(0.1),
        disabledColor: DesignTokens.buttonDisabled,
        labelStyle: TextStyle(color: DesignTokens.gray900),
        secondaryLabelStyle: TextStyle(color: DesignTokens.gray600),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius8),
          side: BorderSide(
            color: DesignTokens.nonPhotoBlue.withOpacity(0.3),
          ),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: DesignTokens.surfacePrimary,
        elevation: 8,
        shadowColor: DesignTokens.shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius16),
        ),
        titleTextStyle: TextStyle(
          color: DesignTokens.gray900,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: DesignTokens.gray600,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.gray900,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DesignTokens.primaryCoral,
        linearTrackColor: DesignTokens.nonPhotoBlue.withOpacity(0.3),
        circularTrackColor: DesignTokens.nonPhotoBlue.withOpacity(0.3),
      ),
    );
  }

  // Dark Theme - For future dark mode support
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.dark(
        primary: DesignTokens.primaryCoralLight,
        primaryContainer: DesignTokens.primaryCoral,
        secondary: DesignTokens.accent,
        secondaryContainer: DesignTokens.accentLight,
        surface: DesignTokens.darkSurfacePrimary,
        surfaceContainerHighest: const Color(0xFF0F1419),
        error: DesignTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        outline: DesignTokens.nonPhotoBlue.withOpacity(0.5),
        shadow: DesignTokens.shadowDark,
      ),
      
      scaffoldBackgroundColor: DesignTokens.darkSurfacePrimary,
      
      // Dark theme specific overrides
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.darkSurfacePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: DesignTokens.shadowDark,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: DesignTokens.darkSurfacePrimary.withOpacity(0.8),
        elevation: 4,
        shadowColor: DesignTokens.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
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
    color: DesignTokens.surfacePrimary,
    borderRadius: BorderRadius.circular(DesignTokens.radius16),
    boxShadow: [
      BoxShadow(
        color: DesignTokens.shadowLight,
        offset: const Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: DesignTokens.shadowMedium,
        offset: const Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration get pressedNeuomorphicDecoration => BoxDecoration(
    color: DesignTokens.surfacePrimary,
    borderRadius: BorderRadius.circular(DesignTokens.radius16),
    boxShadow: [
      BoxShadow(
        color: DesignTokens.shadowMedium,
        offset: const Offset(2, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ],
  );

  // Gradient decorations
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
    gradient: DesignTokens.primaryCoralGradient,
    borderRadius: BorderRadius.circular(DesignTokens.radius16),
    boxShadow: [DesignTokens.getElevatedShadow()],
  );

  static BoxDecoration get accentGradientDecoration => BoxDecoration(
    gradient: DesignTokens.getGradient(DesignTokens.accentGradient),
    borderRadius: BorderRadius.circular(DesignTokens.radius16),
    boxShadow: [DesignTokens.getElevatedShadow()],
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