import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/auth/providers/auth_provider.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/tutorial_provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/ios_theme.dart';
import 'core/config/app_config.dart';
import 'core/services/analytics_service.dart';
import 'core/utils/accessibility_utils.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/support/screens/support_screen.dart';

import 'features/reviews/screens/reviews_screen.dart';
import 'features/reviews/screens/create_review_screen.dart';
import 'features/calendar/screens/calendar_screen.dart';
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
import 'features/marketplace/screens/marketplace_feed_screen.dart';
import 'features/marketplace/screens/marketplace_listing_detail_screen.dart';
import 'features/marketplace/screens/marketplace_offer_compose_screen.dart';
import 'features/marketplace/screens/marketplace_create_listing_screen.dart';
import 'features/marketplace/screens/my_listings_screen.dart';
import 'features/marketplace/screens/listing_detail_screen.dart';
import 'features/marketplace/screens/listing_offers_screen.dart';

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp(
      title: AppConfig.appName,
      theme: iOSTheme.lightTheme,
      darkTheme: iOSTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(userType: 'customer'),
        '/login-craftsman': (context) => const LoginScreen(userType: 'craftsman'),
        '/register': (context) {
          final userType = ModalRoute.of(context)!.settings.arguments as String? ?? 'customer';
          return RegisterScreen(userType: userType);
        },
        '/register-craftsman': (context) => const RegisterScreen(userType: 'craftsman'),
        '/support': (context) {
          final userType = ModalRoute.of(context)!.settings.arguments as String? ?? 'customer';
          return SupportScreen(userType: userType);
        },

        '/reviews': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ReviewsScreen(
            craftsmanId: args['craftsmanId'],
            craftsmanName: args['craftsmanName'],
          );
        },
        '/create-review': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CreateReviewScreen(
            craftsmanId: args['craftsmanId'],
            quoteId: args['quoteId'],
            craftsmanName: args['craftsmanName'],
            serviceName: args['serviceName'],
          );
        },
        '/calendar': (context) {
          final userType = ModalRoute.of(context)!.settings.arguments as String? ?? 'customer';
          return CalendarScreen(userType: userType);
        },
        '/customer-dashboard': (context) => const CustomerDashboard(),
        '/craftsman-dashboard': (context) => const CraftsmanDashboard(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/quote-form': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuoteFormScreen(craftsman: args['craftsman']);
        },
        '/request-quote': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuoteFormScreen(craftsman: {
            'id': args['craftsmanId'],
            'name': args['craftsmanName'],
            'business_name': args['craftsmanName'],
          });
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
        '/settings': (context) => const ProfileScreen(), // Settings redirects to profile for now
        
        // Marketplace routes
        '/marketplace': (context) => const MarketplaceFeedScreen(),
        '/marketplace/new': (context) => const MarketplaceCreateListingScreen(),
        '/marketplace/edit': (context) {
          final listing = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return MarketplaceCreateListingScreen(listingToEdit: listing);
        },
        '/marketplace/mine': (context) => const MyListingsScreen(),
        '/listing-detail': (context) {
          final listing = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ListingDetailScreen(listing: listing);
        },
        '/listing-offers': (context) {
          final listing = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ListingOffersScreen(listing: listing);
        },
      },
      onGenerateRoute: (settings) {
        // Handle marketplace dynamic routes
        if (settings.name != null) {
          final uri = Uri.parse(settings.name!);
          
          // Marketplace listing detail: /marketplace/listing/{id}
          if (uri.pathSegments.length == 3 && 
              uri.pathSegments[0] == 'marketplace' && 
              uri.pathSegments[1] == 'listing') {
            final listingId = uri.pathSegments[2];
            return MaterialPageRoute(
              builder: (context) => MarketplaceListingDetailScreen(listingId: listingId),
              settings: settings,
            );
          }
          
          // Marketplace offer compose: /marketplace/listing/{id}/offer
          if (uri.pathSegments.length == 4 && 
              uri.pathSegments[0] == 'marketplace' && 
              uri.pathSegments[1] == 'listing' &&
              uri.pathSegments[3] == 'offer') {
            final listingId = uri.pathSegments[2];
            return MaterialPageRoute(
              builder: (context) => MarketplaceOfferComposeScreen(listingId: listingId),
              settings: settings,
            );
          }
        }
        
        return null;
      },
      // Track navigation events
      navigatorObservers: [
        AnalyticsNavigatorObserver(),
      ],
    );
  }
}
