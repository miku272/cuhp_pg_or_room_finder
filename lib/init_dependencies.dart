import 'package:cuhp_pg_or_room_finder/core/utils/theme_preference.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './core/common/cubits/app_theme/theme_cubit.dart';
import 'core/utils/sf_handler.dart';
import './core/common/cubits/app_user/app_user_cubit.dart';

import './features/splash/data/datasources/splash_remote_data_source.dart';
import './features/splash/domain/repository/splash_repository.dart';
import './features/splash/data/repositories/splash_repository_impl.dart';
import './features/splash/domain/usecases/current_user.dart' as sp_current_user;
import './features/splash/presentation/bloc/splash_bloc.dart';

import './features/auth/data/datasources/auth_remote_data_source.dart';
import './features/auth/domain/repository/auth_repository.dart';
import './features/auth/data/repositories/auth_repository_impl.dart';
import './features/auth/domain/usecases/user_signup.dart';
import './features/auth/domain/usecases/user_login.dart';
import './features/auth/domain/usecases/current_user.dart';
import './features/auth/presentation/bloc/auth_bloc.dart';

import './features/verify_email_or_phone/data/datasourses/verify_email_or_phone_remote_data_source.dart';
import './features/verify_email_or_phone/domain/repositories/verify_email_or_phone_repository.dart';
import './features/verify_email_or_phone/data/repositories/verify_email_or_phone_repository_impl.dart';
import './features/verify_email_or_phone/domain/usecases/send_email_otp.dart';
// import './features/verify_email_or_phone/domain/usecases/send_phone_otp.dart';
import './features/verify_email_or_phone/domain/usecases/verify_email_otp.dart';
// import './features/verify_email_or_phone/domain/usecases/verify_phone_otp.dart';
import './features/verify_email_or_phone/presentation/bloc/verify_email_or_phone_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initTheme();
  _initTokenHandler();
  _initSplash();
  _initAuth();
  _initVerifyEmailOrPhone();

  final prefs = await SharedPreferences.getInstance();

  serviceLocator.registerLazySingleton(() => prefs);

  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initTheme() {
  serviceLocator.registerLazySingleton(
    () => ThemePreference(prefs: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => ThemeCubit(prefs: serviceLocator()),
  );
}

void _initTokenHandler() {
  serviceLocator.registerLazySingleton(
    () => SFHandler(prefs: serviceLocator()),
  );
}

void _initSplash() {
  serviceLocator.registerFactory<SplashRemoteDataSource>(
    () => SplashRemoteDataSourceImpl(),
  );

  serviceLocator.registerFactory<SplashRepository>(
    () => SplashRepositoryImpl(
      splashRemoteDataSource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<sp_current_user.CurrentUser>(
    () => sp_current_user.CurrentUser(
      splashRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<SplashBloc>(
    () => SplashBloc(
      currentUser: serviceLocator(),
      appUserCubit: serviceLocator(),
      sfHandler: serviceLocator(),
    ),
  );
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserSignup>(
    () => UserSignup(
      authRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserLogin>(
    () => UserLogin(
      authRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<CurrentUser>(
    () => CurrentUser(
      authRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      userSignup: serviceLocator(),
      userLogin: serviceLocator(),
      currentUser: serviceLocator(),
      appUserCubit: serviceLocator(),
      sfHandler: serviceLocator(),
    ),
  );
}

void _initVerifyEmailOrPhone() {
  serviceLocator.registerFactory<VerifyEmailOrPhoneRemoteDataSource>(
    () => VerifyEmailOrPhoneRemoteDataSourceImpl(),
  );

  serviceLocator.registerFactory<VerifyEmailOrPhoneRepository>(
    () => VerifyEmailOrPhoneRepositoryImpl(
      verifyEmailOrPhoneRemoteDataSource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<SendEmailOtp>(
    () => SendEmailOtp(
      verifyEmailOrPhoneRepository: serviceLocator(),
    ),
  );

  // serviceLocator.registerFactory<SendPhoneOtp>(
  //   () => SendPhoneOtp(
  //     verifyEmailOrPhoneRepository: serviceLocator(),
  //   ),
  // );

  serviceLocator.registerFactory<VerifyEmailOtp>(
    () => VerifyEmailOtp(
      verifyEmailOrPhoneRepository: serviceLocator(),
    ),
  );

  // serviceLocator.registerFactory<VerifyPhoneOtp>(
  //   () => VerifyPhoneOtp(
  //     verifyEmailOrPhoneRepository: serviceLocator(),
  //   ),
  // );

  serviceLocator.registerLazySingleton<VerifyEmailOrPhoneBloc>(
    () => VerifyEmailOrPhoneBloc(
      sendEmailOtp: serviceLocator(),
      // sendPhoneOtp: serviceLocator(),
      verifyEmailOtp: serviceLocator(),
      // verifyPhoneOtp: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}
