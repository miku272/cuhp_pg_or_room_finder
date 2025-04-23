import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/utils/sf_handler.dart';

import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/get_properties_active_and_inactive_count.dart';
import '../../domain/usecases/get_total_properties_count.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUser _getCurrentUser;
  final GetTotalPropertiesCount _getTotalPropertiesCount;
  final GetPropertiesActiveAndInactiveCount
      _getPropertiesActiveAndInactiveCount;
  final SFHandler _sfHandler;
  final AppUserCubit _appUserCubit;

  ProfileBloc({
    required GetCurrentUser getCurrentUser,
    required GetTotalPropertiesCount getTotalPropertiesCount,
    required GetPropertiesActiveAndInactiveCount
        getPropertiesActiveAndInactiveCount,
    required SFHandler sfHandler,
    required AppUserCubit appUserCubit,
  })  : _getCurrentUser = getCurrentUser,
        _getTotalPropertiesCount = getTotalPropertiesCount,
        _getPropertiesActiveAndInactiveCount =
            getPropertiesActiveAndInactiveCount,
        _sfHandler = sfHandler,
        _appUserCubit = appUserCubit,
        super(const ProfileInitial()) {
    // on<ProfileEvent>((event, emit) => emit(const ProfileLoading()));

    on<ProfileGetCurrentUser>((event, emit) async {
      emit(const ProfileLoading());

      final res =
          await _getCurrentUser(GetCurrentUserParams(token: event.token));

      res.fold(
        (failure) => emit(
          ProfileFailure(status: failure.status, message: failure.message),
        ),
        (user) {
          final token = _sfHandler.getToken()!;
          final expiresIn = _sfHandler.getExpiresIn()!;

          final updatedUser = user.copyWith(
            jwtToken: token,
            expiresIn: expiresIn,
          );

          _appUserCubit.setUser(updatedUser);
          emit(ProfileSuccess(user: updatedUser));
        },
      );
    });

    on<ProfileGetTotalPropertiesCount>((event, emit) async {
      emit(const PropertyMetadataLoading());

      final res = await _getTotalPropertiesCount(
        GetTotalPropertiesCountParams(token: event.token),
      );

      res.fold(
        (failure) => emit(PropertyMetadataFailure(
          status: failure.status,
          message: failure.message,
        )),
        (totalCount) {
          emit(
            TotalPropertyCountSuccess(
              totalCount: totalCount,
              user: state.user,
            ),
          );
        },
      );
    });

    on<ProfileGetPropertiesActiveAndInactiveCount>((event, emit) async {
      emit(const PropertyMetadataLoading());

      final res = await _getPropertiesActiveAndInactiveCount(
        GetPropertiesActiveAndInactiveCountParams(token: event.token),
      );

      res.fold(
        (failure) => emit(PropertyMetadataFailure(
          status: failure.status,
          message: failure.message,
        )),
        (counts) {
          emit(
            PropertiesActiveAndInactiveCountSuccess(
              activeCount: counts.activePropertyCount,
              inactiveCount: counts.inactivePropertyCount,
              user: state.user,
            ),
          );
        },
      );
    });
  }
}
