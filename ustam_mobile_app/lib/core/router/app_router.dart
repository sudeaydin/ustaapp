import '../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/messages/screens/messages_screen.dart';
import '../../features/jobs/screens/jobs_screen.dart';
// Payment screen temporarily disabled
// import '../../features/payment/screens/payment_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/marketplace/screens/marketplace_feed_screen.dart';
import '../../features/marketplace/screens/marketplace_listing_detail_screen.dart';
import '../../features/marketplace/screens/marketplace_offer_compose_screen.dart';
import '../../features/marketplace/screens/marketplace_create_listing_screen.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Simplified redirect logic - just go to login if not authenticated
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(userType: 'customer'),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes (with bottom navigation)
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/marketplace',
            builder: (context, state) => const MarketplaceFeedScreen(),
          ),
          GoRoute(
            path: '/jobs',
            builder: (context, state) => const JobsScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessagesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Full Screen Routes (no bottom navigation)
      GoRoute(
        path: '/marketplace/listing/:listingId',
        builder: (context, state) {
          final listingId = state.pathParameters['listingId']!;
          return MarketplaceListingDetailScreen(listingId: listingId);
        },
      ),
      GoRoute(
        path: '/marketplace/listing/:listingId/offer',
        builder: (context, state) {
          final listingId = state.pathParameters['listingId']!;
          return MarketplaceOfferComposeScreen(listingId: listingId);
        },
      ),
      GoRoute(
        path: '/marketplace/new',
        builder: (context, state) => const MarketplaceCreateListingScreen(),
      ),
      // Payment route temporarily disabled - online payment system under development
      // GoRoute(
      //   path: '/payment/:jobId',
      //   builder: (context, state) {
      //     final jobId = state.pathParameters['jobId']!;
      //     return PaymentScreen(jobId: jobId);
      //   },
      // ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Hata')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Main navigation wrapper with bottom navigation bar
class MainNavigationScreen extends ConsumerWidget {
  final Widget child;
  
  const MainNavigationScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Ara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'İşlerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
  
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/jobs':
        return 2;
      case '/messages':
        return 3;
      case '/profile':
        return 4;
      default:
        return 0;
    }
  }
  
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/jobs');
        break;
      case 3:
        context.go('/messages');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}