import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import './core/constants/constants.dart';
import './core/common/cubits/app_theme/theme_cubit.dart';
import './core/utils/theme_preference.dart';
import './core/utils/sf_handler.dart';
import './core/utils/supabase_manager.dart';
import './core/utils/jwt_expiration_handler.dart';
import './core/common/cubits/app_user/app_user_cubit.dart';
import './core/common/cubits/app_socket/app_socket_cubit.dart';
import './core/socket/socket_manager.dart';

import './features/splash/data/datasources/splash_remote_data_source.dart';
import './features/splash/domain/repository/splash_repository.dart';
import './features/splash/data/repositories/splash_repository_impl.dart';
import './features/splash/domain/usecases/current_user.dart' as sp_current_user;
import './features/splash/presentation/bloc/splash_bloc.dart';

import './features/home/data/datasources/home_remote_datasource.dart';
import './features/home/data/repositories/home_repository_impl.dart';
import './features/home/domain/repository/home_repository.dart';
import './features/home/domain/usecases/get_properties_by_pagination.dart';
import './features/home/domain/usecases/home_add_saved_item.dart';
import './features/home/domain/usecases/home_remove_saved_item.dart';
import './features/home/presentation/bloc/home_bloc.dart';

import './features/properties_saved/data/datasources/properties_saved_remote_datasource.dart';
import './features/properties_saved/data/repositories/properties_saved_repository_impl.dart';
import './features/properties_saved/domain/repository/properties_saved_repository.dart';
import './features/properties_saved/domain/usecases/add_saved_item.dart';
import './features/properties_saved/domain/usecases/remove_saved_item.dart';
import './features/properties_saved/domain/usecases/get_saved_items.dart';
import './features/properties_saved/presentation/bloc/properties_saved_bloc.dart';

import './features/auth/data/datasources/auth_remote_data_source.dart';
import './features/auth/domain/repository/auth_repository.dart';
import './features/auth/data/repositories/auth_repository_impl.dart';
import './features/auth/domain/usecases/user_signup.dart';
import './features/auth/domain/usecases/user_login.dart';
import './features/auth/domain/usecases/current_user.dart';
import './features/auth/presentation/bloc/auth_bloc.dart';

import './features/verify_email_or_phone/data/datasources/verify_email_or_phone_remote_data_source.dart';
import './features/verify_email_or_phone/domain/repositories/verify_email_or_phone_repository.dart';
import './features/verify_email_or_phone/data/repositories/verify_email_or_phone_repository_impl.dart';
import './features/verify_email_or_phone/domain/usecases/send_email_otp.dart';

// import './features/verify_email_or_phone/domain/usecases/send_phone_otp.dart';
import './features/verify_email_or_phone/domain/usecases/verify_email_otp.dart';

// import './features/verify_email_or_phone/domain/usecases/verify_phone_otp.dart';
import './features/verify_email_or_phone/presentation/bloc/verify_email_or_phone_bloc.dart';

import './features/profile/data/datasources/profile_remote_datasource.dart';
import './features/profile/data/repositories/profile_repository_impl.dart';
import './features/profile/domain/repository/profile_repository.dart';
import './features/profile/domain/usecases/get_current_user.dart'
    as profile_current_user;
import './features/profile/domain/usecases/get_properties_active_and_inactive_count.dart';
import './features/profile/domain/usecases/get_total_properties_count.dart';
import './features/profile/domain/usecases/get_user_review_metadata.dart';
import './features/profile/presentation/bloc/profile_bloc.dart';

import './features/property_listings/data/datasources/property_listing_remote_datasource.dart';
import './features/property_listings/data/repositories/property_listing_repository_impl.dart';
import './features/property_listings/domain/repository/property_listing_repository.dart';
import './features/property_listings/domain/usecases/add_property_listing.dart';
import './features/property_listings/domain/usecases/update_property_listing.dart';
import './features/property_listings/presentation/bloc/property_listings_bloc.dart';

import './features/my_listings/data/datasources/my_listings_remote_data_source.dart';
import './features/my_listings/data/repositories/my_listings_repository_impl.dart';
import './features/my_listings/domain/repository/my_listings_repository.dart';
import './features/my_listings/domain/usecases/get_properties_by_id.dart';
import './features/my_listings/domain/usecases/toggle_property_activation.dart';
import './features/my_listings/presentation/bloc/my_listings_bloc.dart';

import './features/property_details/data/datasources/property_details_remote_datasource.dart';
import './features/property_details/data/repositories/property_details_repository_impl.dart';
import './features/property_details/domain/repository/property_details_repository.dart';
import './features/property_details/domain/usecases/get_property_details.dart';
import './features/property_details/domain/usecases/add_property_review.dart';
import './features/property_details/domain/usecases/update_property_review.dart';
import './features/property_details/domain/usecases/delete_property_review.dart';
import './features/property_details/domain/usecases/get_current_user_review.dart';
import './features/property_details/domain/usecases/get_recent_property_reviews.dart';
import './features/property_details/domain/usecases/initialize_chat.dart'
    as property_initialize_chat;
import './features/property_details/presentation/bloc/property_details_bloc.dart';

import './features/chat/data/datasources/chat_socket_datasource.dart';
import './features/chat/data/repositories/chat_socket_repository_impl.dart';
import './features/chat/domain/repository/chat_socket_repository.dart';
import './features/chat/data/datasources/chat_remote_datasource.dart';
import './features/chat/data/repositories/chat_remote_repository_impl.dart';
import './features/chat/domain/repository/chat_remote_repository.dart';
import './features/chat/domain/usecase/get_chat_by_id.dart';
import './features/chat/domain/usecase/get_user_chats.dart';
import './features/chat/domain/usecase/initialize_chat.dart';
import './features/chat/domain/usecase/send_message.dart';
import './features/chat/presentation/bloc/chat_bloc.dart';
import './features/chat/data/datasources/messages_remote_datasource.dart';
import './features/chat/data/repositories/messages_remote_repository_impl.dart';
import './features/chat/domain/repository/messages_remote_repository.dart';
import './features/chat/domain/usecase/get_messages.dart';
import './features/chat/presentation/bloc/messages_bloc.dart';
import './features/chat/data/datasources/messages_socket_datasource.dart';
import './features/chat/data/repositories/messages_socket_repository_impl.dart';
import './features/chat/domain/repository/messages_socket_repository.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _loadEnv();

  final prefs = await SharedPreferences.getInstance();

  final dio = Dio()
    ..options = BaseOptions(
      baseUrl: Constants.backendUri,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

  serviceLocator.registerLazySingleton(() => prefs);
  serviceLocator.registerLazySingleton(() => dio);

  serviceLocator.registerLazySingleton(
    () => AppUserCubit(
      sfHandler: serviceLocator(),
      appSocketCubit: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => SocketManager(),
  );

  serviceLocator.registerLazySingleton(
    () => AppSocketCubit(
      socketManager: serviceLocator<SocketManager>(),
    ),
  );

  serviceLocator.registerLazySingleton<JwtExpirationHandler>(
    () => JwtExpirationHandler(
      sfHandler: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );

  await _initSupabase();
  _initTheme();
  _initTokenHandler();
  _initSplash();
  _initAuth();
  _initVerifyEmailOrPhone();
  _initHome();
  _initSavedProperties();
  _initProfile();
  _initPropertyListings();
  _initMyListings();
  _initPropertyDetails();
  _initChat();
}

Future<void> _loadEnv() async {
  await dotenv.load(fileName: '.env');
}

Future<void> _initSupabase() async {
  await SupabaseManager.initialize();
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
    () => SplashRemoteDataSourceImpl(dio: serviceLocator()),
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
    () => AuthRemoteDataSourceImpl(dio: serviceLocator()),
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

void _initHome() {
  serviceLocator.registerFactory<HomeRemoteDatasource>(
    () => HomeRemoteDatasourceImpl(dio: serviceLocator()),
  );

  serviceLocator.registerFactory<HomeRepository>(
    () => HomeRepositoryImpl(
      homeRemoteDatasource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetPropertiesByPagination>(
    () => GetPropertiesByPagination(
      homeRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<HomeAddSavedItem>(
    () => HomeAddSavedItem(
      homeRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<HomeRemoveSavedItem>(
    () => HomeRemoveSavedItem(
      homeRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<HomeBloc>(
    () => HomeBloc(
      getPropertiesByPagination: serviceLocator(),
      homeAddSavedItem: serviceLocator(),
      homeRemoveSavedItem: serviceLocator(),
    ),
  );
}

void _initSavedProperties() {
  serviceLocator.registerFactory<PropertiesSavedRemoteDatasource>(
    () => PropertiesSavedRemoteDatasourceImpl(
      dio: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<PropertiesSavedRepository>(
    () => PropertiesSavedRepositoryImpl(
      propertiesSavedRemoteDatasource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AddSavedItem>(
    () => AddSavedItem(
      propertiesSavedRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<RemoveSavedItem>(
    () => RemoveSavedItem(
      propertiesSavedRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetSavedItems>(
    () => GetSavedItems(
      propertiesSavedRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<PropertiesSavedBloc>(
    () => PropertiesSavedBloc(
      addSavedItem: serviceLocator(),
      removeSavedItem: serviceLocator(),
      getSavedItems: serviceLocator(),
    ),
  );
}

void _initVerifyEmailOrPhone() {
  serviceLocator.registerFactory<VerifyEmailOrPhoneRemoteDataSource>(
    () => VerifyEmailOrPhoneRemoteDataSourceImpl(dio: serviceLocator()),
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

void _initProfile() {
  serviceLocator.registerFactory<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(dio: serviceLocator()),
  );

  serviceLocator.registerFactory<ProfileRepository>(
    () => ProfileRepositoryImpl(
      profileRemoteDatasource: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<profile_current_user.GetCurrentUser>(
    () => profile_current_user.GetCurrentUser(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetTotalPropertiesCount>(
    () => GetTotalPropertiesCount(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetPropertiesActiveAndInactiveCount>(
    () => GetPropertiesActiveAndInactiveCount(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetUserReviewMetadata>(
    () => GetUserReviewMetadata(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<ProfileBloc>(
    () => ProfileBloc(
      getCurrentUser: serviceLocator(),
      getTotalPropertiesCount: serviceLocator(),
      getPropertiesActiveAndInactiveCount: serviceLocator(),
      getCurrentUserReviewMetadata: serviceLocator(),
      sfHandler: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}

void _initPropertyListings() {
  serviceLocator.registerFactory<PropertyListingRemoteDataSource>(
    () => PropertyListingRemoteDataSourceImpl(dio: serviceLocator()),
  );

  serviceLocator.registerFactory<PropertyListingRepository>(
    () => PropertyListingRepositoryImpl(
      propertyListingRemoteDataSource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AddPropertyListing>(
    () => AddPropertyListing(
      propertyListingRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UpdatePropertyListing>(
    () => UpdatePropertyListing(
      propertyListingRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<PropertyListingsBloc>(
    () => PropertyListingsBloc(
      addPropertyListing: serviceLocator(),
      updatePropertyListing: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}

void _initMyListings() {
  serviceLocator.registerFactory<MyListingsRemoteDataSource>(
    () => MyListingsRemoteDataSourceImpl(dio: serviceLocator()),
  );

  serviceLocator.registerFactory<MyListingsRepository>(
    () => MyListingsRepositoryImpl(
      myListingsRemoteDataSource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetPropertiesById>(
    () => GetPropertiesById(myListingsRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<TogglePropertyActivation>(
    () => TogglePropertyActivation(myListingsRepository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<MyListingsBloc>(
    () => MyListingsBloc(
      getPropertiesById: serviceLocator(),
      togglePropertyActivation: serviceLocator(),
    ),
  );
}

void _initPropertyDetails() {
  serviceLocator.registerFactory<PropertyDetailsRemoteDatasource>(
    () => PropertyDetailsRemoteDataSourceImpl(dio: serviceLocator()),
  );

  serviceLocator.registerFactory<PropertyDetailsRepository>(
    () => PropertyDetailsRepositoryImpl(
      propertyDetailsRemoteDatasource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetPropertyDetails>(
    () => GetPropertyDetails(
      propertyDetailsRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AddPropertyReview>(
    () => AddPropertyReview(
      propertyDetailsRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UpdatePropertyReview>(
    () => UpdatePropertyReview(
      propertyDetailsRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<DeletePropertyReview>(
    () => DeletePropertyReview(
      propertyDetailsRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetCurrentUserReview>(
    () => GetCurrentUserReview(
      propertyDetailsRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetRecentPropertyReviews>(
    () => GetRecentPropertyReviews(
      propertyDetailsRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<property_initialize_chat.InitializeChat>(
    () => property_initialize_chat.InitializeChat(
      propertyDetailsRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<PropertyDetailsBloc>(
    () => PropertyDetailsBloc(
      getPropertyDetails: serviceLocator(),
      addPropertyReview: serviceLocator(),
      updatePropertyReview: serviceLocator(),
      deletePropertyReview: serviceLocator(),
      getCurrentUserReview: serviceLocator(),
      getRecentPropertyReviews: serviceLocator(),
      initializeChat: serviceLocator<property_initialize_chat.InitializeChat>(),
    ),
  );
}

void _initChat() {
  serviceLocator.registerLazySingleton<ChatSocketDataSource>(
    () => ChatSocketDataSourceImpl(
      baseUrl: Constants.backendUri,
      socketManager: serviceLocator<SocketManager>(),
    ),
  );

  serviceLocator.registerLazySingleton<ChatSocketRepository>(
    () => ChatSocketRepositoryImpl(
      chatSocketDataSource: serviceLocator<ChatSocketDataSource>(),
    ),
  );

  serviceLocator.registerFactory<ChatRemoteDatasource>(
    () => ChatRemoteDatasourceImpl(dio: serviceLocator<Dio>()),
  );

  serviceLocator.registerFactory<ChatRemoteRepository>(
    () => ChatRemoteRepositoryImpl(
      chatRemoteDatasource: serviceLocator<ChatRemoteDatasource>(),
    ),
  );

  serviceLocator.registerFactory<GetChatById>(
    () => GetChatById(
      chatRemoteRepository: serviceLocator<ChatRemoteRepository>(),
    ),
  );

  serviceLocator.registerFactory<GetUserChats>(
    () => GetUserChats(
      chatRemoteRepository: serviceLocator<ChatRemoteRepository>(),
    ),
  );

  serviceLocator.registerFactory<InitializeChat>(
    () => InitializeChat(
      chatRemoteRepository: serviceLocator<ChatRemoteRepository>(),
    ),
  );

  serviceLocator.registerFactory<SendMessage>(
    () => SendMessage(
      chatRemoteRepository: serviceLocator<ChatRemoteRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => ChatBloc(
      appUserCubit: serviceLocator<AppUserCubit>(),
      socketManager: serviceLocator<SocketManager>(),
      appSocketCubit: serviceLocator<AppSocketCubit>(),
      getChatById: serviceLocator<GetChatById>(),
      getUserChats: serviceLocator<GetUserChats>(),
      initializeChat: serviceLocator<InitializeChat>(),
      sendMessage: serviceLocator<SendMessage>(),
    ),
  );

  serviceLocator.registerFactory<MessagesRemoteDatasource>(
    () => MessagesRemoteDatasourceImpl(dio: serviceLocator<Dio>()),
  );

  serviceLocator.registerFactory<MessagesRemoteRepository>(
    () => MessagesRemoteRepositoryImpl(
      messagesRemoteDatasource: serviceLocator<MessagesRemoteDatasource>(),
    ),
  );

  serviceLocator.registerFactory<GetMessages>(
    () => GetMessages(
      messagesRemoteRepository: serviceLocator<MessagesRemoteRepository>(),
    ),
  );

  serviceLocator.registerFactory<MessagesSocketDatasource>(
    () => MessagesSocketDatasourceImpl(
      baseUrl: Constants.backendUri,
      socketManager: serviceLocator<SocketManager>(),
    ),
  );

  serviceLocator.registerFactory<MessagesSocketRepository>(
    () => MessagesSocketRepositoryImpl(
      messagesSocketDatasource: serviceLocator<MessagesSocketDatasource>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => MessagesBloc(
      socketManager: serviceLocator<SocketManager>(),
      appSocketCubit: serviceLocator<AppSocketCubit>(),
      getMessages: serviceLocator<GetMessages>(),
      appUserCubit: serviceLocator<AppUserCubit>(),
    ),
  );
}
