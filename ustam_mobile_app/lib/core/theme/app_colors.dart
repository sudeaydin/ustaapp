import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Canlı ve Modern
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryPurple = Color(0xFF7B68EE);
  static const Color primaryGreen = Color(0xFF00D4AA);
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryRed = Color(0xFFE53E3E);

  // Background Colors - Yumuşak ve Temiz
  static const Color backgroundLight = Color(0xFFF8FAFD);
  static const Color backgroundDark = Color(0xFF1A202C);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF1F5F9);
  static const Color overlayColor = Color(0x1A000000);

  // Accent Colors - Çizgifilmsel Vurgular
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color accentIndigo = Color(0xFF667EEA);

  // Text Colors - Okunabilir ve Modern
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors - Dinamik Durumlar
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF4299E1);

  // Gradient Colors - Modern Geçişler
  static const List<Color> primaryGradient = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF11998E),
    Color(0xFF38EF7D),
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFFFA726),
    Color(0xFFFFCC02),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFC44569),
  ];

  // Shadow Colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x25000000);

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
}