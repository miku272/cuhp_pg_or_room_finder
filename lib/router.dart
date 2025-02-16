import 'package:go_router/go_router.dart';

import './shell_scaffold.dart';
import './features/splash/presentation/screens/splash_screen.dart';
import './features/not_found/presentation/screens/not_found_screen.dart';
import './features/add_property/presentation/screens/add_property_screen.dart';
import './features/auth/presentation/screens/login_screen.dart';
import './features/auth/presentation/screens/signup_screen.dart';
import './features/home/presentation/screens/home_screen.dart';
import './features/profile/presentation/screens/profile_screen.dart';
import './features/verify_email_or_phone/presentation/screens/verify_email_or_phone_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    // initialLocation: '/splash',
    initialLocation: '/',
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
      // GoRoute(
      //   path: 'verify-email',
      // ),
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
        path: '/add-property',
        builder: (context, state) => const AddPropertyScreen(),
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
