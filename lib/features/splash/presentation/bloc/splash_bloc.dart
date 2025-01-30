import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';

import '../../../../core/utils/sf_handler.dart';
import '../../domain/usecases/current_user.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final SFHandler _sfHandler;

  SplashBloc({
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required SFHandler sfHandler,
  })  : _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _sfHandler = sfHandler,
        super(SplashInitial()) {
    on<SplashEvent>((event, emit) => emit(SplashLoading()));

    on<SplashGetCurrentUser>((event, emit) async {
      final res = await _currentUser(CurrentUserParams(
        id: event.id,
        token: event.token,
      ));

      res.fold(
        (failure) => emit(SplashFailure(
          status: failure.status,
          message: failure.message,
        )),
        (user) => _emitSplashSuccess(user, emit),
      );
    });
  }

  void _emitSplashSuccess(User? user, Emitter<SplashState> emit) {
    if (user == null) {
      emit(SplashFailure(status: 404, message: 'User not found'));
      return;
    }

    String token = _sfHandler.getToken()!;
    String expiresIn = _sfHandler.getExpiresIn()!;

    User updatedUser = user.copyWith(
      jwtToken: token,
      expiresIn: expiresIn,
    );

    _appUserCubit.setUser(updatedUser);
    emit(SplashSuccess(user: updatedUser));
  }
}
