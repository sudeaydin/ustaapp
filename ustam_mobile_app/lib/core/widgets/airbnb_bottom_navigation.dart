import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AirbnbBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AirbnbNavItem> items;

  const AirbnbBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80, // Airbnb navigation height
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: _buildNavItem(item, isSelected),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(AirbnbNavItem item, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with background for selected state
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? DesignTokens.primaryCoral.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: const BorderRadius.circular(DesignTokens.radius12),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 24,
              color: isSelected 
                  ? DesignTokens.primaryCoral 
                  : DesignTokens.gray600,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Label
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected 
                  ? DesignTokens.primaryCoral 
                  : DesignTokens.gray600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class AirbnbNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AirbnbNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// Common navigation items
class AirbnbNavItems {
  static const explore = AirbnbNavItem(
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    label: 'Keşfet',
  );

  static const favorites = AirbnbNavItem(
    icon: Icons.favorite_border,
    activeIcon: Icons.favorite,
    label: 'Favoriler',
  );

  static const trips = AirbnbNavItem(
    icon: Icons.card_travel_outlined,
    activeIcon: Icons.card_travel,
    label: 'Geziler',
  );

  static const inbox = AirbnbNavItem(
    icon: Icons.chat_bubble_outline,
    activeIcon: Icons.chat_bubble,
    label: 'Mesajlar',
  );

  static const profile = AirbnbNavItem(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profil',
  );

  // For our app
  static const search = AirbnbNavItem(
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    label: 'Ara',
  );

  static const calendar = AirbnbNavItem(
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
    label: 'Takvim',
  );

  static const messages = AirbnbNavItem(
    icon: Icons.chat_bubble_outline,
    activeIcon: Icons.chat_bubble,
    label: 'Mesajlar',
  );

  static const dashboard = AirbnbNavItem(
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    label: 'Panel',
  );
}