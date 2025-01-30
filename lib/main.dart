import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './init_dependencies.dart';
import './router.dart';

import './core/styles/themes.dart';
import './core/common/cubits/app_theme/theme_state.dart';
import './core/common/cubits/app_theme/theme_cubit.dart';
import 'core/common/cubits/app_user/app_user_cubit.dart';

import './features/splash/presentation/bloc/splash_bloc.dart';
import './features/auth/presentation/bloc/auth_bloc.dart';
import './features/verify_email_or_phone/presentation/bloc/verify_email_or_phone_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider.value(
        value: serviceLocator<ThemeCubit>(),
      ),
      BlocProvider.value(
        value: serviceLocator<AppUserCubit>(),
      ),
      BlocProvider(
        create: (context) => serviceLocator<SplashBloc>(),
      ),
      BlocProvider(
        create: (context) => serviceLocator<AuthBloc>(),
      ),
      BlocProvider(
        create: (context) => serviceLocator<VerifyEmailOrPhoneBloc>(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        ThemeData themeData =
            state.isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

        return MaterialApp.router(
          title: 'CUHP PG or Room Finder',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
