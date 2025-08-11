import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/providers/auth_provider.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/services/analytics_service.dart';
import 'core/utils/accessibility_utils.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/customer_dashboard.dart';
import 'features/dashboard/screens/craftsman_dashboard.dart';
import 'features/search/screens/search_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/quote/screens/quote_form_screen.dart';
import 'features/craftsman/screens/craftsman_detail_screen.dart';
import 'features/business/screens/business_profile_screen.dart';
import 'features/messages/screens/messages_screen.dart';
import 'features/messages/screens/chat_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/quotes/screens/craftsman_quotes_screen.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/accessibility/screens/accessibility_test_screen.dart';
import 'features/legal/screens/legal_screen.dart';
import 'features/jobs/screens/job_management_screen.dart';
import 'features/notifications/screens/enhanced_notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Initialize analytics service
    await AnalyticsService.getInstance().initialize();
    
    // Initialize accessibility features
    AccessibilityUtils.initialize();
    
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing SharedPreferences: $e');
    // Fallback without SharedPreferences for web debugging
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(userType: 'customer'),
        '/login-craftsman': (context) => const LoginScreen(userType: 'craftsman'),
        '/customer-dashboard': (context) => const CustomerDashboard(),
        '/craftsman-dashboard': (context) => const CraftsmanDashboard(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/quote-form': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuoteFormScreen(craftsman: args['craftsman']);
        },
        '/craftsman-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CraftsmanDetailScreen(craftsman: args['craftsman']);
        },
        '/business-profile': (context) => const BusinessProfileScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChatScreen(conversation: args['conversation']);
        },
        '/notifications': (context) => const NotificationsScreen(),
        '/craftsman-quotes': (context) => const CraftsmanQuotesScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/accessibility-test': (context) => const AccessibilityTestScreen(),
        '/legal': (context) => const LegalScreen(),
        '/job-management': (context) => const JobManagementScreen(),
        '/enhanced-notifications': (context) => const EnhancedNotificationsScreen(),
      },
      // Track navigation events
      navigatorObservers: [
        AnalyticsNavigatorObserver(),
      ],
    );
  }
}
