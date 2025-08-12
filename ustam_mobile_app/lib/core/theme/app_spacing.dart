import 'package:flutter/material.dart';

class AppSpacing {
  // Airbnb 8px Grid System
  static const double _baseUnit = 8.0;
  
  // Basic spacing units
  static const double xs = _baseUnit * 0.5;  // 4px
  static const double sm = _baseUnit * 1;    // 8px
  static const double md = _baseUnit * 2;    // 16px
  static const double lg = _baseUnit * 3;    // 24px
  static const double xl = _baseUnit * 4;    // 32px
  static const double xxl = _baseUnit * 6;   // 48px
  static const double xxxl = _baseUnit * 8;  // 64px
  
  // Component specific spacing
  static const double cardPadding = md;           // 16px
  static const double cardMargin = sm;            // 8px
  static const double cardSpacing = md;           // 16px between cards
  
  static const double buttonPaddingHorizontal = lg; // 24px
  static const double buttonPaddingVertical = md;   // 16px
  static const double buttonSpacing = md;           // 16px between buttons
  
  static const double screenPadding = md;          // 16px screen edges
  static const double sectionSpacing = lg;        // 24px between sections
  static const double contentSpacing = md;        // 16px between content
  
  static const double listItemSpacing = sm;       // 8px between list items
  static const double listItemPadding = md;       // 16px list item padding
  
  // Form spacing
  static const double formFieldSpacing = md;      // 16px between form fields
  static const double formSectionSpacing = lg;   // 24px between form sections
  
  // Icon spacing
  static const double iconSpacing = sm;           // 8px around icons
  static const double iconTextSpacing = sm;      // 8px between icon and text
  
  // Airbnb specific spacing
  static const double cardBorderRadius = 12.0;   // Airbnb card radius
  static const double buttonBorderRadius = 8.0;  // Airbnb button radius
  static const double inputBorderRadius = 8.0;   // Airbnb input radius
  
  // Edge Insets helpers
  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets screenPaddingInsets = EdgeInsets.all(screenPadding);
  static const EdgeInsets contentPaddingInsets = EdgeInsets.all(contentSpacing);
  
  static const EdgeInsets buttonPaddingInsets = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );
  
  static const EdgeInsets listItemPaddingInsets = EdgeInsets.symmetric(
    horizontal: listItemPadding,
    vertical: listItemSpacing,
  );
  
  // Vertical spacing widgets
  static const Widget verticalSpaceXS = SizedBox(height: xs);
  static const Widget verticalSpaceSM = SizedBox(height: sm);
  static const Widget verticalSpaceMD = SizedBox(height: md);
  static const Widget verticalSpaceLG = SizedBox(height: lg);
  static const Widget verticalSpaceXL = SizedBox(height: xl);
  static const Widget verticalSpaceXXL = SizedBox(height: xxl);
  
  // Horizontal spacing widgets
  static const Widget horizontalSpaceXS = SizedBox(width: xs);
  static const Widget horizontalSpaceSM = SizedBox(width: sm);
  static const Widget horizontalSpaceMD = SizedBox(width: md);
  static const Widget horizontalSpaceLG = SizedBox(width: lg);
  static const Widget horizontalSpaceXL = SizedBox(width: xl);
  static const Widget horizontalSpaceXXL = SizedBox(width: xxl);
  
  // Border radius helpers
  static const BorderRadius cardBorderRadiusGeometry = BorderRadius.all(
    Radius.circular(cardBorderRadius),
  );
  
  static const BorderRadius buttonBorderRadiusGeometry = BorderRadius.all(
    Radius.circular(buttonBorderRadius),
  );
  
  static const BorderRadius inputBorderRadiusGeometry = BorderRadius.all(
    Radius.circular(inputBorderRadius),
  );
  
  // Shadow helpers (Airbnb style)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
}