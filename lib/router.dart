import 'package:cuhp_pg_or_room_finder/features/verify_email_or_phone/presentation/screens/verify_email_or_phone_screen.dart';
import 'package:go_router/go_router.dart';

import './shell_scaffold.dart';
import './features/splash/presentation/screens/splash_screen.dart';
import './features/not_found/presentation/screens/not_found_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import './features/home/presentation/screens/home_screen.dart';
import './features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => NotFoundScreen(),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignupScreen(),
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
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => ProfileScreen(),
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
    ],
  );

  static int _calculateCurrentIndex(GoRouterState state) {
    final String location = state.matchedLocation;

    switch (location) {
      case '/':
        return 0;
      case '/profile':
        return 1;
      case '/settings':
        return 2;
      default:
        return 0;
    }
  }
}
