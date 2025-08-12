import 'package:flutter/material.dart';

class AppColors {
  // Airbnb Primary Colors
  static const Color primary = Color(0xFFC64191); // Custom Pink #C64191
  static const Color secondary = Color(0xFF00A699); // Airbnb Teal
  static const Color tertiary = Color(0xFFFC642D); // Airbnb Orange
  
  // Airbnb Neutral Colors
  static const Color textPrimary = Color(0xFF222222); // Airbnb Dark Gray
  static const Color textSecondary = Color(0xFF717171); // Airbnb Medium Gray
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFB0B0B0); // Light Gray
  
  // Airbnb Background Colors
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color cardBackground = Color(0xFFF7F7F7); // Off White
  static const Color surfaceColor = Color(0xFFFAFAFA); // Very Light Gray
  
  // Airbnb Accent Colors
  static const Color success = Color(0xFF008A05); // Green
  static const Color warning = Color(0xFFFFB400); // Yellow
  static const Color error = Color(0xFFD93025); // Red
  static const Color info = Color(0xFF0073E6); // Blue
  
  // Airbnb Border Colors
  static const Color border = Color(0xFFDDDDDD); // Light Border
  static const Color divider = Color(0xFFEBEBEB); // Very Light Border
  
  // BACKWARD COMPATIBILITY - Map old colors to new Airbnb colors
  static const Color uclaBlue = Color(0xFFFF5A5F); // Primary Airbnb Red
  static const Color delftBlue = Color(0xFF00A699); // Secondary Airbnb Teal
  static const Color poppy = Color(0xFFFC642D); // Tertiary Airbnb Orange
  static const Color mintGreen = Color(0xFF008A05); // Success Green
  static const Color nonPhotoBlue = Color(0xFF9FDBF0); // Keep original
  
  // Text colors (backward compatibility)
  static const Color textMuted = Color(0xFF717171); // Medium Gray
  
  // Background colors (backward compatibility)
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundDark = Color(0xFF222222); // Dark Gray
  static const Color surface = Color(0xFFF7F7F7); // Off White
  static const Color cardBackground70 = Color(0xFFF7F7F7); // Off White
  
  // Button colors (backward compatibility)
  static const Color buttonPrimary = Color(0xFFFF5A5F); // Primary Red
  static const Color buttonSecondary = Color(0xFF00A699); // Secondary Teal
  static const Color buttonDanger = Color(0xFFD93025); // Error Red
  static const Color buttonDisabled = Color(0xFFB0B0B0); // Light Gray
  
  // Shadow colors (backward compatibility)
  static const Color shadowLight = Color(0x1A000000); // Light shadow
  static const Color shadowMedium = Color(0x33000000); // Medium shadow
  static const Color shadowDark = Color(0x4D000000); // Dark shadow
  
  // Legacy compatibility colors
  static const Color primaryLight = Color(0xFFFF7A7F); // Lighter primary
  static const Color accent = Color(0xFF00A699); // Same as secondary
  static const Color accentLight = Color(0xFF33B5AA); // Lighter accent
  
  // Airbnb Gradients
  static const List<Color> primaryGradient = [
    Color(0xFFFF5A5F), // Airbnb Red
    Color(0xFFFF385C), // Darker Red
  ];
  
  static const List<Color> headerGradient = [
    Color(0xFFFF5A5F), // Airbnb Red
    Color(0xFFFC642D), // Airbnb Orange
  ];
  
  static const List<Color> cardGradient = [
    Color(0xFFFAFAFA),
    Color(0xFFFFFFFF),
  ];
  
  // Legacy gradient compatibility
  static const List<Color> accentGradient = [
    Color(0xFF00A699), // Airbnb Teal
    Color(0xFF33B5AA), // Lighter Teal
  ];

  // Gradient helper with backward compatibility
  static LinearGradient getGradient(List<Color> colors, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }

  // Shadow helpers with backward compatibility
  static BoxShadow getElevatedShadow({double blurRadius = 12}) {
    return BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: blurRadius,
      offset: const Offset(0, 2),
    );
  }
  
  static BoxShadow getCardShadow({double blurRadius = 8}) {
    return BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: blurRadius,
      offset: const Offset(0, 1),
    );
  }
  
  // Button style helpers (backward compatibility)
  static ButtonStyle getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: buttonPrimary,
      foregroundColor: textWhite,
      disabledBackgroundColor: buttonDisabled,
      disabledForegroundColor: textMuted,
      elevation: 2,
      shadowColor: shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }
}