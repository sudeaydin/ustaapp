import 'package:flutter/material.dart';

class AppColors {
  // Airbnb Primary Colors
  static const Color primary = Color(0xFFFF5A5F); // Airbnb Red/Pink
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
  
  // Legacy colors (keeping for compatibility)
  static const Color nonPhotoBlue = Color(0xFF9FDBF0);
  
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

  // Gradient helper
  static LinearGradient getGradient(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Airbnb Shadow
  static BoxShadow getElevatedShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 2),
    );
  }
  
  static BoxShadow getCardShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 1),
    );
  }
}