import 'package:go_router/go_router.dart';

import './shell_scaffold.dart';
import './features/splash/presentation/screens/splash_screen.dart';
import './features/not_found/presentation/screens/not_found_screen.dart';
import './features/my_listings/presentation/screens/my_listings_screen.dart';
import './features/properties_saved/presentation/widgets/no_properties_saved.dart';
import './features/property_listings/data/models/property_form_data.dart';
import './features/property_listings/presentation/screens/add_property_screen.dart';
import './features/auth/presentation/screens/login_screen.dart';
import './features/auth/presentation/screens/signup_screen.dart';
import './features/home/presentation/screens/home_screen.dart';
import './features/profile/presentation/screens/profile_screen.dart';
import './features/verify_email_or_phone/presentation/screens/verify_email_or_phone_screen.dart';
import './features/property_listings/presentation/screens/add_property_screen_step_2.dart';
import './features/property_listings/presentation/screens/add_property_screen_step_3.dart';
import './features/property_listings/presentation/screens/add_property_success_screen.dart';

import './features/property_listings/presentation/screens/google_maps_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    // initialLocation: '/maps',
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ShellScaffold(
            currentIndex: _calculateCurrentIndex(state),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const NoPropertySaved(),
          ),
          GoRoute(
            path: '/my-listings',
            builder: (context, state) => const MyListingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'verify/:verificationType',
                builder: (context, state) => VerifyEmailOrPhoneScreen(
                  verificationType: state.pathParameters['verificationType']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/maps',
        builder: (context, state) {
          final Map<String, num?>? extraData =
              state.extra as Map<String, num?>?;

          return GoogleMapsScreen(
            lat: extraData?['lat'],
            lng: extraData?['lng'],
          );
        },
      ),
      GoRoute(
        path: '/add-property',
        builder: (context, state) {
          final payLoad = state.extra as Map<String, dynamic>?;

          return AddPropertyScreen(
            isEditing: payLoad?['isEditing'] as bool? ?? false,
            property: payLoad?['propertyFormData'] as PropertyFormData?,
          );
        },
        routes: [
          GoRoute(
            path: 'step-2',
            builder: (context, state) {
              final payLoad = state.extra as Map<String, dynamic>;

              return AddPropertyScreenStep2(
                isEditing: payLoad['isEditing'] as bool,
                propertyFormData:
                    payLoad['propertyFormData'] as PropertyFormData,
              );
            },
          ),
          GoRoute(
            path: 'step-3',
            builder: (context, state) {
              final payLoad = state.extra as Map<String, dynamic>;

              return AddPropertyScreenStep3(
                isEditing: payLoad['isEditing'] as bool,
                propertyFormData:
                    payLoad['propertyFormData'] as PropertyFormData,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/property-success',
        builder: (context, state) {
          final payLoad = state.extra as Map<String, dynamic>;

          return AddPropertySuccessScreen(
            isEditing: payLoad['isEditing'] as bool,
          );
        },
      ),
    ],
  );

  static int _calculateCurrentIndex(GoRouterState state) {
    final String location = state.matchedLocation;

    switch (location) {
      case '/':
        return 0;
      case '/saved':
        return 1;
      case '/my-listings':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }
}
