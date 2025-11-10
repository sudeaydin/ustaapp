import 'package:flutter/material.dart';
import 'design_tokens.dart' as dt;

class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
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

      scaffoldBackgroundColor: dt.DesignTokens.surfacePrimary,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: dt.DesignTokens.surfacePrimary,
        foregroundColor: dt.DesignTokens.gray900,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: dt.DesignTokens.shadowLight,
        titleTextStyle: const TextStyle(
          color: dt.DesignTokens.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: dt.DesignTokens.gray900,
          size: 24,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
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

      // Card Theme
      cardTheme: CardTheme(
        color: dt.DesignTokens.surfacePrimary,
        elevation: 2,
        shadowColor: dt.DesignTokens.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dt.DesignTokens.radius12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),

      // Elevated Button
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

      // Outlined Button
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

      // Text Button
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

      // Input Decoration
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
        hintStyle: const TextStyle(
          color: dt.DesignTokens.textMuted,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: dt.DesignTokens.gray600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        counterStyle: const TextStyle(color: dt.DesignTokens.gray600),
        helperStyle: const TextStyle(color: dt.DesignTokens.gray600),
      ),

      // Neuomorphic Decoration Example
      // BoxShadow listleri const olarak işaretlendi
      extensions: <ThemeExtension<dynamic>>[
        const _NeuomorphicDecoration(),
      ],
    );
  }

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

  static ThemeData getTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
}

// Custom ThemeExtension to hold neuomorphic decorations as const
class _NeuomorphicDecoration extends ThemeExtension<_NeuomorphicDecoration> {
  const _NeuomorphicDecoration();

  BoxDecoration get neuomorphicDecoration => BoxDecoration(
        color: dt.DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(dt.DesignTokens.radius16),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE0E0E0), // shadowLight örnek
            offset: Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0xFFB0B0B0), // shadowMedium örnek
            offset: Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      );

  BoxDecoration get pressedNeuomorphicDecoration => BoxDecoration(
        color: dt.DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(dt.DesignTokens.radius16),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB0B0B0), // shadowMedium örnek
            offset: Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      );

  @override
  _NeuomorphicDecoration copyWith() => const _NeuomorphicDecoration();

  @override
  _NeuomorphicDecoration lerp(
      covariant ThemeExtension<_NeuomorphicDecoration>? other, double t) =>
      this;
}
