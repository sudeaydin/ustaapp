import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'airbnb_bottom_navigation.dart';
import '../../features/messages/screens/messages_screen.dart';

class CommonBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userType; // 'customer' or 'craftsman'

  const CommonBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return AirbnbBottomNavigation(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
        _handleNavigation(context, index);
      },
      items: _getAirbnbNavigationItems(),
    );
  }

  List<AirbnbNavItem> _getAirbnbNavigationItems() {
    if (userType == 'customer') {
      return const [
        AirbnbNavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Panel',
        ),
        AirbnbNavItem(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: 'Ara',
        ),
        AirbnbNavItem(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          label: 'Mesajlar',
        ),
        AirbnbNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil',
        ),
      ];
    } else {
      // craftsman
      return const [
        AirbnbNavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Panel',
        ),
        AirbnbNavItem(
          icon: Icons.business_outlined,
          activeIcon: Icons.business,
          label: 'İşletme',
        ),
        AirbnbNavItem(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          label: 'Mesajlar',
        ),
        AirbnbNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil',
        ),
      ];
    }
  }

  void _handleNavigation(BuildContext context, int index) {
    if (userType == 'customer') {
      switch (index) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(context, '/customer-dashboard', (route) => false);
          break;
        case 1:
          Navigator.pushNamed(context, '/search');
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MessagesScreen(userType: 'customer'),
            ),
          );
          break;
        case 3:
          Navigator.pushNamed(context, '/profile');
          break;
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(context, '/craftsman-dashboard', (route) => false);
          break;
        case 1:
          Navigator.pushNamed(context, '/business-profile');
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MessagesScreen(userType: 'craftsman'),
            ),
          );
          break;
        case 3:
          Navigator.pushNamed(context, '/profile');
          break;
      }
    }
  }
}