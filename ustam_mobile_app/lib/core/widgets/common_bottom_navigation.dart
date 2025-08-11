import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.getGradient(
          AppColors.primaryGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [AppColors.getElevatedShadow()],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          onTap(index);
          _handleNavigation(context, index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.textWhite,
        unselectedItemColor: AppColors.textWhite.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        items: _getNavigationItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems() {
    if (userType == 'customer') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          activeIcon: Icon(Icons.home_rounded, size: 28),
          label: 'Ana Sayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          activeIcon: Icon(Icons.search_rounded, size: 28),
          label: 'Arama',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_rounded),
          activeIcon: Icon(Icons.chat_bubble_rounded, size: 28),
          label: 'Mesajlar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          activeIcon: Icon(Icons.person_rounded, size: 28),
          label: 'Profilim',
        ),
      ];
    } else {
      // craftsman
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          activeIcon: Icon(Icons.dashboard_rounded, size: 28),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_rounded),
          activeIcon: Icon(Icons.business_rounded, size: 28),
          label: 'İşletme',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_rounded),
          activeIcon: Icon(Icons.chat_bubble_rounded, size: 28),
          label: 'Mesajlar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_rounded),
          activeIcon: Icon(Icons.assignment_rounded, size: 28),
          label: 'Teklifler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          activeIcon: Icon(Icons.person_rounded, size: 28),
          label: 'Profilim',
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
      // craftsman
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
          Navigator.pushNamed(context, '/craftsman-quotes');
          break;
        case 4:
          Navigator.pushNamed(context, '/profile');
          break;
      }
    }
  }
}