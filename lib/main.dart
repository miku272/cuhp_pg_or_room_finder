import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './init_dependencies.dart';
import './router.dart';

import './core/styles/themes.dart';
import './core/common/cubits/app_theme/theme_state.dart';
import './core/common/cubits/app_theme/theme_cubit.dart';
import './core/common/cubits/app_user/app_user_cubit.dart';
import './core/common/cubits/app_socket/app_socket_cubit.dart';

import './features/splash/presentation/bloc/splash_bloc.dart';
import './features/auth/presentation/bloc/auth_bloc.dart';
import './features/verify_email_or_phone/presentation/bloc/verify_email_or_phone_bloc.dart';
import './features/home/presentation/bloc/home_bloc.dart';
import './features/properties_saved/presentation/bloc/properties_saved_bloc.dart';
import './features/profile/presentation/bloc/profile_bloc.dart';
import './features/property_listings/presentation/bloc/property_listings_bloc.dart';
import './features/my_listings/presentation/bloc/my_listings_bloc.dart';
import './features/property_details/presentation/bloc/property_details_bloc.dart';
import './features/chat/presentation/bloc/chat_bloc.dart';
import './features/chat/presentation/bloc/messages_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: serviceLocator<ThemeCubit>(),
        ),
        BlocProvider.value(
          value: serviceLocator<AppUserCubit>(),
        ),
        BlocProvider.value(
          value: serviceLocator<AppSocketCubit>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<SplashBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<HomeBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<PropertiesSavedBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<VerifyEmailOrPhoneBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<ProfileBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<PropertyListingsBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<MyListingsBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<PropertyDetailsBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<ChatBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<MessagesBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppUserCubit, AppUserState>(
          listener: (context, state) {
            if (state is AppUserInitial) {
              context.read<HomeBloc>().add(HomeResetEvent());
              context.read<PropertiesSavedBloc>().add(
                    PropertiesSavedResetEvent(),
                  );
              context.read<AuthBloc>().add(AuthResetEvent());
              context.read<VerifyEmailOrPhoneBloc>().add(
                    VerifyEmailOrPhoneResetEvent(),
                  );
              context.read<ProfileBloc>().add(
                    ProfileResetEvent(),
                  );
              context.read<PropertyListingsBloc>().add(
                    PropertyListingsResetEvent(),
                  );
              context.read<MyListingsBloc>().add(
                    MyListingsResetEvent(),
                  );
              context.read<PropertyDetailsBloc>().add(
                    PropertyDetailsResetEvent(),
                  );
              context.read<ChatBloc>().add(
                    ChatResetEvent(),
                  );
              context.read<MessagesBloc>().add(
                    MessagesResetEvent(),
                  );
            }
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
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
      ),
    );
  }
}
