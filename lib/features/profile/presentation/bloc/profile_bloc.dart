import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/utils/sf_handler.dart';

import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/get_properties_active_and_inactive_count.dart';
import '../../domain/usecases/get_total_properties_count.dart';
import '../../domain/usecases/get_user_review_metadata.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUser _getCurrentUser;
  final GetTotalPropertiesCount _getTotalPropertiesCount;
  final GetPropertiesActiveAndInactiveCount
      _getPropertiesActiveAndInactiveCount;
  final GetUserReviewMetadata _getCurrentUserReviewMetadata;
  final SFHandler _sfHandler;
  final AppUserCubit _appUserCubit;

  ProfileBloc({
    required GetCurrentUser getCurrentUser,
    required GetTotalPropertiesCount getTotalPropertiesCount,
    required GetPropertiesActiveAndInactiveCount
        getPropertiesActiveAndInactiveCount,
    required GetUserReviewMetadata getCurrentUserReviewMetadata,
    required SFHandler sfHandler,
    required AppUserCubit appUserCubit,
  })  : _getCurrentUser = getCurrentUser,
        _getTotalPropertiesCount = getTotalPropertiesCount,
        _getPropertiesActiveAndInactiveCount =
            getPropertiesActiveAndInactiveCount,
        _getCurrentUserReviewMetadata = getCurrentUserReviewMetadata,
        _sfHandler = sfHandler,
        _appUserCubit = appUserCubit,
        super(const ProfileInitial()) {
    // on<ProfileEvent>((event, emit) => emit(const ProfileLoading()));

    on<ProfileResetEvent>((event, emit) {
      emit(const ProfileInitial());
    });

    on<ProfileGetCurrentUser>((event, emit) async {
      emit(ProfileLoading(
        activeCount: state.activeCount,
        inactiveCount: state.inactiveCount,
        user: state.user,
        totalCount: state.totalCount,
        overallAverageRating: state.overallAverageRating,
        totalReviews: state.totalReviews,
      ));

      final res =
          await _getCurrentUser(GetCurrentUserParams(token: event.token));

      res.fold(
        (failure) => emit(
          ProfileFailure(
            status: failure.status,
            message: failure.message,
            activeCount: state.activeCount,
            inactiveCount: state.inactiveCount,
            user: state.user,
            totalCount: state.totalCount,
            overallAverageRating: state.overallAverageRating,
            totalReviews: state.totalReviews,
          ),
        ),
        (user) {
          final token = _sfHandler.getToken()!;
          final expiresIn = _sfHandler.getExpiresIn()!;

          final updatedUser = user.copyWith(
            jwtToken: token,
            expiresIn: expiresIn,
          );

          _appUserCubit.setUser(updatedUser);
          emit(ProfileSuccess(
            user: updatedUser,
            activeCount: state.activeCount,
            inactiveCount: state.inactiveCount,
            totalCount: state.totalCount,
            overallAverageRating: state.overallAverageRating,
            totalReviews: state.totalReviews,
          ));
        },
      );
    });

    on<ProfileGetTotalPropertiesCount>((event, emit) async {
      emit(PropertyMetadataLoading(
        activeCount: state.activeCount,
        inactiveCount: state.inactiveCount,
        user: state.user,
        totalCount: state.totalCount,
        overallAverageRating: state.overallAverageRating,
        totalReviews: state.totalReviews,
      ));

      final res = await _getTotalPropertiesCount(
        GetTotalPropertiesCountParams(token: event.token),
      );

      res.fold(
        (failure) => emit(PropertyMetadataFailure(
          status: failure.status,
          message: failure.message,
          activeCount: state.activeCount,
          inactiveCount: state.inactiveCount,
          user: state.user,
          totalCount: state.totalCount,
          overallAverageRating: state.overallAverageRating,
          totalReviews: state.totalReviews,
        )),
        (totalCount) {
          emit(
            TotalPropertyCountSuccess(
              totalCount: totalCount,
              user: state.user,
              activeCount: state.activeCount,
              inactiveCount: state.inactiveCount,
              overallAverageRating: state.overallAverageRating,
              totalReviews: state.totalReviews,
            ),
          );
        },
      );
    });

    on<ProfileGetPropertiesActiveAndInactiveCount>((event, emit) async {
      emit(PropertyMetadataLoading(
        activeCount: state.activeCount,
        inactiveCount: state.inactiveCount,
        user: state.user,
        totalCount: state.totalCount,
        overallAverageRating: state.overallAverageRating,
        totalReviews: state.totalReviews,
      ));

      final res = await _getPropertiesActiveAndInactiveCount(
        GetPropertiesActiveAndInactiveCountParams(token: event.token),
      );

      res.fold(
        (failure) => emit(PropertyMetadataFailure(
          status: failure.status,
          message: failure.message,
          activeCount: state.activeCount,
          inactiveCount: state.inactiveCount,
          user: state.user,
          totalCount: state.totalCount,
          overallAverageRating: state.overallAverageRating,
          totalReviews: state.totalReviews,
        )),
        (counts) {
          emit(
            PropertiesActiveAndInactiveCountSuccess(
              activeCount: counts.activePropertyCount,
              inactiveCount: counts.inactivePropertyCount,
              user: state.user,
              totalCount: state.totalCount,
              overallAverageRating: state.overallAverageRating,
              totalReviews: state.totalReviews,
            ),
          );
        },
      );
    });

    on<ProfileGetUserReviewsMetadata>((event, emit) async {
      emit(UserReviewMetadataLoading(
        activeCount: state.activeCount,
        inactiveCount: state.inactiveCount,
        user: state.user,
        totalCount: state.totalCount,
        overallAverageRating: state.overallAverageRating,
        totalReviews: state.totalReviews,
      ));

      final res = await _getCurrentUserReviewMetadata(
        GetUserReviewMetadataParams(token: event.token),
      );

      res.fold(
        (failure) => emit(UserReviewMetadataFailure(
          status: failure.status,
          message: failure.message,
          activeCount: state.activeCount,
          inactiveCount: state.inactiveCount,
          user: state.user,
          totalCount: state.totalCount,
          overallAverageRating: state.overallAverageRating,
          totalReviews: state.totalReviews,
        )),
        (userReviewMetadataResponse) {
          emit(
            UserReviewMetadataSuccess(
              user: state.user,
              activeCount: state.activeCount,
              inactiveCount: state.inactiveCount,
              totalCount: state.totalCount,
              overallAverageRating:
                  userReviewMetadataResponse.overallAverageRating,
              totalReviews: userReviewMetadataResponse.totalReviews,
            ),
          );
        },
      );
    });
  }
}
