import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/utils/sf_handler.dart';

import '../../domain/usecases/current_user.dart';
import '../../domain/usecases/user_login.dart';
import '../../domain/usecases/user_signup.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final SFHandler _sfHandler;

  AuthBloc({
    required UserSignup userSignup,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required SFHandler sfHandler,
  })  : _userSignup = userSignup,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _sfHandler = sfHandler,
        super(AuthInitial()) {
    on<AuthEvent>((event, emit) => emit(AuthLoading()));

    on<AuthSignup>((event, emit) async {
      final res = await _userSignup(
        UserSignupParams(
          name: event.name,
          email: event.email,
          password: event.password,
        ),
      );

      res.fold(
        (failure) => emit(AuthFailure(
          status: failure.status,
          message: failure.message,
        )),
        (user) => _emitAuthSuccess(user, emit),
      );
    });

    on<AuthLogin>((event, emit) async {
      final res = await _userLogin(
        UserLoginParams(
          email: event.email,
          password: event.password,
        ),
      );

      res.fold(
        (failure) => emit(AuthFailure(
          status: failure.status,
          message: failure.message,
        )),
        (user) => _emitAuthSuccess(user, emit),
      );
    });

    on<AuthIsUserLoggedin>((event, emit) async {
      final res = await _currentUser(NoParams());

      res.fold(
        (failure) => emit(AuthFailure(
          status: failure.status,
          message: failure.message,
        )),
        (user) => _emitAuthSuccess(user, emit),
      );
    });
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _sfHandler.setToken(user.jwtToken);
    _sfHandler.setExpiresIn(user.expiresIn);
    _sfHandler.setId(user.id);

    _appUserCubit.setUser(user);
    emit(AuthSuccess(user: user));
  }
}
