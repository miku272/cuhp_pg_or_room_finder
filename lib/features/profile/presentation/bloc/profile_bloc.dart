import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/utils/sf_handler.dart';

import '../../domain/usecases/get_current_user.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUser _getCurrentUser;
  final SFHandler _sfHandler;
  final AppUserCubit _appUserCubit;

  ProfileBloc({
    required GetCurrentUser getCurrentUser,
    required SFHandler sfHandler,
    required AppUserCubit appUserCubit,
  })  : _getCurrentUser = getCurrentUser,
        _sfHandler = sfHandler,
        _appUserCubit = appUserCubit,
        super(const ProfileInitial()) {
    on<ProfileEvent>((event, emit) => emit(const ProfileLoading()));

    on<ProfileGetCurrentUser>((event, emit) async {
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
  }
}
